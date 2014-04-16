% These are the routines for the bottom track display
%
% bottom_plot4: Main routine. Called in the lab or on the bridge.
%    See the source code for usage notes.
%
% These routines are called by bottom_plot4:
%
%   set_up_survey.m       % reads the survey data and plots it 
%     plot_bathy_c.m      % contours bathy data.
%   update_plot.m         % updates the plot with current info.
%     read_bottom_out.m   % reads current info from BottomAvoid.
%   write_plotfile.m      % (Lab) writes the current user's axes limits
%   read_plotfile.m       % (Bridge) reads the current user's axes limits.
% 
% These are helper routines:
%   distribute.m: distributes the source code to other computers.
%      Useful when editing/debugging is being performed on a
%      machine other than the Lab or Bridge computer.
%   
%  j_ll2xy and j_xy2ll are conversions from lon-lat to x-y.
%  mpernm.m converts from meters to nautical miles. 
%
