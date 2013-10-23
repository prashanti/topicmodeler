function class=olvq1(dataMatrix,training,groups,...
                     path2tvt,sizeCodebook,nBalance,trainingLength);
% olvq1 classifier
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
    
verboseLevel=(size(dataMatrix,1)>100);

timeStampFormat='TS=%s-%08.0f'; % for sprintf(.,datestr,subsecond)
dateFormat='yyyy-mm-dd-HH-MM-SS';

if 0
    % unique filename?
    timestamp=clock;
    ID=sprintf(['+',timeStampFormat],...
               datestr(floor(timestamp),dateFormat),...
               1e8*(timestamp(end)-floor(timestamp(end))));
else
    ID='';
end

lvq_train=sprintf('lvq_train%s.txt',ID);
lvq_data=sprintf('lvq_data%s.txt',ID);
lvq_cod=sprintf('lvq_cod%s.cod',ID);
lvq_class=sprintf('lvq_class%s.txt',ID);

if verboseLevel
    redirect='';
else
    redirect='>&/dev/null';
end

%% Create training matrix
fid=fopen(lvq_train,'w');
fprintf(fid,'%d\n',size(training,2));
for i=1:size(training,1)
    fprintf(fid,'%f\t',training(i,:));
    fprintf(fid,'%d\n',groups(i));
end
fclose(fid);

%% Codebook initialization
cmd=sprintf('%s/lvq_pak-3.1/eveninit -din "%s" -cout "%s" -noc %d %s',...
            path2tvt,lvq_train,lvq_cod,sizeCodebook,redirect);
if verboseLevel
    fprintf('Codebook initialization\n%s\n',cmd)
end
system(cmd);

%% Codebook balancing
for i=1:nBalance
    cmd=sprintf('%s/lvq_pak-3.1/balance -din "%s" -cin "%s" -cout "%s" %s',...
                path2tvt,lvq_train,lvq_cod,lvq_cod,redirect);
    if verboseLevel
        fprintf('Codebook balancing %d\n%s\n',i,cmd)
    end
    system(cmd);
end        

%% Codebook training
cmd=sprintf('%s/lvq_pak-3.1/olvq1 -din "%s" -cin "%s" -cout "%s" -rlen %d %s',...
            path2tvt,lvq_train,lvq_cod,lvq_cod,trainingLength,redirect);
if verboseLevel
    fprintf('Codebook training\n%s\n',cmd)
end
system(cmd);

if verboseLevel
    cmd=sprintf('%s/lvq_pak-3.1/accuracy -din "%s" -cin "%s"',...
                path2tvt,lvq_train,lvq_cod);
    fprintf('Accuracy Evaluation - Training data\n%s\n',cmd)
    system(cmd);
end

%% Create matrix with all data
fid=fopen(lvq_data,'w');
fprintf(fid,'%d\n',size(dataMatrix,2));
for i=1:size(dataMatrix,1)
    fprintf(fid,'%f\t',dataMatrix(i,:));
    fprintf(fid,'\n');
end
fclose(fid);

%% Classify all data
cmd=sprintf('%s/lvq_pak-3.1/classify -din "%s" -cin "%s" -dout /dev/null -cfout "%s" %s',...
            path2tvt,lvq_data,lvq_cod,lvq_class,redirect);
if verboseLevel
    fprintf('Classification\n%s\n',cmd)
end
system(cmd);
class=load(lvq_class,'-ASCII');

delete(lvq_train);
delete(lvq_data);
delete(lvq_cod);
delete(lvq_class);

