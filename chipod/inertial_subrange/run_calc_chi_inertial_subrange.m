% run_calc_chi_inertial_subrange.m
clear all; close all; fclose all;
dpl='eq08';
unit=[120,315,312,314,204,205,304];
depth=[24.2,28,49.4,50.7,52.7,61.7,80.4];
signal={'TP','T','T','T','TP','TP','TP'};
% signal={'T','T','T','T','T','T','T'};
sensors=[1,2];% for 315 use only sensor 2
chidir='\\baltic\work\aperlin\eq08\chipod\summaries\chi_analysis\deglitched\';
dpath='\\mserver\data\eq08\data\chipod\';
outpath='\\baltic\work\aperlin\eq08\chipod\summaries\chi_analysis\inertial_subrange\';
ts=datenum(2008,10,24,7,0,0);
tf=datenum(2008,11,8,23,0,1);
salinity=35;
dt=1/24;
hpf_cutoff=0.04;
for ii=7%:length(unit)
    disp([unit(ii),signal(ii)])
    load([chidir 'mean_chi_' num2str(unit(ii))]);
    [mod,obs]=calc_chi_inertial_subrange(avgchi,ts,tf,dt,unit(ii),depth(ii),salinity,dpath,dpl,hpf_cutoff,sensors,char(signal(ii)));
    save([outpath 'inertial_' num2str(unit(ii)) '_' num2str(dt*24*60) ,'min_test',char(signal(ii))],'mod','obs')
end

