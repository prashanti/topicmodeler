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

clear functions
clear all

parametersMfile='tvtParameters';
eval(parametersMfile);

files=dir([inputFolder,'*.tab']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Runs makedictfromtab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if execute.makedictfromtab
    % change line below to 'if 0', to append to existing dictionary
    if 1
        delete(parameters.makedictfromtab.logFile)
        delete(parameters.makedictfromtab.dicName)
        delete(parameters.makeTMT.TMTname)
    end
    
    % fix random seed for repeatability
    streamSelect=RandStream.create('mt19937ar','seed',0);
    RandStream.setDefaultStream(streamSelect);
    
    fprintf('makedictfromtab\n---------------\n')
    for i=1:length(files)
        inputText=[inputFolder,files(i).name];
        outputMatlab=[outputFolder,regexprep(files(i).name,'.tab$','.mat')];
        fprintf('Reading  .tab [%d of %d]: %s\n',i,length(files),inputText);
        fprintf('Creating .mat [%d of %d]: %s\n\n',i,length(files),outputMatlab);
        makedictfromtab('parametersMfile',parametersMfile,...
                        'inputText',inputText,...
                        'outputMatlab',outputMatlab,...
                        'maxDocs',Inf,'maxLength',10000000,...
                        'stemmer',0);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Runs makeTMT (TMT - Topic Modeling Toolbox)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if execute.makeTMT
    % change line below to 'if 0', to append to existing TMT file
    if 1
        delete(parameters.makeTMT.TMTname)
    end
    
    % fix random seed for repeatability
    streamSelect=RandStream.create('mt19937ar','seed',0);
    RandStream.setDefaultStream(streamSelect);

    fprintf('makeTMT\n-------\n')
    for i=1:length(files)
        outputMatlab=[outputFolder,regexprep(files(i).name,'.tab$','.mat')];
        fprintf('Reading .mat [%d of %d]: %s\n\n',i,length(files),outputMatlab);
        makeTMT('parametersMfile',parametersMfile,...
                'inputData',outputMatlab,...
                'blockSize',10000000);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Runs reduceTMT 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if execute.reduceTMT
    % fix random seed for repeatability
    streamSelect=RandStream.create('mt19937ar','seed',0);
    RandStream.setDefaultStream(streamSelect);

    fprintf('reduceTMT\n---------\n')
    reduceTMT('parametersMfile',parametersMfile);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Runs ldacol
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if execute.ldacol
    % fix random seed for repeatability
    streamSelect=RandStream.create('mt19937ar','seed',0);
    RandStream.setDefaultStream(streamSelect);

    fprintf('ldacol\n------\n')
    ldacol('parametersMfile',parametersMfile);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Runs createSOM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if execute.createSOM
    % fix random seed for repeatability
    streamSelect=RandStream.create('mt19937ar','seed',0);
    RandStream.setDefaultStream(streamSelect);

    fprintf('createSOM\n---------\n')
    createSOM('parametersMfile',parametersMfile);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Runs trainSOM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if execute.trainSOM
    % fix random seed for repeatability
    streamSelect=RandStream.create('mt19937ar','seed',0);
    RandStream.setDefaultStream(streamSelect);

    fprintf('trainSOM\n--------\n')
    trainSOM('parametersMfile',parametersMfile,...
             'path2tvt','..');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Runs createClassesFromMetadata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if execute.createClassesFromMetadata
    % fix random seed for repeatability
    streamSelect=RandStream.create('mt19937ar','seed',0);
    RandStream.setDefaultStream(streamSelect);

    fprintf('createClassesFromMetadata\n-------------------------\n')
    createClassesFromMetadata('parametersMfile',parametersMfile);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Runs cluster4SOM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if execute.cluster4SOM
    % fix random seed for repeatability
    streamSelect=RandStream.create('mt19937ar','seed',0);
    RandStream.setDefaultStream(streamSelect);

    fprintf('cluster4SOM\n-------------\n')
    cluster4SOM('parametersMfile',parametersMfile,'nExamples',0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Runs clusterTopics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if execute.clusterTopics
    % fix random seed for repeatability
    streamSelect=RandStream.create('mt19937ar','seed',0);
    RandStream.setDefaultStream(streamSelect);

    fprintf('clusterTopics\n-------------\n')    
    clusterTopics('parametersMfile',parametersMfile,...
                  'includeTimeSeries',1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Runs arcgisScripts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if execute.arcgisScripts
    % fix random seed for repeatability
    streamSelect=RandStream.create('mt19937ar','seed',0);
    RandStream.setDefaultStream(streamSelect);

    fprintf('arcgisScripts\n-------------\n')    
    arcgisScripts('parametersMfile',parametersMfile,...
                  'geodatabaseFolder','.',...
                  'layersFolder','ArcGIS-layers');
end


