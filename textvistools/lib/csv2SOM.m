function csv2SOM(varargin)
% To get help, type survey2SOM('help')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Help
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'Help', {
        'This script essentially takes a data matrix in a .csv file'
        'and creates the files required by SOM_PAK to create a '
        'Self Organizing Map (SOM).'
        ' '
        'In the process, it also creates a set of tables that will be useful'
        'to process the SOM in ArcGIS.' 
        ' '
        'Specifically, this script performs the following actions:'
        '1) Reads the .csv file with the raw data'
        '   See input variable ''inputMatrix'''
        '2) If needed, normalizes the entries of the data matrix.'
        '   See input variables ''normalizeMatrix''.'
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
        'filename of a .csv file, used for read access (input)'
        'Matrix with data. The first row contains the column names'
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

%declareParameter(...
%    'VariableName','metaHeaders',...
%    'Description', {
%        'Cell array with the names of the metafields'
%                   });
declareParameter(...
    'VariableName','dataCols',...
    'Description', {
        'Headers of .csv file corresponding to the columns that'
        'contain the numeric data. All other columns are assumed'
        'to be metadata'
                   });
declareParameter(...
    'VariableName','nameCol',...
    'Description', {
        'Header of .csv file corresponding to the column that'
        'contains the name of the row'
                   });
declareParameter(...
    'VariableName','normalizeMatrix',...
    'DefaultValue',0,...
    'Description', {
        'when nonzero, every columns of the data matrix is normalized'
        'to have zero mean and unit standard deviation'
                   });
declareParameter(...
    'VariableName','nTrainingMatrices',...
    'DefaultValue',0,...
    'Description', {
        'Number of training matrices to generate.'
                   });


setParameters(varargin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load input matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dataSource=inputMatrix;

t0=clock;
fprintf('Loading data ''%s''...\n  ',inputMatrix);
%% Header row
fid=fopen(inputMatrix);

kName=[];
kData=[];
kMeta=[];
nameCols={};
metaHeaders={};
c=',';
header={};
i=0;
while c==','
    i=i+1;
    [str,c]=readCSVfields(fid,1);
    header{i}=str{1};
    %    fprintf('\theader{%d}=\"%s\", c=%d\n',i,header{i},c); 
    
    if strcmp(header{i},nameCol)
        kName=i;
    end
    if any(strcmp(header{i},dataCols))
        kData(end+1)=i;
        nameCols{end+1}=header{i};
    else
        kMeta(end+1)=i;
        metaHeaders{end+1}=header{i};
    end 
end

fprintf('%d fields... ',length(header));

if isempty(kName)
    error('csv2SOM: name field ''%s'' not found\n',nameCol)
end

if length(kData)~=length(dataCols)
    disp(nameCols)
    error('csv2SOM: only %d out of %d data fields found\n',length(kData),length(dataCols))
end

fprintf('%d data fields... ',length(kData))

%% Data

dataMatrix=zeros(0,length(kData));
nameDocs=cell(0);
metaDocs=cell(0,length(kMeta));
while 1 % loop over lines
        %    fprintf('Reading line %d\n',size(dataMatrix,1)+1);
    [str,c]=readCSVfields(fid,length(header));
    %    fprintf('\tstr{1}=\"%s\", c=%d ... str{%d}=\"%s\"\n',str{1},c,length(header),str{length(header)}); 
    
    if isempty(c)
        break;
    end
    
    dataMatrix(end+1,:)=str2double(str(kData));
    nameDocs(end+1,1)=str(kName);
    metaDocs(end+1,:)=str(kMeta);
    %    nameDocs(end)
    
    if any(isnan(dataMatrix(end,:)))
        fprintf('\n');
        warning('dataMatrix has NaN in row %d (row removed)\n',size(dataMatrix,1));
        disp(str(kData))
        disp(dataMatrix(end,:))
        dataMatrix(end,:)=[];
        nameDocs(end,:)=[];
        metaDocs(end,:)=[];
    end
    
end
fclose(fid);

fprintf('%d rows... done (%.1f sec)\n',size(dataMatrix,1),etime(clock,t0));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Normalize matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if normalizeMatrix
    if 0
        % set minimum to zero
        minCol=min(dataMatrix,[],1);
        dataMatrix=dataMatrix-ones(size(dataMatrix,1),1)*minCol;
        
        % set maximum to one
        maxCol=max(dataMatrix,[],1);
        dataMatrix=dataMatrix./(ones(size(dataMatrix,1),1)*maxCol);
    end
    
    % set mean to zero
    meanCol=mean(dataMatrix,1);
    dataMatrix=dataMatrix-ones(size(dataMatrix,1),1)*meanCol;

    % set std.dev. to 1
    stdCol=std(dataMatrix,1);
    dataMatrix=dataMatrix./(ones(size(dataMatrix,1),1)*stdCol);
    
    % verify if one got NaN (constant columns)
    k=find(any(isnan(dataMatrix),1));
    if ~isempty(k)
        fprintf('survey2SOM: %d columns out of %d are constant, removed\n',length(k),size(dataMatrix,2));
        dataMatrix(:,k)=[];
        nameCols(k)=[];
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Output matrices for SOM training with random row orders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:nTrainingMatrices
    filename=sprintf('%s+train%d',outputPrefix,i);
    fprintf('Saving SOM training data ''%s''\n',filename);
    [dummy,k]=sort(rand(size(dataMatrix,1),1));
    labels=cellstr(num2str(k));
    savematrix('outputPrefix',filename,...
               'dataMatrix',dataMatrix(k,:),...
               'labels',labels);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Output matrix for 1) SOM visualize documents
%%%                   2) ArcGIS document attributes table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Saving SOM visualize docs data ''%s''\n',outputPrefix);
labels=cellstr(num2str((1:size(dataMatrix,1))'));
savematrix('outputPrefix',outputPrefix,...
           'dataMatrix',dataMatrix,...
           'nameDocs',nameDocs,...
           'nameCols',nameCols,...
           'metaHeaders',metaHeaders,...
           'metaDocs',metaDocs,...
           'dataSource',dataSource,...
           'labels',labels);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run sompak
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%system('(cd ../mapping-code/;sompak_survey_training.sh)')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [str,c]=readCSVfields(fid,n)
% read 'n' csv fields into a cell the cell string 'str'
% also returns the character after last data read (to detect end of
% line)

str=cell(n,1);
for k=1:n % loop over records in one line
    str{k}=fscanf(fid,'%c',1);
    
    if isempty(str{k})
        str{k}='0';
        c='';
        break;
    end
    %    fprintf(' str{%d}=%d,',k,str{k});
    
    if str{k}=='"' % read until close "
        str{k}='';
        while 1 % loop until non quoted "
            C=textscan(fid,'%[^"]',1,'whitespace','','endofline','');
            if ~isempty(C{1})
                str{k}=[str{k},C{1}{1}];
            end
            C=textscan(fid,'"%c',1,'whitespace','','endofline','');
            if C{1}~='"'
                c=C{1};
                break;
            else
                str{k}=[str{k},'"'];
            end
        end
    elseif str{k}==',' | str{k}==10 | str{k}==13 % empty field
        c=str{k};
        str{k}='0';
    else % read until , or EOL
        C=textscan(fid,'%[^,\r\n]',1,'whitespace','','endofline','');
        %        C{1}
        if ~isempty(C{1})
            str{k}=[str{k},C{1}{1}];
        end
        c=fscanf(fid,'%c',1);
    end
    %        str{k}
end
