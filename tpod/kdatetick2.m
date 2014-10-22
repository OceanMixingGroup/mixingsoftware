function kdatetick(arg1,arg2)
%
% kdatetick.m--My own version of Matlab's datetick.m program. 
% Plot some quantity versus time, then run kdatetick. The 
% plot x-ticks and x-tick labels will be replaced with "human"
% time format ones appropriate to the time range in the plot
% (e.g., "04:36:22", or "01/01/1983", etc.).
%
% Kdatetick.m must be run after each rescaling of the time axis (with
% zoom, for example) or the tick labels will be incorrect.
%
% Time units used in plotting must be elapsed time in days, hours,
% minutes or seconds. The units in use are specified using the optional
% string input argument "InTimeUnits", which must be one of 'days',
% 'hours', 'minutes' or 'seconds'. The time from which the elapsed time is 
% counted is specified by the optional input argument "DatumTime".
% "DatumTime" is a Matlab-format time, as created by datenum.m.
%
% If DatumTime and InTimeUnits are not specified by the user, kdatetick.m
% assumes the data have been plotted against standard Matlab-format time
% (i.e., DatumTime == 0 and InTimeUnits == 'days'). This makes for the
% simplest call to kdatetick.m, as no input arguments are required, but
% plotting against Matlab-format time has a serious disadvantage. Because
% dates in the 20th century are on the order of 10^6 in Matlab-format time,
% the use of the Matlab time format with contemporary or later data imposes
% a heavy overhead in terms of available precision on Matlab's plotting routines.
% Depending on your machine's precision, you may find yourself unable to 
% zoom in the x-limits of your plots to a range of less than 12 seconds. 
% Plotting in "MonthDays" or hours since the start of an instrument 
% deployment, etc., will avoid this problem.
%
% Main differences from Matlab's datetick.m function:
%   1) Only x-tick labelling supported.
%   2) Tick label formats are chosen by the program, not the user.
%   3) Unlike datetick.m, kdatetick.m supports the use of time formats
%      other than Matlab-format time. You may plot using "MonthDays", "YearDays"
%      or elapsed seconds, etc., and kdatetick.m will still work.
%   4) Unlike datetick.m, kdatetick.m does NOT change the x-limits of
%      your figure. (This was the main motivation for writing my own
%      version of datetick.m). 
%   5) Major ticks and minor ticks are created. For example, a 5-hour
%      long time series will best be labelled using the HH:MM format,
%      but if the 5-hour period happens to cross over midnight, a
%      "major" tick showing the new date (e.g., "25/09/1999") will
%      be placed at the midnight crossing point.
%   6) The xlabel of the axis is updated automatically to give 
%      information not included in the tick labels (the year
%      and month in a two-day long time series, for example). 
%
% Syntax: kdatetick(DatumTime,InTimeUnits)
%
% Example: x=[1:.001:10];y = sin(x)./x;
%          
%          1) Plot your data against a Matlab-format time vector:
%             t = datenum('01-Sep-1999') + linspace(4,25,length(y));
%             plot(t,y);
%             kdatetick;
%             Note that your machine precision will limit how closely
%             you can zoom into this plot.
%
%          2) Plot the same data against September 1999 MonthDays:
%             t = linspace(4,25,length(y));
%             plot(t,y);
%             kdatetick(datenum('01-Sep-1999')-1,'days');
%             You should be able to zoom in much more closely with
%             this version of the plot.

%   See also time2elapsedtime monthday2date date2monthday yearday2date date2yearday

% Kevin Bartlett (bartlettk@dfo-mpo.gc.ca) 9/1999
%------------------------------------------------------------------------------

% Examples for development, testing:
% e.g., t=[721673.67:721732.39];plot(t,t.^3);set(gca,'xlim',[t(1)-20 max(t)+.7]);kdatetick  
% e.g., t=[730378.79:.01:730379.37];plot(t,t.^3);set(gca,'xlim',[t(1)-.3/24 max(t)+.7/24]);kdatetick  
% e.g., t=[730366.79:.1:730391.13];plot(t,t.^3);set(gca,'xlim',[t(1)-.3/24 max(t)+.7/24]);kdatetick  
% e.g., t=[240:552];plot(t,t.^3);kdatetick(datenum('01-Aug-1999 00:00:00'),'hours')
% e.g., t=[724276.6:.01:724277.1];plot(t,t.^3);kdatetick
% Problem: x=[1:.001:10];y = sin(x)./x;t=linspace(4,555,length(y));plot(t,y);kdatetick(datenum('01-Sep-1999')-1,'days');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1) Preparation.

