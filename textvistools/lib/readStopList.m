function stopNdx=readStopList(stopname,dicWords)
% stopNdx=readStopList(stopname,dicWords)
%
% Read stop list, ignores lines commented with the character '%'
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

if ischar(stopname)
    stopname={stopname};
end

stopNdx=zeros(0,1);

for i=1:length(stopname)
    if ~isempty(stopname{i})
        fid=fopen(stopname{i});
        
        if (fid<0)
            error('readStopList: unable to open stop list file ''%s''\n',stopname{i});
        end
        
        stoplist=textscan(fid,'%s','CommentStyle','%');
        stoplist=stoplist{1};
        fclose(fid);

        N=length(stopNdx);
        stopNdx=[stopNdx;nan(size(stoplist,1),1)];
        for thisWord=1:size(stoplist,1)
            k=find(strcmp(dicWords,stoplist{thisWord}));
 
            if isempty(k)  % word in dictionary
                fprintf('readStopList: stop word ''%s'' not in dictionary\n',stoplist{thisWord});
            else
                if length(k)>1
                    disp(k)
                    error('readStopList: stop word ''%s'' appears multiple times in dictionary\n',stoplist{thisWord});
                end
                stopNdx(thisWord+N)=k;
            end	
        end
        
        k=isnan(stopNdx);
        stopNdx(k)=[];  
    end
end

stopNdx=unique(stopNdx);

fprintf('Read %d words to stop list\n',size(stopNdx,1))

