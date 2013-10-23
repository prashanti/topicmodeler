function makedictfromtab(varargin);
% To get help, type makedictfromtab('help')
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
        'This script essentially transforms the raw documents ' 
        '(encoded as strings of characters) into stream of numbers.'
        'The mapping between numbers and words is defined by a'
        'dictionary that this functions creates/updates.'
        ' '
        'Specifically, this script performs the following actions:'
        '1) Reads an input file containing the raw text and'
        '   metadata corresponding to several documents.'
        '   See input variable ''inputText'' regarding the format'
        '   of the input data file.'
        '2) Performs apply a set of substitutions rules to the'
        '   raw text. These rules can be used to remove common'
        '   irrelevant phrases, replace dates and/or numbers'
        '   by special markers, etc.'
        '   See input variable ''substitutionsScript'' for details.'
        '3) Perform some basic validation of the raw data, such'
        '   as detecting missing metadata fields, wrong formats'
        '   for date fields, etc.'
        '   See input variable ''validationScript'' for details.'
        '4) Breaks each text sentence into words by using the following'
        '   characters as word-delimiters '' .,:;"()?!'''
        '5) Searches each word in dictionary and replaces it by'
        '   a unique numerical identifier for the word. The '
        '   resulting streams of numbers representing the text'
        '   are saved in a .mat file. This file also contains the'
        '   documents metadata in their raw format.'
            });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','inputText',...
    'Description', {
        'Filename for a .tab file, used for read access (input)'
        'Tab-separated file with one row per document and'
        'one column per document field. One or more fields contain'
        'text and the remaining columns metadata about the document'
                   });
declareParameter(...
    'VariableName','endOfSentenceWord',...
    'DefaultValue','LiNeBrEaK',...
    'Description', {
        'Word that marks the end of a sentence'
                   });
declareParameter(...
    'VariableName','substitutionsScript',...
    'Description', {
        'Matlab function that returns an Nx2 cell array with a list'
        'of N regexp substitutions to be applied to each document.'
        'The first columns containst the regexp to be replaced'
        'and the second column the new string (following the rules'
        'of regexprep'
                   });
declareParameter(...
    'VariableName','validationScript',...
    'DefaultValue','validateDocument',...
    'Description', {
        'Matlab function of the form'
        '  [err,diagnosis]=validateDocument(metadata,dates,data,allHeaders,allDoc,extractDate)'
        'that checks if document''s metadata fields are valid'
        'The input to the function includes cell arrays with:'
        '  1) the metadata fields pointed by metaHeaders'
        '  2) the metadata fields pointed by dateHeaders'
        '  3) the metadata fields pointed by dataHeaders'
        '  4) the collection of all metadata fields'
        'and'
        '  5) handle to a function that extracts dates from a'
        '     metafield, such as ''extractDateUS'' or ''extractDatePT'''
        'In case an error is detected, it returns err=true and a ' 
        '''\n''-terminated string ''diagnosis'' that explains the error(s).'
        'In case of multiple errors, ''diagnosis'' should'
        'describe one error per line.'
        'Typically points to the default validation script ''validateDocument'''
                   });
declareParameter(...
    'VariableName','extractDateScript',...
    'DefaultValue','extractDateUS',...
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
declareParameter(...
    'VariableName','dicName',...
    'Description', {
        'Filename for a .txt file, used for read/write access (input/output)'
        'Dictionary used to convert words to numbers. The dictionary'
        'is a tab-separated file with:'
        '   1st row contains the date and time the dictionary was created'
        '   Each subsequent row corresponds to one word and contains'
        '   3 columns:'
        '      1st column - word'
        '      2nd column - unique numerical identifier for the word'
        '      3rd column - # of time the word appears in the corpus'
        'If no file exists with the given filename, a new (empty)'
        'dictionary is created before processing the new data.'
                   });
declareParameter(...
    'VariableName','outputMatlab',...
    'Description', {
        'Filename for a .mat file, used for write access (output)'
        'Matlab file with documents'' text converted to numbers and'
        'the documents'' metadata (in raw format).'
                   });
declareParameter(...
    'VariableName','logFile',...
    'Description', {
        'Filename for a .tab file, used for write access (output, append)'
        'Log of warnings (tab-separated)'
                   });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','dataHeaders',...
    'Description', {
        'Cell array with the names of the metafields'
        '(column header from .tab input file)'
        'that contain the text (will be merged)'
                   });
