function parameters=setParameters(list_)
% parameters=setParameters(list)
%
% Assigns a list of parameters in the caller's workspace. 'list'
% is a cell array of the form
% {'variable name 1',value 1,'variable name 2', value 2,...}
%
% All parameters assigned are also returned as fields in a structure:
%   parameters.{variable name}
%
% A parameter list with a single value {'help'} results in the
% output of a help header
%
% This function is typically used within a m-script function as follows:
%
% % function [output variables]=scriptName(varargin)
% % For help on the input parameters type 'scriptName Help' 
%
% % Function global help
% declareParameter(...
%     'Help', { '...' })
%
% % Declare all input parameters, see 'help declareParameter'
% declareParameter( .... ); 
%
% % Assign parameters
% setParameters(varargin);
%
% % Start main code here
%
% Copyright (C) 2010  Joao Hespanha

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

verboseLevel=0;  % 0 none, 1 less, 2 more

callerName_=dbstack(1);
callerName_=callerName_(1).name;

parameters=struct();

%% Get localVariables_ from caller's workspace

if evalin('caller','exist(''localVariables_'',''var'')')
    callerVariables=evalin('caller','localVariables_');
else
    error('setParameters(%s): Use declareParameters before calling setParameter\n',callerName_);
end

%% Print help and exit with "error"
if length(list_)==1 && strcmp(lower(list_{1}),'help')
    % print template
    fprintf('%% [...]=%s(''parameter name 1'',value,''parameter name 2'',value,...);\n%%\n',callerName_);
    % print function description
    Help_=0;
    for i_=1:length(callerVariables)
        if strcmp(callerVariables{i_}.VariableName,'Help_')
            Help_=1;
            for j_=1:length(callerVariables{i_}.Description)
                fprintf('%% %s\n',callerVariables{i_}.Description{j_});
            end
        end
    end    
    if Help_
        fprintf('%%\n');
    end
    % print input parameters
    fprintf('%% Input parameters:\n%% ----------------\n');
    for i_=1:length(callerVariables)
        if ~strcmp(callerVariables{i_}.VariableName,'Help_')
            fprintf('%%\n%% %s',callerVariables{i_}.VariableName);
            if isfield(callerVariables{i_},'DefaultValue') 
                fprintf(' [default %s]',value2str(callerVariables{i_}.DefaultValue));
            end
            if isfield(callerVariables{i_},'AdmissibleValues') 
                fprintf('\n%%    in [');
                for j_=1:length(callerVariables{i_}.AdmissibleValues)
                    fprintf('%s',value2str(callerVariables{i_}.AdmissibleValues{j_}));
                    if j_<length(callerVariables{i_}.AdmissibleValues)
                        fprintf(',');
                    else
                        fprintf(']');
                    end
                end
            end
            fprintf('\n');
            for j_=1:length(callerVariables{i_}.Description)
                fprintf('%%    %s\n',callerVariables{i_}.Description{j_});
            end
        end
    end
    fprintf('%%\n\n');
    error('setParameters(%s): Called with ''help'' -- no error\n',callerName_);
end

if mod(length(list_),2)==1
    error('setParameters(%s): Length of ''list'' must be even (%d instead)\n',callerName_,length(list_));
end

if verboseLevel>=2
    fprintf('setParameters(%s): Setting  parameters for %s(%d parameters);\n',callerName_,callerName_,length(list_)/2);
end

%% Assign values from parameter 'list'
for j_=1:2:length(list_)
    assigned=0;
    for i_=1:length(callerVariables)
        if strcmp(list_{j_},callerVariables{i_}.VariableName)
            if verboseLevel>=2
                fprintf('setParameters(%s): Explicit assignment ''%s''\n',callerName_,list_{j_})
            end
            assignin('caller',list_{j_},list_{j_+1});
            parameters=setfield(parameters,list_{j_},list_{j_+1});
            assigned=1;
            break
        end
    end    
    if ~assigned
        error('setParameters(%s): Undeclared parameter ''%s''\n',callerName_,list_{j_});
    end
end

%% Assign values from Mfile

