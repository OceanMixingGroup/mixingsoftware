% initializes the summary file.  Not sure why this is neede.
% called before process_file.

set_chameleon;

q.script.prefix=cruise_id;
q.script.pathname=path_raw;
path_save='mat\';

nextfile=input('Enter number of profile to start --> ');
save nextfile nextfile;
max_depth_bins=input('Enter maximum number of depth bins --> ');
n_dep=max_depth_bins;
init=NaN*ones(n_dep,1);
clear sum;
sum.EPS1=init;
sum.EPS2=init;
sum.CHI=init;
%  sum.TKE=init;
sum.AZ2=init;
sum.EPS=init;
sum.SCAT=init;
sum.S=init;
sum.THETA=init;
sum.C=init;
sum.FALLSPD=init;
sum.P=init;
sum.N2=init;
sum.SIGMA=init;
sum.pmax=NaN*ones(1,1);
sum.depths=[1:max_depth_bins];  
sum.filenums=[];
sum.direction='d';

sum.lat=NaN;
sum.lon=NaN;

sum.time=NaN;

sum.castnumber=NaN;
sum.filemin=nextfile;
sum.filemax=nextfile;
sum.depthmax=1;

p=pwd;
cd(path_sum);
[sum.filename,sum.pathname]=uiputfile('*.mat',['Choose Summary File' ' Name']);
save([sum.pathname sum.filename],'sum');
cd(p);