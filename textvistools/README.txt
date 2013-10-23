Text Visualization Toolbox (TVT)
--------------------------------

This toolbox permits the spatial visualization of large corpus of
documents based on
  1) Extraction of document features using Latent Dirichlet allocation
  2) Locating documents in two-dimensional space using Self-Organizing Map's
  3) Producing outputs that can be imported into ArcGIS, permitting 
     the visualization of documents clusters

Acknowledgements
----------------

The following toolboxes are included:

1) A modifed version of the
	Matlab Topic Modeling Toolbox 1.3.2
which is the Latent Dirichlet allocation implementation in MATLAB, by
M. Steyvers and T. Griffiths, available at
	http://psiexp.ss.uci.edu/research/programs_data/toolbox.htm

The changes introduced were made simply to optimize memory usage,
allowing for larger corpus. 

2) A modified version of
	SOM_PAK Version 3.1 (April 7, 1995)
which is the Self-Organizing Map Program Package by the SOM
Programming Team of the Helsinki University of Technology

The changes introduced were made simply to avoid compilation
errors/warnings in Mac OSX. 

3) A modified version of
	LVQ_PAK Version 3.1 (April 7, 1995)
which is the Learning vector Quantization Package by the LVQ
Programming Team of the Helsinki University of Technology

The changes introduced were made simply to avoid compilation
errors/warnings in Mac OSX. 

4) A modified version of
        SOM Analyst Tools (Fall 2006)
which is a python ArcGIS toolbox to interface with SOM_PAK by Martin
Lacayo-Emery.

The changes introduced were made simply to allow for more than 9999
documents and to permit a simple interface with matlab.

5) The FunParTools matlab toolbox by Joao Hespanha. This toolbox is mosly
useful when writing scripts to do batch processing of data using
multiple steps (each affected by several parameters) and
reading/writing intermediate files.

6) The ProbabilityTools matlab toolbox by Joao Hespanha. This toolbox
provides a few simple macros to perform estimation.


How to run the examples:
-----------------------

These instructions should work "flawlessly" on Mac OSX and possibly
also under Linux. On MS windows several adaptations may be needed.

1. Download and decode all the files in the same folder. Three subfolders
   should be created:
     textvistools     - contains the Text Visualization Toolbox
     funpartools      - contains the FunParTools toolbox
     probabilitytools - contains the ProbabilityTools toolbox

2. Compile SOM_PAK 3.1. 

   In unix (e.g., Mac OSX) or linux, all you should need to do is to
   1) start a terminal window 
   2) enter the folder 'textvistools/som_pak-3.1' 
   3) type 'make' and wait for all to compile without errors

   If you run into trouble, you need to work through SOM_PAK's
   installation instructions.

3. Within matlab go to the subfolder 'textvistools/topictoolbox'
   and execute the matlab command
	compilescripts
   This will compile all the scripts of the Topic Modeling Toolbox for
   your platform

   If you run into trouble, you need to work through the Topic
   Modeling Toolbox's installation instructions.

4. Within matlab go to the subfolder 'textvistools/example'

5. Add all subfolders of 'textvistools', 'funpartools', and
   'probabilitytools' to the matlab path.
   This can be done using the matlab commands
	  addpath(genpath('../../textvistools'));
	  addpath(genpath('../../funpartools'));
	  addpath(genpath('../../probabilitytools'));

   (You may want to include this command in your ~/matlab/startup.m
   file, but in that case you need to replace the top '..' by absolute
   paths)
	
6. run the example by executing the matlab command
       tvtExecute

A pre-generated set of outputs for this example are included in the folder
    textvistools/example/outputFiles/
The content of the various output files for the example is described in the
document
    textvistools/example/outputs_overview.rtf


Documentation for the TVT functions
-----------------------------------

One can get help on several of the key functions by typing the
following commands at the matlab prompt. These commands produce
reasonably detailed descriptions of all inputs and outputs of the
different scripts, including input/output file formats, and
parameters used by the different algorithms.

makedictfromtab help
makeTMT help
reduceTMT help
ldacol help
createSOM help
trainSOM help
createClassesFromMetadata help
cluster4SOM help
clusterTopics help

help extractDatePT
help extractDateUS
help myhkmeans
help validateDocument

[Note that for the first set of commands the keyword 'help' appears
AFTER the command name. That convention is used by the FunParTools
toolbox, which is used by those functions to process the input
parameters.]


% Copyright (C) 2010  Stacy & Joao Hespanha

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

