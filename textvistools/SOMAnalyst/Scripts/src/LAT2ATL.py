#Martin Lacayo-Emery
#10/19/2008

import sys, transLTA
    
if __name__=="__main__":
    inName=sys.argv[1]
    outName=sys.argv[2]
    transLTA.transform(inName,outName,0,"Time","Attribute")

    