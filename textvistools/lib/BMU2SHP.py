#!/usr/bin/python
# convert BMU to shape file using SOMAnalyst function
#
# Usage:
# BMU2SHP input_filename output_filename
#
# The input filename should have the .bmu extension, but the output
# filename should have no extension

import sys

print "BMU2SHP: path to SOMAnalyst sources ",sys.argv[1]+"/Scripts/src/"
print "BMU2SHP: input  filename ",sys.argv[2]
print "BMU2SHP: output filename ",sys.argv[3]

assert len(sys.argv) == 4

sys.path.append(sys.argv[1]+"/Scripts/src")

import jphATRtoSHP

jphATRtoSHP.ATRtoP(sys.argv[2],sys.argv[3],'point')

