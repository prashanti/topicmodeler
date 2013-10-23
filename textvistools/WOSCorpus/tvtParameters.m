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

clear parameters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Commands to execute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

execute.makedictfromtab           = 1;
execute.makeTMT                   = 1;
execute.reduceTMT                 = 1;
execute.ldacol                    = 1;
execute.createSOM                 = 1;
execute.trainSOM                  = 1;
execute.createClassesFromMetadata = 1;
execute.cluster4SOM               = 1;
execute.clusterTopics             = 1;
execute.arcgisScripts             = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%
%% ATTENTION: This section needs to be significantly changed for
%%            different examples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% input folder (terminated by '/')
inputFolder='inputFiles/';

%% output folder (terminated by '/')
outputFolder='outputFiles/';

%% substitutions 
substitutionsScript='tvtSubstitutions';
parameters.makedictfromtab.substitutionsScript=substitutionsScript;

%% extractDate 
extractDateScript='extractDateUS';
parameters.makedictfromtab.extractDateScript=extractDateScript;
parameters.savematrix.extractDateScript=extractDateScript;
parameters.clusterTopics.extractDateScript=extractDateScript;

%% validation 
validationScript='validateDocument';
parameters.makedictfromtab.validationScript=validationScript;

%% data header
dataHeaders={'TITLE:';'KEYWORDS:';'KEYWORDS2:';'ABSTRACT:'};
parameters.makedictfromtab.dataHeaders=dataHeaders;

%% metadata of interest
metaHeaders={'TITLE:';'DATE:';'SOURCE:'};
parameters.makedictfromtab.metaHeaders=metaHeaders;
parameters.savematrix.metaHeaders=metaHeaders;
parameters.createSOM.metaHeaders=metaHeaders;
parameters.clusterTopics.metaHeaders=metaHeaders;
parameters.createClassesFromMetadata.metaHeaders=metaHeaders;

%% metafields with dates
dateHeaders={'DATE:'};
parameters.makedictfromtab.dateHeaders=dateHeaders;
parameters.savematrix.dateHeader=dateHeaders{1};
parameters.clusterTopics.dateHeader=dateHeaders{1};

%% reducedTMT()
parameters.reduceTMT.stopList={
    '../wordlists/ENstoplist.txt';
                   };
parameters.reduceTMT.minWordCount=10;
parameters.reduceTMT.classDocs='';
parameters.reduceTMT.codes2keep=[];

%% ldacol()
parameters.ldacol.nTopics=20;
parameters.ldacol.multiNiterations=[200,100,100,100];

%% createSOM()
parameters.createSOM.docs2exclude='';
parameters.createSOM.cols2exclude='';
% parameters.createSOM.cols2exclude is created manually, but
% if not assigned here, it will be created by createPedigree (assigned below)
parameters.createSOM.minSumCols=.2;
parameters.createSOM.nTrainingMatrices=3;

%% trainSOM()
parameters.trainSOM.seed=100;
parameters.trainSOM.somSize  =[10,10];
if 0
    parameters.trainSOM.somRadius      =[10,5,1];
    parameters.trainSOM.somAlpha       =[.01,.15,.02];
    parameters.trainSOM.trainingLengths=[20000,30000,200000];
end
if 0
    parameters.trainSOM.somRadius      =[10,5,1];
    parameters.trainSOM.somAlpha       =[.05,.03,.02]/10;
    parameters.trainSOM.trainingLengths=[5000,20000,20000]*10;
end
if 1
    parameters.trainSOM.somRadius      =[10,5,2];
    parameters.trainSOM.somAlpha       =[.005,.04,.04]/10;
    parameters.trainSOM.trainingLengths=[40000,40000,200000];
end
%parameters.trainSOM.alphaType='linear';
parameters.trainSOM.alphaType='inverse_t';
parameters.trainSOM.snapshootIntervals=max(parameters.trainSOM.trainingLengths/50,1000);

%% createClassesFromMetadata

parameters.createClassesFromMetadata.nSamples=inf;
parameters.createClassesFromMetadata.metafieldName='TITLE:';
parameters.createClassesFromMetadata.metafieldRegexp=...
    '^(USA TODAY|The New York Times)$';
parameters.createClassesFromMetadata.metafieldRegexpRep=...
    { '^USA TODAY','+USA TODAY';
      '^The New York Times','+NYT';
      '^[^+].*$','+Other';
        };

%% cluster4SOM()
if 0
    % clusters by maximum column value 
    parameters.cluster4SOM.clusterMethod='maxraw'; 
    parameters.cluster4SOM.maxDocs=Inf;
end
if 1
    % K-means (clusters just once)
    parameters.cluster4SOM.clusterMethod='kmeans'; 
    parameters.cluster4SOM.maxDocs=Inf;
    parameters.cluster4SOM.clusterDistance='cosine';% distance metric used 
    parameters.cluster4SOM.replicates=10;      % # of replicates used by kmeans
    parameters.cluster4SOM.nClusters=20;
end
if 0
    % hierarhical K-means (creates a hierarchy of clusters)
    parameters.cluster4SOM.clusterMethod='hkmeans';
    parameters.cluster4SOM.clusterDistance='cosine';% distance metric used
    parameters.cluster4SOM.replicates=10;      % # of replicates used by hkmeans
    parameters.cluster4SOM.branchesPerNode=5;
    parameters.cluster4SOM.maxDocs=Inf;
