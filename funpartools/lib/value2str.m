function str=value2str(value)
% str=value2str(value)
%
% returns a character string with a value, regardless of whether the
% value is numeric or a string
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

    if isnumeric(value)
        if length(value)==0
            str='[]';
        elseif length(value)==1
            str=sprintf('%g',value);
        else
            str='[';
            for i=1:length(value)-1
                str=[str,sprintf('%g',value(i)),','];
            end
            str=[str,sprintf('%g',value(end)),']'];
        end
    elseif islogical(value)
        if length(value)==0
            str='[]';
        elseif length(value)==1
            if value
                str='true';
            else
                str='false';
            end
        else
            str='[';
            for i=1:length(value)-1
                if value(i)
                    str=[str,'true,'];
                else
                    str=[str,'false,'];
                end
            end
            if value(end)
                str=[str,'true]'];
            else
                str=[str,'false]'];
            end
        end
    elseif ischar(value)
        str=sprintf('''%s''',value);
    elseif iscell(value)
        if length(value)>0
            str='{';
            for i=1:length(value)-1
                str=[str,value2str(value{i}),','];
            end
            str=[str,value2str(value{end}),'}'];
        else
            str='{}';
        end
    else
        disp(value)
        error('value2str: does not know to convert to string\n')
    end
