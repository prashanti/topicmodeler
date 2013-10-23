function seeDocument(name,path4,metafieldName,metafieldRegexp)
% Shows data for a given document. Creates a file called lixo.txt
%      with all the relevant data and opens it in a text editor.
%
% Possible forms:
%
% seeDocument name
% seeDocument(name) 
% seeDocument(name,path4) 
%    See data for the document with the given 'name'
%    The input parameter 'name' should be of the form
%       ppp/ttt/fff(iii)
%    where
%       ppp = path to be ignored
%       ttt = type of document
%       fff = filename with or without extension
%       iii = document index within file
%    Data regarding topics and emotions is taken from the files in
%       4-matlab-global-files/{path4}
%
%    When path4 is not provided or equal to the empty string, a
%    default value for path4 is used.
%
%    The input 'name' can also be a cell array of names, in which
%    case the data of multiple documents will be shown.
%
% seeDocument filename.csv
% seeDocument(filename.csv) 
% seeDocument(filename.csv,path4) 
%   See data for the list of documents whose names appear in the given
%   tab-separated file (single column, one filename per row). The
%   document names follow the format desbribed above.
%
%   Same as above for the parameter path4.
%
% seeDocument count
% seeDocument(count) 
% seeDocument(count,path4) 
% seeDocument(count,path4,metafieldName,metafieldRegexp) 
%    Randomly extracts the requested number of documents and shows their data
%
%    Same as above for the parameter path4.
%
%    When a metafield name and a regular expression is provided,
%    only documents for which the given metafield matches the
%    regexp are considered.
%
% Examples:
%
% seeDocument(inf,'','GRAPHIC:','.') - shows all documents with a
%     nonempty metefield 'GRAPHIC:'
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

maxLength=5000; % truncate text fields larger than this

%% set default 1st input, if not provided
if nargin<1
    name=1;
end

%% convert 1st input to number if a numerical-valued string
if ischar(name) && ~isempty(str2num(name))
    name=str2num(name);
end

path5='../2-matlab-output-mat-files';
%% set default path4, if not provided
if nargin<2 | isempty(path4)
    %    path4='../4-matlab-global-files/20100226-All'
    path4='../4-matlab-global-files'
end

%% which form of the command?
if isnumeric(name)
    % seeDocument(count,path4) 
    count=name;
    name='';
else
    if ischar(name) && ~isempty(regexp(name,'\.(csv|tab|txt)$')) && exist(name,'file')
        % seeDocument(filename.csv,path4) 
        name=textread(name,'%s%*q','headerlines',0,'whitespace',' ','delimiter',',\t');
    else
        % seeDocument(name,path4) 
        if ~iscell(name)
            name={name};
        end
    end
    count=length(name);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Select which data to output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if count==1
    %% detailed information if count==1
    show_source       =1;
    show_RoutputAll   =1;
    show_RoutputBrief =1;
    show_TMT          =1*0;
    show_reducedTMT   =1*0;
    show_ldacol       =1*0;
    show_emotioncounts=1*0;
    show_emotionmatrix=1*0;
    
else
    %% brief information if count>1
    show_source       =0;
    show_RoutputAll   =0;
    show_RoutputBrief =0;
    show_TMT          =1;
    show_reducedTMT   =0;
    show_ldacol       =0;
    show_emotioncounts=0;
    show_emotionmatrix=0;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

amh_parameters
TMTname=parameters.makeTMT.TMTname;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% read all .mat files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% emotions counts
if show_emotioncounts
    emotioncountsname=regexprep(emotioncountsname,'.*(/[^/]*)',[path4,'$1']);
    disp(emotioncountsname)
    load(emotioncountsname,'emotionCounts','emotionAllCategories','nvaaCounts','nameDocs');
    emotioncounts.emotionCounts=emotionCounts;
    emotioncounts.emotionAllCategories=emotionAllCategories;
    emotioncounts.nvaaCounts=nvaaCounts;
    emotioncounts.nameDocs=nameDocs;
    clear('emotionCounts','emotionAllCategories','nvaaCounts','nameDocs');
