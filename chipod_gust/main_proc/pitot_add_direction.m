function [U] = pitot_add_direction(time_spd, spd, time_cmp, cmp)
%%   [U] = pitot_add_direction(time_spd, spd, time_cmp, cmp)
%        
%     This function uses compass information to convert
%     a speed vector into a velocity vector
%
%     INPUT:
%        time_spd       :  time-vector for speed
%        spd            :  speed vector
%        time_cmp       :  time vector for compass
%        cmp            :  compass vector [deg] from north
%
%     OUTPUT
%        U              :  velocity vector
%        real(U)        :  east 
%        imag(U)        :  north
%
%   created by: 
%        Johannes Becherer
%        Mon Sep 19 16:07:44 PDT 2016


%_____________________interpolate compass on speed time step______________________

   if( ~isequal(time_spd, time_cmp ) )
      cmp1  =  interp1(time_cmp, cmp, time_spd, 'nearest'); 
      % the nearest is done as the easiest way to interp in the complex plane
   else
      cmp1 = cmp;
   end

%_____________________generate compex velocity vector______________________

   U = spd .* exp( 1i * ( -(cmp1/180*pi) - pi/2 ));

