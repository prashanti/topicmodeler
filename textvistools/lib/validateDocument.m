function [err,diagnosis]=validateDocument(metadata,dates,data,allHeaders,allDoc,extractDate)
% [err,diagnosis]=validateDocument(metadata,dates,data,allHeaders,allDoc,extractDate)
%
% Checks if document's data, metadata, and dates are valid. 
%
% The input to the function includes cell arrays with:
%   1) the metadata fields pointed by metaHeaders
%   2) the metadata fields pointed by dateHeaders
%   3) the metadata fields pointed by dataHeaders
%   4) the collection of all metadata fields
% and
%   5) handle to a function that extracts dates from a
%      metafield, such as 'extractDateUS' or 'extractDatePT'
% In case an error is detected, it returns err=true and a ' 
% '\n'-terminated string 'diagnosis' that explains the error(s).
% In case of multiple errors, 'diagnosis' should
% describe one error per line.
% Typically points to script 'validateDocument'
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
 
emptyMeta=strcmp(metadata,'');
emptyDates=strcmp(dates,'');
emptyData=strcmp(data,'');

diagnosis=[];
err=0;

% missing metadata fields ?
if any(emptyMeta)
    err=1;
    diagnosis=[diagnosis,'empty metadata field #',sprintf('\t%d',find(emptyMeta)),sprintf('\n')];
end

% missing dates fields ?
if any(emptyDates)
    err=1;
    diagnosis=[diagnosis,'empty dates field #',sprintf('\t%d',find(emptyDates)),sprintf('\n')];
end

% missing data fields ?
if any(emptyData)
    err=1;
    diagnosis=[diagnosis,'empty data field #',sprintf('\t%d',find(emptyData)),sprintf('\n')];
end

% unrecognizable dates
for i=1:length(dates)
    yyyymmdd=extractDate(dates(i));
    if yyyymmdd(1)<0
        err=1;
        diagnosis=[diagnosis,sprintf('unparsable date(%d)\t%s\n',i,dates{i})];
    end
end

