function MatlabDate = yearday2date(YearDay,year,SuppressWarning)
%
% yearday2date--Converts time from YearDay format (January 01
% at 06:00 AM = 0.25, etc.) to Matlab time format. 
%
% If you are using the yearday convention of January 01, 06:00 = 1.25, etc.,
% SUBTRACT 1 from the MatlabDate returned by this function.
%
% Yearday2date warns the user about the yearday format it uses. This warning
% can be suppressed by setting the optional input argument SuppressWarning
% to 1.
%
% Syntax: MatlabDate = yearday2date(YearDay,year,SuppressWarning);
%
% e.g.,   MatlabDate = yearday2date(1,1998,0)
%
%   See also date2yearday.

% Kevin Bartlett (bartlettk@dfo-mpo.gc.ca) 7/1998
%------------------------------------------------------------------------------

if nargin == 2,
   SuppressWarning = 0;
end % if

% Find Matlab representation of January 1 of chosen year:
YearStart = datenum(year,01,01,00,00,00);

% Find Matlab representation of YearDay in chosen year:
MatlabDate = YearStart + YearDay;

% Warn user about Year Day format:
if ~SuppressWarning,
   disp('Caution: Year Day format used by yearday2date.m has January 1 = 0, NOT 1!')
end % if




