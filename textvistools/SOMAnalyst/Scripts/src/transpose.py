#Martin Lacayo-Emery
#11/09/2008

import sys, string

def transpose(inName,outName):
    infile=open(inName,'r')
    outfile=open(outName,'w')

    lines=[]
    #read in header a split for roation
    line=infile.readline()
    line=line.strip().split(',')
    #check names
    charmap=string.maketrans(string.punctuation+string.whitespace,"_"*39)
    line=[l.translate(charmap) for l in line]
    line=[line[1]+","+line[0]]+[l.replace("__",",") for l in line[2:]]
    lines.append(line)

    for l in infile.readlines():
        line=l.strip().split(',')
        lines.append(["__".join(line[:2])]+line[2:])
    lines=apply(zip,lines)
    lines=[','.join(l) for l in lines]
    lines='\n'.join(lines)
    outfile.write(lines)

    infile.close()
    outfile.close()

if __name__=="__main__":
    inName=sys.argv[1]
    outName=sys.argv[2]
    transpose(inName,outName)