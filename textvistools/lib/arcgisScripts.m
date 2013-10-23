function arcgisScripts(varargin)
% To get help, type arcgisScripts('help')
%
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

declareParameter(...
    'Help', {
        'This script creates a set of ArcGIS scripts in python to import'
        'a SOM map into ArcGIS.'
        ' '
        'Specifically, this script performs the following actions:'
        '1) Creates a python ArcGIS script to create a geodatabase'
        '   with the following elements:'
        '   . shape files corresponding to the SOM (including'
        '     the documents'' and neurons'' positions)'
        '   . table with the documents'' metadata (including year)'
        '   . table with the topics'' words'
        '   . tables with the clustering results obatined from different'
        '      runs of cluster4SOM'
        ' '
        '   This script should be executed from outside ArcGIS.'
        '2) Creates a python ArcGIS script to create a set of layers'
        '   to visualize the corpus. These layers include:'
        '   . documents'' shape file joined with the metadata'
        '     table to visualize, e.g., the documents''s year.'
        '   . documents'' shape files joined with the different'
        '     clustering tables to visualize the clustering results.'
        '     One layer is create for each column in the clustering table'
        '     that contains useful data.'
        '   The layers created consist simply of the shape files joined'
        '   with the appropriate tables and they DO NOT include symbology'
        '   information, which has to be set manually. This means that,'
        '   aside from the name, all layers that join a shape file with'
        '   the same clustering table, actually have the same content.'
        ' '
        'This script should be executed from outside ArcGIS.'
            });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
