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

clear all

txt=sprintf('word%.5f ',rand(10000,1));
theseWords=textscan(txt,'%s');
theseWords=theseWords{1};

disp('sort')
tic
a=sort(theseWords);
toc


disp('unique')
tic
[dataUniqueWords,ui,dataUniqueNdx]=unique(theseWords);
toc

%% binstrfind (shortcut)
disp('binstrfind (shortcut)')
dicWords={};
dicNdx=[];
dicCount=[];
nextNdx=1;
codedText=zeros(length(theseWords),1,'uint32');   
%  profile off
%  profile clear
%  profile -detail builtin on
tic
for thisWord=1:length(dataUniqueWords)   % loop over words within line
    where=(thisWord==dataUniqueNdx);
    [rc,kk]=binstrfind(dataUniqueWords{thisWord},dicWords);
    if rc 
        dicWords(kk+1:end+1)=dicWords(kk:end);
        dicWords(kk)=dataUniqueWords(thisWord);
        dicNdx(kk+1:end+1)=dicNdx(kk:end);
        dicNdx(kk)=nextNdx;
        dicCount(kk+1:end+1)=dicCount(kk:end);
        dicCount(kk)=sum(where);
        nextNdx=nextNdx+1;
    else
        dicCount(kk)=dicCount(kk)+sum(where);
    end	
    codedText(where)=dicNdx(kk);
end
toc
%   profile off
%   profile viewer
   
% test
[dicNdx,k]=sort(dicNdx);
dicWords=dicWords(k);
dicCount=dicCount(k);
rtxt=sprintf('%s ',dicWords{codedText});
if strcmp(txt,rtxt) && sum(dicCount)==length(theseWords)
    disp('Correct!!!')
else
    disp('*** Error!!!')
end

%% put hash (shortcut)
disp('put hash (shortcut)')
hash=Hashtable(dataUniqueWords(1),{[1;0]});
nextNdx=size(hash)+1;
codedText=zeros(length(theseWords),1,'uint32');    
%  profile off
%  profile clear
%  profile -detail builtin on
tic
for thisWord=1:length(dataUniqueWords)
    where=(thisWord==dataUniqueNdx);
    x=get(hash,dataUniqueWords{thisWord});
    if isempty(x)
        x=[nextNdx;sum(where)];
        nextNdx=nextNdx+1;
    else
        x(2)=x(2)+sum(where);
    end
    put(hash,dataUniqueWords{thisWord},x);
    codedText(where)=x(1);
end
dicWords=keys(hash);
dicNdx=get(hash,dicWords);
dicNdx=[dicNdx{:}]';
dicCount=dicNdx(:,2);
dicNdx=dicNdx(:,1);
toc
%   profile off
%   profile viewer

% test
[dicNdx,k]=sort(dicNdx);
dicWords=dicWords(k);
dicCount=dicCount(k);
rtxt=sprintf('%s ',dicWords{codedText});
if strcmp(txt,rtxt) && sum(dicCount)==length(theseWords)
    disp('Correct!!!')
else
    disp('*** Error!!!')
end

%% put hash (extensive)' 
disp('put hash (extensive)')
hash=Hashtable();
nextNdx=1;
codedText=zeros(length(theseWords),1,'uint32');    
tic
for thisWord=1:length(theseWords)
    x=get(hash,theseWords{thisWord});
    if isempty(x)
        put(hash,theseWords{thisWord},[nextNdx;1]);
        codedText(thisWord)=nextNdx;
        nextNdx=nextNdx+1;
    else
        x(2)=x(2)+1;
        codedText(thisWord)=x(1);
        put(hash,theseWords{thisWord},x);
    end
end
dicWords=keys(hash);
dicNdx=get(hash,dicWords);
dicNdx=[dicNdx{:}]';
dicCount=dicNdx(:,2);
dicNdx=dicNdx(:,1);
toc

% test
[dicNdx,k]=sort(dicNdx);
dicWords=dicWords(k);
dicCount=dicCount(k);
rtxt=sprintf('%s ',dicWords{codedText});
if strcmp(txt,rtxt) && sum(dicCount)==length(theseWords)
    disp('Correct!!!')
else
    disp('*** Error!!!')
end

%% binstrfind (extensive)
disp('binstrfind (extensive)')
dicWords={};
dicNdx=[];
dicCount=[];
nextNdx=1;
codedText=zeros(length(theseWords),1,'uint32');    
tic
for thisWord=1:length(theseWords)   % loop over words within line
    [rc,kk]=binstrfind(theseWords{thisWord},dicWords);
    if rc 
        dicWords(kk+1:end+1)=dicWords(kk:end);
        dicWords(kk)=theseWords(thisWord);
        dicNdx(kk+1:end+1)=dicNdx(kk:end);
        dicNdx(kk)=nextNdx;
        dicCount(kk+1:end+1)=dicCount(kk:end);
        dicCount(kk)=1;
        nextNdx=nextNdx+1;
    else
        dicCount(kk)=dicCount(kk)+1;
    end	
    codedText(thisWord)=dicNdx(kk);
end
toc

% test
[dicNdx,k]=sort(dicNdx);
dicWords=dicWords(k);
dicCount=dicCount(k);
rtxt=sprintf('%s ',dicWords{codedText});
if strcmp(txt,rtxt) && sum(dicCount)==length(theseWords)
    disp('Correct!!!')
else
    disp('*** Error!!!')
end