% Constants:
YEARS   = 1;
MONTHS  = 2;
DAYS    = 3;
HOURS   = 4;
MINUTES = 5;
SECONDS = 6;
MINTICKS = 3;

MonthList = {'January','February','March','April','May','June','July','August',...
      'September','October','November','December'};

TimeUnits = {'years','months','days','hours','minutes','seconds'};

% If no input arguments specified, assume Matlab-format time.
if nargin == 0,
   DatumTime = 0;
   InTimeUnits = 'days';  
elseif nargin == 2,
   DatumTime = arg1;
   InTimeUnits = arg2;  
else 
   error('kdatetick.m--Wrong number of input arguments.')
end %if

InTimeUnits = lower(InTimeUnits);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2) Choose the time units to calibrate the time axes by.

% Get the x-limits of the axes.
CurrAxes = gca;
xlims = get(CurrAxes,'xlim');

% Convert the x-limits to Matlab-format time.
if strcmp(InTimeUnits,'days'),
   XLimFactor = 1;
elseif strcmp(InTimeUnits,'hours'),
   XLimFactor = 24;
elseif strcmp(InTimeUnits,'minutes'),
   XLimFactor = 24*60;
elseif strcmp(InTimeUnits,'seconds'),
   XLimFactor = 24*3600;
else
   error('kdatetick.m--Input argument "InTimeUnits" must be "days", "hours", "minutes" or "seconds".')
end % if

xlims = xlims./XLimFactor + DatumTime;

% Find the first possible tick for each of the defined time units.
[year1,month1,day1,hour1,minute1,second1] = datevec(xlims(1));

FirstSecondTick = datenum(year1,month1,day1,hour1,minute1,ceil(second1));
FirstMinuteTick = datenum(year1,month1,day1,hour1,minute1+1*(second1~=0),0);
FirstHourTick = datenum(year1,month1,day1,hour1+1*(minute1~=0 | second1~=0),0,0);
FirstDayTick = datenum(year1,month1,day1+1*(hour1~=0 | minute1~=0 | second1~=0),0,0,0);
FirstMonthTick = datenum(year1,month1+1*(day1~=1 | hour1~=0 | minute1~=0 | second1~=0),1,0,0,0);
FirstYearTick = datenum(year1+1*(month1~=1 | day1~=1 | hour1~=0 | minute1~=0 | second1~=0),1,1,0,0,0);

% Find the last possible tick for each of the defined time units.
[year2,month2,day2,hour2,minute2,second2] = datevec(xlims(2));
LastSecondTick = datenum(year2,month2,day2,hour2,minute2,floor(second2));
LastMinuteTick = datenum(year2,month2,day2,hour2,minute2,0);
LastHourTick = datenum(year2,month2,day2,hour2,0,0);
LastDayTick = datenum(year2,month2,day2,0,0,0);
LastMonthTick = datenum(year2,month2,1,0,0,0);
LastYearTick = datenum(year2,1,1,0,0,0);

% Correct for cases for which no tick is available.
if FirstYearTick > LastYearTick,
   FirstYearTick = NaN;
   LastYearTick = NaN;
end % if

if FirstMonthTick > LastMonthTick,
   FirstMonthTick = NaN;
   LastMonthTick = NaN;
end % if

if FirstDayTick > LastDayTick,
   FirstDayTick = NaN;
   LastDayTick = NaN;
end % if

if FirstHourTick > LastHourTick,
   FirstHourTick = NaN;
   LastHourTick = NaN;
end % if

if FirstMinuteTick > LastMinuteTick,
   FirstMinuteTick = NaN;
   LastMinuteTick = NaN;
end % if

if FirstSecondTick > LastSecondTick,
   disp('kdatetick.m--Time range too small to convert to time strings.')
   disp('Try plotting times as elapsed decimal seconds (See time2elapsedtime.m)')   
   error(' ');
end % if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3) Find the tick values.