declareParameter(...
    'VariableName','metaHeaders',...
    'Description', {
        'Cell array with the names of the metafields'
        '(column headers from .tab input file)'
        'that should be included in the .mat output file'
                   });
declareParameter(...
    'VariableName','dateHeaders',...
    'Description', {
        'Cell array with the names of the metafields'
        '(column headers from .tab input file)'
        'that corresponds to dates'
                   });
declareParameter(...
    'VariableName','maxDocs',...
    'DefaultValue',inf,...
    'Description', {
        'Maximum number of documents to process per file (can be Inf)'
        'Used in debugging to speed up processing of each file'
                   });
declareParameter(...
    'VariableName','maxLength',...
    'DefaultValue',1000000,...
    'Description', {
        'Maximum number of characters per document'
                   });
declareParameter(...
    'VariableName','stemmer',...
    'DefaultValue',0,...
    'Description', {
        'Use Stemmer? (1 -yes, 0 - no)'
                   });

setParameters(varargin);

extractDate=str2func(extractDateScript);

% to be recognized as variables by parfor 
stemmer=stemmer+0;
maxLength=maxLength+0;
inputText=[inputText,''];

ferr=fopen(logFile,'a');

% profile ?
profile_code=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Scripts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

substitutionsScript=str2func(substitutionsScript);
substitutions=substitutionsScript();
if ~isempty(validationScript)
    validationScript=str2func(validationScript);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read & Sort dictonary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[dicWords,dicNdx,nextNdx,dicCount,dicVersion...%,dicHash
                                            ]=readDictionary(dicName);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%if ~isdeployed()
%  profile off
%end

%if profile_code && ~isdeployed()
%  profile clear
%  profile -detail builtin on
%end

files=dir(inputText);

t0=clock;
fprintf('Reading file %s (%6.0fKB)\n',inputText,files(1).bytes/1000);

% open text file
fin =fopen(inputText);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read headers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% read headers
allHeaders=fgets(fin);
allHeaders=textscan(allHeaders,'%s','BufSize',maxLength,'Delimiter','\t');
allHeaders=allHeaders{1};

%% find data fields
dataFields=zeros(1,length(dataHeaders));
dataMask=false(1,length(dataHeaders));
for i=1:length(dataHeaders)
    k=strmatch(dataHeaders{i},allHeaders,'exact');
    if isempty(k)
        fprintf('makedictfromtab: datadata field ''%s'' not found\n',dataHeaders{i});
        fprintf(ferr,'%s\tmakedictfromtab:\t%s\tdata field not found\t%s\n',...
                datestr(now),inputText,dataHeaders{i});
        dataMask(i)=true;
        k=1;
    end
    dataFields(i)=k;
end
%dataFields
%dataMask
dataFields=dataFields(~dataMask);
if isempty(dataFields)
    allHeaders
    error('makedictfromtab: no text field found\n')
end

%% find relevant metafields
metaFields=zeros(1,length(metaHeaders));
metaMask=false(1,length(metaHeaders));
for i=1:length(metaHeaders)
    k=strmatch(metaHeaders{i},allHeaders,'exact');
    if isempty(k)
        fprintf('makedictfromtab: metadata field ''%s'' not found\n',metaHeaders{i});
        fprintf(ferr,'%s\tmakedictfromtab:\t%s\tmetadata field not found\t%s\n',...
                datestr(now),inputText,metaHeaders{i});
        metaMask(i)=true;
        k=1;
    end
    metaFields(i)=k;
end
%metaFields
%metaMask

