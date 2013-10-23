The FunParTools toolbox provides functions to

1) declare 'named' inputs to a matlab function
2) process input parameters from 'varargin'
3) take values from a 'global' parameter file, when not in 'varargin'
4) set default values for inputs, when not in 'varargin' or global file
5) test if parameter values fall within admissible sets
6) automatically generate 'help' from declared inputs

This toolbox is mostly useful when writing scripts to do batch
processing of data using multiple steps (each affected by several
parameters) and reading/writing intermediate files.

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

