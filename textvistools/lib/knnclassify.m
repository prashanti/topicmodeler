function class=knnclassify(dataMatrix,training,groups,...
                     numberNeighbors,classifyDistance);
% knn classifier
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
 
%% This would probably be much faster, but it requires the statistical
%% toolbox 7.3.
%kdtree = kdtreesearcher(training,'distance',classifyDistance);
%idx=knnsearch(kdtree,dataMatrix,'K',numberNeighbors);
%class=groups(idx);

verboseLevel=(size(dataMatrix,1)>1000);

%% This code below is quite slow for a large number of rows in dataMatrix
%% and could be optimized, e.g., by processing blocks of rows  (not the
%% whole matrix because of memory). However, it is probably not worth the
%% investiment given that it may become obsolete with the statistical
%% toolbox 7.3

if numberNeighbors>1
    error('knnclassify: only numberNeighbors=1 implemented, %d requested',...
          numberNeighbors);
end

one=ones(size(training,1),1);
class=NaN*ones(size(dataMatrix,1),1);

switch classifyDistance
  case 'cosine'
    % Normalize training vectors
    d=sqrt(sum(training.^2,2));
    training=training./(d*ones(1,size(training,2)));
    
    for i=1:size(dataMatrix,1)
        if mod(i,1000)==0
            fprintf('classifying sample %6d out of %6d\r',i,size(dataMatrix,1));
        end
        % Compute inner product
        % no need to normalize dataMatrix since multiplication by constant
        % does change maximum 
        d=sum(training.*(one*dataMatrix(i,:)),2); % inner product
        [dummy,k]=max(d);
        class(i)=groups(k);
    end
    
  case 'euclidean'
    
    for i=1:size(dataMatrix,1)
        if mod(i,1000)==0
            fprintf('classifying sample %6d out of %6d\r',i,size(dataMatrix,1));
        end
        d=sum((training-(one*dataMatrix(i,:))).^2,2); % inner product
        [dummy,k]=min(d);
        class(i)=groups(k);
    end
  
  otherwise
    error('knnclassify: classifyDistance=''%s'' not implemented\n',...
          classifyDistance);
end