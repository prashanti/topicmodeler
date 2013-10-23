import sys, struct
from dbftool import dbfwriter

ifile=sys.argv[1]
ofile=sys.argv[2].split('.')[0]

shp=open(ifile,'rb')
shp.seek(36)
Xmin=struct.unpack("<d",shp.read(8))[0]
Ymin=struct.unpack("<d",shp.read(8))[0]
Xmax=struct.unpack("<d",shp.read(8))[0]
Ymax=struct.unpack("<d",shp.read(8))[0]
shp.close

shp=open(ofile+".shp",'wb')
shx=open(ofile+".shx",'wb')
dbf=open(ofile+".dbf",'wb')
shapeType=5
contentLength=64
id=0
#version as set forth in 1998 whitepaper
version=1000
#Unused, with value 0.0, if not Measured or Z type
Zmin=0.0
Zmax=0.0
Mmin=0.0
Mmax=0.0
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
shp.write(struct.pack('>i', 50+contentLength))
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
shx.write(struct.pack('>i', 50+4))


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


shp.write(struct.pack('>i',id))
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
shp.write(struct.pack('<i',5))
#parts index
shp.write(struct.pack('<i',0))

#points
shp.write(struct.pack('<d',Xmax))
shp.write(struct.pack('<d',Ymax))

shp.write(struct.pack('<d',Xmax))
shp.write(struct.pack('<d',Ymin))

shp.write(struct.pack('<d',Xmin))
shp.write(struct.pack('<d',Ymin))

shp.write(struct.pack('<d',Xmin))
shp.write(struct.pack('<d',Ymax))

shp.write(struct.pack('<d',Xmax))
shp.write(struct.pack('<d',Ymax))


#writing index records
#size=record header+content length
shx.write(struct.pack('>i',50+((contentLength+4)*id)))
shx.write(struct.pack('>i',contentLength))
        
shp.close()
shx.close()

dbfwriter(dbf, ['N'], [('N',1,0)], [[1]])

dbf.close()



