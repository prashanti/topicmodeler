#Martin Lacayo-Emery
#Fall 2006
#
# Modified by JPH on 8/3/2010 to allow for paths with '..'

#The BMU file is space delimited
#The attribute file is comma delimited

#import helper libraries
import sys, struct
import math
from dbftool import dbfwriter
import random

#helper function
def round6(x):
    return round(x,6)

def convertNums(x):
    y=[int(x[0]),int(x[1])]
    y.extend(x[2:])
    return y

def ATRtoP(bmufile,outfile,stype):

    #set shape file name
    # Modified by JPH on 8/3/2010 to allow for paths with '..'
    #shpfile=outfile.split('.')[0]
    shpfile=outfile;

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
            hexX=hexX+(math.cos(2*math.pi*n)*random.random()*(centroidsDist*0.3))
            hexY=hexY+(math.sin(2*math.pi*n)*random.random()*(centroidsDist*0.3))
            centroids.append([hexX,hexY])
            cod.append(l[2:])

    ######################################Construct Point Shapefile####################
    #In this section the shapefiles are written
    #The 1998 white paper was use as the only reference for this section        

    #dictionary for shape types        
    shapes={}
    shapes["point"]=1
    shapes["polygon"]=5

    shapeType=shapes[stype]

    shp=open(shpfile+'.shp','wb') #main file
    shx=open(shpfile+'.shx','wb') #index file
    dbf=open(shpfile+'.dbf','wb') #dbf table

        #if point file desired
    if shapeType==1:    
        #min expected at first point
        Xs=[centroids[i][0] for i in range(len(centroids))]
        Ys=[centroids[i][1] for i in range(len(centroids))]
        Xmin=min(Xs)
        Ymin=min(Ys)

        #max expected at last point
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
    #Main file and Index file creation begins here
    #Integers are signed 32-bit integers (4 bytes)
    #Doubles are signed 64-bit IEEE double-precision
    #floating point numbers (8 bytes)
    #lengths are measured in 16-bit words

    #if point    
    if shapeType==1:
        #shapetype+x+y=int+float+float=2+4+4
        contentLength=10
    elif shapeType==5:
        if topology=="hexa":
            contentLength=16+(4*7)
        elif topology=="rect":
            contentLength=16+(4*5)
         
    ########Main File Header##########
    #This section corresponds directly to the whitepaper
    #regarding main file creation
            
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
    #This section corresponds directly to the whitepaper
    #regarding index file creation

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

    #if point shape type
    if shapeType==1:
        #loop over all centroids and number them for ids
        for id,i in enumerate(centroids):

            #write record header
            #record numbers start at 1
            #however this seemingly works
            shp.write(struct.pack('>i',id))
            #content length
            shp.write(struct.pack('>i',contentLength))

            #write record contents
            shp.write(struct.pack('<i',shapeType))

            #write coordinates            
            shp.write(struct.pack('<d',float(i[0])))
            shp.write(struct.pack('<d',float(i[1])))

            #write index records
            shx.write(struct.pack('>i',50+((contentLength+4)*id)))
            shx.write(struct.pack('>i',contentLength))
            
    #close files to empty buffer
    shp.close()
    shx.close()
    ################DBF File###############
    #In this section the DBF for the shapefile is created
    #This relies on a third party tool
    #values are stored in their rounded-off amounts as numbers

    #set column headers    
    fieldnames = names
    #set column width
    fieldwidth=[0]*len(cod[0])
    for i in cod:
        for id,j in enumerate(i):
            if len(j)>fieldwidth[id]:
                fieldwidth[id]=len(j)

    #set field specs
    # Changed by JPH on 8/3/2010 to allow 7 bytes in the field ID 
    #fieldspecs=[('N', 4, 6)]    
    fieldspecs=[('N', 7, 6)]    
    for w in fieldwidth:
        fieldspecs.append(('N', w, 6))
        
    #set records
    records = [([id+1]+map(round6,map(float,i))) for id,i in enumerate(cod)]

    #write dbf
    dbfwriter(dbf, ["PointID"]+fieldnames, fieldspecs, records)
    dbf.close()

if __name__=="__main__":
    bmufile=sys.argv[1]
    outfile=sys.argv[2]
    stype=sys.argv[3]
    ATRtoP(bmufile,outfile,stype)
