% make_currents_timer_oceanus.m
%
% Run a timer that calls process_currents_oceanus at a regular interval to
% process the realtime ship adcp data.
%
% Note: if there is an error in process_currents_oceanus, that is not resolved
% as new realtime data comes in, this code will turn into an INFINITE LOOP.
% Therefore, when debugging or running for the first time, just run
% process_current_oceanus without using this funciton to run the timer. (The
% infinite loop is necessary because timing problems arise with the way the
% ship writes the adcp data at the beginning of a new file. Without the
% infinite loop, the timer will crash every two hours.)
%
% *** To stop the timer, write the command: stop(processadcp)
% *** To get more information about the timer: get(processadcp)
%
% *** To stop the timer, write the command: stop(copyadcp)
% *** To get more information about the timer: get(copyadcp)
%
% Sally Warner, January 2014



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get paths and parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% look to set_currents_oceanus to get all important pathnames and
% parameters
set_currents_oceanus


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% process raw adcp data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code uses the paths and parameters set in set_currents_oceanus.
% The processing is done by process_currents_oceanus which is on a timer. The
% timer wait time is set in set_currents_oceanus. A good choice is 120
% seconds.

% If an error occurs, make_currents_timer_oceanus (this code) is rerun until the error resolves
% itself. There are timing errors that occur when processing the raw adcp
% data. They happen every 2 hours and resolve themselves in a minute and a
% half. If another kind of error occurs, an infinite loop may begin.

% *** STOP this timer loop by typing the command: stop(processadcp) ***
% *** To get more information about the timer: get(processadcp) ***


processadcp = timer('TimerFcn','process_currents_oceanus',...
    'Period',waittime,'executionmode','fixedrate','busymode','queue');
starttimeprocess = now + 1/86400;
startat(processadcp,starttimeprocess);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% backup raw adcp data and adcp data processed by the ship's UHDAS+CODAS system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code uses the paths and parameters set in set_currents_oceanus.
% The backup is done by copyalladcp which is on a timer. The
% timer wait time is set in set_currents_oceanus. A good choice is 3600
% seconds.

% If an error occurs, run_currents_timer is rerun until the error resolves
% itself. This may cause an infinite loop if problem does not resolve
% itself.

% *** STOP this timer loop by typing the command: stop(copyadcp) ***
% *** To get more information about the timer: get(copyadcp) *** 

copyadcp=timer('TimerFcn','copyalladcp_dir',...
    'Period',polltime,'executionmode','fixedrate','busymode','queue');
starttimebackup = starttimeprocess + 5*60/85400; % set to start 5 min after processing starts
startat(copyadcp,starttimebackup);