% To get rid of rounding errors, all tick values will be rounded to the
% nearest second.
MonthTicks = [];
DayTicks = [];
HourTicks = [];
MinuteTicks = [];
SecondTicks = [];

% ...Get the year tick values (Needed for all time units).
if year2>year1 & ~isnan(FirstYearTick) & ~isnan(LastYearTick),
   [FirstVal,dummy,dummy,dummy,dummy,dummy] = datevec(FirstYearTick);
   [LastVal,dummy,dummy,dummy,dummy,dummy] = datevec(LastYearTick);
   YearVector = FirstVal:LastVal;
   YearTicks = roundn(datenum(YearVector,ones(size(YearVector)),ones(size(YearVector))),1/(24*3600) );   
else
   YearTicks = [];
end % if

BaseUnits = YEARS;
NumYearTicks   = length(YearTicks);
NumMonthTicks  = NaN;
NumDayTicks    = NaN;
NumHourTicks   = NaN;
NumMinuteTicks = NaN;
NumSecondTicks = NaN;

% ...If there are not enough year ticks, get the month tick values.   
if NumYearTicks < MINTICKS,

   YearsDiff = (length(YearTicks)>1)*(length(YearTicks)-1);
   
   if ~isnan(FirstMonthTick),
      [FirstMonthTickYear,FirstVal,dummy,dummy,dummy,dummy] = datevec(FirstMonthTick);
   else 
      FirstMonthTickYear = NaN;
      FirstVal = NaN;
   end % if ~isnan
   
   if ~isnan(LastMonthTick),
      [LastMonthTickYear,LastVal,dummy,dummy,dummy,dummy] = datevec(LastMonthTick);
   else  
      LastMonthTickYear = NaN;
      LastVal = NaN;
   end % if ~isnan
   
   if isnan(FirstVal) | isnan(LastVal),
      if ~isnan(FirstVal),
         MonthVector = FirstVal;      
      elseif ~isnan(LastVal),
         MonthVector = LastVal;
      else
         MonthVector = [];      
      end % if   
   else
      if FirstVal < LastVal,
         MonthVector = FirstVal:LastVal;
      elseif FirstVal > LastVal,
         MonthVector = FirstVal + [0:(YearsDiff*12 + 12-FirstVal + LastVal)];
      elseif FirstVal == LastVal,
         MonthVector = FirstVal;
      end % if
      
   end % if isnan
   
   YearVector = FirstMonthTickYear*ones(size(MonthVector));
   
   while any(MonthVector>12),
      YearVector(MonthVector>12) = YearVector(MonthVector>12) + 1;
      MonthVector(MonthVector>12) = MonthVector(MonthVector>12) - 12;
   end % while
   
   if ~isempty(MonthVector),
      MonthTicks = roundn(datenum(YearVector,MonthVector,ones(size(MonthVector))),1/(24*3600) );
   else
      MonthTicks = [];
   end % if
   
   NumMonthTicks = length(MonthTicks);

   % ...If there are not enough month ticks, get the day tick values.  
   if NumMonthTicks < MINTICKS,

      if ~isnan(FirstDayTick) & ~isnan(LastDayTick),
         DayTicks = roundn(FirstDayTick:LastDayTick,1/(24*3600) ); 
      else
         DayTicks = [];
      end % if

      NumDayTicks = length(DayTicks);
      
      % If there are not enough day ticks, get the hour tick values.
      if NumDayTicks < MINTICKS,
         if ~isnan(FirstHourTick) & ~isnan(LastHourTick),
            HourTicks = roundn(FirstHourTick:1/24:LastHourTick,1/(24*3600) );
         else
            HourTicks = [];
         end % if

         NumHourTicks = length(HourTicks);

         % If there are not enough hour ticks, get the minute tick values.      
         if NumHourTicks < MINTICKS,
            if ~isnan(FirstMinuteTick) & ~isnan(LastMinuteTick),
               MinuteTicks = roundn(FirstMinuteTick:1/24/60:LastMinuteTick,1/(24*3600) );
            else
               MinuteTicks = [];
            end % if

            NumMinuteTicks = length(MinuteTicks);        

            % If there are not enough minute ticks, get the second tick values.
            if NumMinuteTicks < MINTICKS,

               if ~isnan(FirstSecondTick) & ~isnan(LastSecondTick),
                  SecondTicks = roundn(FirstSecondTick:1/24/3600:LastSecondTick,1/(24*3600) );
                  NumSecondTicks = length(SecondTicks);        

               else
                  disp('kdatetick.m--Time range too small to convert to time strings.')
                  disp('Try converting times to elapsed decimal seconds (See time2elapsedtime.m)')   
                  error(' ');
               end % if
               
            end % if units are seconds.
            
         end % if units minutes or smaller.
         
      end % if units hours or smaller.
      
   end % if units days or smaller.
   
