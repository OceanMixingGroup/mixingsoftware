%%

clear ; close all

load('/Volumes/scienceparty_share/data/nav_tot.mat')
%
datadir='/Volumes/scienceparty_share/pipestring/mat/'
Flist=dir(datadir)

tm=nan*ones(1,length(Flist));
time_off=nan*ones(1,length(Flist));
for ifile=3:length(Flist)
%
clear adcp
load(fullfile(datadir,Flist(ifile).name))


clear D1 D2 id
D1=datetime(N.dnum_hpr,'ConvertFrom','datenum');
D2=datetime(adcp.mtime,'ConvertFrom','datenum');
id=isin(N.dnum_hpr,[nanmin(adcp.mtime)-0/24 nanmax(adcp.mtime)+0/24]);



t1=N.dnum_hpr(id);
x1=N.head(id);
ip=find(x1<0);x1(ip)=x1(ip)+360;

t2=adcp.mtime;
x2=adcp.heading;
ip=find(x2<0);x2(ip)=x2(ip)+360;


% fcut=200*24;
% x1low=MyLowpass(t1,x1,4,fcut);
% x2low=MyLowpass(t2,x2,4,fcut);

%h1r=(N.head(id) )*pi/180;
%h1r=(x1low-nanmean(x1low) )*pi/180;
h1r=(N.head(id)-nanmean(N.head(id)) )*pi/180;
h1ru=unwrap(h1r);

%h2r=( adcp.heading ) *pi/180;
%h2r=(x2low-nanmean(x2low))*pi/180;
h2r=( adcp.heading-nanmean(adcp.heading) ) *pi/180;
h2ru=unwrap(h2r);
% 
% figure(23);clf
% plot(D1(id),h1ru)
% hold on
% plot(D1(id),h1r)
% plot(D2,h2r,D2,h2ru)

% q1=MyLowpass(t1,h1ru,4,fcut);
% q2=MyLowpass(t2,h2ru,4,fcut);

% figure(24);clf
% plot(D1(id),h1ru-nanmean(h1ru))
% hold on
% %plot(D1(id),h1r-nanmean(h1r))
% %plot(D2,h2r)
% plot(D2,h2ru-nanmean(h2ru))

%delt3=TimeOffset_ap(N.dnum_hpr(id),h1ru,adcp.mtime,h2ru)
try
delt3=TimeOffset_ap(N.dnum_hpr(id),h1ru,adcp.mtime,h2ru);

%delt4=TimeOffset_ap(N.dnum_hpr(id),q1,adcp.mtime,q2)
%delt3=TimeOffset_ap(N.dnum_hpr(id),h1ru-nanmean(h1ru),adcp.mtime,h2ru-nanmean(h2ru))
delt3*86400;

%plot(D2+delt3,h2ru-nanmean(h2ru),'--')
%

time_off(ifile)=delt3*86400;
catch
end

tm(ifile)=nanmean(t2);

end

%%

tm(tm<datenum(2015,8,15))=nan;
dt=diffs(time_off);
ib=find(abs(dt)>3);
hold on
%inds=1:ifile;

figure(2);clf
ax1=subplot(211)
plot(tm,time_off)
hold on
t2=time_off;t2(ib)=nan;
ib2=find(dt==0);
t2(ib2)=nan;
plot(tm,t2,'o')

ig=find(~isnan(t2));
P=polyfit(tm(ig),t2(ig),1);
Y=polyval(P,tm);
plot(tm,Y,'m')
ylim([-700 500])
datetick('x')

ax2=subplot(212)
plot(tm,dt,'.')
hold on
plot(tm(ib),dt(ib),'o')
datetick('x')

linkaxes([ax1 ax2],'x')

%%

save('/Volumes/scienceparty_share/pipestring/time_offset_fit','P')

%%


figure(1);clf
plot(tm,time_off,'.')
hold on
plot(tm,medfilt1(time_off,15,100),'s')
%
dt=diffs(time_off);
ib=find(abs(dt)>2);
t2=time_off;
t2(ib)=nan;
plot(tm,t2,'rs')

ib=find( abs(time_off-nanmedian(time_off))>10)
time_off2=time_off;
time_off2(ib)=nan;
plot(tm,time_off2,'go')
%plot(tm,medfilt1(time_off2,5),'yp')
ylim([-800 500])
%plot(tm,(time_off),'d')

shg

%%


%%

%t3=medfilt1(time_off,15,100);
%ig=find(~isnan(time_off2));
ig=find(~isnan(t3));
%ig=find(~isnan(time_off));
inds=1:ifile;
%P=polyfit(1:ifile,time_off2,1);
%P=polyfit(inds(ig),time_off2(ig),1);
P=polyfit(inds(ig),t3(ig),1);
%P=polyfit(inds(ig),time_off(ig),1);
Y=polyval(P,1:ifile);
plot(1:ifile,Y,'m')
shg
%%
%
clear D1 D2 id
D1=datetime(N.dnum_hpr,'ConvertFrom','datenum');
D2=datetime(adcp.mtime,'ConvertFrom','datenum');
id=isin(N.dnum_hpr,[nanmin(adcp.mtime)-0/24 nanmax(adcp.mtime)+0/24]);

%%

t1=N.dnum_hpr(id);
x1=N.head(id);
ip=find(x1<0);x1(ip)=x1(ip)+360;

t2=adcp.mtime;
x2=adcp.heading;
ip=find(x2<0);x2(ip)=x2(ip)+360;


fcut=40*24;
x1low=MyLowpass(t1,x1,4,fcut);
x2low=MyLowpass(t2,x2,4,fcut);


delt=TimeOffset_ap(t1,x1,t2,x2)
%delt=TimeOffset(N.dnum_hpr(id),N.head(id),adcp.mtime,adcp.heading)
delt*86400

