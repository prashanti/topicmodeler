function createSOM(varargin)
% To get help, type createSOM('help')
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
        'This script essentially takes the data matrix created by ''ldacol,'''
        'which encodes the topic weigths for each documents and creates'
        'the files required by SOM_PAK to create a Self Organizing Map (SOM).'
        ' '
        'In the process, it also creates a set of tables that will be useful'
        'to process the SOM in ArcGIS.' 
        ' '
        'Specifically, this script performs the following actions:'
        '1) Reads the .mat file produced by ldacol containing the'
        '   results of the TMT analysis.'
        '   See input variable ''inputMatrix'''
        '2) Excludes a set of documents specified by an input file.'
        '   See input variables ''docs2exclude''.'
        '3) Excludes a set of topics specified by an input file.'
        '   See input variables ''cols2exclude''.'
        '4) Creates a set of .txt files to create a SOM using SOM_PAK'
        '   See input parameters ''outputPrefix.'''
        '5) Creates a set of tables (.tab) to facilitate displaying' 
        '   the SOM in ArcGIS.'
        '   See input parameter ''outputPrefix.'''
            });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','inputMatrix',...
    'Description', {
        'Filename for a .mat file, used for read access (input)'
        'Output of ''ldacol'' containing:'
        '1) Matrix ''dataMatrix'' with the topic weights for each document'
        '   (one document per row, one topic per column)'
        '2) Cell vector ''nameDocs'' with documents names in the'
        '   form xxxx(99) where'
        '   ''xxxx'' represents the name of the .tab (raw) file'
        '            ontaining the document'
        '   ''99''   represents the order of the document within'
        '            that file'
        '3) Cell vector ''nameCols'' with topic descriptions '
        '   (i.e., the top words in each topic)'
        '4) Cell array ''metaDocs'' with the documents metadata'
        '   (one document per row, one metadata field per column)'
                   });
declareParameter(...
    'VariableName','docs2exclude',...
    'DefaultValue','',...
    'Description', {
        'Filename of a .tab file, used for read access (input)'
        'Tab-separated file with document names to exclude from the'
        'input matrix:'
        '   1st row = header (ignored)'
        '   1st column = document filename'
        'When empty, no documents will be excluded.'
                   });
declareParameter(...
    'VariableName','cols2exclude',...
    'DefaultValue','',...
    'Description', {
        'Filename of a .tab file, used for read access (input)'
        'Tab-separated file with indices of the topics to exclude from'
        'the input matrix:'
        '   1st row = header (ignored)'
        '   1st column = topic index (starting at 1)'
        'When empty, no topics will be excluded.'
                   });
declareParameter(...
    'VariableName','outputPrefix',...
    'Description', {
        'Filename prefix for the following files:'
        '{outputPrefix}.mat file for write access (output)'
        '     File containing:'
        '     1) Matrix ''dataMatrix'' with the topic weights for each'
        '         document (one document per row, one topic per column).'
        '     2) Cell vector ''nameDocs'' with documents names in the'
        '        form xxxx(99) where'
        '        ''xxxx'' represents the name of the .tab (raw) file'
        '                 ontaining the document'
        '        ''99''   represents the order of the document within'
        '                 that file'
        '     3) Cell vector ''nameCols'' with topic descriptions '
        '        (i.e., the top words in each topic).'
        '     4) Cell array ''metaDocs'' with the documents metadata'
        '        (one document per row, one metadata field per column).'
        '{outputPrefix}+train=*.txt file for write access (output)'
        '     Files containing versions of the matrix ''dataMatrix'' in a'
        '     tab-separated format readble by SOM_PAK:'
        '     1) The first row contains the number of columns'
        '        (i.e., number of topics)'
        '     2) Each subsequent row corresponds to one document, and contains'
        '        the weights of the different topics on different columns.'
        '        The last column of each row contains a unique document ID'
        '        number (essentially reflecting the document order in'
        '        the input matrix).'
        '     These files are used by SOM_PAK''s ''vsom'' to train the SOM.'
        '     The different versions of the matrix in each file produced'
        '     differ only by the order in which the documents appear.'
        '     The construction of these multiple training files permits'
        '     running ''vsom'' multiple times with different document orders.'
        '     The number of training files produced is determined by'
        '     the input variable ''nTrainingMatrices.'''
        '{outputPrefix}.txt file for write access (output)'
        '     Matrix ''dataMatrix'' in a tab-separated format readable'
        '     by som_pack:'
        '     1) The first row contains the number of columns'
        '       (i.e., number of topics)'
        '     2) Each subsequent row corresponds to one document, and contains'
        '        the weights of the different topics on different columns.'
        '        The last column of each row contains a unique document ID'
        '        number (essentially reflecting the document order in'
        '        the input matrix).'
        '      This file is used by SOM_PAK''s ''visual'' to calibrate the SOM.'
        '{outputPrefix}+rowsmetadata.tab file for write access (output)'
        '     Table with document names and metadata:'
        '        1st row - field names (header)'
        '        1st column - document ID number (field: rowID)'
        '        2nd column - document name (field: rowName)'
        '        3rd-5th columns - document year, month, day'
        '        6th ... columns - document metadata fields'
        '     This file is readable by ArcGIS as a table and the first'
        '     field can be used to join this table with the objects'
        '     representing documents in a shape file.'
        '{outputPrefix}+colsnames.tab file for write access (output)'
        '     Table with the top words for each topic:'
        '        1st row - field names (header)'
        '        1st column - topic ID number (field: columnID)'
        '        2nd column - topics top words (field: columnName)'
        '     This file is readable by ArcGIS as a table and can be used'
        '     used to join topics with ArcGIS objects.'
                   });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','metaHeaders',...
    'Description', {
        'Cell K vector of strings with the names of each metadata field'
                   });