end % if units months or smaller.

% Find the largest time unit for which the number of available ticks
% exceeds the desired minimum number of ticks. This will be the time
% unit by which the time axis will be delineated.
AvailTicks = [NumYearTicks NumMonthTicks NumDayTicks NumHourTicks NumMinuteTicks NumSecondTicks];
BaseUnits = min(find(AvailTicks >= MINTICKS));

% If there is no time unit for which the number of available ticks exceeds
% the desired minimum number of ticks, choose the base time unit to be
% the smallest time unit (i.e., seconds).
if isempty(BaseUnits),
   BaseUnits = SECONDS;
end % if

% Certain variables will control how the time axis ticks will be placed and
% labelled. Assign these variables according to which base time units 
% have been chosen. "MinorTicks" and "MajorTicks" give the tick locations
% as-is, and "TimeJumps" is a vector of permitted increments between
% ticks if they require thinning. "MaxTicks" controls how many ticks can
% be plotted (different date label formats require different amounts of
% space, so MaxTicks varies from one time unit to another).
if BaseUnits == YEARS,
   MinorTicks = YearTicks;
   MajorTicks = [];
   MaxTicks = 8;
   TimeJumps = [2 5 10 20 25 50 100 200 250 500 1000]; % (open-ended--could expand if needed).
elseif BaseUnits == MONTHS,
   MinorTicks = MonthTicks;   
   MajorTicks = YearTicks;
   MaxTicks = 8;
   TimeJumps = [2 3 4 6 12];
elseif BaseUnits == DAYS,
   MinorTicks = DayTicks;   
   MajorTicks = MonthTicks;
   MaxTicks = 8;
   TimeJumps = [2 5 10 50 100];
elseif BaseUnits == HOURS,
   MinorTicks = HourTicks;   
   MajorTicks = DayTicks;
   MaxTicks = 8;
   TimeJumps = [2 3 4 6 8 12 24];
elseif BaseUnits == MINUTES,
   MinorTicks = MinuteTicks;   
   MajorTicks = HourTicks;
   MaxTicks = 8;
   TimeJumps = [2 5 10 15 30 60];
elseif BaseUnits == SECONDS,
   MinorTicks = SecondTicks;   
   MajorTicks = MinuteTicks;
   MaxTicks = 6;
   TimeJumps = [2 5 10 15 30 60];
end % if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4) Thin the ticks if necessary.

% Thin the number of ticks if there are too many to fit nicely on a plot
% axis. Thin the ticks in such a way that the "major" ticks are not
% skipped.
if length(MinorTicks) <= MaxTicks,
   ThinnedTicks = MinorTicks;
