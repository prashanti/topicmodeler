#Martin Lacayo-Emery
#11/3/2008

import sys,os

def normalizeByColumn(inName,outName,numerators,denominator):
    inFile=open(inName,'r')
    outFile=open(outName,'w')

    header=inFile.readline().strip()
    outFile.write(header)
    header=header.split(",")
    
    denominator=header.index(denominator)
    numerators=map(header.index,numerators)

    lines=inFile.readlines()
    for line in lines:
        line=line.split(",")
        denom=float(line[denominator])
        for n in numerators:
            line[n]=str(float(line[n])/denom)
        outFile.write("\n"+','.join(line))
        

if __name__=="__main__":
    inName=sys.argv[1]
    outName=sys.argv[2]
    numerators=sys.argv[3].split(";")
    denominator=sys.argv[4]
    
    normalizeByColumn(inName,outName,numerators,denominator)