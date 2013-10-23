function trainSOM(varargin)
% To get help, type trainSOM('help')
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

declareParameter(...
    'Help', {
        'This script is essentially a wrapper to interface matlab'
        'with SOM_PAK. It calls the appropriate SOM_PAK executables'
        'passing as inputs the files created by createSOM.'
        'It then creates the arcGIS shape files using the SOMAnalyst'
        'macros.'
        ' '
        'Specifically, this script performs the following actions:'
        'trainSOM from createSOM data:'
        '1) Calls ''randinit'' to initialize the SOM.'
        '   The size of the SOM is specified by the ''somSize'''
        '   input variable.'
        '2) Calls ''vsom'' multiple times to train the SOM and create'
        '   its .cod codebook'
        '   Each call to ''vsom'' uses a different set of training'
        '   data and different parameters.'
        '   See input variables ''inputPrefix,'' ''trainingLengths,'''
        '   ''somRadius,'' ''somAlpha,'' and ''outputPrefix.'''
        '3) Calls ''qerror'' to display the quantization error'
        '   associated with the final map.'
        '4) Calls ''visual'' to calibrate the SOM (i.e., to localize'
        '   each document in the SOM) and create a .bmu file with'
        '   document coordinates'
        '   See input variables ''inputPrefix'' and ''outputPrefix.'''
        '5) Call ''SOMAnalyst'' to convert the SOM_PAK outputs into'
        '   shape files, one for the documents and another for the neurons.'
            });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','inputPrefix',...
    'Description', {
        'Filename prefix for the following files:'
        '{inputPrefix}+train=*.txt file for read access (input)'
        '     Files containing a version of the matrix ''dataMatrix'' in a'
        '     tab-separated format readble by SOM_PAK:'
        '     1) The first row contains the number of columns'
        '        (i.e., number of topics)'
        '     2) Each subsequent row corresponds to one document, and contains'
        '        the weights of the different topics on different columns.'
        '        The last column of each row contains a unique document ID'
        '        number (essentially reflecting the document order in'
        '        the input matrix).'
        '     These files are used by SOM_PAK''s ''vsom'' to train the SOM.'
        '     The different versions of the matrix in each file produced'
        '     differ only by the order in which the documents appear.'
        '     The construction of these multiple training files permits'
        '     running ''vsom'' multiple times with different document orders.'
        '     One training file is needed for each entry in the vector'
        '     of ''trainingLengths.'''
        '     These files are typically created by createSOM'
        '{inputPrefix}.txt file for read access (input)'
        '     Matrix ''dataMatrix'' in a tab-separated format readable'
        '     by som_pack:'
        '     1) The first row contains the number of columns'
        '       (i.e., number of topics)'
        '     2) Each subsequent row corresponds to one document, and contains'
        '        the weights of the different topics on different columns.'
        '        The last column of each row contains a unique document ID'
        '        number (essentially reflecting the document order in'
        '        the input matrix).'
        '     This file is used by SOM_PAK''s ''visual'' to calibrate the SOM.'
        '     This file is typically created by createSOM'
                   });
declareParameter(...
    'VariableName','outputPrefix',...
    'Description', {
        'Filename prefix for the following files:'
        '{outputPrefix}+neurons.cod for write access (output)'
        '   Code file produced by SOM_PAK''s ''vsom'' after training.'
        '   This file contains the vectors associated with each neuron.'
        '   of the SOM. Its format is described in the SOM_PAK''s'
        '   documentation. This file can be converted to a shape file'
        '   using the ArcGIS toolbox SOMAnalyst.'
        '{outputPrefix}+snap/{outputPrefix}+snap+X+YYYY.cod for write access (output)'
        '   Snapshots of the code file produced by SOM_PAK''s ''vsom'''
        '   during training, where X stands for index of the training '
        '   file and YYYY for the the iteration number.'
        '   These files contain the vectors associated with each neuron.'
        '   of the SOM. Their formats are described in the SOM_PAK''s'
        '   documentation.'
        '{outputPrefix}+docs.bmu for write access (output)'
        '   Code file produced by SOM_PAK''s ''visual'' after calibrating'
        '   the documents. For each document (one per row), this file contains'
        '   the x-y coordinates of the best-matching neuron and the associated'
        '   quantization error. This file can be converted to a shape file'
        '   using the ArcGID toolbox SOMAnalyst.'
        '{outputPrefix}+qerror.txt for write access (output)'
        '   Output of SOM_PAK''s ''qerror'', displaying the quantization error.'
        '{outputPrefix}+snap+qerror.eps for write access (output)'
        '   Plot with the outputs of SOM_PAK''s ''qerror'', displaying the'
        '   quantization error for the snapshots of the code files.'
                   });
