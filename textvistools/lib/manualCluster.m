function [idx,conf,classifierOutput]=manualCluster(...
    dataMatrix,nameDocs,nameCols,flog,trainingFile,...% inputs for manual and supervised
    testingFile,classifierType,...                  % inputs for supervised
    zeroMeanTopics,dimPCA,...
    FisherLinearDiscriminant,...
    excludesLeaveKoutTest,repeatsLeaveKoutTest,...
    numberNeighbors,classifyDistance,...            % inputs for knnclassify
    path2tvt,sizeCodebook,nBalance,trainingLength); % inputs for olvq1

% This script is used by cluster4SOM
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
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read file with training clustering
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remove paths to facilitate match
nameDocs=regexprep(nameDocs,'^.*/','');

[trainNames,trainCodes]=textread(trainingFile,'%[^\t]%d%*q',...
                           'headerlines',1,'delimiter','\t');
trainNames=regexprep(trainNames,'^.*/','');

if ~isempty(testingFile)
    [testNames,testCodes]=textread(testingFile,'%[^\t]%d%*q',...
                               'headerlines',1,'delimiter','\t');
    testNames=regexprep(testNames,'^.*/','');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Assign codes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Training data
fprintf('Read %d document training codes\n      Training codes\tCounts:\n',length(trainCodes));
fprintf(flog,'Read %d document training codes\n      Training codes\tCounts:\n',length(trainCodes));
n=hist(trainCodes,unique(trainCodes))';
fprintf('   %8.0f\t%8.0f\n',[unique(trainCodes),n]');
fprintf(flog,'   %8.0f\t%8.0f\n',[unique(trainCodes),n]');

k=find(trainCodes<0);
if ~isempty(k)
    fprintf('found %d trainCodes<0, set then to -1\n',length(k));
    fprintf(flog,'found %d trainCodes<0, set then to -1\n',length(k));
    trainCodes(k)=-1;
end

nErrFind=0;
idx=-ones(length(nameDocs),1);
conf=-ones(length(nameDocs),1);
for i=1:length(trainNames)
    % remove paths to facilitate match
    trainNames{i}=regexprep(trainNames{i},'^.*/','');
    trainN=find(strcmp(trainNames{i},nameDocs));

    if length(trainN)~=1
        fprintf('manualCluster: error finding document ''%s''\n',trainNames{i});
        fprintf(flog,'manualCluster: error finding document ''%s''\n',trainNames{i});
        nErrFind=nErrFind+1;
    else
        if idx(trainN)~=-1
            fprintf('manualCluster: multiple copies of ''%s'' in the training set, last with code ''%d'' (previously ''%d'')\n',...
                    trainNames{i},trainCodes(i),idx(trainN));
            fprintf(flog,'manualCluster: multiple copies of ''%s'' in the training set, last with code ''%d'' (previously ''%d'')\n',...
                    trainNames{i},trainCodes(i),idx(trainN));
        end
        idx(trainN)=trainCodes(i);
        conf(trainN)=1;
    end

end

fprintf('manualCluster: a total of %d out of %d training documents could not be found\n',...
        nErrFind,length(trainNames));
fprintf(flog,'manualCluster: a total of %d out of %d training documents could not be found\n',...
        nErrFind,length(trainNames));

%% Testing data
if ~isempty(testingFile) && length(testCodes)>0
    fprintf('Read %d document testing codes\n      Testing codes\tCounts:\n',length(testCodes));
    fprintf(flog,'Read %d document testing codes\n      Testing codes\tCounts:\n',length(testCodes));
    n=hist(testCodes,unique(testCodes))';
    fprintf('   %8.0f\t%8.0f\n',[unique(testCodes),n]');
    fprintf(flog,'   %8.0f\t%8.0f\n',[unique(testCodes),n]');

    nErrFind=0;
    kTest=NaN*ones(length(testCodes),1);
    for i=1:length(testNames)
        % remove paths to facilitate match
        testNames{i}=regexprep(testNames{i},'^.*/','');
        testN=find(strcmp(testNames{i},nameDocs));
        
        if length(testN)~=1
            fprintf('manualCluster: error finding document ''%s''\n',testNames{i});
            fprintf(flog,'manualCluster: error finding document ''%s''\n',testNames{i});
            nErrFind=nErrFind+1;
        else
            kTest(i)=testN;
        end
    end
    
    fprintf('manualCluster: a total of %d out of %d testing documents could not be found\n',...
            nErrFind,length(testNames));
    fprintf(flog,'manualCluster: a total of %d out of %d testing documents could not be found\n',...
            nErrFind,length(testNames));

end
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Automatic classification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin>3 && ~isempty(classifierType)

    classifierOutput=struct();

    %% Make each topic zero mean (each column adds to zero)
    if zeroMeanTopics
        classifierOutput.mu=sum(dataMatrix,1)/size(dataMatrix,1);
        dataMatrix=dataMatrix-ones(size(dataMatrix,1),1)*classifierOutput.mu;
        fprintf('Made every column add up to zero\n');
        fprintf(flog,'Made every column add up to zero\n');
    end
        
    %% Use PCA to reduce the matrix dimension
    if nargin>4 && dimPCA<size(dataMatrix,2)
        [classifierOutput.v_svd,classifierOutput.sigma_svd,flag]=...
            eigs(dataMatrix'*dataMatrix,dimPCA);
        if flag
            error('manualCluster: eigs did not converge\n');
        end
        dataMatrix=dataMatrix*classifierOutput.v_svd;
        classifierOutput.v=classifierOutput.v_svd;
        if zeroMeanTopics
            str='PCA';
        else
            str='SVD';
        end
        fprintf('Applied %s to reduce dimensionality from %d to %d dimensions\n',...
                str,size(classifierOutput.v,1),size(classifierOutput.v,2));
        fprintf(flog,'Applied %s to reduce dimensionality from %d to %d dimensions\n',...
                str,size(classifierOutput.v,1),size(classifierOutput.v,2));
    else
        classifierOutput.v=eye(size(dataMatrix,2));
        fprintf('Kept all %d dimensions\n',size(dataMatrix,2));
        fprintf(flog,'Kept all %d dimensions\n',size(dataMatrix,2));
    end
    
    kTrain=find(idx>=0);
    
    training=dataMatrix(kTrain,:);

    trainCodes=idx(kTrain);
    uGroupsTrain=unique(trainCodes);
    
    n=hist(trainCodes,uGroupsTrain)';
    fprintf('     Training groups\t# training samples]\n');
    fprintf('   %8.0f\t%8.0f\n',[uGroupsTrain,n]');
    fprintf(flog,'     Training groups\t#training samples]\n');
    fprintf(flog,'   %8.0f\t%8.0f\n',[uGroupsTrain,n]');

    %% Use Fisher Linear Discriminant for dimensionality reduction
    if FisherLinearDiscriminant
        classifierOutput.Sb=zeros(size(training,2),size(training,2));
        classifierOutput.Sw=zeros(size(training,2),size(training,2));
        mu=sum(training,1)/size(training,1);
        for i=uGroupsTrain'
            k=find(trainCodes==i);
            mui=sum(training(k,:),1)/length(k);
            classifierOutput.Sb=classifierOutput.Sb+length(k)*(mu-mui)'*(mu-mui);
            classifierOutput.Sw=classifierOutput.Sw+...
                (training(k,:)-ones(length(k),1)*mui)'*(training(k,:)-ones(length(k),1)*mui);
        end
        [classifierOutput.v_fisher,classifierOutput.sigma_fisher,flag]=eigs(classifierOutput.Sb,classifierOutput.Sw,length(uGroupsTrain)-1);
        if flag
            error('manualCluster: eigs did not converge\n');
        end
        training=training*classifierOutput.v_fisher;
        classifierOutput.v=classifierOutput.v*classifierOutput.v_fisher;
        
        fprintf('applied FLD to reduce dimensionality from %d to %d dimensions\n',...
                size(classifierOutput.v_fisher,1),size(classifierOutput.v_fisher,2));
        fprintf(flog,'applied FLD to reduce dimensionality from %d to %d dimensions\n',...
                size(classifierOutput.v_fisher,1),size(classifierOutput.v_fisher,2));
    else
        classifierOutput.v_fisher=eye(size(dataMatrix,2));
    end

    switch classifierType
        
      case {'linear','diagLinear','quadratic','diagQuadratic','mahalanobis'}
        [class,err,posterior,logp,coef]=classify(...
            dataMatrix*classifierOutput.v_fisher,...
            training,trainCodes,classifierType);
        classifierOutput.coef=coef;
        % classifier error rate estimate
        fprintf('Supervised classifier ''%s'' estimates %4.1f%% misclassification error rate\n',classifierType,100*err);
        fprintf(flog,'Supervised classifier ''%s'' estimates %4.1f%% misclassification error rate\n',classifierType,100*err);
       
        % compute confidence (= posterior for the guessed class)
        if ~isempty(posterior)
            % posterior probability of the right class
            [i,j]=find(class*ones(1,size(posterior,2))==...
                       ones(size(posterior,1),1)*uGroupsTrain');
            [i,k]=sort(i);
            j=j(k);
            conf=posterior(sub2ind(size(posterior),i,j));
            if any(conf~=max(posterior,[],2))
                error('classification does not match maximum posterior\n');
            end
        end
    
        if strcmp(classifierType,'linear') || ...
                strcmp(classifierType,'diagLinear')
            fprintf('\nLinear classifier rule:\n');
            fprintf(flog,'\nLinear classifier rule:\n');
            for k1=1:size(classifierOutput.coef,1)
                for k2=1:size(classifierOutput.coef,2)
                    %                    classifierOutput.coef(k1,k2)
                    if ~isempty(classifierOutput.coef(k1,k2).linear)
                        fprintf('  Group %d versus %d coefficients\n',...
                                classifierOutput.coef(k1,k2).name1,...
                                classifierOutput.coef(k1,k2).name2);
                        fprintf(flog,'  Group %d versus %d coefficients\n',...
                                classifierOutput.coef(k1,k2).name1,...
                                classifierOutput.coef(k1,k2).name2);
                        % adjust for dimensionality reduction
                        if isfield(classifierOutput,'v')
                            L=classifierOutput.v*classifierOutput.coef(k1,k2).linear;
                        else
                            L=classifierOutput.coef(k1,k2).linear;
                        end
                        % display coeffs sorted by weight
                        [dummy,k3]=sort(abs(L),'descend');
                        for k4=k3'
                            fprintf('      L=%8.2f: topic %3d = %s\n',L(k4),k4,nameCols{k4}(1:min(end,80)));
                            fprintf(flog,'      L=%8.2f: topic %3d = %s\n',L(k4),k4,nameCols{k4}(1:min(end,80)));
                        end
                        % adjust for zero-mean
                        if isfield(classifierOutput,'mu')
                            K=classifierOutput.coef(k1,k2).const-classifierOutput.mu*L;
                        else
                            K=classifierOutput.coef(k1,k2).const;
                        end
                        fprintf('  group %d chosen over %d if L * topics > %.4f\n',...
                                classifierOutput.coef(k1,k2).name1,...
                                classifierOutput.coef(k1,k2).name2,-K);
                        fprintf(flog,'  group %d chosen over %d if L * topics > %.4f\n',...
                                classifierOutput.coef(k1,k2).name1,...
                                classifierOutput.coef(k1,k2).name2,-K);
                    end
                end
            end
        end
        
      case 'olvq1'
        class=olvq1(dataMatrix*classifierOutput.v_fisher,...
                    training,trainCodes,...
                    path2tvt,sizeCodebook,nBalance,trainingLength);
        coef=NaN;
        fprintf('Supervised classifier ''%s'' finished\n',classifierType);
        fprintf(flog,'Supervised classifier ''%s'' finished\n',classifierType);
        
      case 'knn'
        class=knnclassify(dataMatrix*classifierOutput.v_fisher,...
                          training,trainCodes,...
                          numberNeighbors,classifyDistance);
        
        conf=NaN*class;
        fprintf('Supervised classifier ''%s'' finished\n',classifierType);
        fprintf(flog,'Supervised classifier ''%s'' finished\n',classifierType);
        
      otherwise,
        error('unknown supervised classification method ''%s''\n',classifierType);
    end
    
    %% classification
    idx=class;
   
    %% Training set error rate
    validateClustering(flog,'training data',...
                       kTrain,trainCodes,idx(kTrain),conf(kTrain));
    set(gcf,'Name','Training data');
    %% Testing set error rate
    if ~isempty(testingFile) && length(testCodes)>0
        validateClustering(flog,'testing data',...
                           kTest,testCodes,idx(kTest),conf(kTest));
        set(gcf,'Name','Testing data');
    end

    %% Leave-K-out error rate
    k=rand(length(kTrain),1);
    [dummy,k]=sort(k);  % compute permutation
    validateClustering(flog,sprintf('leave-%d-out',excludesLeaveKoutTest),...
                       kTrain(k),trainCodes(k),[],conf(kTrain(k)),...
                       excludesLeaveKoutTest,repeatsLeaveKoutTest,...
                       dataMatrix(kTrain(k),:),classifierType,...
                       FisherLinearDiscriminant,...
                       numberNeighbors,classifyDistance,... 
                       path2tvt,sizeCodebook,nBalance,trainingLength);
    set(gcf,'Name',sprintf('Leave-%d-out data',excludesLeaveKoutTest));
    

    %% Add training & testing classification to 2nd columns of idx
    idx(:,2)=-1;
    conf(:,2)=-1;
    idx(kTrain,2)=trainCodes;
    conf(kTrain,2)=1;
    if ~isempty(testingFile) && length(testCodes)>0
        idx(kTest,2)=testCodes;
        conf(kTest,2)=1;
    end
end

%% validation function
function validateClustering(flog,type,...
                            ndx,truth,guess,conf,...
                            excludesLeaveKoutTest,repeatsLeaveKoutTest,...
                            data,classifierType,...
                            FisherLinearDiscriminant,...
                            numberNeighbors,classifyDistance,... 
                            path2tvt,sizeCodebook,nBalance,trainingLength)
    
CI=.95;

if nargin<7
    excludesLeaveKoutTest=1;
    repeatsLeaveKoutTest=inf;
else
    guess=NaN*ones(size(truth));
end

fprintf('\nValidation type: %s\n',type);
fprintf(flog,'\nValidation type: %s\n',type);
dataAll=initMC();
uTruth=unique(truth);
for j=1:length(uTruth)
    dataGroups{j}=initMC();
end
status{1}='okay ';
status{2}='ERROR';
for i=1:excludesLeaveKoutTest:...
      min(length(truth)-excludesLeaveKoutTest+1,...
          repeatsLeaveKoutTest*excludesLeaveKoutTest);
    if nargin<7
        % testing or training data
        thisNdx=ndx(i);
        thisTruth=truth(i);
        thisConf=conf(i);
        thisGuess=guess(i);
    else
        % leave-K-out
        excludes=i:i+excludesLeaveKoutTest-1;
        keep=[1:i-1,i+excludesLeaveKoutTest:length(truth)];

        thisNdx=ndx(excludes);
        thisTruth=truth(excludes);
        thisConf=conf(excludes);
        
        training=data(keep,:);
        trainCodes=truth(keep);
        testing=data(excludes,:);
        
        %% Use Fisher Linear Discriminant for dimensionality reduction
        if FisherLinearDiscriminant
            uGroupsTrain=unique(trainCodes);

            %% training=data;    %% cheating 
            %% trainCodes=truth; %% cheating 

            Sb=zeros(size(training,2),size(training,2));
            Sw=zeros(size(training,2),size(training,2));
            mu=sum(training,1)/size(training,1);
            for j=uGroupsTrain'
                k=find(trainCodes==j);
                mui=sum(training(k,:),1)/length(k);
                Sb=Sb+length(k)*(mu-mui)'*(mu-mui);
                Sw=Sw+...
                   (training(k,:)-ones(length(k),1)*mui)'*(training(k,:)-ones(length(k),1)*mui);
            end
            [v_fisher,sigma_fisher,flag]=eigs(Sb,Sw,length(uGroupsTrain)-1);
            if flag
                error('manualCluster: eigs did not converge\n');
            end

            %% training=data(keep,:);  %% cheating 
            %% trainCodes=truth(keep); %% cheating 

            training=training*v_fisher;
            testing=testing*v_fisher;
        end

        
        if ~any(isnan(thisTruth))
            switch classifierType
              case {'linear','diagLinear','quadratic','diagQuadratic','mahalanobis'}
                thisGuess=classify(testing,training,trainCodes,classifierType);
              case 'olvq1'
                thisGuess=olvq1(testing,training,trainCodes,...
                                path2tvt,sizeCodebook,nBalance,trainingLength);
              case 'knn'
                thisGuess=knnclassify(testing,training,trainCodes,...
                                      numberNeighbors,classifyDistance);
              otherwise
                error('unknown supervised classification method ''%s''\n',classifierType);
            end
            guess(excludes)=thisGuess;
        end
    end    
    
    if ~any(isnan(thisTruth))
        % overall errors
        kErrAll=(thisGuess~=thisTruth);
        samples=num2cell(kErrAll);
        dataAll=add2MC(dataAll,samples{:});
        
        % groups-specific errors
        for j=1:length(uTruth)
            k=(thisTruth==uTruth(j));
            if any(k)
                dataGroups{j}=add2MC(dataGroups{j},samples{k});
            end
        end
        
        % print matching
        for j=1:length(kErrAll)
            fprintf(flog,'   sample %5d: %5s truth=%3d (conf =%5.2f%%), guess=%3d\n',...
                    thisNdx(j),status{kErrAll(j)+1},...
                    thisTruth(j),100*thisConf(j),thisGuess(j));
        end
    end
    
    % periodic output of error rate estimates
    if i==length(truth) || ...
        (nargin>=7 && ~strcmp(classifierType,'olvq1') && mod(i,10)==0) || ...
        (nargin>=7 && strcmp(classifierType,'olvq1') && mod(i,100)==0) 
        [mean,stddev,meanCIlow,meanCIhigh,stddevCIlow,stddevCIhigh]...
            =estimMC(dataAll,CI);
        fprintf(    'Overall error rate estimate     (sample %5d out of %5d): %5.2f%% in [%5.2f%%,%5.2f%%] (%2.0f%% CI)\n',...
                i,length(truth),100*mean,100*meanCIlow,100*meanCIhigh,100*CI);
        fprintf(flog,'Overall error rate estimate     (sample %5d out of %5d): %5.2f%% in [%5.2f%%,%5.2f%%] (%2.0f%% CI)\n',...
                i,length(truth),100*mean,100*meanCIlow,100*meanCIhigh,100*CI);
        
        for j=1:length(uTruth)
            [mean,stddev,meanCIlow,meanCIhigh,stddevCIlow,stddevCIhigh]...
                =estimMC(dataGroups{j},CI);
            fprintf('  group %3d error rate estimate (sample %5d out of %5d): %5.2f%% in [%5.2f%%,%5.2f%%] (%2.0f%% CI)\n',...
                    uTruth(j),i,length(truth),100*mean,100*meanCIlow,100*meanCIhigh,100*CI);
            fprintf(flog,'  group %3d error rate estimate (sample %5d out of %5d): %5.2f%% in [%5.2f%%,%5.2f%%] (%2.0f%% CI)\n',...
                    uTruth(j),i,length(truth),100*mean,100*meanCIlow,100*meanCIhigh,100*CI);
        end
    end
end

%% confidence histograms

k=(truth==guess);
figure(gcf+1);clf
subplot(1,2,1)
hist(100*conf(k))
title(sprintf('Confidence of correctly classified %d samples',sum(k)));
xlabel('confidence [%]');

k=(truth~=guess);
subplot(1,2,2)
hist(100*conf(k))
title(sprintf('Confidence of incorrectly classified %d samples',sum(k)));
xlabel('confidence [%]');

drawnow