end
if 0
    % manual
    parameters.cluster4SOM.clusterMethod='manual';
    parameters.cluster4SOM.maxDocs=Inf;
    parameters.cluster4SOM.trainingFile='coded_samples_to_vizualize.tab';
end
if 0
    % supervised classification
    %parameters.cluster4SOM.clusterMethod='supervised';
    %parameters.cluster4SOM.maxDocs=Inf;
    %parameters.cluster4SOM.trainingFile='coded_samples_to_vizualize.tab';
    %parameters.cluster4SOM.classifierType='diagLinear';
    %parameters.cluster4SOM.dimPCA=Inf;
    parameters.cluster4SOM.classifierType='linear';
    parameters.cluster4SOM.dimPCA=99;
    %parameters.cluster4SOM.classifierType='diagQuadratic';
    %parameters.cluster4SOM.dimPCA=149;
    %parameters.cluster4SOM.classifierType='quadratic';
    %parameters.cluster4SOM.dimPCA=50;
    %parameters.cluster4SOM.classifierType='mahalanobis';
    %parameters.cluster4SOM.dimPCA=149;
end

%% clusterTopics()
parameters.clusterTopics.periodInYears=1;
% hierarhical K-means (creates a hierarchy of clusters)
parameters.clusterTopics.clusterMethod='kmeans';
parameters.clusterTopics.replicates=10;
parameters.clusterTopics.maxDocs=Inf;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filenames
%% ATTENTION: This section does NOT need to be significantly 
%%            changed for different examples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% log file to report errors
logFile='00errors_log.tab';
parameters.makedictfromtab.logFile=[outputFolder,logFile];
parameters.makeTMT.logFile=[outputFolder,logFile];
parameters.reduceTMT.logFile=[outputFolder,logFile];
parameters.trainSOM.logFile=[outputFolder,logFile];

%% makedictfromtab() -> makeTMT
parameters.makedictfromtab.dicName=createPedigree(...
    [outputFolder,'01dictionary.txt'],parameters.makedictfromtab);
parameters.makeTMT.dicName=parameters.makedictfromtab.dicName;

%% makeTMT() -> reduceTMT
parameters.makeTMT.TMTname=createPedigree(...
    [outputFolder,'02TMT.mat'],parameters.makeTMT);
parameters.reduceTMT.inputTMT=parameters.makeTMT.TMTname;

%% reducedTMT -> lda(inputTMT), ldacol(inputTMT)
parameters.reduceTMT.redTMT=createPedigree(...
    [outputFolder,'03redTMT.mat'],parameters.reduceTMT);
parameters.lda.inputTMT=parameters.reduceTMT.redTMT;
parameters.ldacol.inputTMT=parameters.reduceTMT.redTMT;

%% ldacol -> createSOM(inputMatrix,cols2exclude)
parameters.ldacol.outputPrefix=createPedigree(...
    [outputFolder,'04ldacol'],parameters.ldacol);
parameters.createSOM.inputMatrix=...
    [parameters.ldacol.outputPrefix,'+nIter=500.mat'];
if ~isfield(parameters.createSOM,'cols2exclude')
    % cols2exclude is created manually, but its name should be 
    % derived from the output of ldacol since this function
    % creates the list of topics
    parameters.createSOM.cols2exclude=... 
        [parameters.ldacol.outputPrefix,'+MANUAL+topics2exclude.tab'];
end

%% createSOM ->
%%   trainSOM(inputPrefix), cluster4SOM(inputMatrix), clusterTopics(inputMatrix)
%%   createClassesFromMetadata(inputData),arcgisScripts(createSOMoutputPrefix)
parameters.createSOM.outputPrefix=createPedigree(...
    [outputFolder,'05creatSOM'],parameters.createSOM);
parameters.trainSOM.inputPrefix=parameters.createSOM.outputPrefix;
parameters.cluster4SOM.inputMatrix=parameters.createSOM.outputPrefix;
parameters.clusterTopics.inputMatrix=parameters.createSOM.outputPrefix;
parameters.createClassesFromMetadata.inputData=parameters.createSOM.outputPrefix;
parameters.arcgisScripts.createSOMoutputPrefix=parameters.createSOM.outputPrefix;

%% trainSOM -> ArcGIS
parameters.trainSOM.outputPrefix=createPedigree(...
    [outputFolder,'06sompak'],parameters.trainSOM);

%% createClassesFromMetadata -> cluster4SOM
parameters.createClassesFromMetadata.outputPrefix=createPedigree(...
    [outputFolder,'09metaClasses'],parameters.createClassesFromMetadata);
if ~isfield(parameters.cluster4SOM,'trainingFile')
    % cols2exclude can be created manually, but it can also be
    % created automatically by createClassesFromMetadata
    parameters.cluster4SOM.trainingFile=...
        [parameters.createClassesFromMetadata.outputPrefix,'+train.tab'];
    parameters.cluster4SOM.testingFile=...
        [parameters.createClassesFromMetadata.outputPrefix,'+test.tab'];
end

%% cluster4SOM -> ArcGIS
parameters.cluster4SOM.outputPrefix=createPedigree(...
    [outputFolder,'07clusterDocs'],parameters.cluster4SOM);

%% clusterTopics -> ArcGIS
parameters.clusterTopics.outputPrefix=createPedigree(...
    [outputFolder,'08clusterTopics'],parameters.clusterTopics);

%% arcgisScripts
parameters.arcgisScripts.outputPrefix=createPedigree(...
    [outputFolder,'10arcgisScripts'],parameters.arcgisScripts);
