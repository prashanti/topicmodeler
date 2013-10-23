function [mean,stddev,meanCIlow,meanCIhigh,stddevCIlow,stddevCIhigh]=...
    estimMC(data,CI)
% [mean,stddev,meanCIlow,meanCIhigh,stddevCIlow,stddevCIhigh]...
%                 =estimatesMC(data,CI)
%
% Obtain mean and stddev point estimates and confidence intervals from
% from MC data set. The CI for the standard deviation assumes a normal
% distribution.
%
% Input
% -----
%
% data : structure with data from Monte Carlo runs. Initialized by
%        initMC() and updated by add2MC().
%
% CI   : confidence interval for means and standard deviations
%
% Output
% ------
%
% mean   : estimate for the means 
% stddev : estimate for the standard deviations
%
% meanCIlow,meanCIhigh : confidence interval for the means (only
%                        returned if CI is given as an input parameter)
% stddevCIlow,stddevCIhigh : confidence interval for the standard deviations
%                        (only returned if CI is given as an input parameter)
%
% all outputs are of the same size as the samples processed by add2MC().



mean=data.sum/data.N;
stddev=sqrt((data.sum2-data.N*(mean.^2))/(data.N-1));

if nargin>1
  % confidence interval for the mean  (t-distribution)
  c=tinv(1-(1-CI)/2,data.N-1);
  meanCIlow =c*stddev/sqrt(data.N);
  meanCIhigh=mean+meanCIlow;
  meanCIlow =mean-meanCIlow;

  % confidence interval for the std dev 
  %   (chi-distribution, assumes normal population)
  stddevCIlow=sqrt(data.N-1)*stddev/sqrt(chi2inv(1-(1-CI)/2,data.N-1));
  stddevCIhigh=sqrt(data.N-1)*stddev/sqrt(chi2inv((1-CI)/2,data.N-1));
end  


return

% test: page 272 of WMM
data=initMC;
data=add2MC(data,46.4);
data=add2MC(data,46.1);
data=add2MC(data,45.8);
data=add2MC(data,47.0);
data=add2MC(data,46.1);
data=add2MC(data,45.9);
data=add2MC(data,45.8);
data=add2MC(data,46.9);
data=add2MC(data,45.2);
data=add2MC(data,46.0);
[mean,stddev,meanCIlow,meanCIhigh,stddevCIlow,stddevCIhigh]=estimMC(data,.95)

