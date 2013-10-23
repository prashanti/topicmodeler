#Martin Lacayo-Emery
#10/18/2008

import sys

def normalize(inName,outName,start,end,direction,minEqMax):    
    infile=open(inName,'r')
    outfile=open(outName,'w')

    outfile.write(infile.readline())

    if (direction=="column") or (direction=="global"):
        #read in table and convert it to numbers
        table=[]
        for l in infile.readlines():
            line=l.split(",")
            try:
                table.append(line[:2]+map(float,line[2:]))
            #don't crash on empty lines
            except ValueError:
                pass
        if (direction=="column"):
            minimums=table[0][2:]
            maximums=table[0][2:]
            for l in table:
                for id,n in enumerate(l[2:]):
                    if n < minimums[id]:
                        minimums[id]=n
                    elif n > maximums[id]:
                        maximums[id]=n
            for l in table:
                row=l[:2]
                for id,n in enumerate(l[2:]):
                    try:
                        row.append(str(start+((end-start)*(n-minimums[id])/float(maximums[id]-minimums[id]))))
                    except ZeroDivisionError:
                        row.append(str(minEqMax))
                        
                outfile.write(','.join(row)+"\n")
        else:
            minimum=table[0][2]
            maximum=table[0][2]
            for l in table:
                for n in l[2:]:
                    if n < minimum:
                        minimum=n
                    elif n > maximum:
                        maximum=n
            for l in table:
                row=l[:2]
                for n in l[2:]:
                    try:
                        row.append(str(start+((end-start)*(n-minimum)/float(maximum-minimum))))
                    except ZeroDivisionError:
                        row.append(str(minEqMax))
                outfile.write(','.join(row)+"\n")

    elif (direction=="row"):
        line=infile.readline()
        while(line):
            line=line.split(",")
            row=line[:2]+map(float,line[2:])
            minimum=min(row[2:])
            maximum=max(row[2:])
            for id,n in enumerate(row[2:]):
                try:
                    row[id+2]=str(start+((end-start)*(n-minimum)/float(maximum-minimum)))
                except ZeroDivisionError:
                    row[id+2]=minEqMax
                    
            outfile.write(','.join(map(str,row))+"\n")
            line=infile.readline()
    else:
        pass

    infile.close()
    outfile.close()

        
if __name__ == "__main__":
    inName = sys.argv[1]
    outName = sys.argv[2]
    start = float(sys.argv[3])
    end = float(sys.argv[4])
    direction = sys.argv[5]
    minEqMax = float(sys.argv[6])

    normalize(inName,outName,start,end,direction,minEqMax)    
    