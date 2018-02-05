###
# Generate a series of SQL update statements for an existing database
###

## Helper functions

import sys, os, glob, string, qinput

defaultFile = "../../asm_predatabase_clean.csv"
outputFileNoExtBase = "../../asm_update_sql"
default_table = "mammal_diversity_database"

dropDupRefCol = "IfTransfer_oldSciName"
dropDupDbCol = "canonical_sciname"

def doExit():
    import os,sys
    print("\n")
    os._exit(0)
    sys.exit(0)

def cleanKVPairs(col, val, asType = False):
    # Format the value for SQL
    try:
        val = val.strip()
    except:
        pass
    if val.lower() == "true" or val.lower() == "false":
        # Keep bools as bools
        if asType:
            val = val.lower() == "true"
        return val
    try:
        # Is it a number?
        test = int(val)
        if asType:
            val = int(val)
        return val
    except ValueError:
        try:
            test = float(val)
            if asType:
                val = float(val)
            return val
        except ValueError:
            # Give back the original if no matches
            # But enclosed as an SQL string
            if val == "" or val.lower() == "NA":
                return "NULL"
            val = val.replace("'","&#39;")
            return "'"+val+"'"


def generateUpdateSqlQueries(rowList, refCol, tableName, addCols=True, makeLower=False):
    # Generate update SQL queries
    i=0
    j=0
    query = ""
    queryList = list()
    first=True
    try:
        for row in rowList:
            # Each row should be a dict of the form "column":"value"
            query="INSERT INTO `"+tableName+"` "
            s=""
            set_statement = ""
            colList = list()
            valuesList = list()
            try:
                where = ""
                for col,val in row.items():
                    colList.append(str(col))
                    if first is True and addCols:
                        #alter_query = "IF (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA='"+tableName+"' AND COLUMN_NAME='"+col+"') IS NULL"
                        #alter_query += "\n\tTHEN\n\t\t"
                        try:
                            testData = cleanKVPairs(col, rowList[1][col], True)
                            print("Testing", testData)
                            if isinstance(testData, bool):
                                dataType = "TINYINT(1)"
                            elif isinstance(testData, int):
                                dataType = "INT"
                            elif isinstance(testData, float):
                                dataType = "FLOAT"
                            else:
                                dataType = "VARCHAR(1023)"
                        except:
                            print("Failed to check data type for", testData)
                            dataType = "VARCHAR(1023)"
                        alter_query = "-- This will fail if the column exists. No harm, no foul. \nALTER TABLE `"+tableName+"` ADD COLUMN `"+col+"` "+dataType+";" # Just in case!
                        #alter_query += "\n\tEND IF;"
                        queryList.append(alter_query)
                    if makeLower: val = val.lower()
                    val = cleanKVPairs(col,val)
                    if col != refCol:
                        if str(val) != "NULL":
                            s+="\n\t`"+col+"`="+str(val)+","
                    else:
                        where = ",\n\t`"+col+"`="+str(val)+" "
                        #where = " WHERE `"+col+"`="+str(val)
                    valuesList.append(str(val))
                # Trim the last comma
                s = s[:-1]
                set_statement = s
                s += where
                s = " ON DUPLICATE KEY UPDATE "
                # if not addCols:
                #     # If we skipped adding cols, let's not crap out if
                #     # a col is missing
                #     s += "IGNORE "
                s += set_statement
            except AttributeError:
                print("ERROR: Row is not a dictionary.")
                print("Each row should be a dictionary of the form {column:value}.")
                return False
            query += "(" + ",".join(colList) + ") VALUES "
            query += "(" + ",".join(valuesList) + ") "
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


def updateTableQueries(rowList, refCol, tableName, addAbsentCols):
    # generate queries for this directory
    import time
    time.clock()
    # Check the format of rowList
    print("Table",tableName)
    preamble="/* Automatically generated SQL entries from "+time.strftime('%d %B %Y at %H%M%S %Z')+"  */\n"
    queries = generateUpdateSqlQueries(rowList, refCol, tableName, addAbsentCols)
    if queries is not False:
        queries_string = "\n\n".join(queries)
        fileName = outputFileNoExtBase + "-tbl_" + tableName + ".sql"
        try:
            f=open(fileName, 'w')
        except PermissionError:
            print("")
            print("ERROR: We couldn't get write permissions to '"+os.getcwd()+"/"+fileName+"'")
            print("Please check that the directory is writeable and that the file hasn't been locked by another user or program (like Excel),")
            print("then try to run this again.")
        f.write(preamble)
        f.write(queries_string)
        i = 0
        if len(asmDrops) > 0:
            # Loop over the cols to drop
            for ref in asmDrops:
                cleanRef = ref.replace("'","&#39;")
                query = "\n\nDELETE FROM `"+tableName+"` WHERE `"+dropDupDbCol+"`='"+cleanRef+"' LIMIT 1;"
                f.write(query)
                i += 1
            f.write("\n\n")
            print("Using reference duplicates column '"+dropDupRefCol+"', dropped "+str(i)+" rows with matching `"+dropDupDbCol+"`")
        f.close()
        #finalSize = len(queries) - i
        #print("Expected final size: "+str(finalSize))
        print('Processed queries in ',round(time.clock(),2),'seconds')
        print("Wrote '"+os.getcwd()+"/"+fileName+"'")
    else:
        print("Unable to generate queries.")

