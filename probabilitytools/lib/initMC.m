function data=initMC();
% data=initMC()
%
% Initialize Monte Carlo data collection
%
% Output
% ------
%
% data : structure where data from Monte Carlo simualtions will be stored
%        initMC() return this array with no data, ready for subsequent
%        calls to add2MC().

data.N=0;
data.sum=0;
data.sum2=0;
