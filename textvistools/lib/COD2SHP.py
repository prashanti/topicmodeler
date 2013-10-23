#!/usr/bin/python
# convert COD to shape file using SOMAnalyst function
#
# Usage:
# COD2SHP input_filename output_filename
#
# The input filename should have the .bmu extension, but the output
# filename should have no extension

import sys

print "COD2SHP: path to SOMAnalyst sources ",sys.argv[1]+"/Scripts/src/"
print "COD2SHP: input  filename ",sys.argv[2]
print "COD2SHP: output filename ",sys.argv[3]

assert len(sys.argv) == 4

sys.path.append(sys.argv[1]+"/Scripts/src")

import jphCODtoSHP

jphCODtoSHP.CODtoSHP(sys.argv[2],sys.argv[3],'polygon')

