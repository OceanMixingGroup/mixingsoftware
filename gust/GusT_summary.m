clc;
close all 
pathname = 'C:\Users\mixing\Documents\gustT\water_tank_orientation_test\';
nm = dir(pathname); gst.time = []; gst.compass = []; gst.pitch = []; gst.roll = [];
gst.AX = []; gst.AY = []; gst.AZ = [];
gst.P = []; gst.W = []; gst.WP = [];
gst.T = []; gst.TP = [];gst.time = [];
% load('\\ganges\data\concorde16\t-chain\gust\t-chain\header\G-02.mat');
for i = 3:4
    data = raw_load_gust([pathname nm(i).name]);
%     save(nm(i).name(1:(end-4)),'data','head');
    display(nm(i).name);
    gst.time = [gst.time;data.time];
    gst.compass = [gst.compass;data.compass];
    gst.pitch = [gst.pitch;data.pitch];
    gst.roll = [gst.roll;data.roll];
    gst.AX = [gst.AX;data.AX];
    gst.AY = [gst.AY;data.AY];
    gst.AZ = [gst.AZ;data.AZ];
    gst.W = [gst.W;data.W];
    gst.WP = [gst.WP;data.WP];
    gst.P = [gst.P;data.P];
    gst.T = [gst.T;data.T];
    gst.TP = [gst.TP;data.TP];
clear data;
end
% clear data;
save('C:\Users\mixing\Documents\gustT\water_tank_orientation_test\G001_tank_orientation.mat','gst');
    