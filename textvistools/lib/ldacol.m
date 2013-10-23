function ldacol(varargin)
% To get help, type ldacol('help')
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
        'This script essentially performs LDA (Latent Dirichlet Allocation)'
        'with Collocation by calling the relevant TMT (Topic Modeling'
        'Toolbox) functions: GibbsSamplerLDACOL, CreateCollocationTopics,'
        'and WriteTopics.'
        ' '
        'Specifically, this script performs the following actions:'
        '   1) Reads TMT data structures created by makeTMT and/or reduceTMT.'
        '   2) Calls the TMT scripts for LDA with Collocations'
        '   3) Saves the outputs of TMT in a set of .mat and .txt files'
        '      See input variable ''outputPrefix'' for a description '
        '      of the files created.'
            });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','inputTMT',...
    'Description', {
        'Filename for a .mat file, used for read access (input)'
        'documents'' data in the TMT (Topic Modeling Toolbox) format'
                   });
declareParameter(...
    'VariableName','outputPrefix',...
    'Description', {
        'Filename prefix for the following files:'
        '{outputPrefix}+nIter=*.mat file for write access (output)'
        '     File containing all inputs and outputs to the TMT scripts,'
        '     which includes the following variables:'
        '       1) input parameters for GibbsSamplerLDACOL:'
        '          nTopics,Niterations,'
        '          ALPHA,BETA,GAMMA0,GAMMA1,DELTA,SEED,MAXC'
        '       2) input data for GibbsSamplerLDACOL:'
        '          WO,DS,WS,SI,WW'
        '       3) outputs from GibbsSamplerLDACOL:'
        '          WP,DP,WC,C,Z'
        '       4) outputs from CreateCollocationTopics:'
        '          WPNEW,DPNEW,WONEW'
        '     as well as:'
        '       1) Matrix ''dataMatrix'' with the topic weights for each'
        '           document (one document per row, one topic per column).'
        '       2) Cell vector ''nameDocs'' with documents names in the'
        '          form xxxx(99) where'
        '          ''xxxx'' represents the name of the .tab (raw) file'
        '                   ontaining the document'
        '          ''99''   represents the order of the document within'
        '                   that file'
        '       3) Cell vector ''nameCols'' with topic descriptions '
        '          (i.e., the top words in each topic).'
        '       4) Cell array ''metaDocs'' with the documents metadata'
        '          (one document per row, one metadata field per column).'
        '{outputPrefix}+nIter=*+topics.txt file for write access (output)'
        '     File describing the several topics, including:'
        '     1) The overall weight of each topic on the corpus.'
        '     2) The tops words associated with each topic and'
        '        their weight within the topic.'
                   });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','nTopics',...
    'DefaultValue',300,...
    'Description', {
        'Number of topics'
                   });
declareParameter(...
    'VariableName','multiNiterations',...
    'DefaultValue',[200,100,100,100,100],...
    'Description', {
        'Number of iterations for the TMT script ''GibbsSamplerLDACOL.'''
        'If a vector is given, the script will run ''GibbsSamplerLDACOL'''
        'multiple times, each time starting from the previous state'
        'and saving the intermediate outputs.'
        'This is useful to check the convergence progress.'
                   });

