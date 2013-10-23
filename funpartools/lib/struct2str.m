function str=struct2str(s)
% returns a string that describes the fields and values of a given
% structure
% Copyright (C) 2010  Joao Hespanha

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

%s
names=fieldnames(s);
str=[];
leading='(';
for i=1:length(names)
    value=getfield(s,names{i});
    if ischar(value)
        value={value};
    end
    for j=1:length(value);
        vj=value(j);
        if iscell(vj) && length(vj)==1
            vj=vj{1};
        end
        if isfloat(vj)
            if j==1
                str=sprintf('%s%s%s=%g',str,leading,names{i},vj);
            else
                str=sprintf('%s_%g',str,vj);
            end
            leading='|';
        elseif ischar(vj)
            if j==1 && length(vj)>0
                % remove paths
                vj=regexprep(vj,'^.*/([^/.]*)\.*[^/]*','$1');
                str=sprintf('%s%s%s=%s',str,leading,names{i},vj);
                leading='|';
            end
        end
    end
end
if leading=='|'
    str=[str,')'];
end
%str