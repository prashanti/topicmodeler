#Martin Lacayo-Emery
#10/22/2008

import sys, random

def randomize(inName,outName):
    inFile=open(inName,'r')
    outFile=open(outName,'w')

    outFile.write(inFile.readline())
    lines=inFile.readlines()
    inFile.close()

    for i in range(len(lines)):
        outFile.write(lines.pop(random.randint(0,len(lines)-1)))

    outFile.close()        


if __name__ == "__main__":
    inName = sys.argv[1]
    outName = sys.argv[2]
    randomize(inName,outName)