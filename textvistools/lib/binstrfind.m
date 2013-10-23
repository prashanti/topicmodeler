function [rc,k1]=binstrfind(str,array);
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


k1=1;
k2=length(array);
str=char(str);
if ~k2
  rc=-1;
  return  
end

while 1
  k=round((k1+k2)/2);
  
  w=char(str,array{k});
  
  rc=w(1,:)-w(2,:);

  if any(rc)
    if rc(find(rc,1))<0
      k2=k-1;  
      if k2<k1
	rc=-1;       
	return
      end
    else
      k1=k+1;  
      if k2<k1
	rc=1;
	return
      end
    end      
  else
    rc=0;
    k1=k;     
    return
  end
  
end