declareParameter(...
    'VariableName','logFile',...
    'Description', {
        'Filename for a .tab file, used for write access (output, append)'
        'Log of warnings (tab-separated)'
                   });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','somSize',...
    'DefaultValue',[100,100],...
    'Description', {
        'Two-vector with the x and y-dimensions of the SOM'
                   });
declareParameter(...
    'VariableName','seed',...
    'DefaultValue',123,...
    'Description', {
        'Seed used to initialize the random number generator'
        'used to construct the initial SOM'
                   });
declareParameter(...
    'VariableName','trainingLengths',...
    'DefaultValue',[100000,100000,500000],...
    'Description', {
        'Vector with number of iterations for each training set.'
        'The length of this array should match the length of the'
        '''somTrain'' cell array'
                   });
declareParameter(...
    'VariableName','snapshootIntervals',...
    'DefaultValue',[],...
    'Description', {
        'Vector with the number of iterations between snapshots.'
        'When empty, no snapshots are produced.'
        'The length of this array should match the length of the'
        '''somTrain'' cell array'
                   });
declareParameter(...
    'VariableName','somRadius',...
    'DefaultValue',[100,50,10],...
    'Description', {
        'Vector with SOM''s radius parameter for each training set.'
        'The length of this array should match the length of the'
        '''somTrain'' cell array'
                   });
declareParameter(...
    'VariableName','somAlpha',...
    'DefaultValue',[.05,.04,.03],...
    'Description', {
        'Vector with SOM''s alpha parameter for each training set.'
        'The length of this array should match the length of the'
        '''somTrain'' cell array'
                   });
declareParameter(...
    'VariableName','alphaType',...
    'DefaultValue','linear',...
    'Description', {
        'String specifying the type of adjustment for the alpha parameter.'
        'Can be either ''linear'' or ''inverse_t''.'
        'The linear function is defined as '
        '    alpha(t) = alpha(0)(1.0 - t/rlen)'
        'and the inverse-time type function is defined as'
        '    alpha(t) = alpha(0)C/(C + t)'
        'with C = rlen/100.0.'
        'According to the som_pak manual,'
        ' "It is advisable to use the inverse-time type function'
        '  with large maps and long training runs, to allow more'
        '  balanced finetuning of the reference vectors.'
                   });
declareParameter(...
    'VariableName','path2tvt',...
    'DefaultValue','..',...
    'Description', {
        'Path to the base tvt folder. The SOM_PAK executables are expected'
        'to be in a subfolder named ''som_pak-3.1''.'
                   });
    
