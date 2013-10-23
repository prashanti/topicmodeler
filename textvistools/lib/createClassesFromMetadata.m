function createClassesFromMetadata(varargin);
% To get help, type createClassesFromMetadata('help')
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
        'Creates a training set for the supervised classification'
        'documents. The classes are extracted from the distinct '
        'values of a given metadata field'
            });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','inputData',...
    'Description', {
        'Filename for a .mat file, used for read access (input)'
        'Output of ''createSOM'' containing, at least:'
        '2) Cell vector ''nameDocs'' with documents names in the'
        '   form xxxx(99) where'
        '   ''xxxx'' represents the name of the .tab (raw) file'
        '            ontaining the document'
        '   ''99''   represents the order of the document within'
        '            that file'
        '4) Cell array ''metaDocs'' with the documents metadata'
        '   (one document per row, one metadata field per column)'
                   });
declareParameter(...
    'VariableName','outputPrefix',...
    'Description', {
        'Filename prefix for the following files:'
        '{outputPrefix}+train.tab file for write access (output)'
        '   tab-separated file with coded document for cluster training'
        '   by the ''supervised'' methods of ''cluster4SOM'''
        '{outputPrefix}+test.tab file for write access (output)'
        '   tab-separated file with coded document for cluster testing'
        '   by the ''supervised'' methods of ''cluster4SOM'''
        'Both files are Tab-separated and contain:'
        '   1st row = header (ignored)'
        '   1st col - document filename and number within file as'
        '               filename(number)'
        '   2rd col - integer denoting the document code (i.e., cluster)'
        '   3rd col - string with metadata value (ignored by ''cluster4SOM'')'
                   });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','nSamples',...
    'Description', {
        'Number of samples to be included in the output file'
                   });
declareParameter(...
    'VariableName','metaHeaders',...
    'Description', {
        'Cell array with the names of the metafields'
        '(column headers from .tab input file)'
        'that should be included in the .mat output file'
                   });
declareParameter(...
    'VariableName','metafieldName',...
    'Description', {
        'Cell string with the name of a metafield used to'
        '  (1) select documents'
        '  (2) create classes'
                   });
declareParameter(...
    'VariableName','metafieldRegexp',...
    'Description', {
        'Cell string with a regexp to be applied to the metafield'
        'in order to select documents'
                   });
declareParameter(...
    'VariableName','metafieldRegexpRep',...
    'Description', {
        'Nx2 Cell array with a list of N regexp substitutions to '
        'be applied to the metafield before converting into numerical'
        'classes'
                   });

setParameters(varargin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(inputData,'nameDocs','metaDocs');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Select random training sample
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

metafieldNdx=find(strcmp(metafieldName,metaHeaders));
if isempty(metafieldNdx)
    metaHeaders
    error('unknown metafield "%s"\n',metafieldName);
end
kAll=regexp(metaDocs(:,metafieldNdx),metafieldRegexp,'once');
kAll=find(~cellfun('isempty',kAll));
fprintf('createClassesFromMetadata: %d out of %d documents match regexp\n\t"%s" =~ "%s"\n',...
        length(kAll),length(nameDocs),metafieldName,metafieldRegexp);

% select random sample for training
fprintf(['createClassesFromMetadata: selecting a random sample for ' ...
         'training (remaining will be used for testing)\n']);
% compute random permutation
[dummy,ks]=sort(rand(length(kAll),1));
kTrain=kAll(ks);
% pick first documents in the permutation and sort to get original order
kTrain=sort(kTrain(1:min(end,nSamples)));
kTest=setdiff(kAll,kTrain);
fprintf('\ttraining sample = %d, test sample = %d\n',...
        length(kTrain),length(kTest));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create classes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
metaDocsRep=regexprep(metaDocs(:,metafieldNdx),...
                     metafieldRegexpRep(:,1),metafieldRegexpRep(:,2));
[classNames,i,docClass]=unique(metaDocsRep);
fprintf('%d classes in sample:\n',length(classNames))
for i=1:min(length(classNames),5000)
    fprintf('%3d: %-40s (%5d docs)\n',i,classNames{i},sum(docClass==i));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Save classification data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid=fopen(sprintf('%s+train.tab',outputPrefix),'w');
fprintf(fid,'document\tclass number\tclass name (original)\tclass name (regexprep)\n');
for i=1:length(kTrain)
    fprintf(fid,'%s\t%d\t%s\t%s\n',nameDocs{kTrain(i)},docClass(kTrain(i)),...
            metaDocs{kTrain(i),metafieldNdx},metaDocsRep{kTrain(i)});
end
fclose(fid);

fid=fopen(sprintf('%s+test.tab',outputPrefix),'w');
fprintf(fid,'document\tclass number\tclass name (original)\tclass name (regexprep)\n');
for i=1:length(kTest)
    fprintf(fid,'%s\t%d\t%s\t%s\n',nameDocs{kTest(i)},docClass(kTest(i)),...
            metaDocs{kTest(i),metafieldNdx},metaDocsRep{kTest(i)});
end
fclose(fid);

