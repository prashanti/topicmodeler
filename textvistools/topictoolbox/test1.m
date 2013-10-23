%% TEST for running LDA model with special topic for each document

%%
% Choose the dataset
dataset = 1; % 1 = psych review abstracts 2 = NIPS papers 5 = NYTimes

if (dataset == 1)
   load 'psychreviewbagofwordsfromstream'; % WO DS WS ORIGWSPOS; 
elseif (dataset == 2)
   load 'nipsbagofwordsfromstream'; % WO DS WS ORIGWSPOS; 
elseif (dataset == 5)
   load '..\kdd\NYTimesCollocation'; % load in variables: WW WO DS WS SI
end

%%
% Set the number of topics
T = 50; 

%%
% Set the hyperparameters
BETA=0.01;
ALPHA0=50/T;
ALPHA1=2 * (50/T);

%%
% The number of iterations
N = 100; 

%%
% The random seed
SEED = 3;

%%
% What output to show (0=no output; 1=iterations; 2=all output)
OUTPUT = 2;

%%
% This function might need a few minutes to finish
tic
[ WP,DP,Z,X ] = GibbsSamplerLDAExceptions( WS , DS , T , N , ALPHA0 , ALPHA1 , BETA , SEED , OUTPUT );
toc

%%
% Just in case, save the resulting information from this sample 
if (dataset==1)
    save 'ldasingle_psychreview_50' WP DP Z X ALPHA0 ALPHA1 BETA SEED N;
end

if (dataset==2)
    save 'ldasingle_nips_100' WP DP Z X ALPHA0 ALPHA1 BETA SEED N;
end

if (dataset==5)
    save 'ldasingle_NYT_100' WP DP Z X ALPHA0 ALPHA1 BETA SEED N;
end

D = size( DP , 1 );

WP1 = WP( : , 1:T );
WriteTopics( WP1 , BETA , WO , 10 , 0.7 , 4 , 'topics1.txt' );

WP2 = WP( : , (T+1):(T+D) );
WriteTopics( WP2 , BETA , WO , 10 , 0.7 , 4 , 'topics2.txt' );




