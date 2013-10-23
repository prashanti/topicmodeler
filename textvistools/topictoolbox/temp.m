load 'psychreviewstream';

filename1 = 'topics_psychreview_hmmlda_2.txt'; % text file showing topic-word distributions
filename2 = 'states_psychreview_hmmlda_2.txt'; % text file showing hmm state-word distributions
    
load 'hmmldasingle_psychreview';

[WP,DP,MP,Z,X]=GibbsSamplerHMMLDA( WS,DS,T,NS,5,ALPHA,BETA,GAMMA,SEED,2,Z,X);

%%
% Calculate the most likely words in each topic and write to a cell array
% of strings
[S] = WriteTopics( WP , BETA , WO , 7 , 0.8 , 4 , filename1 );


%%
% Show the most likely words in the topics
fprintf( '\n\nMost likely words in the topics:\n' );
S( 1:T )  

%%
% Calculate the most likely words in each syntactic state and write to a
% cell array of strings
[S] = WriteTopics( MP , BETA , WO , 7 , 0.8 , 4 , filename2 );

%%
% Show the most likely words in the syntactic states
fprintf( '\n\nMost likely words in the syntactic states:\n' );
S( 1:NS ) 