declareParameter(...
    'VariableName','minSumCols',...
    'DefaultValue',0.2,...
    'Description', {
        'Minimum value for the sum of all columns. Documents'
        'whose columns sum to a value below this are excluded'
                   });

declareParameter(...
    'VariableName','nTrainingMatrices',...
    'DefaultValue',0,...
    'Description', {
        'Number of training matrices to generate.'
                   });

setParameters(varargin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t0=clock;
fprintf('Loading data ''%s''... ',inputMatrix);
load(inputMatrix,'dataMatrix','nameCols','nameDocs','metaDocs');
fprintf('done (%f sec)\n',etime(clock,t0));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Exclude columns (by index)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(cols2exclude)
    excludedCols=textread(cols2exclude,'%d%*q','headerlines',1,'delimiter',',\t');
    fprintf('Removing %d columns out of %d (added to metadata)\n',length(excludedCols),size(dataMatrix,2))

    % add cols2remove to metadata
    %    size(metaHeaders)
    %    size(metaDocs)
    metaHeaders=[metaHeaders;cellstr(num2str(excludedCols,'TopicExcluded%03d'))];
    dataStr=sprintf('%f\t',dataMatrix(:,excludedCols));
    dataStr=regexp(dataStr,'\t','split');dataStr=dataStr(1:end-1);
    dataStr=reshape(dataStr,size(dataMatrix,1),length(excludedCols));

    %dataMatrix(1:10,excludedCols(1:5))
    %dataStr(1:10,1:5)
    
    metaDocs=[metaDocs,dataStr];
    clear dataStr
    
    %size(metaHeaders)
    %size(metaDocs)

    % exclude columns
    dataMatrix(:,excludedCols)=[];
    nameCols(excludedCols,:)=[];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Remove documents (by name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(docs2exclude)
    docName=textread(docs2exclude,'%s%*q','headerlines',1,'delimiter',',\t');
    fprintf('Read %d document names to exclude\n',length(docName))
    
    kExclude=zeros(length(docName));
    
    for i=1:length(docName)
        C=regexp(docName{i},'([a-z]*/[A-Za-z&0-9_-]*)(\.\w\w\w)?','tokens');
        filename=C{1}{1};
        
        docN=find(strcmp(filename,nameDocs));
        
        if length(docN)~=1
            warning('error finding document ''%s''\n',docName{i});
            fprintf(fid,'error finding document ''%s''\n',docName{i});
        else
            kExclude(i)=docN;
        end
        
    end
    
    fprintf('%d out of %d documents have been excluded - will be ignored\n',length(kExclude),size(dataMatrix,1));
    for i=1:length(kExclude)
        disp(nameDocs{kExclude(i)})
    end
    fprintf('\n');
    
    dataMatrix(kExclude,:)=[];
    nameDocs(kExclude)=[];
    metaDocs(kExclude,:)=[];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Remove documents with NaN values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

kNaN=find(all(~isnan(dataMatrix),2));

fprintf('%d out of %d documents have NaN counts - will be ignored\n',size(dataMatrix,1)-length(kNaN),size(dataMatrix,1));

dataMatrix=dataMatrix(kNaN,:);
nameDocs=nameDocs(kNaN);
metaDocs=metaDocs(kNaN,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Remove documents with low sum over the columns
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

kLow=find(sum(dataMatrix,2)>=minSumCols);

fprintf('%d out of %d documents have low sum over their columns - will be ignored\n',size(dataMatrix,1)-length(kLow),size(dataMatrix,1));

dataMatrix=dataMatrix(kLow,:);
nameDocs=nameDocs(kLow);
metaDocs=metaDocs(kLow,:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Output matrices for SOM training with random row orders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:nTrainingMatrices
    filename=sprintf('%s+train%d',outputPrefix,i);
    fprintf('Saving SOM training data ''%s''\n',filename);
    [dummy,k]=sort(rand(size(dataMatrix,1),1));
    labels=cellstr(num2str(k));
    savematrix('parametersMfile',parametersMfile,...
               'outputPrefix',filename,...
               'dataMatrix',dataMatrix(k,:),...
               'labels',labels);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Output matrix for 1) SOM visualize documents
%%%                   2) ArcGIS document attributes table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Saving SOM visualize docs data ''%s''\n',outputPrefix);
labels=cellstr(num2str((1:size(dataMatrix,1))'));
savematrix('parametersMfile',parametersMfile,...
           'outputPrefix',outputPrefix,...
           'dataMatrix',dataMatrix,...
           'nameDocs',nameDocs,...
           'nameCols',nameCols,...
           'metaHeaders',metaHeaders,...
           'metaDocs',metaDocs,...
           'dataSource',inputMatrix,...
           'labels',labels);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run sompak
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%system('(cd ../mapping-code/;sompak_docs_training.sh)')

