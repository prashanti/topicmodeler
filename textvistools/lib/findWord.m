function findWord(varargin);
% To get help, type findWord('help')
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
        'This script goes through the files with streams of numbers'
        'produced by makedictfromtab to find specific words or'
        'sequences of words.'
        'Typical usage is:'
        '   findWord(''wildcard'',''../5-matlab-output-mat-files/weblogs/'',''words'',{''copyright'',''by''})'
            });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','wildcard',...
    'DefaultValue','../5-matlab-output-mat-files/*/*',...
...%    'DefaultValue','../5-matlab-output-mat-files/weblogs/*',...
...%    'DefaultValue','../5-matlab-output-mat-files/transcripts/*',...
...%    'DefaultValue','../5-matlab-output-mat-files/newspapers/*',...
...%    'DefaultValue','../5-matlab-output-mat-files/magazines/*',...
    'Description', {
        'String with a wildcard specifying the set of .mat files'
        'to consider (input). These files should contain the documents'''
        'text converted to numbers by makedictfromtab.'
                   });
declareParameter(...
    'VariableName','dicName',...
    'DefaultValue','',...
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','words',...
    'DefaultValue',{'radio','weblogs'},...
    'Description', {
        'Cell array with the sequence of words to search in the form'
        '{''word1'',''word2'',''word3'',...}'
                   });

verboseLevel=1; % by default displays text around words

setParameters(varargin);

if isempty(dicName)
    stacyParameters
    
    dicName=parameters.makedictfromtab.dicName;
end

fprintf('findWord parameters:\n   dictionary:   %s\n   search files: %s\n   verboseLevel: %d\n   words:    ',dicName,wildcard,verboseLevel);
disp(words)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Files to search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[status,allfiles]=system(sprintf('find %s -name "*.mat"',wildcard));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read dictionary & find word
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[dicWords,dicNdx,nextNdx,dicCount,dicVersion]=readDictionary(dicName);

wordsNdx=zeros(length(words),1);

if ischar(words)
    words={words};
end

for i=1:length(words)
    [rc,kk]=binstrfind(words{i},dicWords);
	
    if rc  % new word
        fprintf('Word "%s" not in the dictionary\n',words{i});
        return
    else
        wordsNdx(i)=dicNdx(kk);
        fprintf('Word "%s" in dictionary (index = %d)\n',words{i},wordsNdx(i));
    end
end

%% end-of-sentence marker
endOfSentenceWord='LiNeBrEaK';
[rc,k]=binstrfind(endOfSentenceWord,dicWords);

if rc 
    warning('makeTMT: end-of-sentence word ''%s'' not in dictionary\n',endOfSentenceWord);
    endOfSentenceNdx=-1;
else
    endOfSentenceNdx=dicNdx(k);
end	

fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Search in files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

allfiles=textscan(allfiles,'%s','BufSize',1000000,'Delimiter','\n');
allfiles=allfiles{1};

if length(allfiles)==1 &&  ~isempty(regexp(allfiles,'[nN]o [Mm]atch','once'))
    fprintf('no files to search for: %s\n',char(allfiles))
    return
end

for thisFile=1:length(allfiles);
  fprintf('  Looking into file %3d of %3d: %-30s\r',thisFile,length(allfiles),allfiles{thisFile});
  load(allfiles{thisFile});

  if ~strcmp(dicVersion,dicVersionMat)
      warning('findWord: mistmatch between dictionary "%s" and the Mat-dictionary "%s"',dicVersion,dicVersionMat)
      continue
  end
  
  for thisDoc=1:length(codedText)
          line=codedText{thisDoc};
          k=1:length(line);
          for i=1:length(wordsNdx)
              kk=find(line(k)==wordsNdx(i));
              k=k(kk)+1;
              k=k(find(k<=length(line)));
          end
          if ~isempty(k)
              % select text around word
              ks=max(min(k)-10,1):min(max(k)+10,length(line));
%              line(ks)
              fprintf('found in "%s(%d)"\n   ',allfiles{thisFile},thisDoc);
              lineLength=3;
              if verboseLevel
                 for jj=ks %1:length(line)
                     if line(jj)==endOfSentenceNdx
                        fprintf('\n');
                        continue;
                     end
                     ii=find(dicNdx==line(jj));
%                     fprintf('[%d %s]',jj,dicWords{ii});
                     if any(jj==k-length(wordsNdx))
                        fprintf('**>');
                        lineLength=lineLength+4;
                     end
                     fprintf('%s ',dicWords{ii});
                     if any(jj==k-1)
                        fprintf('<**');
                        lineLength=lineLength+4;
                     end
                     lineLength=lineLength+length(dicWords{ii})+1;
                     if lineLength>90
                        fprintf('...\n      ');
                        lineLength=6;
                     end
                 end
                 fprintf('\n\n');
              end
          end 
      end
  end
