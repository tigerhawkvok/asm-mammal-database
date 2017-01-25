###
# Generate a series of SQL update statements for an existing database
###

## Helper functions

import sys, os, glob, string

def doExit():
    import os,sys
    print("\n")
    os._exit(0)
    sys.exit(0)

def cleanKVPairs(col,val):
    # Specific hacks for the current use case
    if col == "alignment":
        if val == "negative": return -1
        elif val == "positive": return 1
        else: return 0
    if col == "strength":
        if val == "strong": return 1
        else: return 0
    # Format the value for SQL
    if val.lower() == "true" or val.lower() == "false":
        # Keep bools as bools
        return val
    try:
        # Is it a number?
        test = int(val)
        return val
    except ValueError:
        # Give back the original if no matches
        # But enclosed as an SQL string
        val = val.replace("'","&#39;")
        return "'"+val+"'"
        

def generateUpdateSqlQueries(rowList,refCol,tableName,makeLower=True):
    # Generate update SQL queries
    i=0
    j=0
    query = ""
    queryList = list()
    first=True
    try:
        for row in rowList:
            # Each row should be a dict of the form "column":"value"
            query="UPDATE `"+tableName+"` SET "
            s=""
            set_statement = ""
            try:
                for col,val in row.items():
                    if first is True:
                        #alter_query = "IF COL_LENGTH(`"+tableName+"`,`"+col+"`) IS NULL"
                        #alter_query += "\n\tBEGIN"
                        alter_query = "ALTER TABLE `"+tableName+"` ADD `"+col+"` VARCHAR(MAX)" # Just in case!
                        # alter_query += "\n\tEND;"
                        queryList.append(alter_query)
                    if makeLower: val = val.lower()
                    val = cleanKVPairs(col,val)
                    if col != refCol:
                        s+="\n\t`"+col+"`="+str(val)+","
                    else:
                        where = " WHERE `"+col+"`="+str(val)
                # Trim the last comma
                s = s[:-1]
                set_statement = s
                s+=where
            except AttributeError:
                print("ERROR: Row is not a dictionary.")
                print("Each row should be a dictionary of the form {column:value}.")
                return False
            query += s
            query+=";"
            if query not in queryList and len(set_statement) > 0:
                # Avoid duplicate entries and only use entries with alterations
                queryList.append(query)
                j+=1
            i+=1
            first = False
        print("Processed",i,"rows, generated ",j,"entries")
        return queryList
    except:
        # Error
        print("Unexpected error encountered generating queries")
        print(sys.exc_info()[1])
        return False


def updateTableQueries(rowList,refCol,tableName):
    # generate queries for this directory
    import time
    time.clock()
    # Check the format of rowList
    print("Table",tableName)
    preamble="/* Automatically generated SQL entries from "+time.strftime('%d %B %Y at %H%M%S %Z')+"  */\n"
    queries = generateUpdateSqlQueries(rowList,refCol,tableName)
    if queries is not False:
        queries_string = "\n\n".join(queries)
        filename = "sql_update_queries_"+tableName+".sql"
        f=open(filename,'w')
        f.write(preamble)
        f.write(queries_string)
        f.close()
        print('Processed queries in ',round(time.clock(),2),'seconds')
    else:
        print("Unable to generate queries.")

## Primary Script at runtime
        
# Take in input CSV file and write out an SQL file to update a database.
path = None
while path is None:
    try:
        path = input("Enter the path to the CSV file to be used: ")
        # Check for file existence and filetype
        exit_script_prompt = "If you want to exit, press Control-c."
        if not os.path.isfile(path):
            path = None
            print("Invalid file.",exit_script_prompt)
        else:
            tmp = path.split(".")
            if tmp.pop().lower() != "csv":
                path = None
                print("You did not point to a valid CSV file.",exit_script_prompt)
    except KeyboardInterrupt:
        # Exit the script
        doExit()
default_table = 'master_emotion_list'
table = input("Which table should be written to? (default: `"+default_table+"`): ")
if not table:
    table = default_table
import yn
boolstate = yn.yn("Is the first row the database columns?")
if not boolstate:
    # Find out how many rows should be skipped
    skip = None
    while skip is None:
        skip_string = input("How many rows should be skipped? ")
        if skip_string is "":
            skip = 0
        else:
            try:
                skip = int(skip_string)
            except ValueError:
                skip = None
                print("Invalid number of rows. Please try again.")
            except KeyboardInterrupt:
                # Exit the script
                doExit()
    # Are there eventually columns?
    row_of_columns = skip+1
    boolstate = yn.yn("Is the row "+str(row_of_columns)+" the database columns?")
    if boolstate:
        # We're ready now
        firstRow = True
    else:
        # Get the columns
        columns_string = None
        while columns_string is None or columns_string is "":
            try:
                if columns_string is "":
                    print("Please input at least one column.")
                columns_string = input("Please input the order of columns, seperated by commas: ")
            except KeyboardInterrupt:
                doExit()
        # We're going to act as if the first row has already been read in the code,
        # since it has no useful data.
        firstRow = False
        columns = columns_string.split(",")

else:
    firstRow = True
    skip = 0
# Read out the file
try:
    fileStream = open(path)
    contents = fileStream.read()
    fileStream.close()
except:
    print("Unexpected error encountered while reading",path)
    print(sys.exc_info[0])
    doExit()
# Split up CSV
import csv
#f = StringIO.StringIO(contents)
rows = csv.reader(contents.split("\n"),delimiter=",")
entryList = list()
n = 0
refCol = None
for row in rows:
    # Each array element corresponds to column
    # if it's the first row, use it as the column definitions
    i = 0
    if n >= skip:
        if firstRow is True:
            columns = row
            firstRow = False
        else:
            if refCol is None:
                refColNum = None
                ask = ""
                for k,column in enumerate(columns):
                    if column:
                       ask += str(k)+": "+column+"\n"
                ask+="\nWhich column is the reference column to match against? "
                while refColNum is None:
                    try:
                        refColNumStr = input(ask)
                        refColNum = int(refColNumStr)
                        refCol = columns[refColNum]
                        if columns[refColNum] == "":
                            print("That column isn't part of this dataset. Please try again.")
                    except ValueError:
                        refColNum = None
                        print("That wasn't a number. Please try again.")
                    except KeyboardInterrupt:
                        doExit()
            # use "columns" to create the dict
            try:
                thisRow = {}
                # Each row is a list object as per the CSV library.
                for entry in row:
                    column = columns[i]
                    if column != "":
                        thisRow[column] = entry
                    i+=1
                entryList.append(thisRow)
            except IndexError:
                # Not enough columns!
                print("The number of columns doesn't match the number of items per row.")
                print("(We have",len(columns),"columns and",len(entries),"items per row)")
                print(entries)
                doExit()
    n+=1
updateTableQueries(entryList,refCol,table)
