import time, os, glob, sys, qinput, string, yn

defaultFile = "Herp Resources.csv"
outputFile = "parsed_html_table.html"
exitScriptPrompt = "Press Control-c to exit."

def doExit():
    import os,sys
    print("\n")
    os._exit(0)
    sys.exit(0)

def readCSVToDict(path = defaultFile):
    if not os.path.isfile(path):
        print("Invalid file.")
        return False
    # Read the fle
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
    columnList = list()
    hasHeaders = yn.yn("Does the first row have the table headers?")
    csvDict = {}
    for i,row in enumerate(rows):
        if i is 0:
            # First iter, set up the headers
            if hasHeaders:
                # The first row has the table headers
                for column in row:
                    csvDict[column.strip()] = list()
                    columnList.append(column.strip())
            else:
                # We need the table headers
                tableHeaders = ""
                while len(tableHeaders.split(",")) is not len(row):
                    tableHeaders = qinput.input("Please give a comma-separated list of the table headers (there should be "+str(len(row))+" entries)")
                for k,column in enumerate(tableHeaders.split(",")):
                    # We actually do have the first row's information
                    # this time, so set it for each column
                    csvDict[column.strip()] = list()
                    csvDict[column.strip()].append(row[k])
                    columnList.append(column.strip())
            print("Got headers",columnList)
        else:
            # All other loops
            for j,column in enumerate(row):
                csvDict[columnList[j]].append(column)
    # We now have a dictionary of the CSV
    # Give it the meta-column
    csvDict["columnList"] = columnList
    csvDict["columnCount"] = len(columnList)
    csvDict["numRows"] = len(csvDict[columnList[0]])
    return csvDict


def dictToHtmlTable(refDict,id):
    # Take a dictionary and make an HTML table out of it
    id = "".join(id.split()) # Remove all whitespace
    htmlFrame = "<table id='"+id+"'>\n"
    htmlBuffer = ""
    i = 0
    skippedColCounts = {}
    for column in refDict["columnList"]:
        skippedColCounts[column] = 0
    while i < refDict["numRows"]:
        # Go through each column, and shove each item in its place
        skipNext = False
        for j,column in enumerate(refDict["columnList"]):
            if skipNext:
                skipNext = False
                continue
            entry = refDict[column].pop(0) # Remove the first element
            if j is 0:
                htmlBuffer += "\t<tr id='"+id+"-row"+str(i)+"'>\n"
            if j < len(refDict["columnList"]) - 1:
                # Is the next entry a hyperlink for this one?
                nextCol = refDict["columnList"][j+1]
                if refDict[nextCol][0].find("http") is 0:
                    uri = refDict[nextCol].pop(0)
                    skipNext = True
                    skippedColCounts[nextCol] += 1
                    entry = "<a href='"+uri+"' onclick='window.open(this.href); return false;' onkeypress='window.open(this.href); return false;'>"+entry+"</a>"
            cssCol = "".join(column.split())
            htmlBuffer += "\t\t<td id='"+id+"-"+cssCol+str(i)+"' class='"+cssCol+"'>"+entry+"</td>\n"
        # Cleanup
        htmlBuffer += "\t</tr>\n"
        i += 1
    # We've finished the table
    # Make the column headers
    for i,column in enumerate(refDict["columnList"]):
        if i is 0:
            htmlFrame += "\t<tr id='"+id+"-headerRow' class='tableHeader'>\n"
        if skippedColCounts[column] is refDict["numRows"]:
            print("Column '"+column+"' only had URLs, and the values were attached to the previous column.")
        else:
            cssCol = "".join(column.split())
            htmlFrame += "\t\t<th class='"+cssCol+"'>"+column+"</th>\n"
    htmlBuffer += "</table>"
    htmlBuffer = htmlFrame + htmlBuffer
    return htmlBuffer


# Main read
path = None
tableId = None
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
            # they'll fail the next check.
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
        fileName = path.split("/").pop()
        fileName = fileName.split("\\").pop() # Windows
        fileBase = fileName.split(".")
        fileBase.pop()
        fileBase = ".".join(fileBase)
        tableId = "".join(fileBase.split())
        keepTableId = yn.yn("Do you want to keep the default table id '"+tableId+"'?")
        if not keepTableId:
            tempTableId = qinput.input("Please provide a table id: ")
            tableId = "".join(tempTableId.split())
            print("Using "+tableId+" as the table id ...")
    except KeyboardInterrupt:
        doExit()

# We now have a valid path
csvDict = readCSVToDict(path)
buffer = dictToHtmlTable(csvDict,tableId)
writeToDefault = yn.yn("Write to default output "+outputFile+"?")
if not writeToDefault:
    outputFile = qinput.input("Please give the output file name: ")
try:
    o = open(outputFile,'w')
    o.write(buffer)
    o.close()
    print("Successfully wrote to "+outputFile)
except:
    print("There was an exception writing to "+outputFile)
    print(sys.exc_info[0])
