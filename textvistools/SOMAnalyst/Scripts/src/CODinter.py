import sys

codFile=sys.argv[1]
cod2File=sys.argv[2]

cod=open(codFile,'r')
cod2=open(cod2File,'w')
cod2.write(cod.readline())
lines=[map(float,i.split()) for i in cod.readlines()]
cod.close()

for l in range(len(lines)-1):
    cod2.write(' '.join(map(str,lines[l]))+"\n")
    inter=[]
    for i in range(len(lines[l])):
        inter.append((lines[l][i]+lines[l+1][i])/2)
    cod2.write(' '.join(map(str,inter))+"\n")
 
cod2.write(' '.join(map(str,lines[len(lines)-1]))+"\n")
cod2.close()