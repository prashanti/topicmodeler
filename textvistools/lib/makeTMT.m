function makeTMT(varargin) 
% To get help, type makeTMT('help')
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
        'This script essentially takes the outputs of ''makedictfromtab'''
        'and creates a file that represents the whole corpus of documents'
        'using the data structures used by the Topic Modeling Toolbox (TMT).'
        ' '
        'Specifically, this script performs the following actions:'
        '1) Reads one or several .mat files created by ''makedictfromtab'''
        '   containing streams of numbers representing texts'
        '   and the corresponding metadata in raw format.'
        '2) Adds the information about the documents read to a .mat'
        '   file that aggregates the information about the whole'
        '   corpus of documents. This output .mat file represents'
        '   the corpus using the data structures required by the TMT'''
        '3) Removes any duplicate documents that may exits in the'
        '   output .mat file'
        });
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','inputData',...
    'Description', {
        'Filename for a .mat file, used for read access (input)'
        'Matlab file with documents'' texts converted to numbers and'
        'the documents'' metadata (in raw format).'
        'This function can accept a cell array of filenames to process'
        'multiple input files.'
                   });
declareParameter(...
    'VariableName','dicName',...
    'Description', {
        'Filename for a .txt file, used for read access (input)'
        'Dictionary used to convert words to numbers. The dictionary'
        'is a tab-separated file with:'
        '   1st row contains the date and time the dictionary was created'
        '   Each subsequent row corresponds to one word and contains'
        '   3 columns:'
        '      1st column - word'
        '      2nd column - unique numerical identifier for the word'
        '      3rd column - # of time the word appears in the corpus'
                   });
