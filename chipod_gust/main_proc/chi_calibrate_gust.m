function [data] = chi_calibrate_gust(rfid, head)
%%  [data] = chi_calibrate_gust(rfid, head)
%     
%        This function reads GUST raw data and calibrates them acording
%        to the coefficients in head.
%
%        Input
%           rfid   :  path the the specific raw-file
%           head   :  corresponding header
%
%        Output
%           data   : data structure containing calibrated data
%
%   created by: 
%        Johannes Becherer
%        Fri Sep  2 15:53:26 PDT 2016

%_____________________read in raw data______________________

%[rdat, headtest]  = raw_load_gust(rfid);
[rdat]  = raw_load_gust(rfid);



%_____________________calibrate data______________________


   % tempertuare
      chi.T=calibrate_polynomial(rdat.T,head.coef.T);
   % pressure
      chi.P=calibrate_polynomial(rdat.P,head.coef.P);
      chi.depth = (chi.P-14.7)/1.47;

   % time vector
      chi.time     = rdat.time;
      chi.time_tp  = rdat.time;
      chi.time_cmp = chi.time(1:25:end);
      
   % accelerometer
         g=9.81;
         chi.AX=g.*calibrate_polynomial(rdat.AX,head.coef.AX);
         chi.AY=g.*calibrate_polynomial(rdat.AY,head.coef.AY);
         chi.AZ=g.*calibrate_polynomial(rdat.AZ,head.coef.AZ);
          chi.AX=fillgap(chi.AX);
          chi.AY=fillgap(chi.AY);
          chi.AZ=fillgap(chi.AZ);
          [dis,vel]=integrate_acc(chi,head);

          chi.a_dis_x = dis.x;
          chi.a_dis_y = dis.y;
          chi.a_dis_z = dis.z;
          chi.a_vel_x = vel.x;
          chi.a_vel_y = vel.y;
          chi.a_vel_z = vel.z;
           
         chi.AXtilt=calibrate_tilt(rdat.AX,head.coef.AX);
         chi.AYtilt=calibrate_tilt(rdat.AY,head.coef.AY);
         chi.AZtilt=calibrate_tilt(rdat.AZ,head.coef.AZ);

   % compass
         chi.cmp      = rdat.compass;
         chi.pitch    = rdat.pitch;
         chi.roll     = rdat.roll;
      
   % DTdt
      rdat.TP = rdat.TP - nanmean(rdat.TP);
      chi.TPt = calibrate_tp( rdat.TP, head.coef.TP, rdat.T, head.coef.T, 100*ones(size(rdat.T)) );

   % find pitot data W or WP
         dV1 = abs(nanmean(rdat.W)-2.02);
         dV2 = abs(nanmean(rdat.WP)-2.02);
         if dV1>dV2
            chi.W  = rdat.W;
         else
            chi.W  = rdat.WP;
         end

%---------------------return data----------------------
   data = chi;
