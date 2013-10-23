function k=rand_discr(p)
% k = rand_discr(p) 
% Creates a matrix of discrete random variables
%   
% Inputs and outputs:
% p - NxM matrix of probabilities with each column adding to one
%
% k - M-vector of random integers, each in the set {1:N}. The
%     probabilities of k(i) being equal to j is given by p(j,i)

k=rand(1,size(p,2));
p=cumsum(full(p),1);    % even if p is sparse, cumsum will unspasify it
                        % this is very inefficient for sparse p and
                        % should be improved
k=sum(ones(size(p,1),1)*k>p,1)+1;

return

% test

M=10000;
p=repmat([.2;.3;.5],[1,M]);
k=rand_discr(p);hist(k),grid on
