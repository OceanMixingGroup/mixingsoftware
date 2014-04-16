function cal=calc_filtered_rotations(cal)
% Filter and calculate rotations from rate data output
% Right Hand coordinate system. Positive rotations are
% in clockwise direction when looking in the positive axis direction
% RX is rotation rate about X-axis
% Rotation about Z is YAW, about Y is PITCH, and about X is ROLL
% Filters seem to work for Chipod, but should probably be modified for any
% other application
% A. Perlin, 28 August 2008
number=72000; % 10 minutes
len=length(cal.RX);
flipsize=min(len,number);
% First calculate short-term rotations from rate signals
names1={'RX','RY','RZ'};
% names2={'npitch','nroll','nyaw'};
names2={'alphaX','alphaY','alphaZ'};

for i=1:length(names1)
    in=detrend(cal.(char(names1(i))));
    if size(in,1)>1
        in=in';
    end
    fin=fliplr(in(1:flipsize)); fin=fin(1:end-1);
    bin=fliplr(in(end-flipsize+1:end)); bin=bin(2:end);
    in=[fin in  bin];
    in=detrend(gappy_filt(120,{'h0.005'},4,in,1,1,20));
    in=gappy_filt(120,{'l1'},4,in,1,1,20);
    in=1/120*cumtrapz(in);
    in=detrend(gappy_filt(120,{'h0.005'},4,in,1,1,20));
    cal.(char(names2(i)))=in(flipsize:flipsize+len-1);
    if size(cal.(char(names1(i))),1)>1
        cal.(char(names2(i)))=cal.(char(names2(i)))';
    end
end

