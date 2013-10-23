function cluster4SOM(varargin)
% To get help, type cluster4SOM('help')
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
        'This scripts performs document clustering based on the'
        'matrix created by the TMT (using the ldacol script),'
        'which was subsequently used to create a SOM (using the'
        'createSOM script).'
        ' '
        'Since the createSOM script may have removed some documents'
        'and/or topics, this function uses the version of the matrix'
        'created by createSOM. This guarantees consistency with'
        'the shape files and tables used by ArcGIS, which'
        'are also derived from the outputs of createSOM.'
        ' '
        'Specifically, this script performs the following actions:'
        '1) Reads the output of createSOM.'
        '   The key input that will be used for document clusering is the'
        '   matrix ''dataMatrix'' with the topic weights for each'
        '   document (one document per row, one topic per column).'
        '   See input variable ''inputMatrix.'''
        '2) Clusters the documents using a specified clustering method'
        '   Several methods are available: some hierarchical other not,'
        '   some supervised and others unsupervised.'
        '   Different methods require different input parameters.'
        '   For the supervised methods, training data must be provided'
        '   and (optionally) test data.'
        '   For further details see the description of the different'
        '   input variables.'
        '3) Creates a table file (.tab) with the documents clusters,'
        '   which can be used by ArcGIS to label documents by cluster'
            });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','inputMatrix',...
    'Description', {
        'Filename for a .mat file, used for read access (input)'
        'This file is typically created by createSOM and contains:'
        '     1) Matrix ''dataMatrix'' with the topic weights for each'
        '        document (one document per row, one topic per column).'
        '     2) Cell vector ''nameDocs'' with documents names in the'
        '        form xxxx(99) where'
        '        ''xxxx'' represents the name of the .tab (raw) file'
        '                 ontaining the document'
        '        ''99''   represents the order of the document within'
        '                 that file'
        '     3) Cell vector ''nameCols'' with topic descriptions '
        '        (i.e., the top words in each topic).'
        '     4) Cell array ''metaDocs'' with the documents metadata'
        '        (one document per row, one metadata field per column).'
                   });
declareParameter(...
    'VariableName','outputPrefix',...
    'Description', {
        'Filename prefix for the following files:'
        '{outputPrefix}+{method}+*.mat file for write access (output)'
        '     Most entries of .mat input file plus the clustering results.'
        '{outputPrefix}+{method}+*.tab file for write access (output)'
        '     Table with cluster numbers and cluster confidence'
        '     as document attributes for ArcGIS. For clustering'
        '     methods that result in multiple clustering results'
        '     (e.g., the hierarchical methods), the different results'
        '     appear in different columns.'
        '     For supervised clustering, the last clustering columns'
        '     Contain the true clusters (from the training and testing'
        '     data) or -1 if no true data is available.'
        '     ATTENTION: ArcGIS cannot handle very large filenames' 
        '{outputPrefix}+log.txt file for write access (output)'
        '     Text file with log outputs from the classifiers,'
        '     including warnings, number of clusters identified,'
        '     and classification errors and confidence levels for supervised'
        '     classifiers.'
        '     This file is not produced by all classifiers.'
        '{outputPrefix}+{method}+clusters_examples.txt file for'
        '     write access (output)'
        '     Randomized subset of documents in each clusters from seeDocuments'
        '     ATTENTION: this feature is not fully implemented'
                   });
declareParameter(...
    'VariableName','trainingFile',...
    'DefaultValue','',...
    'Description', {
        'Filename of a .tab file, used for read access (input)'
        'Tab-separated .tab file with manually coded documents'
        'for the ''manual'' and ''supervised'' clustering methods'
        '   1st row = header (ignored)'
        '   1st col - document filename and number within file as'
        '               filename(number)'
        '   2rd col - integer denoting the document code (i.e., cluster)'
        '   remaining columns - ignored'
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','testingFile',...
    'DefaultValue','',...
    'Description', {
        'Filename of a .tab file, used for read access (input)'
        'Tab-separated .tab file with manually coded documents'
        'for testing the ''supervised'' clustering method'
        '   1st row = header (ignored)'
        '   1st col - document filename and number within file as'
        '               filename(number)'
        '   2rd col - integer denoting the document code (i.e., cluster)'
        '   remaining columns - ignored'
        'This parameter is unused in the other clustering methods.'
                   });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','maxDocs',...
    'DefaultValue',+inf,...
    'Description', {
        'Maximum number of documents to cluster, when smaller'
        'than the total # of document, uses a random sample'
        'should be set to +inf to process all documents'
                   });