end

% emotion groups
if show_emotionmatrix 
    emotionmatrixname=regexprep(emotionmatrixname,'.*(/[^/]*)',[path4,'$1']);
    disp(emotionmatrixname)
    load(emotionmatrixname,'dataMatrix','nameCols','nameDocs');
    emotionmatrix.dataMatrix=dataMatrix;
    emotionmatrix.nameCols=nameCols;
    emotionmatrix.nameDocs=nameDocs;
    clear('dataMatrix','nameCols','nameDocs');
end

% TMT
if show_TMT || isempty(name)
    TMTname=parameters.makeTMT.TMTname;
    TMTname=regexprep(TMTname,'.*(/[^/]*)',[path4,'$1']);
    fprintf('seeDocuments: reading ''%s'' ... ',TMTname);
    load(TMTname,'WS','DS','WO','nameDocs','metaDocs');
    fprintf(' saving in structure ... ');
    TMT.WS=WS;
    TMT.WO=WO;
    TMT.DS=DS;
    TMT.nameDocs=nameDocs;
    % remove paths to facilitate match
    TMT.nameDocsNoPath=regexprep(nameDocs,'^.*/','');
    TMT.metaDocs=metaDocs;
    fprintf(' clear mem ... ');
    clear('WS','DS','WO','nameDocs','metaDocs');
    fprintf('done\n');
end

% reducedTMT
if show_reducedTMT
    reducedTMTname=regexprep(reducedTMTname,'.*(/[^/]*)',[path4,'$1']);
    fprintf('seeDocuments: reading ''%s'' ... ',reducedTMTname);
    load(reducedTMTname,'WS','DS','WO','nameDocs');
    reducedTMT.WS=WS;
    reducedTMT.WO=WO;
    reducedTMT.DS=DS;
    reducedTMT.nameDocs=nameDocs;
    % remove paths to facilitate match
    reducedTMT.nameDocsNoPath=regexprep(nameDocs,'^.*/','');
    clear('WS','DS','nameDocs');
    fprintf('done\n');
end

