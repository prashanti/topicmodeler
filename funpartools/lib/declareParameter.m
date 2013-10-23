function declareParameter(varargin)
% declareParameter(...
%     'VariableName','string with the name of the variable',...
%     'DefaultValue',default value for the variable; assigned if
%                      (1) not present in the list of parameters passed
%                          to the function, and
%                      (2) a value cannot be recoved from the
%                          ''parametersMfile'' in a variable named
%                           parameters.'callerFunction'.'VariableName'
%     'AdmissibleValues',{ list of admissible value for the variable },...
%     'Description',{ 
%                    'variable description (line 1)'
%                    'variable description (line 2)'
%                    ... })
%
% Declares an input parameter for a function
%
% The first times it is called, declares the following 'standard' parameters:
%
% declareParameter(...
%     'VariableName','verboseLevel',...
%     'DefaultValue',0,...
%     'Description', {
%         'Level of verbose for debug outputs (0 - for no debug output)'});
% declareParameter(...
%     'VariableName','parametersMfile',...
%     'DefaultValue','',...
%     'Description', {
%         'Filename of a .m file with global parameters values.'
%         'Variables defined in this script are used to initialize'
%         'parameters not present in the list of parameters passed'
%         'to the function.'
%         'Alternatively, it may simply be a valid MATLAB command that'
%         'creates variables used to initialize parameters.'
%         });
% declareParameter(...
%     'VariableName','commonPath',...
%     'DefaultValue','',...
%     'Description', {
%         'Path that can be prefixed to given filenames'
%         'NOT YET IMPLEMENTED'
%         });
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

verboseLevel=0;

callerName=dbstack(1);
callerName=callerName(1).name;

%% Get localVariables_ from caller's workspace

if evalin('caller','~exist(''localVariables_'',''var'')')
    % first time it is called, create 'standard' parameters
    if verboseLevel
        fprintf('declareParameter(%s): Initializing ''localVariables_'' in caller''s workspace\n',callerName);
    end
    callerVariables{1,1}.VariableName='verboseLevel';
    callerVariables{1,1}.DefaultValue=0;
    callerVariables{1,1}.Description={
        'Level of verbose for debug outputs (0 - for no debug output)'};
    callerVariables{2,1}.VariableName='parametersMfile';
    callerVariables{2,1}.DefaultValue='';
    callerVariables{2,1}.Description={
        'Filename of a .m file with global parameters values.'
        'Variables defined in this script can be used to initialize'
        'parameters not present in the list of parameters passed'
        'to the function.'
        'Within thus script one should crate variables with name'
        '   FunctionName.VariableName'
        'where ''FunctionName'' is the name of the function that'
        'needs this parameter and ''VariableName'' is the parameter'
        'passed to declareParameter'
                   };
else
    % add to existing parameter list
    callerVariables=evalin('caller','localVariables_');
end

thisVariable=[];

%% Go over list of inputs
i=1;
while i<length(varargin)
    if isfield(thisVariable,varargin{i})
        error('declareParameter(%s): Only one ''%s'' allowed\n',callerName,varargin{i})
    end
    switch varargin{i}
      case 'Help'
        thisVariable.VariableName='Help_';
        thisVariable.Description=varargin{i+1};
        i=i+2;
      case 'VariableName'
        thisVariable.VariableName=varargin{i+1};
        if exist(thisVariable.VariableName,'builtin')
            error('declareParameter(%s): Variable name ''%s'' is a builtin function\n',callerName,thisVariable.VariableName);
        end
        % if exist(thisVariable.VariableName,'file')
        %     error('declareParameter(%s): Variable name ''%s'' is an m-script (%s)\n',callerName,thisVariable.VariableName,which(thisVariable.VariableName));
        % end
        i=i+2;
      case 'DefaultValue'
        thisVariable.DefaultValue=varargin{i+1};
        i=i+2;
      case 'AdmissibleValues'
        thisVariable.AdmissibleValues=varargin{i+1};
        i=i+2;
      case 'Description'
        thisVariable.Description=varargin{i+1};
        i=i+2;
      otherwise
        error('declareParameter(%s): Unknown input type ''%s''\n',callerName,varargin{i});
    end
end

if ~isfield(thisVariable,'VariableName')
    error('declareParameter(%s): ''VariableName'' required\n',callerName);
end

%% Assign localVariables_ to caller's workspace

callerVariables{end+1,1}=thisVariable;

assignin('caller','localVariables_',callerVariables);