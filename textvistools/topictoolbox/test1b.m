%% TEST for running LDA model with special topic for each document
% MULTIPLE SAMPLES

%%
% Choose the dataset
dataset = 2; % 1 = psych review abstracts 2 = NIPS papers 5 = NYTimes

if (dataset == 1)
   load 'psychreviewbagofwordsfromstream'; % WO DS WS ORIGWSPOS; 
elseif (dataset == 2)
   load 'nipsbagofwordsfromstream'; % WO DS WS ORIGWSPOS; 
elseif (dataset == 5)
   load '..\kdd\NYTimesCollocation'; % load in variables: WW WO DS WS SI
end

NS = 2;

%%
% Set the number of topics
T = 100; 

%%
% Set the hyperparameters
BETA   = 0.01;
ALPHA0 = 50/T;
ALPHA1 = 0.05 * 50/T;

%%
% The number of iterations
N = 100; 

%%
% What output to show (0=no output; 1=iterations; 2=all output)
OUTPUT = 2;

%%
% This function might need a few minutes to finish
ZA = zeros( NS,length( WS ));
XA = zeros( NS,length( WS ));
for S=1:NS
   SEED = S;
   [ WP,DP,Z,X ] = GibbsSamplerLDAExceptions( WS , DS , T , N , ALPHA0 , ALPHA1 , BETA , SEED , OUTPUT );

   WPA{ S } = WP;
   DPA{ S } = DP;
   ZA( S , : ) = Z;
   XA( S , : ) = X;
end

%%
% Just in case, save the resulting information from this sample 
if (dataset==1)
    save 'multiple_psychreview_50' WPA DPA ZA XA ALPHA0 ALPHA1 BETA SEED N;
end

if (dataset==2)
    save 'multiple_nips_100_b' WPA DPA ZA XA ALPHA0 ALPHA1 BETA SEED N;
end

if (dataset==5)
    save 'multiple_NYT_100' WPA DPA ZA XA ALPHA0 ALPHA1 BETA SEED N;
end

D = size( DP , 1 );
 
WP1 = WPA{1}( : , 1:T );
WriteTopics( WP1 , BETA , WO , 10 , 0.7 , 4 , 'topics1.txt' );

% 
% WP2 = WP( : , (T+1):(T+D) );
% WriteTopics( WP2 , BETA , WO , 10 , 0.7 , 4 , 'topics2.txt' );
% 