% ldacol
if show_ldacol
    ldacolmatrix=regexprep(ldacolmatrix,'.*(/[^/]*)',[path4,'$1']);
    files=dir([ldacolmatrix,'*.mat']);
    
    jj=1;
    for j=1:length(files)
        if regexp(files(j).name,'nTopics_[0-9]*_nIter_[0-9]*.mat')
            
            ldacolname=[path4,'/',files(j).name];
            disp(ldacolname)
            load(ldacolname,'dataMatrix','nameCols','nameDocs')
            ldacol(jj).ldacolname=ldacolname;
            ldacol(jj).dataMatrix=dataMatrix;
            ldacol(jj).nameCols=nameCols;
            ldacol(jj).nameDocs=nameDocs;
            % remove paths to facilitate match
            ldacol(jj).nameDocsNoPath=regexprep(nameDocs,'^.*/','');
            jj=jj+1;
            clear('ldacolname','dataMatrix','nameCols','nameDocs');
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% if needed, select random documents
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(name)
    % nonempty documents
    k=unique(TMT.DS);
    fprintf('seeDocuments: selecting documents among %d nonempty out of %d\n'...
            ,length(k),length(TMT.nameDocs));
    % find documents matching the given metafield
    if nargin>=4
        i=find(strcmp(metafieldName,metaHeaders));
        if isempty(i)
            metaHeaders
            error('unknown metafield "%s"\n',metafieldName);
        end
        k1=regexp(TMT.metaDocs(k,i),metafieldRegexp,'once');
        k1=find(~cellfun('isempty',k1));
        k=k(k1);
        fprintf('seeDocuments: selecting based on regexp ("%s" =~ "%s") %d documents out of %d\n',...
                metafieldName,metafieldRegexp,length(k),length(TMT.nameDocs));
    end
    fprintf('seeDocuments: selecting a random sample ... ');
    % compute random permutation
    [dummy,ks]=sort(rand(length(k),1));
    k=k(ks);
    % pick first documents in the permutation
    k=k(1:min(end,count));
    % get document names (in original order)
    name=TMT.nameDocs(sort(k));
    fprintf('done\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% open output file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outputname='lixo.txt';
fout=fopen(outputname,'w+');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% loop over documents
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remove paths to facilitate match
name=regexprep(name,'^.*/','');

for thisDoc=1:length(name)
fprintf('%4d/%5d : %s\n',thisDoc,length(name),name{thisDoc})

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% extract document filename and index
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

C=regexp(name{thisDoc},'^(.*)(\.\w\w\w)?\(([0-9]*)\)$','tokens');

if length(C)<1
    fprintf('seeDocument: cannot parse filename ''%s''\n',name{thisDoc});
    continue;
end

filename=C{1}{1};
index=str2num(C{1}{3});

fprintf(fout,'\n%4d\t%s\t%d',thisDoc,name{thisDoc},index);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% get source
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

source_index=index;

if show_source
    sourcename=sprintf('../1-raw-html-data/%s.html',filename);
    fin=fopen(sourcename,'r');

    if fin<0
        error('seeDocument: unable to open source file ''%s''\n',sourcename)
    end
    
    % find start 
    i=0;
    while 1
        tline=fgets(fin);
        if ~ischar(tline), break, end
        
        if ~isempty(regexp(tline,'[0-9]* of [0-9]* DOCUMENTS'))
            i=i+1;
            if i==source_index
                break;
            end
        end
    end
    
    if i<source_index
        fclose(fin);
        error(['Document source %d in file "%s" not found (only %d ' ...
               'documents found)'],source_index,sourcename,i);
    end
    
    fprintf(fout,'\tSOURCE\t');

    % output source document
    len=0;
    while 1
        tline=regexprep(tline,'\n','\\n');
        tline=regexprep(tline,'"','\\"');
        if len<maxLength
            fwrite(fout,tline);
        end
        len=len+length(tline);
        tline=fgets(fin);
        if ~ischar(tline), break, end
        
        if ~isempty(regexp(tline,'[0-9]* of [0-9]* DOCUMENTS'))
            break;
        end
    end
    
    fclose(fin);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% get R-output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if show_RoutputAll || show_RoutputBrief
    Rname=sprintf('../3-R-output-txt-files/%s.tab',filename);
    fin=fopen(Rname,'r');
    
    if fin<0
        error('seeDocument: unable to open .tab input ''%s''\n',Rname)
    end

    tline=fgetl(fin);
    heading=textscan(tline,'%s','Delimiter',char(9)); % tab
    
    % find start 
    i=1;
    while 1
        tline=fgetl(fin);
        if ~ischar(tline), break, end
        if i==index
            break;
        end
        i=i+1;
    end
    
    line=textscan(tline,'%s','Delimiter',char(9),'BufSize',1000000); % tab
    if show_RoutputAll
        fprintf(fout,'\tR-OUTPUT');
        for i=1:length(heading{1})
            fprintf(fout,'\tFIELD %s\t%s',heading{1}{i},line{1}{i});
        end
    else
        fprintf(fout,'\tR-OUTPUT TXT');
            %% TXT
        k=find(strcmp('TXT',heading{1}));
        if length(line{1}{k})>maxLength
            fprintf(fout,'\t%s TrUnCaTeD',line{1}{k}(1:maxLength));
        else
            fprintf(fout,'\t%s',line{1}{k});
        end
        fprintf(fout,'\tR-OUTPUT META');
        %% metaHeaders
        for i=1:length(metaHeaders)
            k=find(strcmp(metaHeaders{i},heading{1}));
            fprintf(fout,'\t%s',line{1}{k});
        end
    end
    fclose(fin);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% TMT output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if show_TMT
    docN=find(strcmp(name{thisDoc},TMT.nameDocsNoPath));
    k=find(TMT.DS==docN);
    
    fprintf(fout,'\tTMT OUTPUT (doc=%d, len=%d)\t',docN,length(k));        

    % text
    for i=1:length(k)
        fprintf(fout,'%s ',TMT.WO{TMT.WS(k(i))});
    end
    
    % meta data
    for i=1:length(TMT.metaDocs(thisDoc,:))
        fprintf(fout,'\t%s',TMT.metaDocs{thisDoc,i});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% reducedTMT output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if show_reducedTMT
    docN=find(strcmp(name{thisDoc},reducedTMT.nameDocsNoPath));
    k=find(reducedTMT.DS==docN);
    
    fprintf(fout,'\treducedTMT OUTPUT (doc=%d, len=%d)\t',docN,length(k));        

    % text
    for i=1:length(k)
        fprintf(fout,'%s ',reducedTMT.WO{reducedTMT.WS(k(i))});
    end
    
    % meta data
    for i=1:length(reducedTMT.metaDocs(thisDoc,:))
        fprintf(fout,'\t%s',reducedTMT.metaDocs{thisDoc,i});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% ldacol output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if show_ldacol
    ldacolmatrix=regexprep(ldacolmatrix,'.*(/[^/]*)',[path4,'$1']);
    
    for j=1:length(ldacol)
        docN=find(strcmp(name{thisDoc},ldacol(j).nameDocsNoPath));
        
        fprintf(fout,'\tLDACOL %s (doc=%d)',ldacol(j).ldacolname,docN);
        
        fprintf(fout,'%5.3f LDACOL COUNTS:',sum(ldacol(j).dataMatrix(docN,:)));
        [dummy,k]=sort(ldacol(j).dataMatrix(docN,:),'descend');
        for i=1:length(ldacol(j).nameCols)
            if ldacol(j).dataMatrix(docN,k(i))>0
                fprintf(fout,'\n  %5.3f: %3d %s',ldacol(j).dataMatrix(docN,k(i)),k(i),ldacol(j).nameCols{k(i)}(1:min(end,65)));
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% emotion counts output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if show_emotioncounts
    RName=sprintf('../3-R-output-txt-files/%s',name{thisDoc});
    docN=find(strcmp(RName,emotioncounts.nameDocs));
    
    fprintf(fout,'%sEMOTION COUNTS%s"%s"%s',...
            char(9),char(9),emotioncountsname,char(9));        
        
    fprintf(fout,'DOCUMENT NUMBER = %d\n',docN);
    fprintf(fout,'NUMBER NOUNS+VERBS+ADJ+ADV = %d\n',emotioncounts.nvaaCounts(docN));
    
    fprintf(fout,'%d EMOTION COUNTS:',sum(emotioncounts.emotionCounts(docN,:)));
    for i=1:length(emotioncounts.emotionAllCategories)
        if emotioncounts.emotionCounts(docN,i)>0
            fprintf(fout,'\n   %-25s = %3d',emotioncounts.emotionAllCategories{i},emotioncounts.emotionCounts(docN,i));
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% emotion matrix output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if show_emotionmatrix
    RName=sprintf('../3-R-output-txt-files/%s',name{thisDoc});
    docN=find(strcmp(RName,emotionmatrix.nameDocs));
    
    fprintf(fout,'%sEMOTION GROUPS%s"%s"%s',...
            char(9),char(9),emotionmatrixname,char(9));

    fprintf(fout,'DOCUMENT NUMBER = %d\n',docN);
    
    fprintf(fout,'%5.3f EMOTION GROUP COUNTS:',sum(emotionmatrix.dataMatrix(docN,:)));
    for i=1:length(emotionmatrix.nameCols)
        if emotionmatrix.dataMatrix(docN,i)>0
            fprintf(fout,'\n   %-25s = %5.3f',emotionmatrix.nameCols{i},emotionmatrix.dataMatrix(docN,i));
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% close output file and open it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end % loop over documents

fclose(fout);


!open -a "/Applications/Microsoft Office 2008/Microsoft Excel.app" lixo.txt
