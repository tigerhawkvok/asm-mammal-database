## Helper functions

import time, os, glob, sys, qinput, string, yn, json

defaultFile = "../../sql_ref/ssar_predatabase.csv"
outputFile = "../../sql_ref/ssar_predatabase_clean.csv"
exitScriptPrompt = "Press Control-c to exit."
default_table = "north_american_species"

def doExit():
    import os,sys
    print("\n")
    os._exit(0)
    sys.exit(0)


def cleanGenus(data):
    # Split spaces, throw out first, throw out numbers, trim and throw
    # out comma if exists at end
    data_split = data.split(" ")
    genus = data_split.pop(0)
    data = " ".join(data_split)
    data_split = data.split(",")
    year = data_split.pop()
    authority = ",".join(data_split)
    auth_use = authority.strip()
    return [year.strip(),auth_use]

def cleanSpecies(data):
    #throw out numbers, parens
    data = data.replace("(","")
    data = data.replace(")","")
    data_split = data.split(",")
    year = data_split.pop()
    authority = ",".join(data_split)
    auth_use = authority.strip()
    return [year.strip(),auth_use]

def cleanCSV(path = defaultFile, newPath = outputFile):
    if not os.path.isfile(path):
        print("Invalid file.")
        return False
    # Read the file
    try:
        fileStream = open(path)
        contents = fileStream.read()
        fileStream.close()
    except:
        print("Unexpected error reading",path)
        print(sys.exc_info[0])
        doExit()
    import csv
    rows = csv.reader(contents.split("\n"),delimiter=",")
    newFile = open(newPath,"w", newline='')
    cleanRows = csv.writer(newFile,delimiter=",",quoting=csv.QUOTE_ALL)
    genus_auth_col = 0
    species_auth_col = 0
    auth_year_col = 0
    for i,row in enumerate(rows):
        if i is 0:
            for j,column in enumerate(row):
                if column == "genus_authority":
                    genus_auth_col = j
                if column == "species_authority":
                    species_auth_col = j
                if column == "authority_year":
                    auth_year_col = j
        else:
            # All other loops
            json_year = dict()
            genus_year = ""
            species_year = ""
            for j,column in enumerate(row):
                if j is genus_auth_col:
                    cleaned = cleanGenus(column)
                    genus_year = cleaned[0]
                    row[j] = cleaned[1]
                if j is species_auth_col:
                    cleaned = cleanSpecies(column)
                    species_year = cleaned[0]
                    row[j] = cleaned[1]
                if j is auth_year_col:
                    json_year[genus_year] = species_year
                    row[j] = json.dumps(json_year)
        # Append the cleaned row back on
        cleanRows.writerow(row)
        if i%50 is 0 and i > 0:
            print("Cleaned",i,"rows...")
    print("Finished cleaning",i,"rows.")
    return newPath
    
def cleanKVPairs(col,val):
    # Clean authorities
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
        

def generateInsertSqlQueries(rowList,tableName,makeLower=True):
    # Generate update SQL queries
    i=0
    j=0
    query = ""
    queryList = list()
    queryList.append("DROP TABLE IF EXISTS `"+tableName+"`;")
    first=True
    try:
        for row in rowList:
            # Each row should be a dict of the form "column":"value"
            query="INSERT INTO `"+tableName+"` "
            s=""
            set_statement = "SET "
            try:
                for col,val in row.items():
                    if makeLower: val = val.lower()
                    val = cleanKVPairs(col,val)
                    s+="\n\t`"+col+"`="+str(val)+","
                # Trim the last comma
                s = s[:-1]
                set_statement += s
            except AttributeError:
                print("ERROR: Row is not a dictionary.")
                print("Each row should be a dictionary of the form {column:value}.")
                return False
            query += set_statement
            query+=";"
            if query not in queryList and len(s) > 0:
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


def updateTableQueries(rowList,tableName,refFile = outputFile):
    # generate queries for this directory
    import time
    time.clock()
    # Check the format of rowList
    print("Table",tableName)
    preamble="/* Automatically generated SQL entries from "+time.strftime('%d %B %Y at %H%M%S %Z')+"  */\n"
    queries = generateInsertSqlQueries(rowList,tableName)
    if queries is not False:
        queries_string = "\n\n".join(queries)
        filename = refFile + "__sql_creation_"+tableName+".sql"
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
        path = qinput.input("Please input the path to the CSV file to be used (default:"+defaultFile+")")
        # Check for file existence and filetype
        exit_script_prompt = "If you want to exit, press Control-c."
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
        # Check the file
        if not os.path.isfile(path):
            print("Invalid file.",exitScriptPrompt)
            print("You provided",path)
            path = None
            continue
    except KeyboardInterrupt:
        # Exit the script
        doExit()

        
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

path = cleanCSV(path)
    
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
rows = csv.reader(contents.split("\n"),delimiter=",")
entryList = list()
n = 0
for row in rows:
    # Each array element corresponds to column
    # if it's the first row, use it as the column definitions
    i = 0
    if n >= skip:
        if firstRow is True:
            columns = row
            firstRow = False
        else:
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
updateTableQueries(entryList,table)
