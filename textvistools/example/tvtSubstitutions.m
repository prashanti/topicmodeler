function substitutions=tvtSubstitutions();
% Returns cell array with regexp substitutions for the function
% 'makedictfromtab'
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Substitutions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

substitutions={

    '\{ltriangle\}',     '';               % to remove {ltriangle}
    '\{ndash\}',         '';               % to remove {ndash}
    '\{rdrsp\}',         '';               % to remove {rdrsp}
    '\{subhead\}',       '';               % to remove {subhead}
    '\{SUBHEAD\}',       '';               % to remove {subhead}
    '\{send\}',          '';               % to remove {send}
    '\{SEND\}',          '';               % to remove {send}
    '\{deam\}',          '';               % to remove {deam}
    '\{hbox\}',          '';               % to remove {hbox}
    '\{lcub\}',          '';               % to remove {lcub}
    '\{rcub\}',          '';               % to remove {rcub}
    '\{tilde\}',         '';               % to remove {tilde}
%  '\{',                '';               % to remove {
%  '\}',                '';               % to remove }

    '\[#x201a]',           '';               % to remove [#x201a]
    '\[#x2[dD][cC]]',      '';               % to remove [#x2dc]
    '\[#x160]',            'S';              % to replace [#x160] with S
    '\[#x192]',            'f';              % to replace [#x192] with f
    '&amp;#8212',          ' ';              % to replace &amp;#x192 with space
    '&[aA]cute;?',         '';               % to remove &acute
    '&[cC]edil;?',         '';               % to remove &cedil
    '&[uU]ml;?',           '';               % to remove &uml
    '&[tT]ilde;?',         '';               % to remove &tilde
    '&[aA]tilde;&[pP]ound;?', 'a';   % to replace [aA]tilde;[pP]ound; with a
    '&[aA]tilde;&[iI]excl;?', 'a';   % to replace [aA]tilde;[iI]excl; with a
    '&[aA]acute;?',        'a';              % to replace [aA]acute with a
    '&[aA]grave;?',        'a';              % to replace [aA]grave with a
    '&[aA]circ;?',         'a';              % to replace [aA]circ with a
    '&[aA]tilde;?',        'a';              % to replace [aA]tilde with a
    '&[aA]uml;?',          'a';              % to replace [aA]uml with a
    '&[aA]ring;?',         'a';              % to replace [aA]ring with a
    '&[aA]elig;?',         'a';              % to replace [aA]elig with a
    '&[cC]cedil;?',        'c';              % to replace [cC]cedil with c
    '&[eE][tT][hH];?',     'e';              % to replace eth with e
    '&[eE]acute;?',        'e';              % to replace [eE]acute with e
    '&[eE]grave;?',        'e';              % to replace [eE]grave with e
    '&[eE]circ;?',         'e';              % to replace [eE]circ with e
    '&[eE]uml;?',          'e';              % to replace [eE]uml with e
    '&[iI]acute;?',        'i';              % to replace [iI]acute with i
    '&[iI]grave;?',        'i';              % to replace [iI]grave with i
    '&[iI]circ;?',         'i';              % to replace [iI]circ with i
    '&[iI]uml;?',          'i';              % to replace [iI]uml with i
    '&[nN]tilde;?',        'n';              % to replace ntilde with n
    '&[oO]acute;?',        'o';              % to replace [oO]acute with o
    '&[oO]grave;?',        'o';              % to replace [oO]grave with o
    '&[oO]circ;?',         'o';              % to replace [oO]circ with o
    '&[oO]tilde;?',        'o';              % to replace [oO]tilde with o
    '&[oO]uml;?',          'o';              % to replace [oO]uml with o
    '&[oO]slash;?',        'o';              % to replace [oO]slash with o
    '&[oO]elig;?',         'o';              % to replace [oO]elig with o
    '&[sS]zlig;?',         's';              % to replace szlig with s
    '&[tT][hH][oO][rR][nN];?', 't';          % to replace thorn with t
    '&[uU]acute;?',        'u';              % to replace [uU]acute with u
    '&[uU]grave;?',        'u';              % to replace [uU]grave with u
    '&[uU]circ;?',         'u';              % to replace [uU]circ with u
    '&[uU]uml;?',          'u';              % to replace [uU]uml with u
    '&[yY]acute;?',        'y';              % to replace [yY]acute with u
    '&[yY]uml;?',          'y';              % to replace [yY]uml with u

    '&[lL]squo;?',         '';               % to remove &lsquo
    '&[rR]squo;?',         '';               % to remove &rsquo
    '&[sS]bquo;?',         '';               % to remove &sbquo
    '&[lL]dquo;?',         '';               % to remove &ldquo
    '&[rR}dquo;?',         '';               % to remove &rdquo
    '&[bB]dquo;?',         '';               % to remove &bdquo
    '&[dD]agger;?',        '';               % to remove &dagger
    '&[pP]ermil;?',        '';               % to remove &permil
    '&[rR]saquo;?',        '';               % to remove &rsaquo
    '&[lL]saquo;?',        '';               % to remove &lsaquo
    '&[sS]pades;?',        '';               % to remove &spades
    '&[cC]lubs;?',         '';               % to remove &clubs
    '&[dD]iams;?',         '';               % to remove &diams
    '&[oO]line;?',         '';               % to remove &oline
    '&[lL]arr;?',          '';               % to remove &larr
    '&[uU]arr;?',          '';               % to remove &uarr
    '&[rR]arr;?',          '';               % to remove &rarr
    '&[dD]arr;?',          '';               % to remove &darr
    '&[tT]rade;?',         '';               % to remove &trade
    '&[qQ]uot;?',          '';               % to remove &quot
    '&[aA]mp;?',           'and';            % to replace &amp with and
    '&[fF]rasl;?',         '';               % to remove &frasl
    '&[gG]t;?',            ' ';              % to replace &gt with space
    '&[lL]t;?',            '';               % to remove &lt
    '&[nN]dash;?',         '';               % to remove &ndash
    '&[mM]dash;?',         '';               % to remove &mdash
    '&[nN]bsp;?',          ' ';              % to remove &frasl
    '&[iI]excl;?',         '';               % to remove &iexcl
    '&[cC]ent;?',          'cent';           % to replace &cent with cent
    '&[pP]ound;?',         'pound';          % to replace &pound with pound
    '&[cC]urren;?',        'currency';       % to replace &curren with currency
    '&[yY]en;?',           'yen';            % to replace &yen with yen
    '&[eE]uro;?',          'euro';           % to replace &euro with euro
    '&[bB]rvbar;?',     ' ';               % to replace &brvbar with space
    '&[bB]rkbar;?',     ' ';               % to replace &brkbar with space
    '&[sS]ect;?',          '';               % to remove &sect
    '&[dD]ie;?',           '';               % to remove &die
    '&[cC]opy;?',          '';               % to remove &copy
    '&[oO]rd[fm];?',       '';               % to remove &ordf or &ordm
    '&[lLrR]aquo;?',       '';               % to remove &laquo and &raquo
    '&[nN]ot;?',           '';               % to remove &not
    '&[sS]hy;?',           '';               % to remove &shy
    '&[rR]eg;?',           '';               % to remove &reg
    '&[mM]acr;?',          '';               % to remove &macr
    '&[hH]ibar;?',         '';               % to remove &hibar
    '&[dD]eg;?',           '';               % to remove &deg
    '&[pP]lusmn;?',        '';               % to remove &plusmn
    '&[sS]up;?',           '';               % to remove &sup
    '&[sS]up[123];?',      '';               % to remove &sup1 or &sup2 or &sup3
    '&[mM]icro;?',         '';               % to remove &micro
    '&[pP]ara;?',          '';               % to remove &para
    '&[mM]iddot;?',        '';               % to remove &middot
    '&[fF]rac;?',          '';               % to remove &frac
    '&[fF]rac[13][24];?',  '';               % to remove fractions
    '&[iI]quest;?',        '';               % to remove &iquest
    '&[tT]imes;?',         '';               % to remove &times
    '&[dD]ivide;?',        '';               % to remove &divide
    '&[bB]ull;?',          '';               % to remove &bull
    '&[eE][nm]sp;?',       ' ';              % to replace &ensp and &emsp with space
    '&[tT]hinsp;?',        ' ';              % to replace &thinsp with space
    '&[zZ]wnj;?',          '';               % to remove &zwnj
    '&[zZ]wj;?',           '';               % to remove &zwj
    '&[lL]rm;?',           '';               % to remove &lrm
    '&[rR]lm;?',           '';               % to remove &rlm

    'tilde',             '';               % to remove tilde
    'CO{-2}',            'CO2';            % CO2
    '''+',            '';                    % to remove single and double apostrophes
    '`+',             '';                    % to remove single and double apostrophes
    '\^',              '';                   % to remove carat
    '--',             ' ';                   % replace -- by space
  %'-',             ' _';                  % replace hyphen by space underscore
    '-',              ' ';                   % replace hyphen by space
    '_',              ' ';                   % to replace underscore by space
    '/',              ' ';                   % to replace / by space
    '\\',             ' ';                   % to replace \ by space
    '[a-zA-Z]\?\?\?[a-zA-Z]',    '$1$2';     % to remove ??? from middle of words
    ' _ ',            ' ';                   % remove isolated hyphens 
    ' = ',            ' equals ';            % replace isolated = by 'equals' 
    ',',              '';                    % to remove commas
    '\[',             '';                    % to remove [
    '\]',             '';                    % to remove ]
    '\*',             '';                    % to remove asterisks
    '\+',             '';                    % to remove +
    '~',              '';                    % to remove tildes
    '#',              '';                    % to remove #
    '\|',             ' ';                   % to replace | by space
    '(^| |\n|\()[a-z_A-Z0-9\.]*@[a-z_A-Z0-9\.]*( |\.|-|\))'   '$1$2';  % email address
    ' @ ',            ' at ';                % replace isolated @ by 'at' 
    '\(Videotape\)',   '';                   % to remove (Videotape) from transcripts
    '\(From videotape\.\)',   '';            % to remove (From videotape.) from transcripts
    '\(BEGIN VIDEOTAPE\)', '';               % to remove (BEGIN VIDEOTAPE) from transcripts
    '\([bB]egin videotape\.?\)', '';         % to remove (Begin videotape.) from transcripts
    '\(END VIDEOTAPE\)',   '';               % to remove (END VIDEOTAPE) from transcripts
    '\(End videotape\)',   '';               % to remove (End videotape) from transcripts
    '\(END OF VIDEOTAPE\)',   '';            % to remove (END OF VIDEOTAPE) from transcripts
    '\(BEGIN VIDEO CLIP\)',  '';             % to remove (BEGIN VIDEO CLIP) from transcripts
    '\(END VIDEO CLIP\)',    '';             % to remove (END VIDEO CLIP) from transcripts
    '\(End of clips?\)',    '';              % to remove (End of clip(s)) from transcripts
    '\(Excerpt from videotape\)',    '';     % to remove (Excerpt from videotape) from transcripts
    '\(Excerpt of song\)',    '';            % to remove (Excerpt of song) from transcripts
    '\(Begin videotaped segment\.?\)', '';   % to remove (Begin videotaped segment.) from transcripts
    '\(Begin clip from [^)]*\)',    '';      % to remove (Begin clip from...) from transcripts
    '\(Beginning of excerpt from [^)]*\)',  '';  % to remove (Beginning of excerpt from...) from transcripts
    '\(Beginning of clips? from [^)]*\)',  '';  % to remove (Beginning of clip(s) from...) from transcripts
    '\(Clip from [^)]*\)',      '';         % to remove (Clip from...) from transcripts
    '\(Soundbite of [^)]*\)',      '';      % to remove (Soundbite of...) from transcripts
    '\(OFF MIKE\)',          '';               % to remove (OFF-MIKE) & (OFF MIKE) from transcripts
    '\([oO]ff [mM]ike\.?\)',          '';      % to remove (Off Mike.) from transcripts
    '\(CROSSTALK\)',         '';               % to remove (CROSSTALK) from transcripts
    '\([lL]aughter\.?\)',          '';         % to remove (Laughter.) from transcripts
    '\(LAUGHTER\)',          '';               % to remove (LAUGHTER) from transcripts
    '\([aA]pplause\.?\)',          '';         % to remove (Applause.) from transcripts
    '\(APPLAUSE\)',          '';               % to remove (APPLAUSE) from transcripts
    '\(CHILDREN CHEERING\)',          '';      % to remove (CHILDREN CHEERING) from transcripts
    '\(BELL RINGING\)',          '';           % to remove (BELL RINGING) from transcripts
    '\(MUSIC\)',          '';                  % to remove (MUSIC) from transcripts
    '\([mM]usic\)',          '';               % to remove (Music or music) from transcripts
    '\(MUSIC PLAYS\)',          '';            % to remove (MUSIC PLAYS) from transcripts
    '\(REGGAE MUSIC PLAYS\)',          '';     % to remove (REGGAE MUSIC PLAYS) from transcripts
    '\(EXPLOSION\)',          '';              % to remove (EXPLOSION) from transcripts
    '\(BREAK\)',              '';              % to remove (BREAK) from transcripts
    '\(COMMERCIAL BREAK\)',          '';       % to remove (COMMERCIAL BREAK) from transcripts
    'commercial break',          '';       % to remove commercial break from transcripts
    '\(NEWS BREAK\)',          '';             % to remove (NEWS BREAK) from transcripts
    '\(MOVIE BREAK\)',          '';            % to remove (MOVIE BREAK) from transcripts
    '\(Announcements\)',          '';          % to remove (Announcements) from transcripts
    '\(Journalist\)',          '';             % to remove (Journalist) from transcripts
    '\([Vv]oice[- ]?over\)',          '';         % to remove (Voiceover) from transcripts
    '\(VOICE ?OVER\)',          '';            % to remove (Voiceover) from transcripts
    '\([vV][oO]\)',        '';                 % to remove (VO) from transcripts
    '\(on camera\)',        '';                % to remove (on camera and on-camera) from transcripts
    '\(ON CAMERA\)',        '';                % to remove (ON CAMERA) from transcripts
    '\(OFF CAMERA\)',        '';               % to remove (OFF-CAMERA) from transcripts
    '\([oO]ff [cC]amera\)',  '';               % to remove (Off Camera) from transcripts
    '\([iI]naudible\.?\)',        '';          % to remove (inaudible) from transcripts
    '\(INAUDIBLE\.?\)',        '';          % to remove (inaudible) from transcripts
    '\([uU]nintelligible\.?\)',        '';     % to remove (unintelligible) from transcripts
    '\([iI]n [uU]nison\)',  '';                % to remove (In unison) from transcripts
    '\(IN UNISON\)',  '';                      % to remove (In unison) from transcripts
    '\(with southern accent\)',        '';     % to remove (with southern accent) from transcripts
    '\([pP][hH]\)',        '';                 % to remove (ph) from transcripts
    '\([sS][pP]\)',        '';                 % to remove (sp) from transcripts
    '\(AP\)',              '';                 % to remove (AP) from transcripts
    'UNIDENTIFIED MALE:', '';                  % to remove UNIDENTIFIED MALE: from articles
    'UNIDENTIFIED FEMALE:', '';                % to remove UNIDENTIFIED FEMALE: from articles
    'UNIDENTIFIED REPORTER:', '';              % to remove UNIDENTIFIED REPORTER from articles
    'UNIDENTIFIED FEMALE REPORTER:', '';       % to remove UNIDENTIFIED FEMALE REPORTER from articles
    'Unidentified Man', '';                    % to remove Unidentified Man from articles
    'Unidentified Woman', '';                  % to remove Unidentified Woman from articles
    'Unidentified Boy', '';                    % to remove Unidentified Boy from articles
    'Unidentified Girl', '';                   % to remove Unidentified Girl from articles
    'All [rR]ights [rR]eserved', '';           % to remove All Rights Reserved from articles
    '\(EDITORS: END OPTIONAL TRIM\)',  '';     % to remove (EDITORS: END OPTIONAL TRIM)
    'READER COMMENTS',     '';                 % to remove READER COMMENTS from articles
    'COMMENT THREAD',     '';                  % to remove COMMENT THREAD from articles
    'POST A COMMENT',      '';                 % to remove POST A COMMENT from articles
    'Information Bank Abstracts', '';          % to remove Information Bank Abstracts from articles
    'Times Publishing Company', '';            % to remove Times Publishing Company from articles
    'Associated Press Writer', '$1';           % to remove Associated Press Writer from articles
    '(^|\n)Associated Press', '$1';            % to remove Associated Press from articles
    'Starcott Media Services',  '';            % to remove Starcott Media Services
    'UTCsup',  '';                             % to remove UTCsup
    'sup[0-9][0-9]-',  '';                     % to remove sup+number
    'This column was distributed by McClatchy-Tribune Information Services', ''; 
    'New York Times News Service', '';
    'is a columnist with The New York Times\. Copyright [0-9]* New York Times News Service. E-mail: [a-zA-Z]*nytimes.com', '';
    'is a syndicated columnist for The Washington Post\.',                  '';%to remove
    'Not for publication or retransmission without permission of MCT\.',    '';%to remove
    'EDITORS: The following are among the best commentaries, columns and editorials that moved this week on the McClatchy-Tribune News Service and are still suitable for use this weekend\.',    '';%to remove
    'For questions or retransmissions, please contact Op-Ed Editor E\. Ray Walker, 202-383-6084, rwalker@mctinfoservices\.com; or the News Desk, 202-383-6080\.',    '';%to remove
    '\([^)]* Newstex\)', '';                   % to remove (... Newstex)
    'ImageData',   '';                         % remove ImageData
    'Newstex Web Blogs',   '';                 % remove Newstex Web Blogs
    'Technorati Tags:',   '';                  % remove Technorati Tags:
    'Permalink',    '';                        % remove Permalink
    '[0-9]+ comments',    '';                  % remove # comments
    'Add to del.icio.us',   '';                % remove Add to del.icio.us
    'Search blogs linking this post with Technorati',   '';     
    'Want more on these topics *? Browse the archive of posts filed under',  ''; 
    'Information from [-a-zA-Z, ]* was used in this report\.',   '';
    '\[A hat tip [^]]*\]', '';
    '\[Hat tip [^]]*\]', '';
    '\(A hat tip [^)]*\)', '';
    '\(Hat tip [^)]*\)', '';
    'http://radio\.weblogs\.com[^ ]*', '';      % to remove http://radio.weblogs.com...
    'CLICK HERE TO RECEIVE AUTOMATIC E-MAIL UPDATES WHENEVER A NEW ARTICLE IS PUBLISHED TO ''TWO STEPS FORWARD''', '';
    
    '(^|\n)Q ', '$1Q: ';                       % to put Q into the same format as the other speaker indicators
    '\(\d\d:\d\d:\d\d\)', '';                  % to remove time stamps
    '\(Company:[^)]*\)', '';                   % to remove (Company: ...)
    '\(OTCBB:[^)]*\)', '';                   % to remove (Company: ...)
    '\(OOTC:[^)]*\)', '';                   % to remove (Company: ...)
    '\(NYSE:[^)]*\)', '';                   % to remove (Company: ...)
    '\(NASDAQ:[^)]*\)', '';                   % to remove (Company: ...)
    '\(LSE:[^)]*\)', '';                   % to remove (Company: ...)
    '\(TSE:[^)]*\)', '';                   % to remove (Company: ...)
    '\(FRA:[^)]*\)', '';                   % to remove (Company: ...)
    '\(SWX:[^)]*\)', '';                   % to remove (Company: ...)
    '\(AMS:[^)]*\)', '';                   % to remove (Company: ...)
    '\(PAR:[^)]*\)', '';                   % to remove (Company: ...)
    '\(BRU:[^)]*\)', '';                   % to remove (Company: ...)
    '\(TSX:[^)]*\)', '';                   % to remove (Company: ...)
    '\(TSXV:[^)]*\)', '';                   % to remove (Company: ...)
    '\(HKSE:[^)]*\)', '';                   % to remove (Company: ...)
    '\(AMEX:[^)]*\)', '';                   % to remove (Company: ...)
    '\(STO:[^)]*\)', '';                   % to remove (Company: ...)
    '\(BIT:[^)]*\)', '';                   % to remove (Company: ...)
    '\(ticker:[^)]*\)', '';                   % to remove (Company: ...)
    % to remove Mac Mc AAAA (AAA aaa)? : ?
    '(^|\n)(Prof\. |PROF\. |MR\. |Mr\. |MS\. |Ms\. |MRS\. |Mrs\. |DR\. |Dr\. )?[acA-Z. ]+(\([a-zA-Z\-, ]+\))? ?: ?\w', '$1';
    % to remove Mac Mc AAAA , aaa aaa : ?
    '(^|\n)(Prof\. |PROF\. |MR\. |Mr\. |MS\. |Ms\. |MRS\. |Mrs\. |DR\. |Dr\. )?[acA-Z. ]+,[A-Za-z ]+: ?\w',  '$1';
    'THIS IS A RUSH TRANSCRIPT\. THIS COPY MAY NOT BE IN ITS FINAL FORM AND MAY BE UPDATED\.', ''; %to remove RUSH TRANSCRIPT message
    'i\.e\.','ie';
    'e\.g\.','eg';
% to replace percentages
    '%BC%',              '';                    % to remove %BC%
    '%EC%',              '';                    % to remove %EC%
    '[0-9\.]+ *%',       'QuAnTpCt';            % to replace number+% with QuAnTpCt
    '[0-9\.]+ *percent', 'QuAnTpCt'; 
    ' % ',               ' percent ';           % to replace isolated % by 'percent'
  % to replace dollar values with DoLlQuAnT
    '\$[:l]',        '\$';
    '\$+ *\d+',   ' DoLlQuAnT';
    '\$+ *\d+m',   ' DoLlQuAnT';
    '\$%',            '';                    % to remove $% 
    ' \$\$ ',         'dollars';             % to replace $$ with dollars
    ' \$\$\$ ',       'dollars';             % to replace $$$ with dollars
  % to replace C-Span/C-Spans with CSPAN
  % (at start, middle, or end of sentence)
    'C _?Span' , 'CSPAN'; 
  % to replace web-site with website
  % (at start, middle, or end of sentence)
    '[wW]eb _?[sS]ite' , 'website';
  % to replace Wal-mart with walmart
  % (at start, middle, or end of sentence)
    '[wW]al _?[mM]art' , 'walmart';
    '[gG]reenhouse _?gas', 'greenhouse gas';  % to replace greenhouse-gas with greenhouse gas
    '[pP]olicy _?maker', 'policymaker';       % to replace policy-maker with policymaker
    '(^| |\.|\n)[eE] _?mail', '$1email';            % to replace e-mail with email
  % to replace Gov. with Governor 
  % (at start or middle of sentence)
    '(^| |\.|\n)[gG]ov\.', '$1Governor';
  % to replace acronyms with periods with acronmys without periods
  % (at start, middle, or end of sentence)
  '(^| |\.|\n)([A-Z])\.(s?)( |\.|$)' , '$1$2$3$4'; 
  '(^| |\.|\n)([A-Z])\.([A-Z])\.(s?)( |\.|$)' , '$1$2$3$4$5'; 
  '(^| |\.|\n)([A-Z])\.([A-Z])\.([A-Z])\.(s?)( |\.|$)' , '$1$2$3$4$5$6'; 
  '(^| |\.|\n)([A-Z])\.([A-Z])\.([A-Z])\.([A-Z])\.(s?)( |\.|$)' , '$1$2$3$4$5$6$7'; 
  '(^| |\.|\n)([A-Z])\.([A-Z])\.([A-Z])\.([A-Z])\.([A-Z])\.(s?)( |\.|$)' , '$1$2$3$4$5$6$7$8'; 
  % other stuff
  '( |\d)[aA]\.[mM]\.( |\.|$)', '$1amtime$2'; % to replace a.m. and A.M. with amtime
  '( |\d)p\.m\.( |\.|$)', '$1pmtime$2'; % to replace p.m. with pmtime
  'Ph\.D\.','phd';
  'W\.V[aA]\.','westvirginia';
  '(^| |\.|\n)N\. Y\.( |$)','$1NY$2';
  '\*\*\*\*BOX', '';  % to remove ****BOX
  % to replace Washington, D.C. with WashingtonDC
  % (at start, middle, or end of sentence)
%  'Washington DC' , 'WashingtonDC';
  % to replace EPA(s) with Environmental Protection Agency
  % (at start, middle, or end of sentence)
  '(^| |\.|\n)EPA(s?)( |\.|$)' , '$1Environmental Protection Agency$2$3'; 
  % to replace U.S./US with United States
  % (at start, middle, or end of sentence)
  '(^| |\.|\n)US(s?)( |\.|$)',  '$1United States$2$3'; 
  % to replace U.N./UN with United Nations
  % (at start, middle, or end of sentence)
  '(^| |\.|\n)UN(s?)( |\.|$)',  '$1United Nations$2$3';
  % resolve numbers attached to words
  '(\d)([a-zA-Z])',         '$1 $2';
  % resolve % attached to words
  '%([a-zA-Z])',         'percent $2';
  '(^| |\.|\n)oes( |\.|\?|,|:|;|-|$)',          '$1does$2';     % to replace 'oes' with 'does'
  '(^| |\.|\n)oesnt( |\.|\?|,|:|;|-|$)',        '$1doesnt$2';   % to replace 'oesnt' with 'doesnt'
    
% oe prefix
    '(^| |\.|\n)oe([A-Za-z0-9]+)( |\.|\?|,|:|;|-|$)',  '$1$2$3'; 

% tt prefix 
    '(^| |\.|\n)tt1029( |\.|\?|,|:|;|-|$)',	'$1 1029$2';
    '(^| |\.|\n)tt=tt000410( |\.|\?|,|:|;|-|$)',	'$1= 000410$2';
    '(^| |\.|\n)ttabout( |\.|\?|,|:|;|-|$)',	'$1about$2';
    '(^| |\.|\n)ttalbert( |\.|\?|,|:|;|-|$)',	'$1albert$2';
    '(^| |\.|\n)ttan( |\.|\?|,|:|;|-|$)',	'$1an$2';
    '(^| |\.|\n)ttand( |\.|\?|,|:|;|-|$)',	'$1and$2';
    '(^| |\.|\n)ttariel( |\.|\?|,|:|;|-|$)',	'$1ariel$2';
    '(^| |\.|\n)ttbeijings( |\.|\?|,|:|;|-|$)',	'$1beijings$2';
    '(^| |\.|\n)ttbhouse( |\.|\?|,|:|;|-|$)',	'$1house$2';
    '(^| |\.|\n)ttbpelosi( |\.|\?|,|:|;|-|$)',	'$1pelosi$2';
    '(^| |\.|\n)ttbritish( |\.|\?|,|:|;|-|$)',	'$1british$2';
    '(^| |\.|\n)ttcalifornia( |\.|\?|,|:|;|-|$)',	'$1california$2';
    '(^| |\.|\n)ttcarbon( |\.|\?|,|:|;|-|$)',	'$1carbon$2';
    '(^| |\.|\n)ttcarol( |\.|\?|,|:|;|-|$)',	'$1carol$2';
    '(^| |\.|\n)ttcher( |\.|\?|,|:|;|-|$)',	'$1cher$2';
    '(^| |\.|\n)ttcolin( |\.|\?|,|:|;|-|$)',	'$1colin$2';
    '(^| |\.|\n)ttdavid( |\.|\?|,|:|;|-|$)',	'$1david$2';
    '(^| |\.|\n)ttdemocrat( |\.|\?|,|:|;|-|$)',	'$1democrat$2';
    '(^| |\.|\n)ttdemocrats( |\.|\?|,|:|;|-|$)',	'$1democrats$2';
    '(^| |\.|\n)ttdemonstrator( |\.|\?|,|:|;|-|$)',	'$1demonstrator$2';
    '(^| |\.|\n)ttearth( |\.|\?|,|:|;|-|$)',	'$1earth$2';
    '(^| |\.|\n)ttfilm( |\.|\?|,|:|;|-|$)',	'$1film$2';
    '(^| |\.|\n)tthas( |\.|\?|,|:|;|-|$)',	'$1has$2';
    '(^| |\.|\n)tthe( |\.|\?|,|:|;|-|$)',	'$1he$2';
    '(^| |\.|\n)tthes( |\.|\?|,|:|;|-|$)',	'$1hes$2';
    '(^| |\.|\n)ttinterior( |\.|\?|,|:|;|-|$)',	'$1interior$2';
    '(^| |\.|\n)ttjanet( |\.|\?|,|:|;|-|$)',	'$1janet$2';
    '(^| |\.|\n)ttjohn( |\.|\?|,|:|;|-|$)',	'$1john$2';
    '(^| |\.|\n)ttjonathan( |\.|\?|,|:|;|-|$)',	'$1jonathan$2';
    '(^| |\.|\n)ttkevin( |\.|\?|,|:|;|-|$)',	'$1kevin$2';
    '(^| |\.|\n)ttmarch( |\.|\?|,|:|;|-|$)',	'$1march$2';
    '(^| |\.|\n)ttmayor( |\.|\?|,|:|;|-|$)',	'$1mayor$2';
    '(^| |\.|\n)ttmedia( |\.|\?|,|:|;|-|$)',	'$1media$2';
    '(^| |\.|\n)ttmr( |\.|\?|,|:|;|-|$)',	'$1mr$2';
    '(^| |\.|\n)ttmuslims( |\.|\?|,|:|;|-|$)',	'$1muslims$2';
    '(^| |\.|\n)ttobama( |\.|\?|,|:|;|-|$)',	'$1obama$2';
    '(^| |\.|\n)ttpersonal( |\.|\?|,|:|;|-|$)',	'$1personal$2';
    '(^| |\.|\n)ttpeter( |\.|\?|,|:|;|-|$)',	'$1peter$2';
    '(^| |\.|\n)ttphoto( |\.|\?|,|:|;|-|$)',	'$1photo$2';
    '(^| |\.|\n)ttpolar( |\.|\?|,|:|;|-|$)',	'$1polar$2';
    '(^| |\.|\n)ttsenator( |\.|\?|,|:|;|-|$)',	'$1senator$2';
    '(^| |\.|\n)ttsevere( |\.|\?|,|:|;|-|$)',	'$1severe$2';
    '(^| |\.|\n)ttsomali( |\.|\?|,|:|;|-|$)',	'$1somali$2';
    '(^| |\.|\n)ttthe( |\.|\?|,|:|;|-|$)',	'$1the$2';
    '(^| |\.|\n)tttt1( |\.|\?|,|:|;|-|$)',	'$11$2';
    '(^| |\.|\n)ttttgreenpeace( |\.|\?|,|:|;|-|$)',	'$1greenpeace$2';
    '(^| |\.|\n)ttttprevious( |\.|\?|,|:|;|-|$)',	'$1previous$2';
    '(^| |\.|\n)ttuntil( |\.|\?|,|:|;|-|$)',	'$1until$2';
                  };
    