setParameters(varargin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set the hyperparameters
BETA   = 0.01;
ALPHA  = 50/nTopics;
GAMMA0 = 0.1;
GAMMA1 = 0.1;
DELTA  = 0.1;

MAXC   = 5;   % maximum collocation length (in post-processing topics)

%% The random seed
SEED = 1;

%% What output to show (0=no output; 1=iterations; 2=all output)
OUTPUT = 2;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read TMT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(inputTMT,'D','N','WS','DS','SI','WW')  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% loop over multiNiterations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Niterations=0;
for i=1:length(multiNiterations)
    fprintf('LDACOL File:  "%s"\n',inputTMT);
    fprintf('Total: D = %5.0f, N = %5.0fw\n',D,N);
    fprintf('sizes: WS=%dx%d, DS=%dx%d, WW=%dx%d(nnz=%d,sum=%d), SI=%dx%d\n\n',... 
            size(WS,1),size(WS,2),size(DS,1),size(DS,2),...
            size(WW,1),size(WW,2),nnz(WW),full(sum(sum(WW))),size(SI,1),size(SI,2));
    
    fprintf('\nRunning GibbsSamplerLDACOL (iterations %d-%d)...\n',...
            Niterations+1,Niterations+multiNiterations(i));

    Niterations=Niterations+multiNiterations(i);
    
    %% create filenames
    ldacoloutput=sprintf('%s+nIter=%d',outputPrefix,Niterations);
    ldacoltopics=sprintf('%s+nIter=%d+topics.txt',outputPrefix,Niterations);
    
    if verboseLevel
        whos
    end
    WS=int32(WS);
    DS=int32(DS);
    SI=int32(SI);
    if verboseLevel
        whos
    end
    
    %% Find model parameters

    %    disp([WS(1:20)',DS(1:20)',SI(1:20)'])
    tic
    if i==1
        [WP,DP,WC,C,Z]=GibbsSamplerLDACOL(WS,DS,SI,WW,...
                                          nTopics,multiNiterations(i),...
                                          ALPHA,BETA,GAMMA0,GAMMA1,DELTA,...
                                          SEED,OUTPUT);
    else
        C=int8(C);
        Z=int32(Z);
        %        disp([Z(1:20),C(1:20)])
        [WP,DP,WC,C,Z]=GibbsSamplerLDACOL(WS,DS,SI,WW,...
                                          nTopics,multiNiterations(i),...
                                          ALPHA,BETA,GAMMA0,GAMMA1,DELTA,...
                                          SEED,OUTPUT,...
                                          C,Z);
    end
    toc
    
    DS=int32(DS);
    WS=int32(WS);
    SI=int32(SI);
    C=int8(C);
    Z=int32(Z);
    WC=int32(WC);
    WP=int32(full(WP));
    DP=int32(full(DP));
    
    if verboseLevel
        whos
    end

    %% Clear all and reload only necessary variables
    fprintf('\nSaving GibbsSamplerLDACOL output...\n')
    save(ldacoloutput,...%'-v7.3',...
         'WP','DP','WC');           %% from GibbsSamplerLDACOL()
    clear SI WW WP DP WC nameDocs metaDocs

    load(inputTMT,'WO')  
    if verboseLevel
        whos
    end

    %% Post-process the vocabulary to include collocations as separate entries. 
    % Convert topics to include collocations
    fprintf('\nRunning CreateCollocationTopics ...\n');
    tic
    [WPNEW,DPNEW,WONEW]=CreateCollocationTopics(C,Z,WO,DS,WS,nTopics,MAXC);
    toc
    
    fprintf('\n\nWriting topics to file...\n');
    %% Recalculate word-topic distributions with expanded vocabulary 
    nameCols = WriteTopics(WPNEW,BETA,WONEW,40,1.0,1,ldacoltopics);
    
    load(inputTMT,'SI','WW','nameDocs','metaDocs')  
    load(ldacoloutput);
    if verboseLevel
        whos
    end

    %% Show some topics
    fprintf('\n\nMost likely words in the topics:\n');
    for i=1:length(nameCols)
        disp(nameCols{i}(1:90))
    end

    fprintf('\n\nInspect the file ''%s'' for a text-based summary of the topics\n',ldacoltopics); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Save matrix & metadata
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % normalize to get prob of topics
    %dataMatrix=full(double(DP)./(sum(DP,2)*ones(1,size(DP,2))));
    dataMatrix=full(double(DPNEW)./(sum(DPNEW,2)*ones(1,size(DPNEW,2))));
    
    % pad with NaN rows in case the last few documents do not appear in
    % DS and therefore not in DPNEW
    if size(dataMatrix,1)<length(nameDocs)
        dataMatrix=[dataMatrix;NaN*ones(length(nameDocs)-size(dataMatrix,1),size(dataMatrix,2))];
    end
    
    fprintf('\n\nSaving GibbsSamplerLDACOL & CreateCollocationTopics outputs...\n')
    save(ldacoloutput,...%'-v7.3',...
         'nTopics','Niterations',...    %% input parameters
         'ALPHA','BETA','GAMMA0','GAMMA1','DELTA','SEED','MAXC',...
         'WO','DS','WS','SI','WW','nameDocs','metaDocs',...%% from TMTname
         'WP','DP','WC','C','Z',...             %% from GibbsSamplerLDACOL
         'WPNEW','DPNEW','WONEW',...            %% from CreateCollocationTopics
         'nameCols',...                          %% from WriteTopics
         'dataMatrix'...
         );

    clear WO nameDocs metaDocs % from TMTname
    clear WP DP WC WPNEW DPNEW WONEW nameCols dataMatrix 

end