declareParameter(...
    'VariableName','clusterMethod',...
    'DefaultValue','hkmeans',...
    'AdmissibleValues',{'maxraw','maxnorm',...
                        'kmeans','hkmeans','linkage',...
                        'manual','supervised'},...
    'Description', {
        'Method used for clustering the documents:'
        '''maxraw''  - cluster documents based on the top topics'
        '''maxnorm''  - cluster documents based on the top topics, with'
        '               the topic weights normalized across documents'
        '''kmeans''  - cluster documents using kmeans unsupervised clustering'
        '''hkmeans'' - cluster documents hierarchically using kmeans'
        '              unsupervised clustering'
        '''linkage'' - cluster documents hierarchically using linkage'
        '              unsupervised clustering'
        '''manual''  - cluster documents manually, based on the file'
        '              ''trainingFile'''
        '''supervised'' - supervised clustering of documents, based on'
        '                 the file ''trainingFile'''
                   });
declareParameter(...
    'VariableName','nTopTopics',...
    'DefaultValue',3,...
    'Description', {
        'For the ''maxraw'' and ''maxnorm'' clustering methods, this variable'
        'defines how many top topics should be considered for clustering.'
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','nClusters',...
    'DefaultValue',16,...
    'Description', {
        'For the ''kmeans'' clustering method, this variable defines the'
        ' desired number of clusters. When this parameter is a vector,'
        '''kmeans'' runs multiple times, each time setting the desired number'
        'of clusters to a different entry of the vector.'
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','clusteringDistance',...
    'DefaultValue','cosine',...
    'AdmissibleValues',{'sqEuclidean','cityblock','cosine','correlation','Hamming',... % for kmeans
                    'euclidean','seuclidean','cityblock','cosine','correlation','hamming'},... % for linkage
    'Description', {
        'For the ''kmeans,'' ''hkmeans,'' and ''linkage'' clustering methods,'
        'this variable specifices the metric used for clustering.'
        'See ''help kmeans.'''
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','replicates',...
    'DefaultValue',10,...
    'Description', {
        'For the ''kmeans'' and ''hkmeans'' clustering methods, this'
        'variable specifies the number of replicates, i.e., the'
        'number of times to repeat the clustering, each with a'
        'new set of initial centroids. See ''help kmeans.'''
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','branchesPerNode',...
    'DefaultValue',2,...
    'Description', {
        'For the ''hkmeans'' clustering method, this variable specifies'
        'the number of branches at node of the clustering tree.'
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','treeDepth',...
    'DefaultValue',10,...
    'Description', {
        'For the ''linkage'' clustering method, this variable specifies'
        'the depth of the clustering tree.'
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','minNClusters',...
    'DefaultValue',2,...
    'Description', {
        'For the ''linkage'' clustering method, this variable specifies'
        'the minimum (i.e., coarsest) number of clusters.'
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','maxNClusters',...
    'DefaultValue',2000,...
    'Description', {
        'For the ''linkage'' clustering method, this variable specifies'
        'the maximum (i.e., finest) number of clusters.'
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','classifierType',...
    'DefaultValue','linear',...
    'AdmissibleValues',{'linear','diagLinear','quadratic','diagQuadratic','mahalanobis','knn','olvq1'},...
    'Description', {
        'For the ''supervised'' clustering method, this variable specifies'
        'the type of supervised classifier used. Training and testing'
        'classification data is provided through the input parameters'
        '''trainingFile'' and ''testingFile.'''
        'See ''help classify.'''
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','zeroMeanTopics',...
    'DefaultValue',1,...
    'Description', {
        'For the ''supervised'' clustering method, this variable specifies'
        'whether or not one should normalize the topic weights matrix'
        '''dataMatrix'' so that each column adds to zero.'
        'When 1, the script subtracts to each column of the data matrix'
        'the average of that column.'
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','dimPCA',...
    'DefaultValue',+inf,...
    'Description', {
        'For the ''supervised'' clustering method, this variable specifies'
        'the desired dimensionality reduction to be performed on the'
        'topic weights matrix ''dataMatrix.'''
        'When a value smaller than the number of columns if given,'
        'the script uses the singular value decompositon (SVD)'
        'to optimaly reduce the number of columns to this dimension.'
        'This is often needed when using the following supervised'
        'classifiers:'
        '1) ''linear,'' ''diagLinear,'' ''quadratic,'''
        '   ''diagQuadratic,'' and ''mahalanobis'''
        '   when the matrix columns are linearly dependent,'
        '   e.g., when one uses all topics (which sum to 1 for'
        '   every document).'
        '2) ''quadratic'' and ''mahlanobis'''
        '   when the number of columns of the matrix (rank) is smaller'
        '   than the number of traning samples in some clusters.'
        'When zeroMeanTopics=1, this method of dimensionality reduction'
        'amounts to the usual Principal Components Analysis.'
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','FisherLinearDiscriminant',...
    'DefaultValue',0,...
    'Description',{
        'For the ''supervised'' clustering method, this variable specifies'
        'whether or not one should apply Fisher Linear Discriminant'
        'for dimensionality reduction of topic weights matrix'
        '''dataMatrix.'''
        'This parameter is unused in the other clustering methods.'
                  });
declareParameter(...
    'VariableName','excludesLeaveKoutTest',...
    'DefaultValue',1,...
    'Description', {
        'For the ''supervised'' clustering method, this variable specifies'
        'how many K samples to leave out in the leave-K-out classification'
        'test. A set of K samples is selected independently from test to test.'
        'This parameter is unused in the other clustering methods.'
                   });
declareParameter(...
    'VariableName','repeatsLeaveKoutTest',...
    'DefaultValue',inf,...
    'Description', {
        'For the ''supervised'' clustering method, this variable specifies'
        'how many times to perform the leave-K-out test. When set to'
        'inf, all samples will be used.'
        'This parameter is unused in the other clustering methods.'
                   });

declareParameter(...
    'VariableName','numberNeighbors',...
    'DefaultValue',1,...
    'Description', {
        'For the ''supervised'' clustering method, using the ''knn'''
        'k-nearest neighbor classifier, this variable specifies the'
        'number of neighbors K.'
        'This parameter is unused in the other clustering/classifier methods.'
                   });
declareParameter(...
    'VariableName','classifyDistance',...
    'DefaultValue','cosine',...
    'Description', {
        'For the ''supervised'' clustering method, using the ''knn'''
        'k-nearest neighbor classifier, this variable specifies the'
        'distance user. See help knnsearch.'
        'This parameter is unused in the other clustering/classifier methods.'
                   });
declareParameter(...
    'VariableName','sizeCodebook',...
    'DefaultValue',1000,...
    'Description', {
        'For the ''supervised'' clustering method, using the ''olvq1'''
        'classifier, this variable specifies the number of vectors'
        'in the codebook.'
        'This parameter is unused in the other clustering/classifier methods.'
                   });
    
declareParameter(...
    'VariableName','path2tvt',...
    'DefaultValue','../lvq_pak-3.1',...
    'Description', {
        'For the ''supervised'' clustering method, using the ''olvq1'''
        'classifier, this variable specifies the path to the folder'
        'containing the LVQ_PAK executables.'
        'This parameter is unused in the other clustering/classifier methods.'
                   });
declareParameter(...
    'VariableName','sizeCodebook',...
    'DefaultValue',1000,...
    'Description', {
        'For the ''supervised'' clustering method, using the ''olvq1'''
        'classifier, this variable specifies the number of vectors'
        'in the codebook.'
        'This parameter is unused in the other clustering/classifier methods.'
                   });
declareParameter(...
    'VariableName','nBalance',...
    'DefaultValue',4,...
    'Description', {
        'For the ''supervised'' clustering method, using the ''olvq1'''
        'classifier, this variable specifies the number of times that'
        'the ''balance'' program is executed.'
        'This parameter is unused in the other clustering/classifier methods.'
                   });
declareParameter(...
    'VariableName','trainingLength',...
    'DefaultValue',10000,...
    'Description', {
        'For the ''supervised'' clustering method, using the ''olvq1'''
        'classifier, this variable specifies the number of training steps.'
        'This parameter is unused in the other clustering/classifier methods.'
                   });
declareParameter(...
    'VariableName','nExamples',...
    'DefaultValue',0,...
    'Description', {
        'Number of examples per cluster to display with seeDocuments'
        'ATTENTION: this feature is not fully implemented.'
                   });

setParameters(varargin);

logFile=sprintf('%s+log.txt',outputPrefix);
flog=fopen(logFile,'w');
if flog<0
    error('cluster4SOM: error opening output file ''%s''',logFile);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load matrices
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t0=clock;
fprintf('Loading data ''%s''... ',inputMatrix);
load(inputMatrix);
fprintf('done (%.1f sec)\n',etime(clock,t0));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Keep # of docs below the maximum value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[dummy,k]=sort(rand(size(dataMatrix,1),1));
kProcess=sort(k(1:min(end,maxDocs)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot Matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1);clf
semilogy(sum(dataMatrix(kProcess,:),1));
grid on
axis tight
ylabel('total per column')
xlabel(sprintf('columns from ''%s''',inputMatrix),'interpreter','none')
title('Frequency')
drawnow

figure(gcf+1);clf
semilogy(sum(dataMatrix(kProcess,:),2))
grid on
axis tight
ylabel('total per document')
xlabel(sprintf('documents in ''%s''',inputMatrix),'interpreter','none')
title('Frequency')
drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Clustering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t0=clock;
fprintf('Start clustering (%d documents, %d topics)...\n',...
        length(kProcess),size(dataMatrix,2));

switch clusterMethod
    
  case 'maxraw'
    %% cluster based on which column is largest
    [conf,idx]=sort(dataMatrix,2,'descend');
    idx=idx(:,1:nTopTopics);
    conf=conf(:,1:nTopTopics);

    nClusters=zeros(size(idx,2),1);
    for i=1:size(idx,2)
        nClusters(i)=length(unique(idx(:,i)));
    end
    fprintf('maxraw: # of clusters\n');
    fprintf('         %8.0f\n',nClusters);
    fprintf(flog,'maxraw: # of clusters\n');
    fprintf(flog,'         %8.0f\n',nClusters);

    clusterIDs=(1:size(idx,2));
    outputPrefix=sprintf('%s+maxraw+%d',outputPrefix,size(idx,2));

  case 'maxnorm'
    %% cluster based on which normalized column is largest
    maxcolumn=max(dataMatrix,[],1);
    [conf,idx]=sort(dataMatrix./(ones(size(dataMatrix,1),1)*maxcolumn),2,'descend');
    idx=idx(:,1:nTopTopics);
    conf=conf(:,1:nTopTopics);
    
    nClusters=zeros(size(idx,2),1);
    for i=1:size(idx,2)
        nClusters(i)=length(unique(idx(:,i)));
    end
    fprintf('maxnorm: # of clusters\n');
    fprintf('         %8.0f\n',nClusters);
    fprintf(flog,'maxnorm: # of clusters\n');
    fprintf(flog,'         %8.0f\n',nClusters);

    clusterIDs=(1:size(idx,2));
    outputPrefix=sprintf('%s+maxnorm+%d',outputPrefix,size(idx,2));
  
  case 'kmeans'
    %% kmeans clustering (with given distance)
    idx=zeros(length(kProcess),length(nClusters));
    conf=zeros(length(kProcess),length(nClusters));
    centroids=cell(length(nClusters),1);
    for i=1:length(nClusters)
        fprintf('kmeans: # of clusters = %d\n',nClusters(i));
        [idx(:,i),centroids{i},dummy,distances]=kmeans(...
            full(dataMatrix(kProcess,:)),nClusters(i),...
            'distance',clusteringDistance,'replicates',replicates,...
            'MaxIter',200,'display','final');
        %            'MaxIter',200,'display','iter');
        nClusters(i)=length(unique(idx(:,i)));
        conf(:,i)=distances(sub2ind(size(distances),(1:length(idx(:,i)))',idx(:,i)));
        if any(conf(:,i)~=min(distances,[],2))
            error('kmeans classification does not match minimum distance\n');
        end
    end
    tree={};

    clusterIDs=nClusters;
    outputPrefix=sprintf('%s+kmeans+%d_%d',...
                         outputPrefix,min(nClusters),max(nClusters));

  case 'hkmeans'
    %% hierarchical kmeans clustering (with given distance)
    idx=myhkmeans(full(dataMatrix(kProcess,:)),branchesPerNode,...
                  'distance',clusteringDistance,'replicates',replicates,...
                  'MaxIter',200,'display','off');
    % give unique identifiers to clusters at each level
    for i=2:size(idx,2);
        idx(:,i)=idx(:,i)+branchesPerNode*(idx(:,i-1)-1);
    end
    tree={};  % do not compute tree to speed things up

    nClusters=zeros(size(idx,2),1);
    for i=1:size(idx,2)
        nClusters(i)=length(unique(idx(:,i)));
    end
    fprintf('hkmeans: # of clusters\n');
    fprintf('         %8.0f\n',nClusters);
    fprintf(flog,'hkmeans: # of clusters\n');
    fprintf(flog,'         %8.0f\n',nClusters);
    
    clusterIDs=nClusters;
    outputPrefix=sprintf('%s+hkmeans+%d_%d',...
                         outputPrefix,min(nClusters),max(nClusters));

  case 'linkage'
    %% linkage average clustering with Euclidean distance
    nClusters=round(logspace(log10(minNClusters),log10(maxNClusters),treeDepth))
    tree=linkage(dataMatrix(kProcess,:),'average',clusteringDistance);
    idx=cluster(tree,'MaxClust',nClusters);

    dendrogram(tree,0);
    fontsize=ceil(min(10,1600/length(idx)));
    fprintf('dendrogram (fontsize = %g): %s\n',fontsize,[outputPrefix,'+dendrogram.eps']);
    xticklabels=cellstr(get(gca,'xticklabel'));
    format_ticks(gca,xticklabels,[],... % x/y labels
                 [],[],... % x/y tick positions
                 90,[],... % x/y label rotations
                 .5,...  % label offset
                 'FontSize',fontsize,...
                 'FontName','Helvetica');
    %print('-depsc','-opengl','-r300',[outputPrefix,'+dendrogram.eps']);
    %print('-dill','-r300',[outputPrefix,'+dendrogram.il']);
    print2eps([outputPrefix,'+dendrogram.eps']);
    
    nClusters=zeros(size(idx,2),1);
    for i=1:size(idx,2)
        nClusters(i)=length(unique(idx(:,i)));
    end
    fprintf('linkage: # of clusters\n');
    fprintf('         %8.0f\n',nClusters);
    fprintf(flog,'linkage: # of clusters\n');
    fprintf(flog,'         %8.0f\n',nClusters);

    figure(gcf+1);clf
    old=get(0,'RecursionLimit');
    set(0,'RecursionLimit',1000);
    dendrogram(tree,30,'colorthreshold','default','label',num2str(idx(:,end)))
    set(0,'RecursionLimit',old);

    clusterIDs=nClusters;
    outputPrefix=sprintf('%s+linkage+%d_%d',...
                            outputPrefix,minNClusters,maxNClusters);

  case 'manual'
    %% manual clustering
    [idx,conf,classifierOutput]=manualCluster(...
        dataMatrix,nameDocs,nameCols,flog,trainingFile);
    nClusters=length(unique(idx));

    clusterIDs=nClusters;
    outputPrefix=sprintf('%s+manual+%d',outputPrefix,nClusters);

  case 'supervised'
    %% supervised clustering
    [idx,conf,classifierOutput]=manualCluster(...
        dataMatrix,nameDocs,nameCols,flog,trainingFile,...
        testingFile,classifierType,zeroMeanTopics,dimPCA,...
        FisherLinearDiscriminant,...
        excludesLeaveKoutTest,repeatsLeaveKoutTest,...
        numberNeighbors,classifyDistance,...
        path2tvt,sizeCodebook,nBalance,trainingLength);
    nClusters=[length(unique(idx(:,1))),length(unique(idx(:,2)))];

    clusterIDs=nClusters;
    outputPrefix=sprintf('%s+superv+%d',outputPrefix,nClusters(1));
  
  otherwise,
    error('unknown method ''%s''\n',clusterMethod);
end

fprintf('Clustering done (%f sec)\n',etime(clock,t0));

%% expand clusters back to the full matrix (-1, not clustered)

clusters=-ones(size(dataMatrix,1),size(idx,2));
clusters(kProcess,:)=idx;
confidence=-ones(size(dataMatrix,1),size(idx,2));
if exist('conf','var')
    confidence(kProcess,:)=conf;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Output table with clusters as document attributes for ArcGIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% order documents by cluster
[dummy,kOrder]=sortrows(clusters);

fprintf('Saving clusters in document atributes table for ArcGIS ...\n\t%s.tab ... ',outputPrefix);
t0=clock;
fid=fopen(sprintf('%s.tab',outputPrefix),'w');
% header
fprintf(fid,'rowID\t');
for i=1:size(clusters,2)
    fprintf(fid,'%s%d\t',clusterMethod,clusterIDs(i));
end
for i=1:size(confidence,2)
    fprintf(fid,'%s%d_conf\t',clusterMethod,clusterIDs(i));
end
fprintf(fid,'rowName\n');
% data
for i=1:size(dataMatrix,1)
    fprintf(fid,'%d\t',kOrder(i));
    fprintf(fid,'%d\t',clusters(kOrder(i),:));
    fprintf(fid,'%f\t',confidence(kOrder(i),:));
    fprintf(fid,'%s\n',nameDocs{kOrder(i)});
end
fclose(fid);
fprintf('done (%f sec)\n',etime(clock,t0));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Output subset of documents in each clusters for seeDocuments
%%% (with randomized documents within each cluster)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

docs2see={};
if nExamples>0
    % randomize rows or dataMatrix and focus on kProcess rows
    [dummy,k]=sort(rand(length(kProcess),1));
    randMatrix=dataMatrix(kProcess(k),1);
    randClusters=clusters(kProcess(k),:);
    randDoc=nameDocs(kProcess(k));
    
    % sort by clusters
    [randClusters,k]=sortrows(randClusters);
    randMatrix=randMatrix(k,1);
    randDoc=randDoc(k);
    
    % Pick examples from each cluster
    for i=1:size(randMatrix,1)
        if i==1 || any(randClusters(i,:)~=randClusters(i-1,:))
            count=0;
        end
        if count<nExamples
            docs2see{end+1}=randDoc{i};
            count=count+1;
        end
    end
    
    if exist('docs2see','var') && ~isempty(docs2see)
        seeDocument(docs2see)
        
        system(sprintf('mv -f lixo.txt %s+clusters_examples.txt',outputPrefix))
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Save clustering results in a .mat file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Saving clusters in .mat file... ');
t0=clock;
switch clusterMethod

  case {'maxraw','maxnorm'}
    save(sprintf('%s.mat',outputPrefix),...%'-v7.3',...
         'dataMatrix','nameCols','metaDocs','nameDocs','clusters','docs2see');
  
  case 'kmeans'
    save(sprintf('%s.mat',outputPrefix),...%'-v7.3',...
         'dataMatrix','nameCols','metaDocs','nameDocs','clusters','confidence','centroids','docs2see');

  case {'manual','supervised'}
    save(sprintf('%s.mat',outputPrefix),...%'-v7.3',...
         'dataMatrix','nameCols','metaDocs','nameDocs','clusters','confidence','classifierOutput','docs2see');

  case {'hkmeans','linkage'}

    save(sprintf('%s.mat',outputPrefix),...%'-v7.3',...
         'dataMatrix','nameCols','metaDocs','nameDocs','clusters','tree','nClusters','docs2see');

  otherwise,
    error('unknown clustering method ''%s''\n',clusterMethod);
end
fprintf('done (%f sec)\n',etime(clock,t0));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run sompak
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%system('(cd ../mapping-code/;sompak_calibrate.sh)')

fclose(flog);