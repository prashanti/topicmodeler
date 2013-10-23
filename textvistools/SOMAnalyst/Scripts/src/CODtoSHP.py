#Martin Lacayo-Emery
#Fall 2006

#This program converts COD files into SHP files and other related formats
#parameters: (COD book file,Shapefile,Data to map onto the COD)
def round6(x):
    return round(x,6)

#import helper libraries
import sys, struct
from math import sqrt
from dbftool import dbfwriter

#constants
#NaN=math.pow(-10,38)

infile=sys.argv[1]
outfile=sys.argv[2]
stype=sys.argv[3]

#file names
#if len(sys.argv)==3:
codfile=infile
#else:
#    codfile='I:/data/iris.cod'
    
shpfile=outfile.split('.')[0]
##csvfile=shpfile+'_geo.csv'
##txtfile=shpfile+'_point.txt'
##polytxt=shpfile+'_poly.txt'

###################################Process COD###########################
#open files from parameters
inputCOD = open(codfile,'r')
centroidsDist=1

#get file header
#list of strings of fomatting
formatting=inputCOD.readline().split()
#inputCOD.readline()
#list of strings of column headings
names=[]
for i in range(1,int(formatting[0])+1):
    names.append('att'+str(i))


header='Id,x,y'.split(',')+names
#+inputCOD.readline().strip('#n').split()
#parse cod
#list of strings lists of values
line=inputCOD.readline()
if line[0] == '#':
    cod=[i.split() for i in inputCOD.readlines()]
else:
    cod=[line.split()]+[i.split() for i in inputCOD.readlines()]
print len(cod),"records found\n"
inputCOD.close()

#get formatting
topology=formatting[1]
x=int(formatting[2])
y=int(formatting[3])

####################################Calculate centroidss####################
centroids=[]
#neurons listed from left to right, top to bottom
if topology=="rect":
    for lcvY in range(y):
        #loop over colomuns
        for lcvX in range(x,0,-1):
            centroids.append([float(lcvX*centroidsDist),float(lcvY*centroidsDist)])
elif topology=='hexa':
    #caluclate the changes for centroids
    deltaY=centroidsDist*sqrt(3.0/4)
    deltaX=centroidsDist*float(1)

    #set the orgin to start at 0,0 for the first point
    hexX=0-deltaX
    hexY=0
    for lcvY in range(y):
        for lcvX in range(x):
            #increment x coordinate
            hexX=hexX+deltaX
            centroids.append([hexX,hexY])

        #offset x coordinate for alternating rows        
        if (lcvY+1)%2:
            hexX=0-(deltaX/2)
        else:
            hexX=0-deltaX
        #increment y coordinate
        hexY=hexY+deltaY


#####################################Calculate Polygons#######################
polygons=[]
if topology=="rect":
    for i in centroids:
        #center point
        pX=i[0]
        pY=i[1]
        #derive extrema
        minX=pX-(0.5*centroidsDist)
        maxX=pX+(0.5*centroidsDist)
        minY=pY-(0.5*centroidsDist)
        maxY=pY+(0.5*centroidsDist)
        #number of parts 
        NumParts=1
        #total number of points
        NumPoints=4
        #bounding box
        Box=[minX,minY,maxX,maxY]
        #index to first point in part
        Parts=0
        #points for all parts
        #starts from top most, left most, and goes clock-wise
        Points=[Box,[[minX,maxY],[maxX,maxY],[maxX,minY],[minX,minY]]]
        polygons.append(Points)

elif topology=='hexa':
    for i in centroids:
        #center point
        pX=i[0]
        pY=i[1]
        #sides numberd in order of min length
        side2=0.5*centroidsDist
        side1=side2/sqrt(3)
        side3=2*side1
        #derive extreama
        minX=pX-side2
        maxX=pX+side2
        minY=pY-side3
        maxY=pY+side3
        #bounding box
        Box=[minX,minY,maxX,maxY]
        #number of parts
        NumParts=1
        #number of points
        NumPoints=6
        #index to first point in part
        Parts=0
        #starts from top most, left most, and goes clock-wise        
        Points=[Box,[[pX,pY+side3],[pX+side2,pY+side1],[pX+side2,pY-side1],[pX,pY-side3],[pX-side2,pY-side1],[pX-side2,pY+side1]]]
        polygons.append(Points)

######################################Construct Point Shapefile####################
shapes={}
shapes["point"]=1
shapes["polygon"]=5

shapeType=shapes[stype]

shp=open(shpfile+'.shp','wb') #main file
shx=open(shpfile+'.shx','wb') #index file
dbf=open(shpfile+'.dbf','wb') #dbf table



if shapeType==1:    
    #min expected at first point
    Xmin=centroids[0][0]
    Ymin=centroids[0][1]

    #max expected at last point
    Xmax=centroids[len(centroids)-1][0]
    Ymax=centroids[len(centroids)-1][1]
