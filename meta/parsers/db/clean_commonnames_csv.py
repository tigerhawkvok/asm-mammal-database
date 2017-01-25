import time, os, glob, sys, qinput, string, yn

defaultFile = "../../ssar_predatabase.csv"
outputFile = "../../ssar_predatabase_clean.csv"
exitScriptPrompt = "Press Control-c to exit."

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
    return [year,authority]

def cleanSpecies(data):
    #throw out numbers, parens
    data = data.replace("(","")
    data = data.replace(")","")
    data_split = data.split(",")
    year = data_split.pop()
    authority = ",".join(data_split)
    return [year,authority]

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
            json_year = "{"
            for j,column in enumerate(row):
                if j is genus_auth_col:
                    cleaned = cleanGenus(column)
                    json_year += cleaned[0]
                    row[j] = cleaned[1]
                if j is species_auth_col:
                    cleaned = cleanSpecies(column)
                    json_year += ":" + cleaned[0]
                    row[j] = cleaned[1]
                if j is auth_year_col:
                    json_year += "}"
                    row[j] = json_year
        # Append the cleaned row back on
        cleanRows.writerow(row)
        if i%50 is 0 and i > 0:
            print("Cleaned",i,"rows...")
    print("Finished cleaning",i,"rows.")
    return newPath


path = None
while path is None:
    try:
        path = qinput.input("Please input the path to the CSV file to be used (default:"+defaultFile+")")
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
    except KeyboardInterrupt:
        doExit()

cleanCSV(path)
