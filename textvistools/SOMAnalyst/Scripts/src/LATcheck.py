#Martin Lacayo-Emery
#10/27/2008

import sys, time, string

def LATcheck(inName,reportName,verbose,outName,namesCheck=True,blanksCheck=True,noDataCheck=False,noDataValue="0",columnsCheck=True,zerosCheck=False,behavior="drop vector",replacement="0.0000001"):
    inFile=open(inName,'r')
    lines=[l.strip() for l in inFile.readlines()]
    inFile.close()

    report=open(reportName,'w')
    reportString=""
    reportString+=str("SOM Analyst LAT file check report "+str(time.ctime(time.time()))+"\n\n")
    reportString+=str("This check was performed on "+inName+"\n")
    if outName!="#":
        reportString+=str("A corrected file was written to "+outName+"\n")
    reportString+=str("\nIf there is nothing listed under an issue, that indicates there were none of that issue found.\n")
    reportString+=str("\n\nMinor issues checked - \n")

    #check for minor issues

    #blank lines
    blanksFound=0
    tempReport=""
    if blanksCheck:
        reportString+=str("\n\n\tBlank Lines:")
        for id in range(len(lines)-1,0,-1):
            if (len(lines[id]) == 0):
                if verbose:
                    if outName != "#":
                        lines.pop(id)
                        tempReport=str("\n\t\tLine "+str(id+1)+" was removed because it is a blank line.")+tempReport
                        blanksFound+=1
                    else:
                        tempReport=str("\n\t\tLine "+str(id+1)+" is a blank line.")+tempReport
                        blanksFound+=1
                else:
                    blanksFound+=1
    reportString+=tempReport
    if blanksFound:
        if not verbose:
            reportString+="\n"+str(blanksFound)+" blank lines found."
    else:
        reportString+="\n\t\t\tNo blank lines found."

    reportString+=str("\n\n\nMajor issues checked - \n")

    lines=[l.split(',') for l in lines]
    #check for empty cells
    noDataFound=0
    tempReport=""
    if noDataCheck:
        reportString+=str("\n\n\tCells with no data:")
        for id in range(len(lines)-1,0,-1):
            try:
                lines[id].index('')
                missingData=True
            except ValueError:
                missingData=False
            if missingData:
                for i,value in enumerate(lines[id]):
                    if value == "":
                        if outName != "#":
                            lines[id][i]=noDataValue
                            if verbose:
                                tempReport=str("\n\t\tLine "+str(id+1)+" cell "+str(i)+" was replaced with "+noDataValue+".")+tempReport
                        else:
                            tempReport=str("\n\t\tLine "+str(id+1)+" does not have as many values as the header.")+tempReport

    reportString+=tempReport
    
    #check for uneven columns
    tempReport=""
    if columnsCheck:
        reportString+=str("\n\n\tNumber of Cells in a Row:")
        columns=len(lines[0])
        for id in range(len(lines)-1,0,-1):
            try:
                lines[id].index('')
                missingData=True
            except ValueError:
                missingData=False
            if len(lines[id]) != columns or missingData:
                if outName != "#":
                    lines.pop(id)
                    if verbose:
                        tempReport=str("\n\t\tLine "+str(id+1)+" was removed because does not have as many values as the header.")+tempReport
                else:
                    tempReport=str("\n\t\tLine "+str(id+1)+" does not have as many values as the header.")+tempReport

    reportString+=tempReport

    #check for zero vectors
    #requires no empty cell
    tempReport=""
    if zerosCheck:
        reportString+=str("\n\n\tZero vectors:")
        for id in range(len(lines)-1,0,-1):
            if not sum(map(float.__nonzero__,(map(float,lines[id][2:])))):
                if outName != "#":
                    if behavior=="change last value":
                        lines[id][-1]=replacement
                        if verbose:
                            tempReport=str("\n\t\tLine "+str(id+1)+" had the last value replaced with"+replacement+".")+tempReport
                    elif behavior=="drop vector":
                        lines.pop(id)
                        if verbose:
                            tempReport=str("\n\t\tLine "+str(id+1)+" was dropped because it had only zeros.")+tempReport
                    else:
                        lines[id]=lines[id][:2]+([str(replacement)]*(len(lines[id])-2))
                        if verbose:
                            tempReport=str("\n\t\tLine "+str(id+1)+" had all values replaced with"+replacement+".")+tempReport
                else:
                    tempReport=str("\n\t\tLine "+str(id+1)+" contains an all zero vector.")+tempReport

    reportString+=tempReport                    

    #check field names
    #field names may only contain letters, numbers, or underscores
    if namesCheck:
        reportString+=str("\n\n\tField Names with Punctuation or Whitespace:")
        charmap=string.maketrans(string.punctuation+string.whitespace,"_"*39)
        for id,n in enumerate(lines[0]):
            fixed=n.translate(charmap)
            if n!=fixed:
                if outName != "#":
                    lines[0][id]=fixed
                    if verbose:
                        reportString+=str("\n\t\tField "+n+" was renamed to "+fixed)
                else:
                    reportString+=str("\n\t\tField "+n+" contains invalid characters.")

##    #check for mixed types
##    reportString+=str("\n\nData type")
##    types=map(type,map(eval,lines[1][2:]))
##    for id in range(len(lines)-1,0,-1):
##        for colId in range(columns-1,0,-1):
##            if types[colId] !=
    report.write(reportString)
    report.close()

    if outName != "#":
        outFile=open(outName,'w')
        outFile.write('\n'.join([','.join(l) for l in lines]))
        outFile.close()
                          

if __name__ == "__main__":
    inName=sys.argv[1]
    reportName=sys.argv[2]
    if sys.argv[3] == "false":
        verbose=False
    else:
        verbose=True
    outName=sys.argv[4]
    if sys.argv[5] == "false":
        names=False
    else:
        names=True
    if sys.argv[6] == "false":
        blanks=False
    else:
        blanks=True
    if sys.argv[7] == "false":
        noData=False
    else:
        noData=True
    noDataValue=sys.argv[8]
    if sys.argv[9] == "false":
        columns=False
    else:
        columns=True
    if sys.argv[10] == "false":
        zeros=False
    else:
        zeros=True
    behavior=sys.argv[11]
    replacement=sys.argv[12]
    
    LATcheck(inName,reportName,verbose,outName,names,blanks,noData,noDataValue,columns,zeros,behavior,replacement)