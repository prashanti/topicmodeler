%% TEST2 -- outputting results of LDA model with special topic for each document

%%
% Choose the dataset
dataset = 1; % 1 = psych review abstracts 2 = NIPS papers 5 = NYT

if (dataset == 1)
    filenm         = 'temp2.html';
    ND             = 40;
    NT             = 5;
    MAXCOLS        = 3;   
    ncharsperline  = 100;
    maxlines       = 60;
    TOPICTHRES     = 0.0;
    
    load 'psychreviewstream'; % WO DS WS
    DS_REF = DS;
    WS_REF = WS;
    WO_REF = WO;
    
    load 'psychreviewbagofwordsfromstream'; % WO DS WS ORIGWSPOS;
    load 'ldasingle_psychreview_50' WP DP Z X ALPHA BETA SEED N;
elseif (dataset == 2)
    filenm         = 'temp1.html';
    ND             = 40;
    NT             = 5;
    MAXCOLS        = 3;   
    ncharsperline  = 100;
    maxlines       = 60;
    TOPICTHRES     = 0.0;
    
    load 'nips_stream'; % WO DS WS
    DS_REF = DS;
    WS_REF = WS;
    WO_REF = WO;
    
    load 'nipsbagofwordsfromstream'; % WO DS WS ORIGWSPOS;
    load 'ldasingle_nips_100' WP DP Z X ALPHA BETA SEED N;
elseif (dataset == 5)
    filenm         = 'temp3.html';
    ND             = 40;
    NT             = 5;
    MAXCOLS        = 3;   
    ncharsperline  = 100;
    maxlines       = 60;
    TOPICTHRES     = 0.0;
    
    load '..\kdd\NYTimesstream'; % WO DS WS
    DS_REF = DS;
    WS_REF = WS;
    WO_REF = WO;
    
    load '..\kdd\NYTimesCollocation'; % WO DS WS ORIGWSPOS;
    load 'ldasingle_NYT_100' WP DP Z X ALPHA BETA SEED N;
end

rand( 'state' , 2 );

T = size( DP , 2 ) - 1;
D = size( DP , 1 );

% regular topics 
WP1 = WP( : , 1:T );
[ S1 ] = WriteTopics( WP1 , BETA , WO , 10 , 0.7  );

% special topics
WP2 = WP( : , (T+1):(T+D) );
[ S2 ] = WriteTopics( WP2 , BETA , WO , 20 , 0.9 );

fid = fopen( filenm , 'w' );
fprintf( fid , '<html>\r\n<head>\r\n<STYLE TYPE="text/css">\r\n' );
fprintf( fid , 'span.t1 { color: #FF0000;   }\r\n' );
fprintf( fid , 'span.t2 { color: Blue;      }\r\n' );
fprintf( fid , 'span.t3 { color: #00FF00;   }\r\n' );
fprintf( fid , 'span.t4 { color: Magenta;   }\r\n' ); %font-style:italic }\r\n' ); %text-decoration: underline
fprintf( fid , 'span.normal { color: Black  }\r\n' );
fprintf( fid , 'span.filler { color: Gray;  }\r\n' );
fprintf( fid , '</STYLE>\r\n' );
fprintf( fid , '</head>\r\n' );
fprintf( fid , '<body>\r\n' );

dset = randperm( D );
dset = dset( 1:ND );

for d=1:ND
    % index of current document
    whd = dset( d );
    
    % all indices in original word stream for this document
    who  = find( DS_REF == whd );
    
    % number of words in original document
    NORIG = length( who );  
    
    % find all indices in truncated stream 
    whc = find( DS == whd );
    
    % find the original positions for the words in full stream
    origwspos = ORIGWSPOS( whc );
    
    % in the original stream, what are the assignments?
    [ ismem , whloc ] = ismember( who , origwspos ); 

    z  = zeros( 1,NORIG );
    x  = zeros( 1,NORIG ) - 1;
    
    proba = ones( 1,NORIG );
    z( find( ismem ) ) = Z( whc );
    x( find( ismem ) ) = X( whc );

    fprintf( 'Working with doc %d (%d)\n' , d , whd );
     
    fprintf( fid , '\r\n<hr><h2>DOCUMENT (id=%d)</h2>\r\n\r\n' , whd );
    fprintf( fid , '<p>#WORDS = %d - %d</p>\r\n' , length( whc ) , length( who ));
         
    probs = full( DP( whd , 1:(T+1) ) + ALPHA );
    probs = probs / sum( probs );
    [ tprobs , tindex ] = sort( -probs(1:T) ); tprobs = -tprobs;
    fprintf( fid , '<p>' );

    for t=1:NT
         if t<=MAXCOLS
             spanst = sprintf( 't%d' , t );
         else
             spanst = 'normal';
         end      
         fprintf( fid , 'P=%4.4f  Topic=%d <span class="%s"> %s</span><br>\r\n'  , tprobs( t ) , tindex( t ) , spanst, S1{ tindex(t) } );  
    end
    fprintf( fid , '</p>\r\n' );
     
    tindex( MAXCOLS+1 ) = T + 1;
    
    spanst = sprintf( 't%d' , MAXCOLS+1 );
    fprintf( fid , '<p>P=%4.4f  DocTopic <span class="%s"> %s</span></p>\r\n'  , probs( T+1 ) , spanst, S2{ whd } ); 
    
    fprintf( fid , '<p>' );
 
    writestreamstring3( WS_REF(who), WO_REF , ncharsperline , maxlines , fid , x , z , proba , tindex(1:(MAXCOLS+1)) , TOPICTHRES ); 
    
    fprintf( fid , '</p>\r\n' );
end

fprintf( fid , '</body>\r\n' );
fprintf( fid , '</html>\r\n' );

fclose( fid );