declareParameter(...
    'VariableName','TMTname',...
    'Description', {
        'Filename for a .mat file, used for write access (output)'
        'Documents'' data in the TMT (Topic Modeling Toolbox) format.'
        'If no file exists with the given filename, a new (empty)'
        'file is created before processing the new data.'
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
    'VariableName','endOfSentenceWord',...
    'DefaultValue','LiNeBrEaK',...
    'Description', {
        'Word that marks the end of a sentence'
                   });
declareParameter(...
    'VariableName','maxDocs',...
    'DefaultValue',inf,...
    'Description', {
        'Maximum number of documents to process per file (can be Inf)'
        'Used in debugging to speed up processing of each file'
                   });
declareParameter(...
    'VariableName','blockSize',...
    'DefaultValue',1000000,...
    'Description', {
        'Number of words added each time arrays run out of space'
                   });

setParameters(varargin);

% profile ?
profile_code=0;

ferr=fopen(logFile,'a');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read dictionary 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[dicWords,dicNdx,nextNdx,dicCount,dicVersion]=readDictionary(dicName);

if isempty(dicWords)
  error('dictionary ''%s'' is empty\n',dicName);
end

%% end-of-sentence marker
[rc,k]=binstrfind(endOfSentenceWord,dicWords);

if rc 
    warning('makeTMT: end-of-sentence word ''%s'' not in dictionary\n',endOfSentenceWord);
    endOfSentenceNdx=-1;
else
    endOfSentenceNdx=dicNdx(k);
end	

if ~isdeployed()
  profile off
end

if profile_code && ~isdeployed()
  profile clear
  profile -detail builtin on
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read TMT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear N D WS DS WO WW SI documents metadata totalProcessTime


if exist(TMTname)
  load(TMTname)  
  if ~strcmp(dicVersion,dicVersionTMT)
      error('makeTMT: mistmatch between dictionary ''%s'' and the TMT-dictionary ''%s''',dicVersion,dicVersionTMT)
  end
  % reconstruct ndx
  ndx=zeros(1,length(DS));
  for i=1:max(D)
      k=find(DS==i);
      ndx(k)=1:length(k);
  end
else
  totalProcessTime=0;
  N=0;
  D=0;
  WS=zeros(1,blockSize,'uint32');
  DS=zeros(1,blockSize,'uint32');
  SI=ones(1,blockSize,'uint32');
  ndx=zeros(1,blockSize); % index that counts word documents
                                   %  eventually used to find duplicates 
  nameDocs=[];
  metaDocs={};

  % unsort dictionary and save to WO
  WO=cell(1,max(dicNdx));
  WO(dicNdx)=dicWords;
  WOcount(dicNdx)=dicCount;
end  

clear dicNdx dicWords dicCount

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Loop over Files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~iscell(inputData)
    inputData={inputData};
end

t0=clock;

for thisFile=1:length(inputData)
    fprintf('makeTMT: reading %3d of %3d: %s ... ',...
            thisFile,length(inputData),inputData{thisFile});
    load(inputData{thisFile});
    fprintf('done\n');
 
    if ~strcmp(dicVersion,dicVersionMat)
        error('makeTMT: mistmatch between dictionary ''%s'' and the Mat-dictionary ''%s''',dicVersion,dicVersionMat)
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Loop over documents to build WS, DS, SI
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    nameDocs=[nameDocs;cell(length(codedText),1)];
    metaDocs=[metaDocs;cell(length(codedText),size(metadata{1},2))];
    for thisDoc=1:min(length(codedText),maxDocs)
        
        D=D+1;
        nameDocs{D}=sprintf('%s(%d)',regexprep(inputText,'\.[^.]*$',''),thisDoc);
        metaDocs(D,:)=metadata{thisDoc};
        
        if length(WS)<N+length(codedText{thisDoc})
            fprintf('\tadding %d words to WS/DS/SI(%d)\n',blockSize,length(WS));
            WS=[WS,zeros(1,blockSize,'uint32')];
            DS=[DS,zeros(1,blockSize,'uint32')];
            SI=[SI,ones(1,blockSize,'uint32')];
            ndx=[ndx,zeros(1,blockSize)];
        end
        
        doc=codedText{thisDoc};
        %	fprintf('document %d (%s)\n',thisDoc,nameDocs{D});
        %	for jj=1:length(doc)
        %	   ii=find(dicNdx==doc(jj));
        %	   fprintf('   %5d %s\n',doc(jj),char(dicWords(ii)));
        %	end
        
        % add line to WS
        WS(N+1:N+length(doc))=doc;
        % add document number to DS
        DS(N+1:N+length(doc))=D;
        % add index to ndx
        ndx(N+1:N+length(doc))=1:length(doc);
        
        % remove collocation flags from SI: at start of document
        %                                 & right after endOfSentenceWord marker
        SI(N+1)=0;
        k1=find(doc==endOfSentenceNdx);
        SI(N+k1+1)=0;

        N=N+length(doc);
        
        if mod(D,5000)==0
            fprintf('%5d:  D = %6.0f, N = %12.0fw, %6.2fs\n',thisDoc,D,N,etime(clock,t0));
        end

    end % loop over documents
    
end % loop over files

fprintf('%5d:  D = %6.0f, N = %12.0fw, %6.2fs\n',thisDoc,D,N,etime(clock,t0));
    

clear codedText
whos

% truncate nameDocs and metaDocs just to D rows
nameDocs=nameDocs(1:D);
metaDocs=metaDocs(1:D,:);

% truncate WS, DS, SI, back to just N columns
WS=WS(1,1:N);
DS=DS(1,1:N);
SI=SI(1,1:N);
ndx=ndx(1,1:N);

% remove all endOfSentenceWord markers
k1=find(WS==endOfSentenceNdx);
WS(k1)=[];
DS(k1)=[];
SI(k1)=[];
ndx(k1)=[];

N=length(WS);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% find duplicated documents
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('makeTMT: saving .mat file (temporary)... ');
t1=clock;
save(TMTname,...%'-v7.3',...
     'DS','WS','SI',...
     'nameDocs','metaDocs');
fprintf('done (%.0f sec)\n',etime(clock,t1));
clear SI metaDocs 

whos

fprintf('\nmakeTMT: finding duplicate documents\n');
tic

DS=double(DS);
WS=double(WS);

whos

fprintf('  computing corpus matrix ...\t');
% create matrix with one document per row and one word per columns
% >>> seems very inefficient from the memory prespective
docMat=sparse(DS,ndx,WS);
clear DS WS ndx
toc

whos

fprintf('  sorting corpus ...\t');
% find duplicates
[dummy,small,large]=unique(docMat,'rows');
clear dummy
toc

fprintf('  finding potential repeats ...\t');
repeated=sort(large);
repeated=unique(repeated(repeated(1:end-1)==repeated(2:end)));
toc

docs2remove=[];
whos

fprintf('makeTMT: loading .mat file (temporary)... ');
t1=clock;
load(TMTname,'metaDocs');
fprintf('done (%.0f sec)\n',etime(clock,t1));

fprintf('Loop over %d potential duplicates ...\n',length(repeated));
for thisRepeat=1:length(repeated)
    thisRep=repeated(thisRepeat);
    if sum(docMat(small(thisRep),:))==0
        % empty document - no need to do anything about it
        continue;
    end
    k=find(thisRep==large);
    fprintf('[%4d of %4d] Potential duplicates: ',thisRepeat,length(repeated));
    fprintf('%d ',k);
    fprintf('\n');

    % compare all to all
    k=[kron(k,ones(length(k),1)),kron(ones(length(k),1),k)];
    k=k(k(:,1)<k(:,2),:);

    i=1;
    while i<=size(k,1)
        if any(docMat(k(i,1),:)~=docMat(k(i,2),:))
            error('makeTMT: rows %d and %d should be equal\n',k(i,1),k(i,2));
        end
    
        fprintf('   [%4d of %4d] equal data for docs %5d and %5d ... ',i,size(k,1),k(i,1),k(i,2));
        [ii,jj,v]=find(docMat(k(i,1),:));
        %        v
        %        WO(v(1:20))
        
        %% Test if all metafields are also equal
        equal=true;
        for j=1:size(metaDocs,2)
            if ~strcmp(lower(metaDocs{k(i,1),j}),lower(metaDocs{k(i,2),j}))
                equal=false;
                fprintf('different metafield %d\n\t%s\n\t%s\n',j,metaDocs{k(i,1),j},metaDocs{k(i,2),j});
                break;
            end
        end
        
        if equal
            fprintf('equal metafields (removing doc %5d):\n  %s\n',...
                    k(i,2),nameDocs{k(i,2)});
            fprintf(ferr,'%s\tmakeTMT:\tfound duplicate documents, removing second\t%d\t%s\t%d\t%s\n',...
                    datestr(now),k(i,1),nameDocs{k(i,1)},...
                                 k(i,2),nameDocs{k(i,2)});
            % always removes largest number
            docs2remove=union(docs2remove,k(i,2));
            % no need to retest this one for removal
            k(i+find(k(i+1:end,2)==k(i,2)),:)=[];
        end
        i=i+1;
    end
end

fprintf('\nWill remove %d documents\nNumber of documents reduced from %d to %d\n', ...
        length(docs2remove),D,D-length(docs2remove));
toc

clear docMat small large

fprintf('makeTMT: loading .mat file (temporary)... ');
t1=clock;
load(TMTname,...
     'DS','WS','SI',...
     'metaDocs');
fprintf('done (%.0f sec)\n',etime(clock,t1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% remove documents
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nmakeTMT: removing documents from word streams\n');

fprintf('   finding the document words... ');
tic
k=find(ismember(DS,docs2remove));
toc

% remove words from word stream
fprintf('   removing from the word stream... ');
tic
WS(k)=[];
toc
fprintf('   removing from the document stream... ');
tic
DS(k)=[];
toc
fprintf('   removing from the breaks stream... ');
tic
SI(k)=[];
toc

N=length(WS);
D=max(DS);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Recreate word-pairs matris WW from colocation stream SI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('makeTMT: building word-pairs matrix... ');
t1=clock;

% build from scratch
k=find(SI);
w1=double(WS(k-1));
w2=double(WS(k));
ww=ones(length(k),1);
% reconstruct WW
WW=sparse(w2,w1,ww,length(WO),length(WO));
fprintf('done (%.0f sec)\n',etime(clock,t1));

if any(sum(SI)~=sum(sum(WW)))
    error('reducedTMT: mistmatch between sum(SI)=%d and sum(WW)=%d\n',sum(SI),sum(sum(WW)))
end

totalProcessTime=totalProcessTime+etime(clock,t0);

if ~isdeployed()
    profile off
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Write TMT file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Total: D = %5.0f, N = %5.0fw (proc. time=%4.2fs)\n',D,N,totalProcessTime);
fprintf('sizes: WS=%dx%d, DS=%dx%d, WO=%dx%d, WW=%dx%d(nnz=%d,sum=%d), SI=%dx%d, Docs=%dx%d\n\n',... 
	size(WS,1),size(WS,2),size(DS,1),size(DS,2),size(WO,1),size(WO,2),...
	size(WW,1),size(WW,2),nnz(WW),full(sum(sum(WW))),size(SI,1),size(SI,2),size(nameDocs,1),size(nameDocs,2));

fprintf('makeTMT: saving .mat file ... ');
t1=clock;
dicVersionTMT=dicVersion;
save(TMTname,...%'-v7.3',...
     'N','D','WS','DS','WO','WW','SI',...
     'WOcount','nameDocs','metaDocs','dicVersionTMT','totalProcessTime');
fprintf('done (%.0f sec)\n',etime(clock,t1));

fclose(ferr);

if profile_code && ~isdeployed()
    profile viewer
end

