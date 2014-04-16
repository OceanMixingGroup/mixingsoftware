% initialize_summary_file.m

set_chameleon;
q.script.prefix=cruise_id;
q.script.pathname=path_raw;
path_save='mat\';

nextfile=input('Enter number of profile to start --> ');
save nextfile nextfile;
max_depth_bins=input('Enter maximum number of depth bins --> ');
n_dep=max_depth_bins;
init=NaN*ones(n_dep,1);
clear cham;
cham.EPSILON1=init;
cham.EPSILON2=init;
cham.CHI=init;
%  cham.TKE=init;
cham.AZ2=init;
cham.EPSILON=init;
cham.SCAT=init;
cham.S=init;
cham.THETA=init;
cham.T=init;
cham.T2=init;
cham.C=init;
cham.FALLSPD=init;
cham.P=init;
cham.N2=init;
cham.SIGMA=init;
cham.pmax=NaN*ones(1,1);
cham.depth=[1:max_depth_bins];  
cham.filenums=[];
cham.direction='d';

cham.lat=NaN;
cham.lon=NaN;

cham.time=NaN;

cham.castnumber=NaN;
cham.filemin=nextfile;
cham.filemax=nextfile;
cham.depthmax=1;

p=pwd;
mkdir([path_cham 'mat\'])
path_sum=[path_cham '\sum\'];
mkdir(path_sum);
cd(path_sum);
[cham.filename,cham.pathname]=uiputfile('*.mat',['Choose Summary File' ' Name']);
save([cham.pathname cham.filename],'cham');
cd(p);
save nextfile nextfile;
