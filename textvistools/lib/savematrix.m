function savematrix(varargin);
% To get help, type savematrix('help')
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
        'Saves matrix (.txt) with one document per row and one "feature"' 
        'per column for visualization by sompak.'
        ''
        'Document attributes (name & meta data) and column attributes'
        '(names) are saved as attribute tables in a ArcGIS-friendly'
        'format (.tab)'
            });
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        '{outputPrefix}.txt file for write access (output)'
        '     Matrix ''dataMatrix'' in a tab-separated format readable'
        '     by som_pack:'
        '     1) The first row contains the number of columns'
        '       (i.e., number of topics)'
        '     2) Each subsequent row corresponds to one document, and contains'
        '        the weights of the different topics on different columns.'
        '        The last column of each row contains a document label.'
        '     To be used by SOM_PAK''s ''vsom'' and ''visual'' to train'
        '     and calibrate the SOM.'
        '{outputPrefix}+rowsmetadata.tab file for write access (output)'
        '     Table with document names and metadata:'
        '        1st row - field names (header)'
        '        1st column - document ID number (field: rowID)'
        '        2nd column - document name (field: rowName)'
        '        3rd-5th columns - document year, month, day'
        '        6th ... columns - document metadata fields'
        '     This file is reable by ArcGIS as a table and the first'
        '     field can be used to establish a link with the documents in'
        '     a shape file.'
        '{outputPrefix}+colsnames.tab file for write access (output)'
        '     Table with topic words:'
        '        1st row - field names (header)'
        '        1st column - topic ID number (field: columnID)'
        '        2nd column - topics top words (field: columnName)'
        '     This file is reable by ArcGIS as a table.'
                   });
declareParameter(...
    'VariableName','extractDateScript',...
    'DefaultValue','',...
    'Description', {
        'Matlab function of the form'
        '  yyyymmdd=extractDate(dates)'
        'that extracts dates from a cell array of strings'
        'yyyymmdd is a numeric array with one row per document'
        'and three columna: year (from 1950 to 2020),'
        '                   month (from 1 to 12), and'
        '                   day (from 1 to 31)'
        'The value -1 should inserted when it is not possible to'
        'determine the year, month, or day.'
        'Typically ''extractDateScript'' should be set to'
        '''extractDateUS'' or ''extractDatePT''' 
                   });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','dataMatrix',...
    'DefaultValue','',...
    'Description', {
        'Numeric NxM data matrix used to train the SOM'
        '(one document per row, one feature per column)'
                   });
declareParameter(...
    'VariableName','nameCols',...
    'DefaultValue','',...
    'Description', {
        'Cell M vector of strings with the column names'
                   });
declareParameter(...
    'VariableName','nameDocs',...
    'DefaultValue','',...
    'Description', {
        'Cell N vector of strings with the row names'
                   });
declareParameter(...
    'VariableName','metaDocs',...
    'DefaultValue','',...
    'Description', {
        'Cell NxK array of strings with the a K vector of metadata for each row'
                   });
declareParameter(...
    'VariableName','dataSource',...
    'DefaultValue','',...
    'Description', {
        'Variable containing a description of the data. It is saved'
        '"as is" in the .mat file'
                   });
declareParameter(...
    'VariableName','labels',...
    'DefaultValue','',...
    'Description', {
        'Cell N vector of strings used to label each row of the .txt'
        'These labels are recognized by SOM_PAK'
                   });
declareParameter(...
    'VariableName','metaHeaders',...
    'DefaultValue','',...
    'Description', {
        'Cell K vector of strings with the names of each metadata field'
                   });
declareParameter(...
    'VariableName','dateHeader',...
    'DefaultValue','',...
    'Description', {
        'Index of the metafield that contains the date of the row'
                   });

setParameters(varargin);

if ~isempty(dateHeader)
    extractDate=str2func(extractDateScript);
end

if isempty(labels)
    % if no labels in argin, use the row number
    labels=cellstr(num2str((1:size(dataMatrix,1))'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save all (.mat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(nameCols) && ~isempty(metaDocs) && ~isempty(nameDocs)
    save(sprintf('%s.mat',outputPrefix),...%'-v7.3',...
       'dataMatrix','nameCols','metaDocs','nameDocs','dataSource','metaHeaders')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save dataMatrix (.txt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(dataMatrix)
    k=isnan(dataMatrix);
    
    if any(k(:))
        warning(['savematrix: %d NaN values in data matrix when saving ' ...
                 'file ''%s'', ''x'' written in matrix file\n'],full(sum(k(:))),outputPrefix);
    end
    
    fid=fopen(sprintf('%s.txt',outputPrefix),'w');
    fprintf(fid,'%d\n',size(dataMatrix,2));
    for i=1:size(dataMatrix,1)
        if any(isnan(dataMatrix(i,:)))
            for j=1:size(dataMatrix,2)
                if isnan(dataMatrix(i,j))
                    fprintf(fid,'x\t');
                else
                    fprintf(fid,'%f\t',dataMatrix(i,j));
                end
            end
        else
            fprintf(fid,'%f\t',full(dataMatrix(i,:)));
        end
        fprintf(fid,'%s\n',labels{i});
    end
    fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save metadata (.tab)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(metaDocs)
    
    if ~isempty(dateHeader)
        kDate=find(strcmp(dateHeader,metaHeaders));
        if ~isempty(kDate)
            yyyymmdd=extractDate(metaDocs(:,kDate));
        end
    else
        kDate=[];
    end
    
    fid=fopen(sprintf('%s+rowsmetadata.tab',outputPrefix),'w');
    % print header
    if isempty(kDate)
        fprintf(fid,'rowID\trowName');
    else
        fprintf(fid,'rowID\trowName\tyear\tmonth\tday');
    end
    for j=1:length(metaHeaders)
        % remove dangerous characters
        metaHeaders{j}=regexprep(metaHeaders{j},'[^a-zA-Z0-9_]','');
        fprintf(fid,'\t%s',metaHeaders{j});
    end
    fprintf(fid,'\n');
    % print data
    for i=1:size(metaDocs,1)
        % print metadata
        if isempty(kDate)
            fprintf(fid,'%d\t%s',i,nameDocs{i});
        else
            fprintf(fid,'%d\t%s\t%d\t%d\t%d',i,nameDocs{i},...
                    yyyymmdd(i,1),yyyymmdd(i,2),yyyymmdd(i,3));
        end
        for j=1:size(metaDocs,2) 
            % no more than 250 char per field for ArcGIS
            % and replace " by ;'
            txt=regexprep(metaDocs{i,j}(1:min(end,250)),'"','''');
            fprintf(fid,'\t%s',txt);
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save column names (.tab)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(nameCols)
    fid=fopen(sprintf('%s+colsnames.tab',outputPrefix),'w');
    % print header
    fprintf(fid,'columnID\tcolumnName\n');
    % print data
    for i=1:length(nameCols)
        % no more than 250 char per field for ArcGIS
        % and replace " by ;'
        txt=regexprep(nameCols{i}(1:min(end,250)),'"','''');
        fprintf(fid,'%d\t%s\n',i,txt);
    end
    fclose(fid);
end
