function deleteDatalessPedigrees(path)
% deleteOrphanPedigrees(path)
% 
% Removes pedigree files without "child" data files in the class
%
% Attention: Should NOT be called between calling 
%    filename=createPedigree(...)
% and using the returned filename to create the data file.
%
% (This is especially important to keep in mind for files that may be
% manually created much later.)
%
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

    
%% get key formating parameters for filenames
[filename,pedigreeSuffix,dateFormat,basenameUniqueRegexp,timeStampFormat,pedigreeWildcard]=createPedigree();

%% get list of pedigree files
wildcard=sprintf(pedigreeWildcard,path,'/*',pedigreeSuffix);
pedigrees=dir(wildcard);

for thisPedigree=1:length(pedigrees)
    thisName=[path,'/',pedigrees(thisPedigree).name];
    fprintf('Analysing pedigree: %s\n',pedigrees(thisPedigree).name);

    thisWildcard=regexprep(thisName,[pedigreeSuffix,'$'],'*');

    matchFiles=dir(thisWildcard);
    
    match=false;
    for i=1:length(matchFiles)
        if strcmp(matchFiles(i).name,pedigrees(thisPedigree).name) 
            %            fprintf('   same (ignored)\n');
            continue;
        end
        fprintf('         data file: %s\n',matchFiles(i).name)
        match=true;
    end
    
    if ~match
        filename=[path,'/',matchFiles(i).name];
        fprintf('***      NO DATA, will delete %s\n',filename);
        delete(filename);
    end
end

    
    