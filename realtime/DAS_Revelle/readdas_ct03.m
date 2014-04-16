function track=readdas_ct03(fname);
% Function to read raw Revelle DAS data
% and convert it to matlab
% if used in realtime software, called by realtimetrack.m
% function track=readdas_ct03;
fid = fopen(fname,'r');
i=0;
while 1
    i=i+1;
    str=fgetl(fid);
    if ischar(str)
        year=2000+str2num(str(12:13));
        month=str2num(str(10:11));
        day=str2num(str(8:9));
        hour=str2num(str(15:16));
        min=str2num(str(17:18));
        sec=str2num(str(19:20));
        track.time(i)=datenum(year,month,day,hour,min,sec);
        zp = find(str==',');
        track.ws1(i)=str2num(str(zp(3)+1:zp(4)-1)); % relative wind speed, sensor #1 (m/s)
        track.wd1(i)=str2num(str(zp(5)+1:zp(6)-1)); % relative wind direction, sensor #1 (degrees)
        track.tw1(i)=str2num(str(zp(7)+1:zp(8)-1)); % true wind speed, sensor #1 (m/s)
        track.ti1(i)=str2num(str(zp(9)+1:zp(10)-1)); % true wind direction, sensor #1 (degrees)
        track.ws2(i)=str2num(str(zp(11)+1:zp(12)-1)); % relative wind speed, sensor #2 (m/s)
        track.wd2(i)=str2num(str(zp(13)+1:zp(14)-1)); % relative wind direction, sensor #2 (degrees)
        track.tw2(i)=str2num(str(zp(15)+1:zp(16)-1)); % true wind speed, sensor #2 (m/s)
        track.ti2(i)=str2num(str(zp(17)+1:zp(18)-1)); % true wind direction, sensor #2 (degrees)
        track.bp(i)=str2num(str(zp(19)+1:zp(20)-1)); % barometric pressure (mb)
        track.rh(i)=str2num(str(zp(21)+1:zp(22)-1)); % relative humidity (%)
        track.rt(i)=str2num(str(zp(23)+1:zp(24)-1)); % air temperature, RH module (deg C)
        track.dp(i)=str2num(str(zp(25)+1:zp(26)-1)); % Dew point (deg C)
        track.at(i)=str2num(str(zp(27)+1:zp(28)-1)); % air temperature (deg C)
        track.pr(i)=str2num(str(zp(29)+1:zp(30)-1)); % precipitation (mm)
        track.ld(i)=str2num(str(zp(31)+1:zp(32)-1)); % LWR dome temperature (deg K)
        track.lb(i)=str2num(str(zp(33)+1:zp(34)-1)); % LWR body temperature (deg K)
        track.lt(i)=str2num(str(zp(35)+1:zp(36)-1)); % LWR thermopile (Volts)
        track.lw(i)=str2num(str(zp(37)+1:zp(38)-1)); % long wave radiation (W/m^2)
        track.sw(i)=str2num(str(zp(39)+1:zp(40)-1)); % short wave radiation (W/m^2)
        track.tt1(i)=str2num(str(zp(41)+1:zp(42)-1)); % SBE21 temperature (deg C)
        track.tc1(i)=str2num(str(zp(43)+1:zp(44)-1)); % SBE21 conductivity (mS/m)
        track.sa1(i)=str2num(str(zp(45)+1:zp(46)-1)); % salinity (PSU)
        track.sd1(i)=str2num(str(zp(47)+1:zp(48)-1)); % Sigma-t (kg/m^3)
        track.sv1(i)=str2num(str(zp(49)+1:zp(50)-1)); % sound velocity (Chen/Millero) (m/s)
        track.fm(i)=str2num(str(zp(51)+1:zp(52)-1)); % USW flow meter (gpm)
        track.oc(i)=str2num(str(zp(53)+1:zp(54)-1)); % oxigen current (ua)
        track.ot(i)=str2num(str(zp(55)+1:zp(56)-1)); % oxigen temperature (at sink) (deg C)
        track.ox(i)=str2num(str(zp(57)+1:zp(58)-1)); % oxigen (ml/l)
        track.os(i)=str2num(str(zp(59)+1:zp(60)-1)); % oxigen saturation value (ml/l)
        track.wt(i)=str2num(str(zp(61)+1:zp(62)-1)); % auxiliary water temperature (deg C)
        track.fi(i)=str2num(str(zp(63)+1:zp(64)-1)); % USW flow meter (lpm)
        track.fl(i)=str2num(str(zp(65)+1:zp(66)-1)); % fluorometer (ug/l)
        track.tr(i)=str2num(str(zp(67)+1:zp(68)-1)); % transmissometer (%)
        track.tt2(i)=str2num(str(zp(69)+1:zp(70)-1)); % SBE21 temperature (deg C) !!!calibration coefficient wrong!!!
        track.tc2(i)=str2num(str(zp(71)+1:zp(72)-1)); % SBE21 conductivity (mS/m) !!!calibration coefficient wrong!!!
        track.sa2(i)=str2num(str(zp(73)+1:zp(74)-1)); % salinity (PSU) !!!wrong!!!
        track.sd2(i)=str2num(str(zp(75)+1:zp(76)-1)); % Sigma-t (kg/m^3) !!!wrong!!!
        track.sv2(i)=str2num(str(zp(77)+1:zp(78)-1)); % sound velocity (Chen/Millero) (m/s) !!!wrong!!!
        track.bt(i)=str2num(str(zp(79)+1:zp(80)-1)); % bottom depth (m)
        track.ts(i)=str2num(str(zp(81)+1:zp(82)-1)); % time server time (sec)
        track.la(i)=str2num(str(zp(83)+1:zp(84)-1)); % latitude decimal format (deg)
        track.lo(i)=str2num(str(zp(85)+1:zp(86)-1)); % longitude decimal format (deg)
        track.cr(i)=str2num(str(zp(87)+1:zp(88)-1)); % ship course (GPS) (deg)
        track.sp(i)=str2num(str(zp(89)+1:zp(90)-1)); % ship speed (GPS) (knts)
        track.gt(i)=str2num(str(zp(91)+1:zp(92)-1)); % GPS time (sec)
        track.gy(i)=str2num(str(zp(93)+1:zp(94)-1)); % ship course (Gyro) (deg)
        track.sh(i)=str2num(str(zp(95)+1:zp(96)-1)); % Ashtech heading (deg)
    else
        break
    end % ischar(temp)