%% find date fields
dateFields=zeros(1,length(dateHeaders));
dateMask=false(1,length(dateHeaders));
for i=1:length(dateHeaders)
    k=strmatch(dateHeaders{i},allHeaders,'exact');
    if isempty(k)
        fprintf('makedictfromtab: date field ''%s'' not found\n',dateHeaders{i});
        fprintf(ferr,'%s\tmakedictfromtab:\t%s\n\tmetadata field not found\t%s\n',...
                datestr(now),inputText,dateHeaders{i});
        dateMask(i)=true;
        k=1;
    end
    dateFields(i)=k;
end
%dateFields
%dateMask

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read all file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

docFormat=char(kron(ones(1,length(allHeaders)),'%s'));

if isfinite(maxDocs)
    allFile=textscan(fin,docFormat,maxDocs,...
                     'BufSize',maxLength,'Delimiter','\t','CollectOutput',1);
else
    allFile=textscan(fin,docFormat,...
                     'BufSize',maxLength,'Delimiter','\t','CollectOutput',1);
end
    
fclose(fin);
allFile=allFile{1};

fprintf('  Done reading %d docs with %d fields (%.0f sec)\n',...
        size(allFile,1),size(allFile,2),etime(clock,t0));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Process substitutions and validate document
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t1=clock;
fprintf('Processing substitutions & validation\n');

metadata=cell(size(allFile,1),1);
dataUniqueWords=cell(size(allFile,1),1);
dataUniqueNdx=cell(size(allFile,1),1);

totalLength=0;
displayStep=100;
found_errors=false;

for nDoc=1:size(allFile,1)    % loop over documents
    
    %% save metadata & dates
    metadata{nDoc}=allFile(nDoc,metaFields);
    metadata{nDoc}(metaMask)=cellstr('');
    dates=allFile(nDoc,dateFields);
    dates(dateMask)=cellstr('');
    
    % extract columns corresponding to the desired data
    thisData=sprintf('%s ',allFile{nDoc,dataFields});
    
    totalLength=totalLength+length(thisData);
    
    % apply substitution rules
    if ~isempty(substitutions)
        thisData=regexprep(thisData,substitutions(:,1),substitutions(:,2));
    end
    
    % convert to lower case 
    % (preserving end-of-sentence marker as an isolated word)
    thisData=regexprep(thisData,endOfSentenceWord,' \n ');
    thisData=lower(thisData);
    thisData=regexprep(thisData,'\n',endOfSentenceWord);
    
    % validates document
    if ~isempty(validationScript)
        [err,diagnosis]=validationScript(metadata{nDoc},dates,thisData,allHeaders,allFile(nDoc,:),extractDate);
        if err
            found_errors=true;
            %  fprintf('makedictfromtab: %s(%d)\t%s',inputText,nDoc,diagnosis);
            prefix=sprintf('%s\tmakedictfromtab:\t%s(%d)\t',datestr(now),inputText,nDoc);
            fprintf(ferr,'%s%s',prefix,regexprep(diagnosis,'\n(.)',['\n',prefix,'$1']));
        end
    end
    
    if isempty(thisData)
        fprintf('makedictfromtab: %s(%d) has empty data',metadata{nDoc}{1},nDoc);
        fprintf(ferr,'%s\tmakedictfromtab:\%s(%d)\tempty data\n',...
                datestr(now),inputText,nDoc,metadata{nDoc}{1});
    end

    %% parse to words
    thisData=textscan(thisData,'%s','Delimiter',' .,:;"()?!',...
                 'MultipleDelimsAsOne',1,'BufSize',maxLength,'CollectOutput',1);
    thisData=thisData{1};
    
    %% stemmer 
    if stemmer
        for i=1:length(thisData)
            thisData{i}=porterStemmer(thisData{i});
        end
    end

    %% save data
    [dataUniqueWords{nDoc},dummy,dataUniqueNdx{nDoc}]=unique(thisData);
    
    if mod(nDoc,displayStep)==0
        fprintf('    %5d - %-35s\n',nDoc,metadata{nDoc}{1}(1:min(end,25)));
    end
end                                       % end of loop over documents

fprintf('  Done processing substitutions & validation (%.0f sec)\n',etime(clock,t1));

if found_errors
    fprintf('*** Found validation errors: see %s\n',logFile);
end