else
   
   NiceTimeJump = TimeJumps(min(find(TimeJumps >= ceil(length(MinorTicks)/MaxTicks))));

   % The permitted time jumps have been chosen to ensure that the thinned minor
   % ticks will still include their associated major ticks. This doesn't work
   % for days, however, as months do not always contain the same number of days.
   % For this reason, a rather complicated algorithm that builds up the thinned
   % tick vector from the major ticks has to be used.
   if ~isempty(MajorTicks),
            
      % Fill in any minor ticks prior to the first major tick.
      ThinnedTickIndex = sort(find(MinorTicks == MajorTicks(1)):-NiceTimeJump:1);
      
      % Fill in the minor ticks following each of the major ticks.
      % For each major tick...

      for MajorCount = 1:length(MajorTicks),
         
         % If there are more major ticks after this one, only fill in the
         % minor ticks up to the next major tick.
         if MajorCount < length(MajorTicks),
            ThinnedTickIndex = [ThinnedTickIndex find(MinorTicks == MajorTicks(MajorCount))];

            %if BaseUnits == DAYS | BaseUnits == MONTHS,
            %  ThinnedTickIndex = [ThinnedTickIndex (find(MinorTicks == MajorTicks(MajorCount))+NiceTimeJump-1):NiceTimeJump:(find(MinorTicks == MajorTicks(MajorCount+1)))];
            %else
            %  ThinnedTickIndex = [ThinnedTickIndex (find(MinorTicks == MajorTicks(MajorCount))+NiceTimeJump):NiceTimeJump:(find(MinorTicks == MajorTicks(MajorCount+1)))];
            %end % if   
            
            ThinnedTickIndex = [ThinnedTickIndex (find(MinorTicks == MajorTicks(MajorCount))+NiceTimeJump):NiceTimeJump:(find(MinorTicks == MajorTicks(MajorCount+1)))];

            % Else, if this is the last major tick, fill in the remaining minor ticks,
            % (including the current major tick).
         else
            ThinnedTickIndex = [ThinnedTickIndex find(MinorTicks == MajorTicks(MajorCount))];
            
            % All time units start with a value of 0, except for days, which start with
            % day==1; and months, which start with a value of month==1. To get month or
            % day ticks with nice values, they have to be thinned differently.
            %if BaseUnits == DAYS | BaseUnits == MONTHS,
            %   ThinnedTickIndex = [ThinnedTickIndex find(MinorTicks == MajorTicks(MajorCount))+NiceTimeJump-1:NiceTimeJump:length(MinorTicks)];
            %else
            %   ThinnedTickIndex = [ThinnedTickIndex find(MinorTicks == MajorTicks(MajorCount))+NiceTimeJump:NiceTimeJump:length(MinorTicks)];
            %end % if   
            
            ThinnedTickIndex = [ThinnedTickIndex find(MinorTicks == MajorTicks(MajorCount))+NiceTimeJump:NiceTimeJump:length(MinorTicks)];

         end % if there are more major ticks after this one.
         
      end % for each major tick.      
      
      % Remove minor ticks placed too close to a major tick.
      ThinnedTickIndex = unique(ThinnedTickIndex);
      IsMinorIndex = find(~ismember(MinorTicks,MajorTicks));
      IsMinorIndex = intersect(IsMinorIndex,ThinnedTickIndex);
      
      % ...Get index to points that are too close to the following point.
      if NiceTimeJump > 2,
         IsTooCloseIndex = ThinnedTickIndex(find(diff(ThinnedTickIndex) < NiceTimeJump-1));
      else
         IsTooCloseIndex = ThinnedTickIndex(find(diff(ThinnedTickIndex) < NiceTimeJump));
      end % if

      % ...If the point selected is a major point, we don't want to get rid of it. Get
      % rid of the next minor point.
      for TooCloseCount = 1:length(IsTooCloseIndex),
         if ~ismember(IsTooCloseIndex(TooCloseCount),IsMinorIndex),
            IsTooCloseIndex(TooCloseCount) = ThinnedTickIndex(min(find(ThinnedTickIndex>IsTooCloseIndex(TooCloseCount))));
         end % if
      end % for

      ThinnedTickIndex = ThinnedTickIndex(~ismember(ThinnedTickIndex,intersect(IsMinorIndex,IsTooCloseIndex)));
      
   else % (if there are no major ticks).
      
      % No major point to anchor the choice of tick values, so try to find a tick value that
      % is divisible by the time increment between the thinned ticks (NiceTimeJump). 
      [CurrYear,CurrMonth,CurrDay,CurrHour,CurrMinute,CurrSecond] = intdatevec(MinorTicks);
      
      if BaseUnits == YEARS,
         ValList = CurrYear;
      elseif BaseUnits == MONTHS,
         ValList = CurrMonth;
      elseif BaseUnits == DAYS,
         ValList = CurrDay;
      elseif BaseUnits == HOURS,
         ValList = CurrHour;
      elseif BaseUnits == MINUTES,
         ValList = CurrMinute;
      elseif BaseUnits == SECONDS,
         ValList = CurrSecond;
      end % if
      
      AnchorIndex = min(find(rem(ValList,NiceTimeJump)==0));
      
      if isempty(AnchorIndex),
         ThinnedTickIndex = 1:NiceTimeJump:length(ValList);
      else
         ThinnedTickIndex = unique([(AnchorIndex:-NiceTimeJump:1) (AnchorIndex+NiceTimeJump:NiceTimeJump:length(ValList))]);
      end % if
      
   end % if ~isempty(MajorTicks)

   ThinnedTicks = MinorTicks(ThinnedTickIndex);