end % while 1
fclose(fid);
track.readme={'ws1: relative wind speed, sensor #1 (m/s)';
        'wd1: relative wind direction, sensor #1 (degrees)';
        'tw1: true wind speed, sensor #1 (m/s)';
        'ti1: true wind direction, sensor #1 (degrees)';
        'ws2: relative wind speed, sensor #2 (m/s)';
        'wd2: relative wind direction, sensor #2 (degrees)';
        'tw2: true wind speed, sensor #2 (m/s)';
        'ti2: true wind direction, sensor #2 (degrees)';
        'bp: barometric pressure (mb)';
        'rh: relative humidity (%)';
        'rt: air temperature, RH module (deg C)';
        'dp: Dew point (deg C)';
        'at: air temperature (deg C)';
        'pr: precipitation (mm)';
        'ld: LWR dome temperature (deg K)';
        'lb: LWR body temperature (deg K)';
        'lt:LWR thermopile (Volts)';
        'lw: long wave radiation (W/m^2)';
        'sw: short wave radiation (W/m^2)';
        'tt1: SBE21 temperature, sensor #1 (deg C)';
        'tc1: SBE21 conductivity, sensor #1 (mS/m)';
        'sa1: salinity (PSU);'
        'sd1: Sigma-t (kg/m^3);'
        'sv1: sound velocity (Chen/Millero) (m/s);'
        'fm: USW flow meter (gpm);'
        'oc: oxigen current (ua);'
        'ot: oxigen temperature (at sink) (deg C);'
        'ox: oxigen (ml/l);'
        'os: oxigen saturation value (ml/l);'
        'wt: auxiliary water temperature (deg C);'
        'fi: USW flow meter (lpm);'
        'fl: fluorometer (ug/l)';
        'tr: transmissometer (%)';
        'tt2: SBE21 temperature, sensor #2 (deg C) !!!calibration is wrong!!!';
        'tc2: SBE21 conductivity, sensor #2 (mS/m) !!!calibration is wrong!!!';
        'sa2: salinity (PSU) !!!wrong!!!';
        'sd2: Sigma-t (kg/m^3) !!!wrong!!!';
        'sv2: sound velocity (Chen/Millero) (m/s) !!!wrong!!!';
        'bt: bottom depth (m)';
        'ts: time server time (sec)';
        'la: latitude decimal format (deg)';
        'lo: longitude decimal format (deg)';
        'cr: ship course (GPS) (deg)';
        'sp: ship speed (GPS) (knts)';
        'gt: GPS time (sec)';
        'gy: ship course (Gyro) (deg)';
        'sh: Ashtech heading (deg)'};