clear allFile

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Convert words to stream of numbers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

codedText=cell(length(dataUniqueNdx),1);

t1=clock;
fprintf('Building dictionary & converting to numbers\n');

for nDoc=1:length(dataUniqueNdx)    % loop over documents

    codedText{nDoc}=zeros(length(dataUniqueNdx{nDoc}),1,'uint32');
    for thisWord=1:length(dataUniqueWords{nDoc}) % loop unique words
        where=(thisWord==dataUniqueNdx{nDoc});
        [rc,kk]=binstrfind(dataUniqueWords{nDoc}{thisWord},dicWords);
        if rc 
            dicWords(kk+1:end+1)=dicWords(kk:end);
            dicWords(kk)=dataUniqueWords{nDoc}(thisWord);
            dicNdx(kk+1:end+1)=dicNdx(kk:end);
            dicNdx(kk)=nextNdx;
            dicCount(kk+1:end+1)=dicCount(kk:end);
            dicCount(kk)=sum(where);
            nextNdx=nextNdx+1;
        else
            dicCount(kk)=dicCount(kk)+sum(where);
        end	
        codedText{nDoc}(where)=dicNdx(kk);
    end
    
    if mod(nDoc,displayStep)==0
        fprintf('    %5d - %-35s\tdict %5.0fw (%6.1f/%6.1f sec)\n',...
                nDoc,metadata{nDoc}{1}(1:min(end,35)),length(dicWords),...
                etime(clock,t1),...
                etime(clock,t1)/nDoc*length(dataUniqueNdx));
    end
    
end                                       % end of loop over documents

fprintf('    %5d - %-35s\tdict %5.0fw\n',nDoc,metadata{nDoc}{1}(1:min(end,35)),length(dicWords));

fprintf('  Done building dictionary & converting to numbers (%.0f sec)\n',etime(clock,t1));

processTime=etime(clock,t0);

fprintf('Processed %d documents in %.1fs (%3.0fKB/s)\n',nDoc,processTime,totalLength/processTime/1000);

clear dataUniqueWords dataUniqueNdx

%if ~isdeployed()
%    profile off
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% check nDoc against filename 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tokens=regexp(inputText,'[^\d](\d+)-(\d+)[^\d]','tokens');
if length(tokens)<1 || length(tokens{1})~=2
    fprintf('makedictfromtab: cannot guess number of documents from filename\n\t''%s''\n',inputText);
    
    fprintf(ferr,'%s\tmakedictfromtab:\t%s\tcannot guess number of documents from filename\n',...
            datestr(now),inputText);
else
    if nDoc ~= str2num(tokens{1}{2})-str2num(tokens{1}{1})+1
        fprintf('makedictfromtab: number of processed documents (%d) does not match\n\tnumber of documents (%d) guessed from the filename\n\t''%s''\n',nDoc,str2num(tokens{1}{2})-str2num(tokens{1}{1})+1,inputText);
        
        fprintf(ferr,'%s, makedictfromtab:\t%s\tnumber of processed documents does not match number guessed from the filename\t%d processed\t%d guessed\n',...
                datestr(now),inputText,nDoc,str2num(tokens{1}{2})-str2num(tokens{1}{1})+1);
    end
end

fclose(ferr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Write document & dictonary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('makedictfromtab: saving dictionary ... ');
if exist(dicName,'file')
  status=system(sprintf('mv -f \"%s\" \"%s.bak\"',dicName,dicName));
else
  status=0;
end

if ~status
    fid=fopen(dicName,'w');
    fprintf(fid,'%s\n',dicVersion);
    for i=1:length(dicWords)
        fprintf(fid,'%s\t%d\t%d\n',char(dicWords(i)),dicNdx(i),dicCount(i));
    end    
    fclose(fid);
end  

dicVersionMat=dicVersion;

fprintf('saving .mat file ... ');

save(outputMatlab,... %'-v7.3',...
     'codedText','metadata','inputText','dicVersionMat',...
     'processTime','totalLength');

fprintf('done\n\n');
    
%if profile_code && ~isdeployed()
%  profile viewer
%end