## Primary Script at runtime
asmDrops = list()
# Take in input CSV file and write out an SQL file to update a database.
path = None
while path is None:
    try:
        path = qinput.input("Enter the path to the CSV file to be used: (default:"+defaultFile+")")
        # Check for file existence and filetype
        exitScriptPrompt = "If you want to exit, press Control-c."
        if path == "":
            path = defaultFile
            tmp = path.split(".")
            ext = tmp.pop().lower()
        if len(ext) is not 3:
            # no extension, try adding "csv" to it
            # Edge cases for alternate extension types don't matter,
            # they'll fail the next check, since eg test.xlsx.csv
            # won't exist
            path += ".csv"
        elif ext != "csv":
            print("You did not point to a valid CSV file.",exitScriptPrompt)
            print("You provided",path)
            path = None
            continue
        if not os.path.isfile(path):
            path = None
            print("Invalid file.",exitScriptPrompt)
    except KeyboardInterrupt:
        # Exit the script
        doExit()
# Tables ...
table = qinput.input("Which table should be written to? (default: `"+default_table+"`): ")
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
refColumn = None
startCol = None
endCol = None
for row in rows:
    # Each array element corresponds to column
    # if it's the first row, use it as the column definitions
    i = 0
    if n >= skip:
        if firstRow is True:
            columns = row
            try:
                if dropDupRefCol in columns:
                    dropIndex = columns.index(dropDupRefCol)
                else:
                    dropIndex = None
            except:
                dropIndex = None
            if dropDupRefCol != "" and dropDupRefCol is not None and dropIndex is None:
                print("Warning: didn't find '"+dropDupRefCol+"' in columns")
                print(columns)
            firstRow = False
        else:
            if refColumn is None:
                refColumnNum = None
                ask = ""
                for k,column in enumerate(columns):
                    if column:
                       ask += str(k)+": "+column+"\n"
                ask+="\nWhich column is the reference column to match against? "
                skipRefCol = [
                    "none",
                    "null",
                    "skip",
                    "",
                    "-1"
                ]
                while refColumnNum is None:
                    refColumnNumStr = input(ask)
                    if not refColumnNumStr.lower() in skipRefCol:
                        try:
                            refColumnNum = int(refColumnNumStr)
                            refColumn = columns[refColumnNum]
                            if columns[refColumnNum] == "":
                                print("That column isn't part of this dataset. Please try again.")
                        except ValueError:
                            refColumnNum = None
                            print("That wasn't a number. Please try again.")
                        except KeyboardInterrupt:
                            doExit()
                    else:
                        print("OK, we'll rely on unique column values instead")
                        refColumnNum = "SKIP_REF_COL"
                        refColumn = "SKIP_REF_COL"
                if yn.yn("Do you only want to use a subset of columns?"):
                    while startCol is None:
                        startCol = qinput.input("Starting column number: ")
                        try:
                            startCol = int(startCol)
                        except:
                            print("Invalid column '"+startCol+"'")
                            startCol = None
                    while endCol is None:
                        endCol = qinput.input("Ending column number: ")
                        try:
                            endCol = int(endCol)
                        except:
                            print("Invalid column '"+endCol+"'")
                            endCol = None
            # use "columns" to create the dict
            if dropIndex is not None:
                fetchedEntry = False
                di = 0
                for entry in row:
                    if di is dropIndex:
                        cleanEntry = entry.strip()
                        if cleanEntry != "" and cleanEntry.lower() != "na":
                            asmDrops.append(cleanEntry)
                        fetchedEntry = True
                        break
                    di += 1
                if fetchedEntry is False:
                    print("Couldn't get column '"+str(dropIndex)+"' from row")
            if "species" not in columns:
                needCreateSpecies = True
            else:
                needCreateSpecies = False
            try:
                thisRow = {}
                # Each row is a list object as per the CSV library.
                for entry in row:
                    if startCol is not None:
                        colNum = i
                        if colNum < startCol:
                            continue
                        if colNum > endCol:
                            continue
                    column = columns[i]
                    if column != "":
                        thisRow[column] = entry
                    i+=1
                if len(thisRow.keys()) is 0:
                    continue
                if needCreateSpecies:
                    try:
                        species = thisRow["canonical_sciname"].split(" ").pop()
                        thisRow["species"] = species
                    except:
                        print(thisRow)
                        raise
                entryList.append(thisRow)
            except IndexError:
                # Not enough columns!
                print("The number of columns doesn't match the number of items per row.")
                print("(We have",len(columns),"columns and",len(entryList[0]),"items per row)")
                print(entryList)
                doExit()
    n+=1
if refColumn is "SKIP_REF_COL":
    refColumn = None
addColumns = yn.yn("Do you want to add columns that don't already exist in the database?")
updateTableQueries(entryList, refColumn, table, addColumns)
