function clusterTopics(varargin)
% To get help, type clusterTopics('help')
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
        'This scripts performs topic clustering and evolution over'
        'time, based on the matrix created by the TMT (using the ldacol'
        ' script), which was subsequently used to create a SOM (using'
        'the createSOM script).'
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
        '2) Clusters the documents using a specified unsupervised clustering'
        '   method. Several methods are available some hierarchical other not.'
        '   Different methods require different input parameters.'
        '   For further details see the description of the different'
        '   input variables.'
        '3) Creates a table file (.tab) with the documents clusters,'
        '   which can be used by ArcGIS to label topics by cluster'
        '4) Produces a table that can be used to visualize the topics'''
        '   evolution over time with the manyeyes website'
        '      http://manyeyes.alphaworks.ibm.com/manyeyes/'
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
        '{outputPrefix}+{method}*=*.mat file for write access (output)'
        '     Most entries of .mat input file plus the clustering results.'
        '{outputPrefix}+{method}*=*.tab file for write access (output)'
        '     tab-separated table with the words of the clustered topics.'
        '{outputPrefix}+{method}*+clusters_words.tab file for write'
        '     access (output)'
        '     Tab-separated table showing the top words of all the'
        '     metatopics corresponding to each class. For hierarchical'
        '     methods, includes the metatopics for all levels of the'
        '     hierarchy.'
        '{outputPrefix}+{method}*+clusters_hierarchy.tab file for write'
        '     access (output)'
        '     Tab-separated table showing the topics hierarchy.'
        '     For hierarchical methods, the topics are organized in'
        '     in a tree-like form with the first columns corresponding'
        '     to the root and the last columns to the leaves.'
        '{outputPrefix}+{method}*+clusters_manyeyes.tab file for write'
        '     access (output)'
        '     Tab-separated table showing the topics hierarchy.'
        '     For hierarchical methods, the topics are organized in'
        '     in a tree-like form with the first columns corresponding'
        '     to the root and the last columns to the leaves.'
        '     This file may include a time series showing the temporal'
        '     evolution of the topic sum over documents. It was created'
        '     so that it can be directly imported as a manyeyes dataset'
        '        http://manyeyes.alphaworks.ibm.com/manyeyes/'
                   });