end % if too many ticks.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5) Create the tick and axis labels.

% Assemble list of labels for the thinned time axis ticks.
% Matlab bug sometimes has datestr(t,13) = '19:59:00', but
% datestr(t,15) = '20:00'. Work around by calling datestr.m
% with format=15, but removing last 3 characters from the
% resulting string to get HH:MM format.
LabelList = [];

% For each tick...
for TickCount = 1:length(ThinnedTicks),
   CurrTick = ThinnedTicks(TickCount);
   [CurrYear,CurrMonth,CurrDay,CurrHour,CurrMinute,CurrSecond] = datevec(CurrTick);
   
   if ~isempty(MajorTicks),
      IsMajorTick = any(CurrTick == MajorTicks);
   else
      IsMajorTick = 0;
   end % if
   
   % If the current tick is a major tick, give it an appropriate label.
   if IsMajorTick,
      if ismember(CurrTick,YearTicks),
         CurrLabel = [datestr(CurrTick,3) ' ' datestr(CurrTick,10)];
      elseif ismember(CurrTick,MonthTicks),
         CurrLabel = datestr(CurrTick,3);
      elseif ismember(CurrTick,DayTicks),
         CurrLabel = [datestr(CurrTick,3) ' ' sprintf('%.2d',CurrDay)];
      elseif ismember(CurrTick,[HourTicks MinuteTicks]),
         CurrLabel = datestr(CurrTick,13);
         CurrLabel = CurrLabel(1:5);
      end % if
      
      % Else, if the current tick is not a major tick, give it a minor tick label.
   else
      if BaseUnits == YEARS,
         CurrLabel = datestr(CurrTick,10);
      elseif BaseUnits == MONTHS,
         CurrLabel = datestr(CurrTick,3);
      elseif BaseUnits == DAYS,
         CurrLabel = sprintf('%.2d',CurrDay);
      elseif BaseUnits == HOURS,
         CurrLabel = datestr(CurrTick,13);
         CurrLabel = CurrLabel(1:5);
      elseif BaseUnits == MINUTES,
         CurrLabel = datestr(CurrTick,13);
         CurrLabel = CurrLabel(1:5);
      elseif BaseUnits == SECONDS,
         CurrLabel = datestr(CurrTick,13);
      end % if
      
   end % if
   
   LabelList = [LabelList '|' CurrLabel];
   
end % for TickCount

if ~isempty(LabelList),
   LabelList(1) = [];
end % if

% Build a time axis label. The label should include information not included in the
% tick labels (e.g., the year if there are no year ticks on the time axis).

if BaseUnits == YEARS,
   TimeLabelStr = 'Time [years]';
elseif BaseUnits == MONTHS,
   if isempty(YearTicks),
      TimeLabelStr = ['Time [months in ' num2str(CurrYear) ']'];   
   else
      TimeLabelStr = 'Time [months]';
   end % if
   
elseif BaseUnits == DAYS,
   if isempty(MonthTicks),
      TimeLabelStr = ['Time [days in ' char(MonthList{CurrMonth}) ' ' num2str(CurrYear) ']'];
   elseif isempty(YearTicks),
      TimeLabelStr = ['Time [days in ' num2str(CurrYear) ']'];         
   else
      TimeLabelStr = 'Time [days]';
   end % if
   
elseif BaseUnits == HOURS | BaseUnits == MINUTES | BaseUnits == SECONDS,
   if isempty(DayTicks),
      TimeLabelStr = ['Time on ' char(MonthList{CurrMonth}) ' ' sprintf('%.2d',CurrDay) ', ' num2str(CurrYear)];
   elseif isempty(MonthTicks),
      TimeLabelStr = ['Time in ' char(MonthList{CurrMonth}) ' '  num2str(CurrYear)];
   elseif isempty(YearTicks),
      TimeLabelStr = ['Time in ' num2str(CurrYear)];
   else
      TimeLabelStr = 'Time';
   end % if
   
end % if

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6) Set the tick positions and labels.

