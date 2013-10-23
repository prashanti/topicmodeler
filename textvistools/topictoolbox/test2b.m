%% TEST2 -- outputting results of LDA model with special topic for each document

%%
% Choose the dataset
dataset = 2; % 1 = psych review abstracts 2 = NIPS papers 5 = NYT

if (dataset == 1)
    filenm         = 'temp1b.html';
    ND             = 40;
    NT             = 5;
    MAXCOLS        = 3;   
    ncharsperline  = 100;
    maxlines       = 60;
    TOPICTHRES     = 0.4;
    
    load 'psychreviewstream'; % WO DS WS
    DS_REF = DS;
    WS_REF = WS;
    WO_REF = WO;
    
    load 'psychreviewbagofwordsfromstream'; % WO DS WS ORIGWSPOS;
    load 'multiple_psychreview_50'; % WPA DPA ZA XA ALPHA0 ALPHA1 BETA SEED N;
elseif (dataset == 2)
    filenm         = 'temp2b.html';
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
    load 'multiple_nips_100_b'; % WPA DPA ZA XA ALPHA0 ALPHA1 BETA SEED N;
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
    load 'ldasingle_NYT_100'; % WPA DPA ZA XA ALPHA BETA SEED N;
end

rand( 'state' , 2 );

T = size( DPA{1} , 2 ) - 1;
D = size( DPA{1} , 1 );

% regular topics 
%WP1 = WP( : , 1:T );
%[ S1 ] = WriteTopics( WP1 , BETA , WO , 10 , 0.7  );

% special topics
W   = size( WPA{1} , 1 );
NS  = size( ZA , 1 );
WP2 = zeros( W , D );
for i=1:NS
    WP2 = WP2 + WPA{ i }( : , (T+1):(T+D) );
end
X = mean( XA , 1 );

[ S2 ] = WriteTopics( WP2 , BETA , WO , 20 , 0.9 );

fid = fopen( filenm , 'w' );
fprintf( fid , '<html>\r\n<head>\r\n<STYLE TYPE="text/css">\r\n' );

NC = 10;
for c=0:NC
   %colstr = sprintf( '%02X' , round( c * 255 / NC ));
   %fprintf( fid , 'span.t%d { color: #%s0000;   }\r\n' , c , colstr ); 
   
   colstr = sprintf( '%02X' , 255 - round( c * 255 / NC ));
   fprintf( fid , 'span.t%d { background-color: #%sFFFF;   }\r\n' , c , colstr ); 
   
end

%fprintf( fid , 'span.t1 { color: #FF0000;   }\r\n' );
%fprintf( fid , 'span.t2 { color: Blue;      }\r\n' );
%fprintf( fid , 'span.t3 { color: #00FF00;   }\r\n' );
%fprintf( fid , 'span.t4 { color: Magenta;   }\r\n' ); %font-style:italic }\r\n' ); %text-decoration: underline
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
    x  = zeros( 1,NORIG );
    
    proba = zeros( 1,NORIG );
    
    z( find( ismem ) ) = 1;
    x( find( ismem ) ) = X( whc );
    z( find( x > 0 )) = T + 1;
    
    proba = x;
    
    fprintf( 'Working with doc %d (%d)\n' , d , whd );
     
    fprintf( fid , '\r\n<hr><h2>DOCUMENT (id=%d)</h2>\r\n\r\n' , whd );
    fprintf( fid , '<p>#WORDS = %d - %d</p>\r\n' , length( whc ) , length( who ));
         
    
    spanst = sprintf( 't%d' , NC );
    fprintf( fid , '<p>DocTopic <span class="%s"> %s</span></p>\r\n'  , spanst, S2{ whd } ); 
    
    fprintf( fid , '<p>' );
 
    writestreamstring4( WS_REF(who), WO_REF , ncharsperline , maxlines , fid , x , z , proba , T+1 , TOPICTHRES , NC ); 
    
    fprintf( fid , '</p>\r\n' );
end

fprintf( fid , '</body>\r\n' );
fprintf( fid , '</html>\r\n' );

fclose( fid );





