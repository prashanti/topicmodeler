function lda(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Runs lda (from TMT)
%%      1) Reads TMT data structures
%%      2) Runs the TMT script for LDA
%%      3) Saves LDA outputs in file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','inputTMTname',...
    'Description', {
        'filename for a .mat file, used for read access (input)'
        'documents'' data in the TMT (Topic Modeling Toolbox) format'
                   });

declareParameter(...
    'VariableName','outputPerfix',...
    'Description', {
        'filename prefix for the following files:'
        '.mat file for write access (output)'
        '     all inputs and outputs to GibbsSamplerLDACOL'
        '.mat file for write access (output)'
        '     data matrix, names of rows and columns, documents metadata'
        '.txt file for write access (output)'
        '     data matrix (one document per row, one topic per column)'
        '.tab file for write access (output)'
        '     documents name and metadata (readable by ArcGIS)'
        '     (one header row, one document row, one field per column)'
        '.tab file for write access (output)'
        '     topic words (readable by ArcGIS)'
        '     (one header row, one topics per row)'
                   });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declareParameter(...
    'VariableName','nTopics',...
    'DefaultValue',300,...
    'Description', {
        'Number of topics'
                   });

setParameters(varargin);

% profile ?
profile_code=0;

if ~isdeployed()
  profile off
end

if profile_code && ~isdeployed()
  profile clear
  profile -detail builtin on
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Read TMT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(inputTMTname)  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run LDA from Topic Modeling Toolbox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set the hyperparameters
BETA=0.01;
ALPHA=50/nTopics;

%% The number of iterations
N = 100; 

%% The random seed
SEED = 3;

%% What output to show (0=no output; 1=iterations; 2=all output)
OUTPUT = 2;

%% create filenames
ldastatistics=sprintf('%s_nTopics_%d_statistics',outputPerfix,nTopics);
ldatopics=sprintf('%s_nTopics_%d_topics',outputPerfix,nTopics);
ldamatrixdata=sprintf('%s_nTopics_%d',outputPerfix,nTopics);

%% clear memory
WS=double(WS);
DS=double(DS);
clear SI WW 

%% Find model parameters
tic
[WP,DP,Z]=GibbsSamplerLDA(WS,DS,nTopics,N,ALPHA,BETA,SEED,OUTPUT);
toc

save(ldastatistics,...
     'WO','DS','WS','nTopics','N','nameDocs','metaDocs',...%% from inputTMTname
     'ALPHA','BETA','SEED',...                       %% input parameters
     'WP','DP','Z'...                    %% from GibbsSamplerLDA()
     );

%% Write the topics to a text file
nameCols=WriteTopics( WP , BETA , WO , 40 , 0.7 , 1 , ldatopics);

%% Show some topics
fprintf( '\n\nMost likely words in the topics:\n' );
for i=1:length(nameCols)
   disp(nameCols{i}( 1:90 ))
end

fprintf( '\n\nInspect the file ''%s'' for a text-based summary of the topics\n',ldatopics ); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Save matrix & metadata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% normalize to get prob of topics
dataMatrix=DP./(sum(DP,2)*ones(1,size(DP,2)));

dataSource=ldastatistics;
save(sprintf('%s.mat',ldamatrixdata),'dataMatrix','nameCols','metaDocs','nameDocs','dataSource')

