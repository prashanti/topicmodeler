function data=add2MC(data,varargin)
% data=add2MC(data,sample)
%
% data=add2MC(data,sample1,sample2,sample3,...)
%
%
% Add one (or several) realization (scalar, vector, or matrix) to a
% Monte Carlo data set.
%
% Input
% -----
%
% data : structure with data from previous Monte Carlo run to add2MC().
%        This array is initialized by initMC().
%
% sample : realization obtained from one Monte Carlo run. Can be a
%          scalar, vector or matrix, but dimensions must be maintained
%          from one call of add2MC to the next.
%
% Output
% ------
%
% data : updated structure with data from Monte Carlo runs


for i=1:length(varargin)
    if data.N>0
        data.N=data.N+1;
        data.sum=data.sum+varargin{i};
        data.sum2=data.sum2+varargin{i}.^2;
    else
        data.N=1;
        data.sum=varargin{i};
        data.sum2=varargin{i}.^2;
    end
end  
