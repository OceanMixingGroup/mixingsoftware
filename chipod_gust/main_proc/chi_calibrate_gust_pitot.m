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
           
   % compass
         chi.cmp      = rdat.compass;
            chi.cmp      = chi.cmp-16.66;
         chi.pitch    = rdat.pitch;
         chi.roll     = rdat.roll;
      
   % DTdt
      rdat.TP = rdat.TP - nanmean(rdat.TP);
      chi.TPt = calibrate_tp( rdat.TP, head.coef.TP, rdat.T, head.coef.T, 100*ones(size(rdat.T)) );

   %---------------------Pitot stuff----------------------

         % find pitot data W or WP
         dV1 = abs(nanmean(rdat.W)-2.02);
         dV2 = abs(nanmean(rdat.WP)-2.02);
         if dV1>dV2
            chi.V_raw  = rdat.W;
         else
            chi.V_raw  = rdat.WP;
         end

         chi.cal.V0 = head.W.V0;
         chi.cal.T0 = head.W.T0;
         chi.cal.P0 = head.W.P0;
         chi.cal.Vs = 1/head.W.Pd(2);
         chi.cal.Ts = head.W.T(2);
         chi.cal.Ps = head.W.Ps(2);
         [chi.spd, chi.Pdym, chi.V_cal] = pitot_calibrate(chi.V_raw, chi.T, chi.P,...
                  chi.cal.V0, chi.cal.T0, chi.cal.P0, chi.cal.Vs, chi.cal.Ts, chi.cal.Ps);

         chi.U  = pitot_add_direction( chi.time, chi.spd, chi.time_cmp, chi.cmp);
         chi.u  = real(chi.U);
         chi.v  = imag(chi.U);
         

%---------------------return data----------------------
   data = chi;
