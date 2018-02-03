import time, os, glob, sys, qinput, string, yn, re

defaultFile = "../../MDD_taxonomy_v1_19Jan2018.csv"
outputFile = "../../asm_predatabase_clean.csv"
exitScriptPrompt = "Press Control-c to exit."


keepCase = [
    "notes",
    "citation",
    "IfNew_valid_SciName",
    "IfNew_described_SciName",
    "IfNew_evidenceCitation",
    "IfNew_evidenceAuthors",
    "IfNew_evidenceLink",
    "IfNew_nameCitation",
    "IfNew_nameAuthors",
    "IfNew_nameLink",
    "IfTransfer_evidenceCitation"
]


def doExit():
    import os,sys
    print("\n")
    os._exit(0)
    sys.exit(0)

def cleanGenus(data, col):
    # Split spaces, throw out first, throw out numbers, trim and throw
    # out comma if exists at end
    data = formatData(data, col)
    if data.find(" ") > 0:
        return data.split(" ")[0]
    return data


def cleanSpecies(data, col):
    #throw out numbers, parens
    data = formatData(data, col)
    if data.find(" ") > 0:
        return data.split(" ")[1]
    return data

def cleanSubspecies(data, col):
    data = formatData(data, col)
    if data.find(" ") > 0:
        if len(data.split(" ")) is 3:
            return data.split(" ")[2]
        return ""
    return data


def cleanSciname(data, col):
    data = data.strip().replace("_", " ")
    if data.lower() == "NA":
        data = ""
    return data

def formatData(data, col):
    try:
        # Basic formatting
        data = data.strip().replace("_", " ")
        if not col in keepCase:
            data = data.lower()
        # Boolean values
        truthy = [
            "true",
            "1",
            "yes",
            "on",
            "+"
        ]
        falsey = [
            "false",
            "0",
            "no",
            "off",
            "-"
        ]
        if data in truthy or data in falsey:
            if data in truthy:
                data = "true"
            elif data in falsey:
                data = "false"
        if data.lower() == "na":
            data = ""
        # Are you an integer?
        try:
            idata = int(data)
            data = idata
        except ValueError:
            pass
        return data
    except:
        return data


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
    try:
        newFile = open(newPath,"w", newline='')
    except PermissionError:
        print("")
        print("ERROR: We couldn't get write permissions to '"+os.getcwd()+"/"+newPath+"'")
        print("Please check that the directory is writeable and that the file hasn't been locked by another user or program (like Excel),")
        print("then try to run this again.")
    cleanRows = csv.writer(newFile,delimiter=",",quoting=csv.QUOTE_ALL)
    colDefs = {}
    colClean = {
        "genus": lambda x,y: cleanGenus(x,y),
        "species": lambda x,y: cleanSpecies(x,y),
        "subspecies": lambda x,y: cleanSubspecies(x,y),
        "canonical_sciname": lambda x,y: cleanSciname(x,y),
        "IfTransfer_oldSciName": lambda x,y: cleanSciname(x,y),
    }
    for i, row in enumerate(rows):
        if i is 0:
            for j, column in enumerate(row):
                cleanColumn = re.sub(r"[^a-z__]", "", column, 0, re.IGNORECASE)
                colDefs[j] = cleanColumn
        else:
            # All other loops
            for j, column in enumerate(row):
                colName = colDefs[j]
                try:
                    row[j] = colClean[colName](column, colName)
                except KeyError:
                    # Doesn't need cleaning
                    row[j] = formatData(column, colName)
        # Append the cleaned row back on
        cleanRows.writerow(row)
        if i%50 is 0 and i > 0:
            print("Cleaned",i,"rows...")
    print("Finished cleaning",i,"rows.")
    print("Wrote '"+os.getcwd()+"/"+newPath+"'")
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
