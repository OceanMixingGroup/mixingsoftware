function [vel_m] = chi_generate_vel_adcp(time, z_adcp, u, v, z_chi,  sdir)
%% [vel_m] = chi_generate_vel_adcp(time, z_adcp, u, v, z_chi, sdir)
% 
%        This function generates an input file for chi-processing vel_m.mat
%        directory sdir
%        
%        Input
%           time        : adcp time
%           z_adcp      : adcp depth 
%           u           : east velocity matrix
%           v           : north velocity matrix
%           z_chi       : instrument depth 
%           sdir        : directory to save vel_m.mat to (if empty no saving)
% 
%        Output
%           vel_m.time  : time vector  
%           vel_m.u     : east velocity vector
%           vel_m.v     : north velocity vector
%           vel_m.z_chi : instrument depth 
%
%   created by: 
%        Johannes Becherer
%        Fri Sep  2 11:20:31 PDT 2016


% init variables
vel_m.u     = nan(size(time));
vel_m.v     = nan(size(time));
vel_m.time  = time;
vel_m.depth = z_chi;


if z_adcp == z_chi   % in case it is already interpolated

   vel_m.u = u;
   vel_m.v = v;
   
else     % in cse it is at a differnt depth interpolate
   % determin the size of z_adcp (matrix? or vector?)
   sz = size(z_adcp);

   % if vector generate matrix
   if sz(1)~=length(time) & sz(2)~=length(time)
      [z_adcp, ~] = meshgrid(z_adcp, time);
   end



   % loop through every time step
   for t = 1:length(time)

      vel_m.u(t) = interp1(z_adcp(t,:), u(t,:), z_chi);
      vel_m.v(t) = interp1(z_adcp(t,:), v(t,:), z_chi);

   end
end

if ~isempty(sdir)
   save([sdir 'vel_m.mat'], 'vel_m');
end
