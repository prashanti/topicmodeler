function [dicWords,dicNdx,nextNdx,dicCount,dicVersion,dicHash]=readDictionary(dicname)
% [dicWords,dicNdx,nextNdx,dicCount,dicVersion]=readDictionary(dicname)
%
% Read & Sort dictonary
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


if exist(dicname)
  fid=fopen(dicname);
  dicVersion=fgetl(fid);
  dictionary=textscan(fid,'%s%u32%u32');
  fclose(fid);
  
  [dicWords,k]=sort(dictionary{1});
  dicNdx=dictionary{2}(k);
  dicCount=dictionary{3}(k);
  clear dictionary  
  nextNdx=max(dicNdx)+1;
else
    dicVersion=datestr(now);
    dicWords=cell(0,1);
    dicNdx=zeros(0,1,'uint32');
    dicCount=zeros(0,1,'uint32');
    nextNdx=1;
end

if nargout>5
    if isempty(dicNdx)
        dicHash=Hashtable();
    else
        dicHash=Hashtable(dicWords,{[dicNdx,(1:length(dicNdx))']});
    end
end