declareParameter(...
    'VariableName','createSOMoutputPrefix',...
    'Description', {
        'Filename (with path) for the outputPrefix of the data files'
        'created by createSOM(). The pedigree corresponding to the'
        'files with this prefix will be the basis for creating the'
        'ArcGIS scripts. Specifically, the script will process all'
        '''children'' of the corresponding pedigree.' 
                   });
declareParameter(...
    'VariableName','outputPrefix',...
    'Description', {
        'Filename prefix for the following files:'
        '{outputPrefix}+database.py file for write access (output)'
        '     File containing the ArcGIS python script to create'
        '    the geodatabase.'
        '{outputPrefix}+layers.py file for write access (output)'
        '     File containing the ArcGIS python script to create'
        '     the layers.'
                   });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
declareParameter(...
    'VariableName','geodatabaseFolder',...
    'DefaultValue','.',...
    'Description', {
        'Folder where the geodatabase will be created. This path should'
        'interpreted relative to the folder where the python scripts run.'
                   });
declareParameter(...
    'VariableName','layersFolder',...
    'DefaultValue','.',...
    'Description', {
        'Folder where the layers will be created. The layers are actually'
        'grouped inside a folder within this folder. This path should'
        'interpreted relative to the folder where the python scripts run.'
                   });

setParameters(varargin);

%verboseLevel=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parse names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% get key formating parameters for filenames
[filename,pedigreeSuffix,dateFormat,basenameUniqueRegexp,timeStampFormat,pedigreeWildcard]=createPedigree();


S=regexp(createSOMoutputPrefix,'^(.*/|)([^/]+)$','tokens');

folder=S{1}{1};
createSOMbasename=S{1}{2};
createSOMpedigree=[createSOMbasename,pedigreeSuffix];

if isempty(folder)
    folder='./';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Looking for children of SOM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('arcgisScripts: Looking for relevant data files\n');

wildcard=sprintf(pedigreeWildcard,folder,'/*',pedigreeSuffix);
pedigrees=dir(wildcard);

[dataFiles,pedigreeFiles,goodNames]=getDataFiles(...
    pedigreeSuffix,{},{},{},...
    folder,createSOMpedigree);

for thisPedigree=1:length(pedigrees)
    thisName=[folder,pedigrees(thisPedigree).name];
    if verboseLevel
        fprintf('   analysing pedigree: %s\n',pedigrees(thisPedigree).name);
    end

    txt=fileread(thisName);
    found=strfind(txt,createSOMpedigree);
    if ~isempty(found)
        if verboseLevel
            fprintf('\t\tfound reference!\n');
        end
        [dataFiles,pedigreeFiles,goodNames]=getDataFiles(...
            pedigreeSuffix,dataFiles,pedigreeFiles,goodNames,...
            folder,pedigrees(thisPedigree).name);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Looking for SOM tables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Metadata
kMetadata=find(~cellfun('isempty',regexp(dataFiles,'+rowsmetadata.tab$','once')));
if length(kMetadata) ~= 1
    dataFiles
    kMetadata
    error('arcgisScripts: cannot find metadata file\n');
end

%% Topic names
kColsnames=find(~cellfun('isempty',regexp(dataFiles,'+colsnames.tab$','once')));
if length(kColsnames) ~= 1
    dataFiles
    kColsnames
    error('arcgisScripts: cannot find column names file\n');
end

%% documents shape file
kDocsShape=find(~cellfun('isempty',regexp(dataFiles,'+docs.shp$','once')));
if length(kDocsShape) < 1
    dataFiles
    kDocsShape
    error('arcgisScripts: cannot find documents shape file\n');
end

%% neurons shape file
kNeuronsShape=find(~cellfun('isempty',regexp(dataFiles,'+neurons.shp$','once')));
if length(kNeuronsShape) < 1
    dataFiles
    kNeuronsShape
    error('arcgisScripts: cannot find documents shape file\n');
end

%% cluster tables
kClusterTables=find(~cellfun('isempty',regexp(dataFiles,'\+(maxraw|maxnorm|kmeans|hkmeans|linkage|manual|superv)\+.*\.tab$','once')));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create geodatabase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

databaseScript=sprintf('%s+database.py',outputPrefix);

fout=fopen(databaseScript,'w');
fprintf(fout,'import arcgisscripting\n\n');
fprintf(fout,'gp = arcgisscripting.create()\ntry:\n');
fprintf(fout,'\tgp.toolbox = "management"\n');

%% Create geodatabase
fprintf('arcgisScripts: Creating geodatabase script\n');
%gdbName=regexprep(createSOMbasename,'^.*\+TS=','GDB+TS=');
gdbName=['GDB_',createSOMbasename];
fprintf(fout,'\tprint "Creating Geodatabase %s"\n',gdbName);
fprintf(fout,'\tgp.CreateFileGDB("%s","%s.gdb")\n',geodatabaseFolder,gdbName);
gdbName=sprintf('%s/%s.gdb',geodatabaseFolder,gdbName);

%% DocsShape table
for i=1:length(kDocsShape)
    fprintf('\tDocument Shape file\t= \"%s\"\n',dataFiles{kDocsShape(i)});
    if length(dataFiles{kDocsShape(i)})>63
        fprintf('\t\tFILENAME LARGER THAN 63 BYTES, EXPECT TROUBLE\n');
    end
    fprintf(fout,'\n\tprint "Importing Documents Shape ''%s_%d''"\n',goodNames{kDocsShape(i)},i);
    fprintf(fout,'\tgp.FeatureclassToFeatureclass_conversion("%s","%s","%s_%d")\n',...
            dataFiles{kDocsShape(i)},gdbName,goodNames{kDocsShape(i)},i);
end

%% NeuronsShape table
for i=1:length(kNeuronsShape)
    fprintf('\tNeurons Shape file\t= \"%s\"\n',dataFiles{kNeuronsShape(i)});
    if length(dataFiles{kNeuronsShape(i)})>63
        fprintf('\t\tFILENAME LARGER THAN 63 BYTES, EXPECT TROUBLE\n');
    end
    fprintf(fout,'\n\tprint "Importing Neurons Shape ''%s_%d''"\n',goodNames{kNeuronsShape(i)},i);
    fprintf(fout,'\tgp.FeatureclassToFeatureclass_conversion("%s","%s","%s_%d")\n',...
            dataFiles{kNeuronsShape(i)},gdbName,goodNames{kNeuronsShape(i)},i);
end

%% Metadata table
fprintf('\tMetadata table file\t= \"%s\"\n',dataFiles{kMetadata});
if length(dataFiles{kMetadata})>63
    fprintf('\t\tFILENAME LARGER THAN 63 BYTES, EXPECT TROUBLE\n');
end
fprintf(fout,'\n\tprint "Importing Metadata Table ''%s''"\n',goodNames{kMetadata});
fprintf(fout,'\tgp.TableToTable_conversion("%s","%s","%s")\n',...
        dataFiles{kMetadata},gdbName,goodNames{kMetadata});
fprintf(fout,'\tgp.addindex("%s/%s","rowID","rowID","UNIQUE")\n',...
        gdbName,goodNames{kMetadata});

%% Topics table
fprintf('\tTopics table file\t= \"%s\"\n',dataFiles{kColsnames});
if length(dataFiles{kColsnames})>63
    fprintf('\t\tFILENAME LARGER THAN 63 BYTES, EXPECT TROUBLE\n');
end
fprintf(fout,'\n\tprint "Importing Topics Table ''%s''"\n',goodNames{kColsnames});
fprintf(fout,'\tgp.TableToTable_conversion("%s","%s","%s")\n',...
        dataFiles{kColsnames},gdbName,goodNames{kColsnames});
fprintf(fout,'\tgp.addindex("%s/%s","columnID","columnID","UNIQUE")\n',...
        gdbName,goodNames{kColsnames});

%% Clustering tables
for i=1:length(kClusterTables)
    %% Make sure it is a documents table with a rowID field for index & join
    %dataFiles{kClusterTables(i)}
    ftest=fopen(sprintf('%s/%s',folder,dataFiles{kClusterTables(i)}),'r');
    header=fgetl(ftest);
    fclose(ftest);
    if isempty(regexp(header,'(^|\t)rowID(\t|$)','once'))
        kClusterTables(i)=0;
        continue;
    end
    
    fprintf('\tClustering table file [%d]\t= \"%s\"\n',i,dataFiles{kClusterTables(i)});
    if length(dataFiles{kClusterTables(i)})>63
        fprintf('\t\tFILENAME LARGER THAN 63 BYTES, EXPECT TROUBLE\n');
    end
    fprintf(fout,'\n\tprint "Importing Clustering Table ''%s''"\n',goodNames{kClusterTables(i)});
    fprintf(fout,'\tgp.TableToTable_conversion("%s","%s","%s")\n',...
            dataFiles{kClusterTables(i)},gdbName,goodNames{kClusterTables(i)});
    fprintf(fout,'\tgp.addindex("%s/%s","rowID","rowID","UNIQUE")\n',...
            gdbName,goodNames{kClusterTables(i)});
end

kClusterTables=kClusterTables(kClusterTables>0);

fprintf(fout,'except:\n\tprint gp.GetMessages()\n');

fprintf(fout,'\nprint "Done Creating Geodatabase"\n');

fclose(fout);

if verboseLevel>0
    fprintf('arcgisScript: Create Geodatabase Script\n')
    fprintf('\n################### start here ###################\n')
    type(databaseScript)
    fprintf('###################  end here  ###################\n\n')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create layers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

layersScript=sprintf('%s+layers.py',outputPrefix);

fout=fopen(layersScript,'w');
fprintf(fout,'import os\n');
fprintf(fout,'import arcgisscripting\n\n');
fprintf(fout,'gp = arcgisscripting.create()\ntry:\n');

%% Create layers folder
%layersFolderName=regexprep(createSOMbasename,'^.*\+TS=','layers+TS=');
layersFolderName=['Layers_',createSOMbasename];
fprintf(fout,'\n\tprint "Creating folder ''%s/%s''"\n',layersFolder,layersFolderName);
fprintf(fout,'\tos.makedirs(\"%s/%s\")\n',layersFolder,layersFolderName);

%% Document year layer
for l=1:length(kDocsShape)
    if length(kDocsShape)==1
        layerName='Document Year';
    else
        layerName=sprintf('Document Year %d',l);
    end
    fprintf(fout,'\n\tprint "Creating Layer ''%s''"\n',layerName);
    fprintf(fout,'\tgp.MakeFeatureLayer("%s/%s_%d","%s")\n',...
            gdbName,goodNames{kDocsShape(l)},l,layerName);
    fprintf(fout,'\tgp.AddJoin("%s","PointID","%s/%s","rowID","KEEP_ALL")\n',...
            layerName,gdbName,goodNames{kMetadata});
    fprintf(fout,'\tgp.SaveToLayerFile_management("%s","%s/%s/%s")\n',...
            layerName,layersFolder,layersFolderName,layerName);
end

%% Clustering layers
for i=1:length(kClusterTables)
    % get headers
    fin=fopen([folder,'/',dataFiles{kClusterTables(i)}],'r');
    header=fgetl(fin);
    fclose(fin);
    header=regexp(header,'([^\t]*)','tokens');

    for j=2:length(header)-1
        for l=1:length(kDocsShape)
            if length(kDocsShape)==1
                layerName=sprintf('%s-%s',goodNames{kClusterTables(i)},header{j}{1});
            else
                layerName=sprintf('%s-%s %d',goodNames{kClusterTables(i)},header{j}{1},l);
            end
            fprintf(fout,'\n\tprint "Creating Clustering Layer ''%s''"\n',layerName);
            fprintf(fout,'\tgp.MakeFeatureLayer("%s/%s_%d","%s")\n',...
                    gdbName,goodNames{kDocsShape(l)},l,layerName);
            fprintf(fout,'\tgp.AddJoin("%s","PointID","%s/%s","rowID","KEEP_ALL")\n',...
                    layerName,gdbName,goodNames{kClusterTables(i)});
            fprintf(fout,'\tgp.SaveToLayerFile_management("%s","%s/%s/%s")\n',...
                    layerName,layersFolder,layersFolderName,layerName);
        end
    end
end

fprintf(fout,'except:\n\tprint gp.GetMessages()\n');
fprintf(fout,'\nprint "Done Creating Layers"\n');

fclose(fout);

if verboseLevel>0
    fprintf('arcgisScript: Layers Script\n')
    fprintf('\n################### start here ###################\n')
    type(layersScript)
    fprintf('###################  end here  ###################\n\n')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Auxiliary functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [dataFiles,pedigreeFiles,goodNames]=getDataFiles(...
    pedigreeSuffix,dataFiles,pedigreeFiles,goodNames,...
    pedigreePath,pedigreeName)

verboseLevel=0;
    
if verboseLevel>0
        fprintf('Looking for data of ''%s''\n',pedigreeName);
end
    
%% add data files
thisWildcard=regexprep(pedigreeName,[pedigreeSuffix,'$'],'*');
matchFiles=dir([pedigreePath,thisWildcard]);
for i=1:length(matchFiles)
    thisName=[pedigreePath,matchFiles(i).name];
    if strcmp(matchFiles(i).name,pedigreeName) 
        %            fprintf('   same (ignored)\n');
        continue;
    end
    fprintf('         data file: ''%s''\n',matchFiles(i).name)
    pedigreeFiles(end+1,1)={pedigreeName};
    dataFiles(end+1,1)={matchFiles(i).name};
    goodNames(end+1,1)={goodName(dataFiles{end},[pedigreePath,pedigreeFiles{end}])};
end

function goodName=goodName(fileName,pedigreeName)

%% ATTENTION: 
%% For tables, goodName is used to create the table name and therefore cannot
%%            contain space or any other punctuation other than [a-zA-Z0-9_]
%% For clusters, goodName is used to create the layer name and therefore
%%            can contain more characters.
ID=regexp(fileName,'TS=([\d-]*)','tokens');ID=ID{1}{1};
ID=regexprep(ID,'[=-]','_');
if ~isempty(regexp(fileName,'+rowsmetadata\.tab$'))
    % documents metadata
    goodName=sprintf('Metadata_%s',ID);
elseif ~isempty(regexp(fileName,'+colsnames\.tab$'))
    % topic names
    goodName=sprintf('Topics_%s',ID);
elseif ~isempty(regexp(fileName,'+docs\.shp$'))
    % documents shape
    goodName=sprintf('Documents_%s',ID);
elseif ~isempty(regexp(fileName,'+neurons\.shp$'))
    % neurons shape
    goodName=sprintf('Neurons_%s',ID);
elseif ~isempty(regexp(fileName,'\+(maxraw|maxnorm|kmeans|hkmeans|linkage|manual|superv)\+.*\.tab$'))

    % fileName

    % clustering method
    txt=fileread(pedigreeName);
    
    % get key parameters
    clusterMethod=regexp(txt,'<LI><EM>clusterMethod *</EM> = "([^"]*)"<BR>','tokens','once');
    classifierType=regexp(txt,'<LI><EM>classifierType *</EM> = "([^"]*)"<BR>','tokens','once');
    trainingFile=regexp(txt,'<LI><EM>trainingFile *</EM> = ("([^"]*)"|[empty string)<BR>','tokens','once');
    zeroMeanTopics=regexp(txt,'<LI><EM>zeroMeanTopics *</EM> = *([\d.]*) *<BR>','tokens','once');
    dimPCA=regexp(txt,'<LI><EM>dimPCA *</EM> = *(([\d.]*)|Inf) *<BR>','tokens','once');
    topics2exclude=regexp(txt,'<LI><EM>topics2exclude *</EM> = ("([^"]*)"|[empty string)<BR>','tokens','once');
    nClusters=regexp(fileName,'\+(maxraw|maxnorm|kmeans|hkmeans|linkage|manual|superv)\+([^\.]+)\.tab$','tokens','once');
    
    % correct for missing parameters
    if isempty(classifierType)
        classifierType={'unknown'};
    end
    if isempty(trainingFile)
        trainingFile={'unknown'};
    end
    % remove extension
    trainingFile={regexprep(trainingFile{1},'\.[^\.]*$','')};
    % remove path
    trainingFile={regexprep(trainingFile{1},'^.*/','')};
    if isempty(zeroMeanTopics)
        zeroMeanTopics={'unknown'};
    end
    if isempty(dimPCA)
        dimPCA={'unknown'};
    end
    if isempty(topics2exclude)
        topics2exclude={'unknown'};
    end
    
   if strcmp(clusterMethod,'supervised')
       goodName=sprintf('sup_%s_zm_%s_dim_%s_train_%s_%s',...
                        classifierType{1},zeroMeanTopics{1},dimPCA{1},trainingFile{1},ID);
   else
       goodName=sprintf('%s_nClus_%s_%s',...
                        clusterMethod{1},nClusters{2},ID);
   end                 
else
    goodName=regexprep(fileName,'\.[^\.]+$','');
end
%goodName