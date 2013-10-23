function yyyymmdd=extractDateUS(dates);
% yyyymmdd=extractDate(dates)
% 
% Extracts array with the date from the documents metadata.
%
% yyyymmdd is a numeric array with one row per document and three
%          column: year (from 1950 to 2020), 
%                  month (from 1 to 12), and
%                  day (from 1 to 31)
%          The value -1 is inserted when it is not possible to
%          determine the year, month, or day.
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
    
verbose=0;

yyyymmdd=-ones(length(dates),3);

if length(dates)>50
    fprintf('Parsing dates... ');
    t0=clock;
end

for i=1:length(dates)
    if mod(i,5000)==0
        fprintf('%d%% ',round(100*i/length(dates)));
    end
    
    % No date
    if isempty(dates{i})
        if verbose 
            fprintf('Missing data field for document %d\n',i);
        end
        continue;
    end

    % test 'mm/dd/yyyy ...'
    S=regexp(dates{i},...
             '^([0-9][0-9]?)/([0-9][0-9]?)/([1-2][0-9][0-9][0-9])($| |,|[A-Za-z]|;)','tokens');
    if ~isempty(S)
        if str2num(S{1}{1})<1 || str2num(S{1}{1})>12 || ...
                str2num(S{1}{2})<1 || str2num(S{1}{2})>31
            error('extractDatePT: error[0] parsing data for document %d: ''%s''\n',i,dates{i});
        end
        try
            [yyyymmdd(i,1),yyyymmdd(i,2),yyyymmdd(i,3)]=datevec(...
                [S{1}{3},'/',S{1}{1},'/',S{1}{2}],'yyyy/mm/dd');
        catch
            error('extractDatePT: error[1] parsing data for document %d: ''%s''\n',i,dates{i});
        end
    else % test 'Month dd yyyy ...'
        S=regexp(dates{i},...
                 '^([A-Za-z]*)(, | |,)([0-9][0-9]?)(, |,)([1-2][0-9][0-9][0-9])($| |,|[A-Za-z]|;)','tokens');
        if ~isempty(S)
            try
                [yyyymmdd(i,1),yyyymmdd(i,2),yyyymmdd(i,3)]=datevec(...
                    [S{1}{5},' ',S{1}{1},' ',S{1}{3}],'yyyy mmmm dd');
            catch
                error('extractDateUS: error[2] parsing data for document %d: ''%s''\n',i,dates{i});
            end
        else % test 'Month yyyy ...'
            S=regexp(dates{i},...
                     '^([A-Za-z/]*)( |, |,)([1-2][0-9][0-9][0-9])($| |,)','tokens');
            if ~isempty(S) 
                switch lower(S{1}{1})
                  case 'summer'
                    S{1}{1}='june';
                  case 'spring'
                    S{1}{1}='march';
                  case 'winter'
                    S{1}{1}='december';
                  case 'fall'
                    S{1}{1}='september';
                end
                try
                    [yyyymmdd(i,1),yyyymmdd(i,2)]=datevec(...
                        [S{1}{3},' ',S{1}{1}],'yyyy mmmm');
                catch
                    error('extractDateUS: error[3] parsing data for document %d: ''%s''\n',i,dates{i});
                end
            else % test 'yyyy ...'
                S=regexp(dates{i},...
                         '^([1-2][0-9][0-9][0-9])($| |,)','tokens');
                if ~isempty(S)
                    yyyymmdd(i,1)=str2double(S{1}{1});
                else
                    if verbose 
                        fprintf('extractDateUS: error[4] parsing data for document %d: ''%s''\n',i,dates{i});
                    end
                end
            end
        end
    end
    
    if ((yyyymmdd(i,1)>=0 && (yyyymmdd(i,1)<1910 || yyyymmdd(i,1)>2020)) ||...
        (yyyymmdd(i,2)>=0 && (yyyymmdd(i,2)<1 || yyyymmdd(i,2)>12)) ||...
        (yyyymmdd(i,3)>=0 && (yyyymmdd(i,3)<1 || yyyymmdd(i,3)>31)) )
        error('\nInvalid date in document %d: ''%s'' -> ''%04d/%02d/%02d''\n',...
              i,dates{i},yyyymmdd(i,1),yyyymmdd(i,2),yyyymmdd(i,3));
    end
end

if length(dates)>10
    fprintf('done (%f sec)\n',etime(clock,t0));
end