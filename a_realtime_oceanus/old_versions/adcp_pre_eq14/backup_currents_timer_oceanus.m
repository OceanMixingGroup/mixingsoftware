% backup_currents_timer.m
%
% Run a timer that calls copyalladcp at a regular interval to
% copy all of the ship's raw AND processed ADCP data. (Processed adcp data
% is the data processed by the ship's UHDAS+CODAS system, NOT the data
% processed by make_currents_oceanus, which does not need to be backed up
% because it would be very easy to rerun that processing.)
%
% Note: if there is an error in copyalladcp, that is not resolved
% as new realtime data comes in, this code will turn into an INFINITE LOOP.
% Therefore, when debugging or running for the first time, just run
% copyalladcp(frompathbackup,topathbackup) without using this funciton to run the timer. (The
% infinite loop is necessary because timing problems arise with the way the
% ship writes the adcp data at the beginning of a new file. Without the
% infinite loop, the timer will crash every two hours.)
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

polltime = 7200;
copyadcp=timer('TimerFcn','copyalladcp(frompathbackup,topathbackup)',...
    'Period',polltime,'executionmode','fixedrate','busymode','queue',...
    'ErrorFcn','backup_currents_timer_oceanus');
starttimebackup = now + 1/86400;
startat(copyadcp,starttimebackup);


