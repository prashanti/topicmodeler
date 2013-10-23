function [ WPNEW,DPNEW,WONEW] = CreateCollocationTopics( C,Z,WO,DS,WS,T, MAXC )
%% Function CreateCollocationTopics
%
% Create new vocabulary and topic counts based on collocation model output
%%
% |[ WPNEW,DPNEW,WONEW] = CreateCollocationTopics( C,Z,WO,DS,WS,T,MAXC)|
% creates a new vocabulary |WONEW| and new sparse |W| x |T| and |W| x |D|
% count matrices |WPNEW| and |DPNEW| from the output of the LDACOL (LDA
% Collocation) model. |C| and |Z| are vectors containing route (0=topic; 1=collocation)
% and topic assignments |WO| and |DS| contain the word and document indices
% of the corpus input to the model and |T| is the the number of topics.
%
% |MAXC| determines the maximum number of words that can be part of a
% collocation

% remove annoying chars
for i=1:length( WO )
   word = WO{ i };
   if any( word > 255 )
       wh = find( word > 255 );
       word( wh ) = 255;
       WO{ i } = word;
   end 
end

% packing variable
fprintf('Converting variable to integers to save space C,Z,DS\n');
C=uint8(C);
Z=uint32(Z);
DS=uint32(DS);

% set up a cell array for all strings
fprintf( 'Concatenating terms in stream...\n' );
N = size( C , 1 );
D = double(max( DS ));

W2 = cell( 1 , N ); % strings
Z2 = zeros( 1 , N ,'uint32' ); % topic assignments
DS2 = zeros( 1 , N ,'uint32' ); % document indices
CL  = zeros( 1 , N ,'uint8' ); % collocation length
status = 0;
ii = 0;
for i=1:N
    wh = WS( i );
    currentstring = WO{ wh };
    if (C( i ) == 0) || (CL( ii ) > MAXC) % do not exceed maximum col length
        ii = ii + 1;
        W2{ ii } = currentstring;
        Z2( ii ) = Z( i );
        DS2( ii ) = DS( i );
        CL( ii ) = 1;
    else
        W2{ ii } = [ W2{ ii } '_' currentstring ]; 
        CL( ii ) = CL( ii ) + 1;
    end

    if mod(i,1000000)==0
        fprintf( '%4.1f%% completed\n' , 100*i/N );
    end
end

% free memory from variables not needed
fprintf('Freeing memory from C,Z,WO,DS,WS\n');
%whos
clear C Z WO DS WS

% trimming new variables and converting them to double
fprintf('Trimming variables W2,Z2,DS2,CL\n');
NNEW = ii;
W2 = W2( 1:NNEW );
Z2 = Z2( 1:NNEW );
DS2 = DS2( 1:NNEW );
CL  = CL( 1:NNEW );

fprintf( 'Maximum collocation length: %d\n' , max( CL ));

fprintf( 'Finding all unique terms...\n' );
% find all unique strings
[ WONEW ] = unique( W2 ); 
WNEW = length( WONEW );

% map indices of this new vocabulary
%[ temp , WS2 ] = ismember( W2 , WONEW );
fprintf( 'Find term indices (this might be slow)...\n' );
WS2 = zeros( 1 , NNEW, 'uint32');
for i=1:NNEW
    word = W2{ i };
    %wh = find( strcmp( WONEW , word ) , 1 );
    wh = binarysearchstrings( word , WONEW );
    WS2( i ) = wh;
    
    if (wh == 0)
       warning( 'no match found' ); 
    end
    
    if mod(i,250000)==0
        fprintf( '%4.1f%% completed\n' , 100*i/NNEW );
    end
end
clear W2
%whos

fprintf('Converting to double WS2,Z2,CL\n');
WS2=double(WS2);
Z2=double(Z2);
CL=double(CL);
fprintf('Creating WPNEW\n');
WPNEW = sparse( WS2 , Z2 , CL , WNEW , T );
clear WS2
fprintf('Converting to double DS2\n');
DS2=double(DS2);
fprintf('Creating DPNEW\n');
DPNEW = sparse( DS2 , Z2 , CL , D    , T );

