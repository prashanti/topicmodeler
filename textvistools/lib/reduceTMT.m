function reduceTMT(varargin)
% To get help, type reduceTMT('help')
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
        'This script permits the removal and word and/or documents from'
        'a .mat file that represents the whole corpus of documents'
        'using the data structures used by the Topic Modeling Toolbox (TMT).'
        'The input to this file is typically created by makeTMT.'
        ' '
        'Specifically, this script performs the following actions:'
        '1) Reads the .mat file produced by makeTMT.'
        '2) Removes all words in a given stop-words list'
        '   See input variable ''stopList'' regarding the format'
        '   of the stop-list file.'
        '3) Removes all words with counts below a given threshold'
        '   See input variable ''minWordCount''.'
        '4) Removes a set of documents specified by an input file.'
        '   See input variables ''classDocs'' and ''codes2keep''.'
        '5) Saves the resulting "reduced" corpus in a .mat file'
        '   using the same exact structure as the .mat input file'
        '   created by make TMT.'
            });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','inputTMT',...
    'Description', {
        'Filename for a .mat file, used for read access (input)'
        'documents'' data in the TMT (Topic Modeling Toolbox) format'
                   });
declareParameter(...
    'VariableName','stopList',...
    'DefaultValue','',...
    'Description', {
        'Filename (or cell array of filename) for a .txt file,'
        'used for read access (input)'
        'Stop words list'
                   });
declareParameter(...
    'VariableName','classDocs',...
    'Description', {
        'filename for a .tab (or .csv) file, used for read access (input)'
        'Remove documents based on the classification codes in this file'
        '   1st row = header (ignored)'
        '   1st column = document name in the form xxxx(99)'
        '        where ''xxxx'' represents the name of the .tab (raw) file '
        '                       containing the document'
        '          and ''99''   represents the order of the document'
        '                       within that file'
        '   2nd column = document codes (numerical value)'
        '   all remaining columns are ignored'
        'If the variable ''classDoc'' is empty, do not remove any documents'
                   });
declareParameter(...
    'VariableName','redTMT',...
    'Description', {
        'filename for a .mat file, used for write access (output)'
        'pruned documents'' data in the TMT (Topic Modeling Toolbox) format'
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
    'VariableName','minWordCount',...
    'DefaultValue',10,...
    'Description', {
        'Remove words with word counts smaller than this'
                   });
declareParameter(...
    'VariableName','codes2keep',...
    'DefaultValue',[],...
    'Description', {
        'Codes to keep (from the 2nd column of ''classDocs'' file)'
                   });

setParameters(varargin);

ferr=fopen(logFile,'a');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read TMT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(inputTMT)  

fprintf('Before reduceTNT\nTotal: D = %5.0f, N = %5.0fw (proc. time=%4.2fs)\n',D,N,totalProcessTime);
fprintf('sizes: WS=%dx%d, DS=%dx%d, WO=%dx%d, WW=%dx%d(nnz=%d,sum=%d), SI=%dx%d, Docs=%dx%d\n\n',... 
	size(WS,1),size(WS,2),size(DS,1),size(DS,2),size(WO,1),size(WO,2),...
	size(WW,1),size(WW,2),nnz(WW),full(sum(sum(WW))),size(SI,1),size(SI,2),size(nameDocs,1),size(nameDocs,2));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Remove stop words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stopNdx=readStopList(stopList,WO);

fprintf('reduceTMT: removing stop words (colocations ALLOWED to span gap)\n');

fprintf('   finding the document words... ');
tic
k=find(ismember(WS,stopNdx));
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
kS=k(find(SI(k)==0));  % stop words that should not connect to word before
kS(kS==length(SI))=[]; % last word does not matter
SI(kS+1)=0;    % if stopword could not connect to previous, then
               % this is passed to next word
SI(k)=[];
toc

t0=clock;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% histogram of word counts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);clf
[n,x]=hist(double(WOcount),100);
tail=cumsum(n(end:-1:1));
semilogy(x,n,'-',x,tail(end:-1:1),'--');
legend('distribution','tail'); 
%axis([0,1,10,100000]);
title('Word counts')
drawnow


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% determine which words to remove
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('reduceTMT: finding low-count words to remove\n');
tic

words2remove=find(WOcount<minWordCount);

toc
fprintf('\nWill remove %d words with counts smaller than %d\nNumber of words reduced from %d to %d\n', ...
        length(words2remove),minWordCount,length(WO),length(WO)-length(words2remove));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% determine which documents to remove
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

docs2remove=[];

