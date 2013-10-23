import sys

def AddIDtoLAT(inName,outName,atr,id):
    inFile=open(inName)
    header=inFile.readline().strip().split(",")
    lines=inFile.readlines()
    inFile.close()

    header=','.join(["__".join(header[:2]),atr+"__"+id]+map("__".join,zip(header[2:],map(str,range(1,len(header)-1)))))+"\n"
    outFile=open(outName,'w')
    outFile.write(header)
    outFile.write(''.join(lines))
    outFile.close()
    
if __name__=="__main__":
    inName=sys.argv[1]
    outName=sys.argv[2]
    atr=sys.argv[3]
    id=sys.argv[4]
    AddIDtoLAT(inName,outName,atr,id)