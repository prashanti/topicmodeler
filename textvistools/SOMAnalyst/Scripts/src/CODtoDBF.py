import sys
from dbftool import dbfwriter



def roundN(x):
    return round(x,N)

codfile=sys.argv[1]
dfile=sys.argv[2]
N=int(sys.argv[3])

inputCOD = open(codfile,'r')
dbf=open(dfile,'wb')

formatting=inputCOD.readline().split()

names=[]
cols=int(formatting[0])
for i in range(1,cols+1):
    names.append('att'+str(i))
names=['OID']+names

cod=[[id]+map(roundN,map(float,i.split())) for id,i in enumerate(inputCOD.readlines())]
inputCOD.close()

print len(cod),"records found\n"

fieldwidth=12
fieldnames = names
fieldspecs = [('N', fieldwidth, 6)]*cols
fieldspecs=[('N',fieldwidth,0)]+fieldspecs
records = [map(roundN,map(float,i)) for i in cod]
dbfwriter(dbf, fieldnames, fieldspecs, records)

dbf.close()