if ~isempty(classDocs)
    
    fprintf('\nreduceTMT: finding documents to remove\n');
    tic
    
    fprintf('   reading file...');
    [docName,docCode]=textread(classDocs,'%s%n%*[^\n\r]','headerlines',1,'delimiter','\t','bufsize',1000000);
    
    fprintf('   searching for document names...');
    
    idx=-ones(length(nameDocs),1);
    
    for i=1:length(docName)
        if mod(i,1000)==0
            fprintf('%d/%d ',i,length(docName));
        end
        
        docN=find(strcmp(docName{i},nameDocs));
        
        if length(docN)~=1
            fprintf('\nerror finding document ''%s'' with code ''%d''\n', ...
                    docName{i},docCode(i));
            fprintf(ferr,'%s\treduceTMT:\terror finding document\t%s\tcode %d\n', ...
                    datestr(now),docName{i},docCode(i));
        else
            if idx(docN)~=-1
                fprintf('reduceTMT: multiple classes for ''%s'' with code ''%d'' (previously ''%d'')\n',...
                        docName{i},docCode(i),idx(docN));
                fprintf(ferr,'%s\treduceTMT:\tmultiple classes for document\t%s\tcode %d\tpreviously %d\n',...
                        datestr(now),docName{i},docCode(i),idx(docN));
            end
            idx(docN)=docCode(i);
        end
    end
    
    k=find(idx<0);
    if ~isempty(k)
        fprintf('reduceTMT: found %d unclassified documents\n',length(k));
        for i=1:length(k)
            fprintf(ferr,'%s\treduceTMT\tfound %d unclassified documents:\t%s\n',datestr(now),length(k),nameDocs{k(i)});
        end
    end
    
    docs2remove = union(docs2remove,find(~ismember(idx,codes2keep)));
    
    toc
    fprintf('\nWill remove %d documents\nNumber of documents reduced from %d to %d\n', ...
            length(docs2remove),D,D-length(docs2remove));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Remove documents & low-count words
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nreduceTMT: removing (collocations NOT allowed accross gaps)\n');

fprintf('   finding the document words... ');
tic
k=[find(ismember(WS,words2remove)),...
   find(ismember(DS,docs2remove))];
k=unique(k);
toc

% remove words from word streams
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
% no colocation across words removed
SI(k+1)=0; 
SI(k)=[];
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Trim dictionary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nreduceTMT: trimming dictionary\n');

fprintf('  BEFORE: ');
for i=1:100
    fprintf('%s ',WO{WS(i)});
end
fprintf('\n');

[uWS,~,j]=unique(WS);
x=uint32(1:length(uWS));
WS=x(j);
WO=WO(uWS);

fprintf('  AFTER : ');
for i=1:100
    fprintf('%s ',WO{WS(i)});
end
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Trim document IDs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('\nreduceTMT: trimming document list\n');

kd=ceil(length(DS)*rand(1,20));
fprintf('  BEFORE:\n');
for i=1:length(kd)
    fprintf('\t%d %s\n',kd(i),nameDocs{DS(kd(i))});
end

[uDS,~,j]=unique(DS);

x=uint32(1:length(uDS));
DS=x(j);
nameDocs=nameDocs(uDS);
metaDocs=metaDocs(uDS,:);

fprintf('  AFTER:\n');
for i=1:length(kd)
    fprintf('\t%d %s\n',kd(i),nameDocs{DS(kd(i))});
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Recreate word-pairs matris WW from colocation stream SI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('reduceTMT: building word-pairs matrix... ');
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
    error('reducedTMT: mistmatch between sum(SI)=%d and sum(WW)=%d\n',sum(SI),full(sum(sum(WW))))
end

totalProcessTime=totalProcessTime+etime(clock,t0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Write TMT file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N=length(WS);
D=max(DS);

fprintf('After reduceTNT:\nTotal: D = %5.0f, N = %5.0fw (proc. time=%4.2fs)\n',D,N,totalProcessTime);
fprintf('sizes: WS=%dx%d, DS=%dx%d, WO=%dx%d, WW=%dx%d(nnz=%d,sum=%d), SI=%dx%d, Docs=%dx%d\n\n',... 
	size(WS,1),size(WS,2),size(DS,1),size(DS,2),size(WO,1),size(WO,2),...
	size(WW,1),size(WW,2),nnz(WW),full(sum(sum(WW))),size(SI,1),size(SI,2),size(nameDocs,1),size(nameDocs,2));

save(redTMT,...%'-v7.3',...
     'N','D','WS','DS','WO','WW','SI',...
     'WOcount','nameDocs','metaDocs','dicVersionTMT','totalProcessTime');

fclose(ferr);
