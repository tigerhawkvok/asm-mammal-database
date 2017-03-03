import time, os, glob, sys, qinput, string, yn

defaultFile = "../../MasterTax_MamPhy-v1.0_Sept2015.csv"
outputFile = "../../asm_predatabase_clean.csv"
exitScriptPrompt = "Press Control-c to exit."

def doExit():
    import os,sys
    print("\n")
    os._exit(0)
    sys.exit(0)

def cleanGenus(data):
    # Split spaces, throw out first, throw out numbers, trim and throw
    # out comma if exists at end
    return formatData(data)


def cleanSpecies(data):
    #throw out numbers, parens
    return formatData(data)


def cleanSciname(data):
    return data.strip().replace("_", " ")

def formatData(data):
    try:
        return data.lower().strip()
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
    newFile = open(newPath,"w", newline='')
    cleanRows = csv.writer(newFile,delimiter=",",quoting=csv.QUOTE_ALL)
    colDefs = {}
    colClean = {
        "genus": lambda x: cleanGenus(x),
        "species": lambda x: cleanSpecies(x),
        "canonical_sciname": lambda x: cleanSciname(x),
    }
    for i,row in enumerate(rows):
        if i is 0:
            for j,column in enumerate(row):
                colDefs[j] = column
        else:
            # All other loops
            for j, column in enumerate(row):
                colName = colDefs[j]
                try:
                    row[j] = colClean[colName](column)
                except KeyError:
                    # Doesn't need cleaning
                    row[j] = formatData(column)
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
