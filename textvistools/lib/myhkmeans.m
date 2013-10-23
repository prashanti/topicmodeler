function [tree,asgn]=myhkmeans(data,k,varargin)
% myhkmeans  Hierachical integer K-means
%      asgn = myhkmeans(data,k,nleaves,...kmeans parameters...)
%   or
%      [tree,asgn] = myhkmeans(data,k,nleaves,...kmeans parameters...)
%
%   Applies recursively K-means to cluster the data 'data', returing a
%   structure 'tree' representing the clusters and a vector 'asgn'
%   with the data to cluster assignments. The depth of the recursive
%   partition is computed until all leave have vector
%
%   'tree' is a structure representing the hierarchical clusters.  Each
%   node of the tree is also a structure with fields:
%   
%   'depth'    Depth of the tree (only at the root node)
%   'centers'  K cluster centers
%   'sub'      Array of K node structures representing subtrees 
%              (this field is missing at leaves).
%
%   'asgn' is a matrix with one column per datum and height equal to the
%   depth of the tree. Each column encodes the branch of the tree that
%   correspond to each datum.
%
%   When the 'tree' output argument is not included, the tree is
%   not computed saving a signficant ammount of memory
%
%   Example::
%     'asgn'(:,7) = [1 5 3] means that the tree as depth equal to 3 and
%     that the datum X(:,7) corresponds to the branch
%     ROOT->SUB(1)->SUB(5)->SUB(3).
%
%  Inspired by VL_HIKMEANS from Andrea Vedaldi and Brian Fulkerson 
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

if nargout>1
    tree.depth=1;
end

if size(data,1)<=k
    % end of recursion
    %    fprintf('myhkmeans: trivial classification(%d vectors,%d classes)...\n',size(data,1),k);
    if nargout>1
        tree.centers=data;
        tree.sub={};
    end
    asgn=(1:size(data,1))';

    if nargout==1
        tree=asgn;
    end
    return
end

if prod(size(data))>250000
    fprintf('myhkmeans: running kmeans(%d vectors,%d classes)...\n',size(data,1),k);
end
[idx,tree.centers]=kmeans(data,k,'EmptyAction','singleton',varargin{:});
if prod(size(data))>250000
    fprintf('  [classes, counts]\n')
    n=hist(idx,unique(idx))';
    disp([unique(idx),n])
end

if nargout>1
    tree.sub=cell(length(idx),1);
end
asgn=zeros(size(data,1),1);

for i=1:length(idx)
    ci=find(idx==i);
    if nargout>1
        [subtree,subasgn]=myhkmeans(data(ci,:),k,varargin{:});

        % add subtree to tree (except depth)
        tree.sub{i}.centers=subtree.centers;
        tree.sub{i}.sub=subtree.sub;
        
        % update tree depth
        tree.depth=max(tree.depth,subtree.depth+1);
    else
        subasgn=myhkmeans(data(ci,:),k,varargin{:});
    end
    
    asgn(ci,1)=i;
    asgn(ci,2:size(subasgn,2)+1)=subasgn;
end

% replace zeros (shorter subtrees) by ones
kz=find(asgn==0);
asgn(kz)=1;

%asgn
    
if nargout==1
    tree=asgn;
end
