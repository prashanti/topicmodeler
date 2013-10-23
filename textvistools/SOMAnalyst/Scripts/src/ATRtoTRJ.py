#Martin Lacayo-Emery
#Fall 2006

#The BMU file is space delimited
#The attribute file is comma delimited

#import helper libraries
import sys
import math
import random
import struct
from dbftool import dbfwriter

#helper function
def round6(x):
    return round(x,6)

def convertNums(x):
    y=[int(x[0]),int(x[1]),float(x[2])]
    return y


#get user inputs
bmufile=sys.argv[1]
outfile=sys.argv[2]

#set shape file name
shpfile=outfile.split('.')[0]

#open files
file1=open(bmufile,'r')

#extract formatting
formatting=file1.readline()
formatting=formatting.split()
topology=formatting[1]

#get column headers
names=['Qerror']

#split intput
lines=[convertNums(i.split()) for i in file1.readlines()]


####################################Calculate centroids and cod####################
centroids=[]
cod=[]
centroidsDist=1
#neurons listed from left to right, top to bottom
if topology=="rect":
    for l in lines:
        centroids.append([float(l[0]*centroidsDist),float(l[1]*centroidsDist)])
        cod.append(l[2:])
elif topology=='hexa':
    #caluclate the changes for centroids
    deltaY=centroidsDist*math.sqrt(3.0/4)
    deltaX=centroidsDist*float(1)

    #set the orgin to start at 0,0 for the first point
    for l in lines:
        #if odd row
        if (l[1]+1)%2:
            hexX=l[0]
        else:
            hexX=l[0]+(0.5*centroidsDist)

        hexY=(centroidsDist*0.5)*math.sqrt(3)*l[1]
        n=random.random()
        centroids.append([hexX,hexY])
        cod.extend(l[2:])

######################################Construct Point Shapefile####################

shapeType=3

shp=open(shpfile+'.shp','wb') #main file
shx=open(shpfile+'.shx','wb') #index file
dbf=open(shpfile+'.dbf','wb') #dbf table

Xs=[]
Ys=[]
for i in centroids:
    Xs.append(i[0])
    Ys.append(i[1])
Xmin=min(Xs)
Ymin=min(Ys)
Xmax=max(Xs)
Ymax=max(Ys)

#version as set forth in 1998 whitepaper
version=1000

#Unused, with value 0.0, if not Measured or Z type
Zmin=0.0
Zmax=0.0
Mmin=0.0
Mmax=0.0

####################MAIN FILE and INDEX File#######################
contentLength=16+(4*len(centroids))
########Main File Header##########
#BIG BYTE ORDER, integer
#byte 0, File Code
shp.write(struct.pack('>i', 9994))
#byte 4, Unused
shp.write(struct.pack('>i', 0))
#byte 8, Unused
shp.write(struct.pack('>i', 0))
#byte 12, Unused
shp.write(struct.pack('>i', 0))
#byte 16, Unused
shp.write(struct.pack('>i', 0))
#byte 20, Unused
shp.write(struct.pack('>i', 0))
#byte 24, File Length, total length of file in 16-bit words
#this must be determined after file creation.
shp.write(struct.pack('>i', 50+((4+contentLength)*1)))
#byte 28, Version, integer
shp.write(struct.pack('<i', version))
#byte 32, shape type
shp.write(struct.pack('<i',shapeType))
#byte 36, Bounding Box Xmin
shp.write(struct.pack('<d',Xmin))
#byte 44 Bounding Box Ymin
shp.write(struct.pack('<d',Ymin))
#byte 52 Bounding Box Xmax
shp.write(struct.pack('<d',Xmax))
#byte 60 Bounding Box Ymax
shp.write(struct.pack('<d',Ymax))
#byte 68* Bounding Box Zmin
shp.write(struct.pack('<d',Zmin))
#byte 76* Bounding Box Zmax
shp.write(struct.pack('<d',Zmax))
#byte 84* Bounding Box Mmin
shp.write(struct.pack('<d',Mmin))
#byte 92* Bounding Box Mmax
shp.write(struct.pack('<d',Mmax))

##############Index File Header###########
#BIG BYTE ORDER, integer
#byte 0, File Code
shx.write(struct.pack('>i', 9994))
#byte 4, Unused
shx.write(struct.pack('>i', 0))
#byte 8, Unused
shx.write(struct.pack('>i', 0))
#byte 12, Unused
shx.write(struct.pack('>i', 0))
#byte 16, Unused
shx.write(struct.pack('>i', 0))
#byte 20, Unused
shx.write(struct.pack('>i', 0))
#byte 24, File Length, total length of file in 16-bit words
shx.write(struct.pack('>i', 50+(4*1)))
#byte 28, Version, integer
shx.write(struct.pack('<i', version))
#byte 32, shape type
shx.write(struct.pack('<i',shapeType))
#byte 36, Bounding Box Xmin
shx.write(struct.pack('<d',Xmin))
#byte 44 Bounding Box Ymin
shx.write(struct.pack('<d',Ymin))
#byte 52 Bounding Box Xmax
shx.write(struct.pack('<d',Xmax))
#byte 60 Bounding Box Ymax
shx.write(struct.pack('<d',Ymax))
#byte 68* Bounding Box Zmin
shx.write(struct.pack('<d',Zmin))
#byte 76* Bounding Box Zmax
shx.write(struct.pack('<d',Zmax))
#byte 84* Bounding Box Mmin
shx.write(struct.pack('<d',Mmin))
#byte 92* Bounding Box Mmax
shx.write(struct.pack('<d',Mmax))
#record header

#record numbers start at 1
shp.write(struct.pack('>i',0))
#content length
shp.write(struct.pack('>i',contentLength))
#record contents
#print float(i[0]),float(i[1])
shp.write(struct.pack('<i',shapeType))
#bound box for polygon         
shp.write(struct.pack('<d',Xmin))
shp.write(struct.pack('<d',Ymin))
shp.write(struct.pack('<d',Xmax))
shp.write(struct.pack('<d',Ymax))
#number of parts        
shp.write(struct.pack('<i',1))
#number of points
shp.write(struct.pack('<i',len(centroids)))
#parts index
shp.write(struct.pack('<i',0))

#points
for p in centroids:
    #shape type for point
    #shp.write(struct.pack('<i',1))
    #x coordinate
    shp.write(struct.pack('<d',float(p[0])))
    #y coordinate
    shp.write(struct.pack('<d',float(p[1])))
    #print float(p[0]),float(p[1])


#writing index records
#size=record header+content length
shx.write(struct.pack('>i',50))
shx.write(struct.pack('>i',contentLength))
    
shp.close()
shx.close()
################DBF File###############

fieldnames = ['Qerror']
fieldspecs = [('N', 16, 6)]
records = [[sum(cod)/len(cod)]]
dbfwriter(dbf, fieldnames, fieldspecs, records)

dbf.close()