% get value for the variable 'parametersMfile'
% (either from caller's workspace or from default value)
if evalin('caller','exist(''parametersMfile'',''var'')')
    parametersMfile=evalin('caller','parametersMfile');
else
    if verboseLevel>=2
        fprintf('setParameters(%s): Undefined ''parametersMfile'', looking for default value\n',...
                callerName_);
    end
    % look for default value
    for i_=length(callerVariables):-1:1
        if strcmp(callerVariables{i_}.VariableName,'parametersMfile') && ...
                isfield(callerVariables{i_},'DefaultValue')
            if verboseLevel>=1
                fprintf('setParameters(%s): Default  assignment %s=%s\n',...
                        callerName_,callerVariables{i_}.VariableName,...
                        value2str(callerVariables{i_}.DefaultValue));
            end
            assignin('caller',callerVariables{i_}.VariableName,...
                              callerVariables{i_}.DefaultValue); 
            parameters=setfield(parameters,callerVariables{i_}.VariableName,...
                                callerVariables{i_}.DefaultValue); 
            parametersMfile=callerVariables{i_}.DefaultValue;
            break;
        end
    end
end
   
% execute script with name in 'parametersMfile'
if exist('parametersMfile','var')
    if true % exist(parametersMfile,'file')
        for i_=length(callerVariables):-1:1
            cmd=sprintf('~exist(''%s'',''var'')',callerVariables{i_}.VariableName);
            if evalin('caller',cmd)   % already exists in caller's workspace?
                [value,success]=getFromMfile(parametersMfile,...
                             ['parameters.',callerName_,'.',callerVariables{i_}.VariableName]);
                if success
                    if verboseLevel>=1
                        fprintf('setParameters(%s): Mfile    assignment %s=%s\n',...
                                callerName_,callerVariables{i_}.VariableName,...
                                value2str(value));
                    end
                    assignin('caller',callerVariables{i_}.VariableName,value);
                    parameters=setfield(parameters,callerVariables{i_}.VariableName,value);
                else
                    if verboseLevel>=2
                        fprintf('setParameters(%s): Unassigned variable ''%s'' not in parametersMfile\n',...
                                callerName_,callerVariables{i_}.VariableName);
                    end
                end
            end
        end
    else
        if verboseLevel>=2
            fprintf('setParameters(%s): Mfile does not exist: parametersMfile=''%s''\n',...
                    callerName_,parametersMfile);
        end
    end 
else
        if verboseLevel>=2
            fprintf('setParameters(%s): Undefined variable ''parametersMfile''\n',...
                    callerName_);
        end
end

%% Assign default values
for i_=length(callerVariables):-1:1
    if isfield(callerVariables{i_},'DefaultValue')
        cmd=sprintf('~exist(''%s'',''var'')',callerVariables{i_}.VariableName);
        if evalin('caller',cmd)  % already exists in caller's workspace?
            if verboseLevel>=1
                fprintf('setParameters(%s): Default  assignment %s=%s\n',...
                        callerName_,callerVariables{i_}.VariableName,...
                        value2str(callerVariables{i_}.DefaultValue));
            end
            assignin('caller',callerVariables{i_}.VariableName,...
                              callerVariables{i_}.DefaultValue);
            parameters=setfield(parameters,callerVariables{i_}.VariableName,...
                              callerVariables{i_}.DefaultValue);
        end
    end

end 

%% Check for admissible values
for i_=1:length(callerVariables)
    cmd=sprintf('exist(''%s'',''var'')',callerVariables{i_}.VariableName);
    if evalin('caller',cmd)  % exists in caller space?
        if isfield(callerVariables{i_},'AdmissibleValues')
            value=evalin('caller',callerVariables{i_}.VariableName);
            if checkAdmissible(value,callerVariables{i_}.AdmissibleValues)
                err=sprintf(['setParameters(%s): Unadmissible value %s=%s, not in\n   ['],...
                            callerName_,callerVariables{i_}.VariableName,value2str(value));
                for j_=1:length(callerVariables{i_}.AdmissibleValues)
                    err=[err,sprintf('%s',value2str(callerVariables{i_}.AdmissibleValues{j_}))];
                    if j_<length(callerVariables{i_}.AdmissibleValues)
                        err(end+1)=',';
                    else
                        err(end+1)=']';
                    end
                end
                error(err);
            end
        end
    else
        if ~strcmp(callerVariables{i_}.VariableName,'Help_')
            error('setParameters(%s): Variable ''%s'' has not been assigned\n',callerName_,callerVariables{i_}.VariableName);
        end
    end 
end
    
function err=checkAdmissible(value,admissible)

err=1;
for i=1:length(admissible)
    if strcmp(value2str(value),value2str(admissible{i}))
        err=0;
        break
    end
end

function [value_,success_]=getFromMfile(Mfile_,variable_)

verboseLevel_=0;

if verboseLevel_>0
    fprintf('About to eval(''%s'') to get ''%s''\n',Mfile_,variable_);
end

% Evaluate Mfile
eval(Mfile_);
if verboseLevel_>0
    whos
end

fields_  =textscan(variable_,'%s','Delimiter','.');
variable_=fields_{1}{1};

% Look for variable
if exist(variable_,'var')
    value_=eval(variable_);
    for i_=2:length(fields_{1})
        if (isfield(value_,fields_{1}{i_}))
            value_=getfield(value_,fields_{1}{i_});
        else
            value_=[];
            success_=0;
            return
        end
    end
    success_=1;
else
    value_=[];
    success_=0;
end