delt2=TimeOffset_ap(t1,x1low,t2,x2low)
%delt=TimeOffset(N.dnum_hpr(id),N.head(id),adcp.mtime,adcp.heading)
delt2*86400
%%
figure(2);clf
plot(D1(id),N.head(id)-nanmean(N.head(id)))
hold on
plot(adcp.mtime,adcp.heading-nanmean(adcp.heading))

%%

t1=N.dnum_hpr(id);
x1=N.head(id);
ip=find(x1<0);x1(ip)=x1(ip)+360;

t2=adcp.mtime;
x2=adcp.heading;
ip=find(x2<0);x2(ip)=x2(ip)+360;


fcut=200*24;
x1low=MyLowpass(t1,x1,4,fcut);
x2low=MyLowpass(t2,x2,4,fcut);

%h1r=(N.head(id) )*pi/180;
%h1r=(x1low-nanmean(x1low) )*pi/180;
h1r=(N.head(id)-nanmean(N.head(id)) )*pi/180;
h1ru=unwrap(h1r);

%h2r=( adcp.heading ) *pi/180;
%h2r=(x2low-nanmean(x2low))*pi/180;
h2r=( adcp.heading-nanmean(adcp.heading) ) *pi/180;
h2ru=unwrap(h2r);

figure(23);clf
plot(D1(id),h1ru)
hold on
plot(D1(id),h1r)
plot(D2,h2r,D2,h2ru)

q1=MyLowpass(t1,h1ru,4,fcut);
q2=MyLowpass(t2,h2ru,4,fcut);

figure(24);clf
plot(D1(id),h1ru-nanmean(h1ru))
hold on
%plot(D1(id),h1r-nanmean(h1r))
%plot(D2,h2r)
plot(D2,h2ru-nanmean(h2ru))

%delt3=TimeOffset_ap(N.dnum_hpr(id),h1ru,adcp.mtime,h2ru)
delt3=TimeOffset_ap(N.dnum_hpr(id),h1ru,adcp.mtime,h2ru)
%delt4=TimeOffset_ap(N.dnum_hpr(id),q1,adcp.mtime,q2)
%delt3=TimeOffset_ap(N.dnum_hpr(id),h1ru-nanmean(h1ru),adcp.mtime,h2ru-nanmean(h2ru))
delt3*86400
delt4*86400
plot(D2+delt3,h2ru-nanmean(h2ru),'--')
%plot(D2+delt4,h2ru-nanmean(h2ru),'--')
%%

offset=Time_Offset_pipestring(N.dnum_hpr,N.head,adcp.mtime,adcp.heading)

%%
clear D1 D2 id
D1=datetime(N.dnum_hpr,'ConvertFrom','datenum');
D2=datetime(adcp.mtime,'ConvertFrom','datenum');
id=isin(N.dnum_hpr,[nanmin(adcp.mtime)-1/24 nanmax(adcp.mtime)+1/24]);

%%
id=isin(N.dnum_hpr,[nanmin(adcp.mtime) nanmax(adcp.mtime)]);
%%
t1=N.dnum_hpr(id);
x1=N.head(id);

t2=adcp.mtime;
x2=adcp.heading;

delt=TimeOffset_ap(N.dnum_hpr(id),N.head(id),adcp.mtime,adcp.heading)
%delt=TimeOffset(N.dnum_hpr(id),N.head(id),adcp.mtime,adcp.heading)
delt*86400
%%
%delt=TimeOffset_ap(,N.head(id),adcp.mtime,adcp.heading)
%delt=TimeOffset_ap(N.dnum_hpr(id),N.head(id)-nanmean(N.head(id)),adcp.mtime,adcp.heading-nanmean(adcp.heading))

fcut=50*24;
x1low=MyLowpass(t1,x1,4,fcut);
x2low=MyLowpass(t2,x2,4,fcut);

% x1low=MyHighpass(t1,x1,4,fcut);
% x2low=MyHighpass(t2,x2,4,fcut);

% x1low=BandPassData(t1,x1,fcut,.5);
% x2low=BandPassData(t2,x2,fcut,.5);

figure(1);clf
plot(t1,x1,t1,x1low)
hold on
plot(t2,x2,t2,x2low)


figure(2);clf
plot(t1,x1low-nanmean(x1low))
hold on
plot(t2,x2low-nanmean(x2low))
%
delt=TimeOffset_ap(t1,x1low,t2,x2low)
delt*86400

hold on
plot(t2+delt,x2low-nanmean(x2low))
shg
%%
figure(1);clf
plot(D1(id),N.head(id)-nanmean(N.head(id)))
hold on
plot(D2,adcp.heading-nanmean(adcp.heading))
plot(D2+delt3,adcp.heading-nanmean(adcp.heading))
xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])
%%
%%
figure(1);clf
plot(N.dnum_hpr(id),N.head(id)-nanmean(N.head(id)))
hold on
plot(adcp.mtime,adcp.heading-nanmean(adcp.heading))
plot(adcp.mtime+delt,adcp.heading-nanmean(adcp.heading))
xlim([nanmin(adcp.mtime) nanmax(adcp.mtime)])


%%

%%

figure(2);clf
plot(D1(id),N.head(id)-nanmean(N.head(id)))
hold on
plot(adcp.mtime,adcp.heading-nanmean(adcp.heading))

%%

figure(4);clf
plot(adcp.mtime-600/86400,diffs(adcp.heading)./nanmean(diff(adcp.mtime))./86400)
hold on
plot(N.dnum_hpr(id),diffs(N.head(id))./nanmean(diff(N.dnum_hpr(id)))./86400)
ylim(5*[-1 1])
%%