% Convert tick positions back to original plot time units.
ThinnedTicks = (ThinnedTicks - DatumTime).*XLimFactor;
set(gca,'xtick',ThinnedTicks,'xticklabel',LabelList)
%kdatetickXlabel = xlabel(TimeLabelStr);
%set(kdatetickXlabel,'Tag','kdatetickXlabel');

%------------------------------------------------------------------------------
function RoundedNumber = roundn(number,increment)
%
% roundn.m--Rounds a number to the nearest specified increment.
%
% For example, specifying an increment of .01 will cause the input
% number to be rounded to the nearest one-hundredth while an increment
% of 25 will cause the input number to be rounded to the nearest
% multiple of 25. An increment of 1 causes the input number to be
% rounded to the nearest integer, just as Matlab's round.m does.
%
% Roundn.m works for scalars and matrices.
%
% Syntax: RoundedNumber = roundn(number,increment);
%
% e.g., RoundedNumber = roundn(123.456789,.01)
% e.g., RoundedNumber = roundn(123.456789,5)

% Kevin Bartlett (bartlettk@dfo-mpo.gc.ca) 08/1999
%------------------------------------------------------------------------------

if increment == 0,
   error('roundn.m--Cannot round to the nearest zero.')
end % if

multiplier = 1/increment;
RoundedNumber = round(multiplier*number)/multiplier;

%------------------------------------------------------------------------------
function [year,month,day,hour,minute,second] = intdatevec(time)
%
% intdatevec.m--Calls Matlab's datevec.m function, but rounds the seconds value
% up or down to the nearest integer.
%
% If called with 1 or 0 output arguments, intdatevec.m returns the year, 
% month, day, hour, minute and second values in a single vector variable.
% [year,month,day,hour,minute,second] = intdatevec(time) returns the 
% components of the date vector as individual variables.
%
% Syntax: [year,month,day,hour,minute,second] = intdatevec(time)
%
% e.g., DateVector = intdatevec(datenum(1999,12,31,23,59,59.9))
% e.g., [year,month,day,hour,minute,second] = intdatevec(datenum(1999,12,31,23,59,59.9))

% Kevin Bartlett (bartlettk@dfo-mpo.gc.ca) 11/1999
%------------------------------------------------------------------------------
% Tests for development:
% start = datenum(1999,12,31,23,59,59.9);DateVector = intdatevec([start:.2:start+3])

% Make sure time is a column vector.
time = time(:);

% Run Matlab's datevec.m function.
DateVector = datevec(time);

% Round the seconds to the nearest integer value.
DateVector(:,6) = round(DateVector(:,6));

% Carry over the rounding to the other elements of the date vector.

% ...minutes:
FindIndex = find(DateVector(:,6)>=60);

if ~isempty(FindIndex),
   DateVector(FindIndex,5) = DateVector(FindIndex,5) + 1;
   DateVector(FindIndex,6) = 0;
end % if

% ...hours:
FindIndex = find(DateVector(:,5)>=60);

if ~isempty(FindIndex),
   DateVector(FindIndex,4) = DateVector(FindIndex,4) + 1;
   DateVector(FindIndex,5) = 0;
end % if

% ...days:
FindIndex = find(DateVector(:,4)>=24);

if ~isempty(FindIndex),
   DateVector(FindIndex,3) = DateVector(FindIndex,3) + 1;
   DateVector(FindIndex,4) = 0;
end % if

% ...months:
InputYear = DateVector(:,1);
InputMonth = DateVector(:,2);
DaysInMonth = eomday(InputYear,InputMonth);

FindIndex = find(DateVector(:,3)>DaysInMonth);

if ~isempty(FindIndex),
   DateVector(FindIndex,2) = DateVector(FindIndex,2) + 1;
   DateVector(FindIndex,3) = 1;
end % if

% ...years:
FindIndex = find(DateVector(:,2)>12);

if ~isempty(FindIndex),
   DateVector(FindIndex,1) = DateVector(FindIndex,1) + 1;
   DateVector(FindIndex,2) = 1;
end % if

if nargout <= 1,
   year = DateVector;
else
   year   = DateVector(:,1);
   month  = DateVector(:,2);
   day    = DateVector(:,3);
   hour   = DateVector(:,4);
   minute = DateVector(:,5);
   second = DateVector(:,6);
end % if