declareParameter(...
    'VariableName','extractDateScript',...
    'DefaultValue','',...
    'Description', {
        'Matlab function of the form'
        '  yyyymmdd=extractDate(dates)'
        'that extracts dates from a cell array of strings'
        'yyyymmdd is a numeric array with one row per document'
        'and three columna: year (from 1950 to 2020),'
        '                   month (from 1 to 12), and'
        '                   day (from 1 to 31)'
        'The value -1 should inserted when it is not possible to'
        'determine the year, month, or day.'
        'Typically ''extractDateScript'' should be set to'
        '''extractDateUS'' or ''extractDatePT''' 
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
    'AdmissibleValues',{'kmeans','hkmeans','linkage'},...
    'Description', {
        'Method used for clustering the topics:'
        '''kmeans''  - cluster topics using kmeans unsupervised clustering'
        '''hkmeans'' - cluster topics hierarchically using kmeans'
        '              unsupervised clustering'
        '''linkage'' - cluster topics hierarchically using linkage'
        '              unsupervised clustering'
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
    'AdmissibleValues',{'sqEuclidean','cityblock','cosine','correlation','Hamming'},...
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
    'VariableName','includeTimeSeries',...
    'DefaultValue',0,...
    'Description', {
        'Include time series showing the evolution of the'
        'topic sum over documents'
                   });
declareParameter(...
    'VariableName','periodInYears',...
    'DefaultValue',0.5,...
    'Description', {
        'Duration of one period for the time series'
        'expressed in years (e.g., ''.5'' for 6 a months period)'
                   });
declareParameter(...
    'VariableName','metaHeaders',...
    'Description', {
        'Cell K vector of strings with the names of each metadata field'
                   });
declareParameter(...
    'VariableName','dateHeader',...
    'Description', {
        'Index of the metafield that contains the date of the row'
                   });

setParameters(varargin);

extractDate=str2func(extractDateScript);

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
%%% Clustering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t0=clock;
fprintf('Start clustering (%d documents, %d topics, #nCluster= %d)...\n',...
        length(kProcess),size(dataMatrix,2),length(nClusters));

switch clusterMethod
    
  case 'kmeans'
    %% kmeans clustering (with given distance)
    idx=zeros(size(dataMatrix,2),length(nClusters));
    conf=zeros(size(dataMatrix,2),length(nClusters));
    centroids=cell(length(nClusters),1);

    for i=1:length(nClusters)
        [idx(:,i),centroids{i},dummy,distances]=kmeans(...
            full(dataMatrix(kProcess,:)'),nClusters(i),...
            'distance',clusteringDistance,'replicates',replicates,...
            'MaxIter',200,'display','iter');
        nClusters(i)=length(unique(idx(:,i)));
        conf(:,i)=distances(sub2ind(size(distances),(1:length(idx(:,i)))',idx(:,i)));
        if any(conf(:,i)~=min(distances,[],2))
            error('kmeans classification does not match minimum distance\n');
        end
    end
    tree={};

    outputPrefix=sprintf('%s+kmeans+%d_%d',...
                         outputPrefix,min(nClusters),max(nClusters));

  case 'hkmeans'
    %% hierarchical kmeans clustering (with given distance)
    idx=myhkmeans(full(dataMatrix(kProcess,:)'),branchesPerNode,...
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

    outputPrefix=sprintf('%s+hkmeans+%d_%d',...
                         outputPrefix,min(nClusters),max(nClusters));
  case 'linkage'
    %% linkage average clustering with Euclidean distance
    nClusters=round(logspace(log10(minNClusters),log10(maxNClusters),treeDepth))
    tree=linkage(dataMatrix(kProcess,:)','average',clusteringDistance);
    idx=cluster(tree,'MaxClust',nClusters);

    dendrogram(tree,0);
    print('-depsc',[outputPrefix,'+dendrogram.eps']);
    
    nClusters=zeros(size(idx,2),1);
    for i=1:size(idx,2)
        nClusters(i)=length(unique(idx(:,i)));
    end
    fprintf('linkage: # of clusters\n');
    fprintf('         %8.0f\n',nClusters);

    outputPrefix=sprintf('%s+linkage+%d_%d',...
                            outputPrefix,minNClusters,maxNClusters);
    
    figure(gcf+1);clf
    old=get(0,'RecursionLimit');
    set(0,'RecursionLimit',1000);
    dendrogram(tree,30,'colorthreshold','default','label',num2str(idx(:,end)))
    set(0,'RecursionLimit',old);

  otherwise,
    error('unknown method ''%s''\n',clusterMethod);
end

fprintf('Clustering done (%f sec)\n',etime(clock,t0));

%% expand clusters back to the full matrix (-1, not clustered)

clusters=idx;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Reconstruct 'meta topics'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nameColsNew=nameCols; % save nameCols

load(dataSource,'WPNEW','WONEW','BETA','nameCols'); % LDACOL statistics
nameColsOld=nameCols;

nameCols=nameColsNew; % retrieve nameCols

if length(nameColsOld)~=length(nameColsNew)
    warning(['clusterTopics: inputMatrix\n\t''%s''\nhas %d topics, but ' ...
             'dataSource\n\t''%s''\nhas %d topics. This should not be a ' ...
             'problem, if caused by removal of some topics.\n'],...
            inputMatrix,length(nameColsNew),dataSource,length(nameColsOld));
end
    
% match column names
new2old=sparse([],[],[],length(nameColsOld),length(nameColsNew));
for i=1:length(nameColsNew)
    k=find(strcmp(nameCols{i},nameColsOld));
    if length(k)~=1
        error('error finding topic ''%s'' (%d)\n',nameColsNew{i},length(k))
    end
    new2old(k,i)=1;
end

fprintf('Saving topic words in table... ');
t0=clock;
fid=fopen(sprintf('%s+clusters_words.tab',outputPrefix),'w');
% header
fprintf(fid,'clusterLevel\tclusterID\twords\n');
% data

topicsCluster=cell(size(clusters,2),1);
for i=1:size(clusters,2)
    fprintf('level %d ',i);
    Tnew=sparse(1:size(clusters,1),clusters(:,i),ones(size(clusters,1),1));

    % remove phantom clusters with zero topics
    k=find(sum(Tnew)==0);
    topicsCluster{i}.IDs=1:size(Tnew,2);
    Tnew(:,k)=[];
    topicsCluster{i}.IDs(k)=[];

    % add clustered topics
    thisWP=WPNEW*new2old*Tnew;

    topicsCluster{i}.words=WriteTopics(thisWP,BETA,WONEW,40,1.0);

    for j=1:length(topicsCluster{i}.words)
        % no more than 250 char per field for ArcGIS
        % and replace " by ;'
        txt=regexprep(topicsCluster{i}.words{j}(1:min(end,230)),'"','''');
        fprintf(fid,'%d\t%d\t%s\n',i,topicsCluster{i}.IDs(j),txt);
    end
end
fclose(fid);
fprintf('done (%f sec)\n',etime(clock,t0));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Save clustering results in a .mat file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Saving clusters in .mat file... ');
t0=clock;

save(sprintf('%s.mat',outputPrefix),...%'-v7.3',...
     'dataMatrix','nameCols','metaDocs','nameDocs',...
     'clusters','tree','nClusters','topicsCluster');

fprintf('done (%f sec)\n',etime(clock,t0));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Prepare time series
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if includeTimeSeries

    %% Extract dates from metadata
    kDate=find(strcmp(dateHeader,metaHeaders));
    yyyymmdd=extractDate(metaDocs(:,kDate));
    
    %% Remove documents with no year
    kNoYear=find(yyyymmdd(:,1)<0);
    
    if ~isempty(kNoYear)
        fprintf('%d out of %d documents have no year - will be ignored\n',length(kNoYear),size(dataMatrix,1));
        dataMatrix(kNoYear,:)=[];
        nameDocs(kNoYear)=[];
        metaDocs(kNoYear,:)=[];
        yyyymmdd(kNoYear,:)=[];
    end
    fprintf('documents years in the range %d-%d\n',min(yyyymmdd(:,1)),max(yyyymmdd(:,1)));
    
    %% Set no month to January, when month is missing
    kNoMonth=find(yyyymmdd(:,2)<0);
    
    if ~isempty(kNoMonth)
        yyyymmdd(kNoMonth,2)=1;
        fprintf('%d out of %d documents have no month - set to January\n',length(kNoMonth),size(dataMatrix,1));
    end
    
    %% construct dates from year+month in decimal format
    dateDocs=periodInYears*...
             round((yyyymmdd(:,1)+(yyyymmdd(:,2)-1)/12)...
                   /periodInYears);
    
    %% sum all documents in the same period
    dates=unique(dateDocs);
    topicByDate=zeros(length(dates),size(dataMatrix,2));
    for i=1:length(dates)
        k=find(dateDocs==dates(i));
        topicsByDate(i,:)=sum(dataMatrix(k,:),1);
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Save topics hierarchy in table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% order topics by cluster
[dummy,kOrder]=sortrows(clusters);

fprintf('Saving topic words in table... ');
t0=clock;
fid1=fopen(sprintf('%s+clusters_manyeyes.tab',outputPrefix),'w');
fid2=fopen(sprintf('%s+clusters_hierarchy.tab',outputPrefix),'w');
% header manyeyes
fprintf(fid1,'Level%d',1);
fprintf(fid1,'\tLevel%d',2:length(topicsCluster));
% header hierarchy
fprintf(fid2,'topicID\ttopic');
fprintf(fid2,'\tLevel%d\tWords%d',kron(1:length(topicsCluster),[1,1]));

if includeTimeSeries
    fprintf(fid1,'\t%g',dates);
end
fprintf(fid1,'\n');
fprintf(fid2,'\n');
% data
for i=kOrder'
    % data hierarchy
    fprintf(fid2,'%d\t%s',i,nameCols{i});

    lastWords='';
    for j=1:size(clusters,2)
        k=find(clusters(i,j)==topicsCluster{j}.IDs);

        if j>1
            fprintf(fid1,'\t');
        end
        % no more than 250 char per field for ArcGIS
        % and replace " by ;'
        txt=regexprep(topicsCluster{j}.words{k}(1:min(end,230)),'"','''');
        if strcmp(lastWords,topicsCluster{j}.words{k})
            fprintf(fid1,'L%d-%d:(%s)',j,topicsCluster{j}.IDs(k),txt);
            fprintf(fid2,'\t%d\t(same)',topicsCluster{j}.IDs(k));
        else
            fprintf(fid1,'L%d-%d:%s',j,topicsCluster{j}.IDs(k),txt);
            fprintf(fid2,'\t%d\t%s',topicsCluster{j}.IDs(k),txt);
            lastWords=topicsCluster{j}.words{k};
        end
    end
    if includeTimeSeries
        fprintf(fid1,'\t%f',topicsByDate(:,i));
    end
    fprintf(fid1,'\n');
    fprintf(fid2,'\n');
end
fclose(fid1);
fclose(fid2);
fprintf('done (%f sec)\n',etime(clock,t0));

