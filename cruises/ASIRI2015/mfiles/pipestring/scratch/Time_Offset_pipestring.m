function offset=Time_Offset_pipestring(tnav,headnav,tpipe,headpipe)
%~~~~~~~~~~~~~~~~~~~~~~~~
%
% Find time offset of pipestring ADCP by comparing to ship heading
%
% 09/12/15 - A.Pickering - 
%~~~~~~~~~~~~~~~~~~~~~~~~
%%

% find a chunck of the nav time that covers the adcp time (plus extra so we
% can slide it arond)

t_range=[nanmin(tpipe)-1/24 nanmax(tpipe)+1/24];
idd=isin(tnav,t_range);

tvec=t_range(1):1/86400:t_range(2);

% interp to a common time vector

ig=find(~isnan(tnav(idd)));
headnav_i=interp1(tnav(idd(ig)),headnav(idd(ig)),tvec);
ig=find(~isnan(tpipe));
headpipe_i=interp1(tpipe(ig),headpipe(ig),tvec);

% lowpass filter a bit to smooth any spikes
fcut=40*24;
x1low=MyLowpass(tvec,headnav_i,4,fcut);
x2low=MyLowpass(tvec,headpipe_i,4,fcut);

figure(1);clf

subplot(311)
plot(tnav(idd),headnav(idd))
hold on
plot(tpipe,headpipe)

subplot(312)
plot(tvec,headnav_i)
hold on
plot(tvec,headpipe_i)

plot(tvec,x1low)
hold on
plot(tvec,x2low)
%subplot(312)

subplot(313)
plot(tvec,headnav_i-nanmean(headnav_i))
hold on
plot(tvec,headpipe_i-nanmean(headpipe_i))
% shift through lags and compute MSE

lags=-800:800;
mse=nan*ones(1,length(lags));
% for ilag=1:length(lags)
% %    err=headpipe_i - headnav_i(    
% end

% find minimum MSE


%%