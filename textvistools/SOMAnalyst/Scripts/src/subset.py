#Martin Lacayo-Emery
#10/23/2008

import sys

def subset(inName,outName,header,first,last,step):
    inFile=open(inName,'r')
    outFile=open(outName,'w')
    if header=='true':
        outFile.write(inFile.readline())
    if last != '#':
        outFile.write(''.join(inFile.readlines()[first:int(last):step]))
    else:
        outFile.write(''.join(inFile.readlines()[first::step]))

    inFile.close()
    outFile.close()


if __name__=="__main__":
    inName=sys.argv[1]
    outName=sys.argv[2]
    header=sys.argv[3]
    first=int(sys.argv[4])-1
    last=sys.argv[5]
    step=int(sys.argv[6])
    
    subset(inName,outName,header,first,last,step)
    