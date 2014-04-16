function [disp,vel]=integrate_acc(cal,head,hpf_cutoff,number)
% function [disp,vel]=integrate_acc(cal,head,hpf_cutoff,number)
% integrate accelerometer data to get 
% cable velocities & displacements
% hpf_cutoff (optional) - hpf filter cutoff in Hz. Should be adjusted for every cruise!
% For scs07 0,02Hz worked well, for tao data - 0.04 seems to do better  
% For shorter data (less than 2 min) the default value (0.04Hz) should be increased!
% number (optional) - number of points over which acceleration data is extrapolated 
% on both sides to get rid of boundary problems with filtering
% Default value is 2 min worth of datapoints  
% $Revision: 1.5 $ $Date: 2010/05/25 22:41:02 $ $Author: aperlin $
% Originally J.Moum

if nargin<3
  hpf_cutoff=0.04;
end
if nargin<4
  number=head.samplerate(head.sensor_index.AX)*120;
end

% dt=1./head.primary_sample_rate;sr=1/dt;
sr=head.samplerate(head.sensor_index.AX); dt=1/sr;

[b,a]=butter(2,2*hpf_cutoff/sr,'high');

% extrapolate acc data
% extrapolate a VARIABLE over the
% extra NUMBER of points 
% on both sides
len=length(cal.AX);
flipsize=min(len,number);
names1={'AX','AY','AZ'};
names2={'x','y','z'};
for i=1:length(names1)
    in=cal.(char(names1(i)))-mean(cal.(char(names1(i))));
    if size(cal.AX,1)>1
        in=in';
    end
    fin=fliplr(in(1:flipsize)); fin=fin(1:end-1);
    bin=fliplr(in(end-flipsize+1:end)); bin=bin(2:end);
    in=[fin in  bin];
    a_f=filtfilt(b,a,in);
    cuma=cumtrapz(a_f).*dt;
    cuma_f=filtfilt(b,a,cuma);
    vel.(char(names2(i)))=cuma_f(flipsize:flipsize+len-1);
    cumv=cumtrapz(cuma_f).*dt;
    cumv_f=filtfilt(b,a,cumv);
    cumv_ff=filtfilt(b,a,cumv_f);
    disp.(char(names2(i)))=detrend(cumv_ff(flipsize:flipsize+len-1));
    if size(cal.AX,1)>1
        vel.(char(names2(i)))=vel.(char(names2(i)))';
        disp.(char(names2(i)))=disp.(char(names2(i)))';
    end
end