setParameters(varargin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run sompak
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

execute=1; % execute commands

initializeAndTrain=1;  % initialize and train
qerror=1;              % compute quantization error
qerrorDisplay=1;       % display quatization error
calibrate=1;           % calibrate
umat=1;                % display u-matrix
analyst=1;             % run SOMAnalyst

if length(somSize)~=2
    somSize
    error('trainSOM: ''somSize'' input should be a 2-vector\n',length(somSize));
end

if length(trainingLengths)~=length(somRadius) ||...
        length(trainingLengths)~=length(somAlpha)
    trainingLengths
    somRadius
    somAlpha
    error('trainSOM: the inputs ''trainingLengths'', ''somRadius'', ''somAlpha'' should all have the same length\n');
end

if initializeAndTrain
    %% Initialize map
    fprintf('Initializing the SOM\n')
    filename=sprintf('%s+train%d',inputPrefix,1);
    cmd=sprintf(['%s/som_pak-3.1/randinit -din "%s.txt" -cout "%s+neurons.cod" ',...
                 '-xdim %.0f -ydim %.0f -topol hexa -neigh gaussian -rand %f'],...
                path2tvt,filename,outputPrefix,...
                somSize(1),somSize(2),seed);
    fprintf('%s\n',cmd);
    if execute
        system(cmd);            
    end
    if qerror
        % remove qerror file
        cmd=sprintf('rm -f %s+qerror.txt',outputPrefix);
        fprintf('%s\n',cmd);
        if execute
            system(cmd);            
        end
    end
    if ~ isempty(snapshootIntervals)
        % clear snap folder and create if it does not exist
        cmd=sprintf('rm -f %s+snap/*.cod',outputPrefix);
        fprintf('%s\n',cmd);
        if execute
            system(cmd);            
        end
        cmd=sprintf('mkdir %s+snap',outputPrefix);
        fprintf('%s\n',cmd);
        if execute
            system(cmd);            
        end
    end

    fprintf('Training the SOM\n')
    for i=1:length(trainingLengths)

        if qerror
            %% Compute initial quantization error
            fprintf('SOM initial quantization error\n')
            cmd=sprintf('%s/som_pak-3.1/qerror -din "%s.txt" -cin "%s+neurons.cod" | tee -a "%s+qerror.txt"',...
                        path2tvt,inputPrefix,outputPrefix,outputPrefix);
            fprintf('%s\n',cmd);
            if execute
                system(cmd);            
            end
            if qerrorDisplay
                displayQerror(outputPrefix,trainingLengths,somAlpha,somRadius)
                print('-depsc',sprintf('%s+snap+qerror.eps',outputPrefix))
            end
        end
        
        %% Train
        if trainingLengths(i)>0
            filename=sprintf('%s+train%d',inputPrefix,i);
            if isempty(snapshootIntervals)
                snap='';
            else
                snap=sprintf('-snapinterval %d -snapfile "%s+snap/snap+%d+%%09d.cod" ',...
                             snapshootIntervals(i),outputPrefix,i);
            end
            cmd=sprintf(['%s/som_pak-3.1/vsom -din "%s.txt" -cin "%s+neurons.cod" '...
                         '-cout "%s+neurons.cod" %s' ...
                         '-rlen %.0f -alpha %f -radius %f -rand %f'],...
                        path2tvt,filename,outputPrefix,outputPrefix,snap,...
                        trainingLengths(i),somAlpha(i),somRadius(i),seed);
            fprintf('%s\n',cmd);
            if execute
                system(cmd);            
            end
        end

        if qerror
            %% Compute snapshot quantization error
            if ~isempty(snapshootIntervals)
                fprintf('SOM snapshots quantization errors\n')
                %sprintf('%s+snap/snap+%d+*.cod',outputPrefix,i)
                files=dir(sprintf('%s+snap/snap+%d+*.cod',outputPrefix,i));
                for j=1:length(files)
                    iter=regexp(files(j).name,sprintf('snap\\+%d\\+(\\d*)\\.cod',i),'tokens');
                    if ~isempty(iter)
                        iter=str2num(iter{1}{1});
                        cmd=sprintf('%s/som_pak-3.1/qerror -din "%s.txt" -cin "%s+snap/snap+%d+%09d.cod" >>"%s+qerror.txt"',...
                                    path2tvt,inputPrefix,outputPrefix,i,iter,outputPrefix);
                        %fprintf('%s\n',cmd);
                        if execute
                            system(cmd);            
                        end
                        if qerrorDisplay
                            displayQerror(outputPrefix,trainingLengths,somAlpha,somRadius)
                        end
                    end
                end
            end
        end
    
        if qerror
            %% Compute final quantization error
            fprintf('SOM final quantization error\n')
            cmd=sprintf('%s/som_pak-3.1/qerror -din "%s.txt" -cin "%s+neurons.cod" | tee -a "%s+qerror.txt"',...
                        path2tvt,inputPrefix,outputPrefix,outputPrefix);
            fprintf('%s\n',cmd);
            if execute
                system(cmd);            
            end
            if qerrorDisplay
                displayQerror(outputPrefix,trainingLengths,somAlpha,somRadius)
                print('-depsc',sprintf('%s+snap+qerror.eps',outputPrefix))
            end
        end
        
    end

end

if calibrate
    %% Calibrate
    fprintf('Calibrating the SOM\n')
    cmd=sprintf('%s/som_pak-3.1/visual -din "%s.txt" -cin "%s+neurons.cod" -dout "%s+docs.bmu" -noskip 1',...
                path2tvt,inputPrefix,outputPrefix,outputPrefix);
    fprintf('%s\n',cmd);
    if execute
        system(cmd);            
    end
end

if umat
    %% u-matrix visualization
    fprintf('u-matrix visualization of the SOM\n')
    cmd=sprintf('%s/som_pak-3.1/umat -cin "%s+neurons.cod" -paper A4 -fontsize 1.7 -o "%s+umat.eps"',path2tvt,outputPrefix,outputPrefix);
    fprintf('%s\n',cmd);
    if execute
        system(cmd);            
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run SOMAnalyst
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if analyst
    %% Create shape files
    fprintf('Creating neurons shape file\n')
    cmd=sprintf('%s/lib/COD2SHP.py "%s/SOMAnalyst" "%s+neurons.cod" "%s+neurons"',path2tvt,path2tvt,outputPrefix,outputPrefix);
    fprintf('%s\n',cmd);
    if execute
        system(cmd);            
    end
    
    fprintf('Creating documents shape file\n')
    cmd=sprintf('%s/lib/BMU2SHP.py "%s/SOMAnalyst" "%s+docs.bmu" "%s+docs"',path2tvt,path2tvt,outputPrefix,outputPrefix);
    fprintf('%s\n',cmd);
    if execute
        system(cmd);            
    end
end

%%system('(cd ../mapping-code/;sompak_docs_training.sh)')


function displayQerror(outputPrefix,trainingLengths,somAlpha,somRadius)

%% Read and display quantization errors
fid=fopen(sprintf('%s+qerror.txt',outputPrefix));
x=textscan(fid,'Quantization error of %[^ ] with map %[^ ] is %f per sample (%d samples)\n');
fclose(fid);
qerror=x{3};
snap=regexp(x{2},'/snap\+(\d*)\+(\d*)\.cod','tokens');

% remove final
final=find(cellfun(@(x) isempty(x),snap));
if ~isempty(final)
    qfinal=qerror(final);
    snap(final)=[];
    qerror(final)=[];
end

% get file and iteration numbers
testFile=cellfun(@(x) str2num(x{1}{1}),snap);
iter=cellfun(@(x) str2num(x{1}{2}),snap);

% sort by iteration numbers
[iter,k]=sort(iter);
testFile=testFile(k);
qerror=qerror(k);

% plot
figure(1);clf
iter0=0;
h=[];
leg={};
for i=1:length(trainingLengths)
    k=find(testFile==i);
    if ~isempty(k)
        h(end+1)=plot(iter(k)+iter0,qerror(k),'-*b');
        leg{end+1}=sprintf('train %d, \\alpha=%g, radius=%g',i,somAlpha(i),somRadius(i));
        hold on
    end
    iter0=iter0+trainingLengths(i);
end
if ~isempty(final)
    n=cumsum(trainingLengths)';
    n=[0;n(round(.5:.5:length(trainingLengths)-.5))];
    h(end+1)=plot(n(1:length(qfinal)),qfinal,'*r');
    leg{end+1}='final';
end
if length(qerror)>2
    axis([0,max(n),min([qfinal;qerror]),min(max(qerror),2*min([qfinal;qerror]))])
    grid on
end
title(sprintf('Final quantization error = %g (min = %g)',qfinal(end),min([qfinal;qerror])))
legend(h,leg)

drawnow