elif shapeType==5:
    #set default to first polygon
    Xmin=polygons[0][0][0]
    Ymin=polygons[0][0][1]
    Xmax=polygons[0][0][2]
    Ymax=polygons[0][0][3]

    for i in polygons:
        if i[0][0]<Xmin:
            Xmin=i[0][0]
        if i[0][1]<Ymin:
            Ymin=i[0][1]
        if i[0][2]>Xmax:
            Xmax=i[0][2]
        if i[0][3]>Ymax:
            Ymax=i[0][3]

#version as set forth in 1998 whitepaper
version=1000

#Unused, with value 0.0, if not Measured or Z type
Zmin=0.0
Zmax=0.0
Mmin=0.0
Mmax=0.0

####################MAIN FILE and INDEX File#######################
if shapeType==1:
    contentLength=10
elif shapeType==5:
    #16+8*pnts
    #contentLength=16+(8*len(polygons[0][1]))
    if topology=='rect':
        contentLength=64
    elif topology=='hexa':
        contentLength=80
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
shp.write(struct.pack('>i', 50+(contentLength*len(cod))))
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
shx.write(struct.pack('>i', 50+(4*len(cod))))


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



  
if shapeType==1:
    for id,i in enumerate(centroids):
        #record header
        #record numbers start at 1
        shp.write(struct.pack('>i',id))
        #content length
        shp.write(struct.pack('>i',contentLength))

        #record contents
        #print float(i[0]),float(i[1])
        shp.write(struct.pack('<i',shapeType))
    
        shp.write(struct.pack('<d',float(i[0])))
        shp.write(struct.pack('<d',float(i[1])))

        #writing index records
        #size=record header+content length
        shx.write(struct.pack('>i',50+((contentLength+4)*id)))
        shx.write(struct.pack('>i',contentLength))
        
       
elif shapeType==5:
     for id,i in enumerate(polygons):
        #record header
        #record numbers start at 1
        shp.write(struct.pack('>i',id))
        #content length
        shp.write(struct.pack('>i',contentLength))

        #record contents
        #print float(i[0]),float(i[1])
        shp.write(struct.pack('<i',shapeType))

        #bound box for polygon         
        for e in i[0]:
            shp.write(struct.pack('<d',e))

        #number of parts        
        shp.write(struct.pack('<i',1))
        #number of points
        shp.write(struct.pack('<i',len(i[1])+1))
        #parts index
        shp.write(struct.pack('<i',0))
    
        #points
        for p in i[1]:
            #shape type for point
            #shp.write(struct.pack('<i',1))
            #x coordinate
            shp.write(struct.pack('<d',float(p[0])))
            #y coordinate
            shp.write(struct.pack('<d',float(p[1])))
            #print float(p[0]),float(p[1])
        #x coordinate
        shp.write(struct.pack('<d',float(i[1][0][0])))
        #y coordinate
        shp.write(struct.pack('<d',float(i[1][0][1])))

        #writing index records
        #size=record header+content length
        shx.write(struct.pack('>i',50+((contentLength+4)*id)))
        shx.write(struct.pack('>i',contentLength))
        


shp.close()
shx.close()
################DBF File###############

fieldnames = header[3:]
fieldwidth=max(max([map(len,i) for i in cod]))
deci=0
##    for i in cod:
##        for j in i:
##            decimals=max(map(len,j.split('.')))
##            if decimals > deci:
##                deci=decimals
0
fieldspecs = [('N', fieldwidth, 6)]*(len(fieldnames)+1)
records = [([id+1]+map(round6,map(float,i))) for id,i in enumerate(cod)]
dbfwriter(dbf, ["NeuronID"]+fieldnames, fieldspecs, records)

dbf.close()


######################################Ouput Options##########################
##outputPoly=open(polytxt,'w')       
##outputPoly.write('Polygon\n')
##for id,l in enumerate(polygons):
##    outputPoly.write(str(id)+' '+str(0)+'\n')
##    for pid,p in enumerate(l[1]):
##        outputPoly.write(str(pid)+' '+str(p[0])+' '+str(p[1])+'\n')
##outputPoly.write('END')
##outputPoly.close()
##
##outputTXT=open(txtfile,'w')
##outputTXT.write('Point\n')
##outputCSV=open(csvfile,'w')        
##outputCSV.write(','.join(header)+'\n')
##for id,l in enumerate(cod):
##    outputCSV.write(','.join([str(id+1),','.join(map(str,centroids[id])),','.join(l)])+'\n')
##    outputTXT.write(str(id+1)+' '+' '.join(map(str,centroids[id]))+'\n')
##outputCSV.close()
##outputTXT.write('END')
##outputTXT.close()

