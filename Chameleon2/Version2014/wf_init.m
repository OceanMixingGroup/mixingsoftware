function [wfstruct] = wf_init( h_axes, timespan,xmin,xmax,maxchannels,plotrate )
% wf_init    Initialize a waterfall plot structure
% inputs are:  axes, #seconds to show, volts min and max,
%              Number of channels of data, and plots/second
%  this structure holds the variables that wf_plot uses to control
%  the plot display

wfstruct.wfaxes = h_axes;    % axes to us for this plot
set(h_axes, 'YDir','reverse');
wfstruct.wftimespan = timespan;  %  the time interval from top to bottom
wfstruct.wfxlim = [xmin xmax];  % the X-axis limits, normally -5 to +5
% specify an hsv color map with maxchannels entries
mymap = hsv(maxchannels);
% use that color map for this application
%colormap(mymap);
for jj = 1:maxchannels
    cval = mymap(jj,:);
    wfstruct.wfcolors(jj,:) = cval;
end

wfstruct.wfchannels = maxchannels; % the number of channels of data
% the number of rows of data will be the timespan * plotrate % guard rows
wfstruct.wfnumrows = timespan*plotrate+5;
wfstruct.wfgain = ones(1,16);
wfstruct.wfgain(7) = 1; %S2 Gain
wfstruct.wfgain(5) = 1; %S1 Gain
wfstruct.wfgain(3) = 1; %TP5 gain
wfstruct.wfoffset = zeros(1,16); 
wfstruct.wfoffset(5) = -1; %S1 offset
wfstruct.wfoffset(7) = 1; %s2 offset
% wfstruct.wfoffset(3)
wfstruct.wfplotrate = plotrate;  % number of rows of data per second
% wfchantoplot is to specify a subset of the maximum
% numbers of channels to actually plot----allowing channels to be
% turned on and off during plotting
% the calling program can set the array points to 1s to plot and
% zeros to not plot a channel
wfstruct.wfchantoplot = ones(1,maxchannels);  % array with indices of channels to plot
wfstruct.emode = 0;
% calling wf_plot with -1 for time resets the persistent variables
% and initializes the data and time arrays
% wf_plot(wfstruct, [],-1);  % reset the persistent variables
end

