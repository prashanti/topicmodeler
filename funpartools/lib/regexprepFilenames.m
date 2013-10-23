%% Renames all files that match a given wildcard, in a given folder
%% by performing a regexprep substitution in the file names.

% which files
folder='./'   
wildcard = '*.*'

% regexprep substitution ($N for tokens in rep)
%regexp='(TS=2010)-(\d\d)-(\d\d)-(\d\d)-(\d\d)-(\d\d)-(\d\d\d\d\d\d)(\d\d)';
%rep   ='$1$2$3-$4$5$6-$7';

%% Loop over files
files=dir([folder,wildcard]);
nChanges=0;
for i=1:length(files)
    oldname=files(i).name;
    newname=regexprep(oldname,regexp,rep);
    if ~strcmp(oldname,newname)
        nChanges=nChanges+1;
        cmd=sprintf('mv -nvi "%s%s" "%s%s"',folder,oldname,folder,newname);
        if 1
            system(cmd);
        else
            disp(cmd)
        end
    end
end
fprintf('regexprepFiles:\t%d files changed\n',nChanges);

