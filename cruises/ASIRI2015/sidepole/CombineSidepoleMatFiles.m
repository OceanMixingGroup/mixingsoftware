%~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% CombineSidepoleMatFiles.m
%
% Combine separate processed sidepole ADCP files into one mat file.
%
% 
% 09/02/15 - A.Pickering - apickering@coast.oregonstate.edu
% 09/05/15 - AP - Starting with 3rd file, ADCP set up with more depth bins
%~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%  

clear ; close all

%data_dir='/Volumes/scienceparty_share/data/'
data_dir='/Volumes/scienceparty_share/sidepole/mat/'

fnames={'sentinel_1min_File1.mat','sentinel_1min_File2.mat','sentinel_1min_File3.mat',...
    'sentinel_1min_File4.mat','sentinel_1min_File5.mat','sentinel_1min_File6.mat'...
    ,'sentinel_1min_File7.mat','sentinel_1min_File8.mat'}

% make an empty structure for the total combined data
Vtot=struct()
Vtot.u=[];
Vtot.v=[];
Vtot.dnum=[];
Vtot.z=[];
Vtot.lat=[];
Vtot.lon=[];

for whfile=1:length(fnames)

    load(fullfile(data_dir,fnames{whfile}))
    Vtot.dnum=[Vtot.dnum V.dnum];
    Vtot.lat=[Vtot.lat V.lat];
    Vtot.lon=[Vtot.lon V.lon];
    if whfile<3
    Vtot.u=[Vtot.u [V.u ; nan*ones(11,length(V.dnum)) ]  ];
    Vtot.v=[Vtot.v [V.v ; nan*ones(11,length(V.dnum)) ]  ];
    else
    Vtot.u=[Vtot.u V.u];
    Vtot.v=[Vtot.v V.v];
    end
%     Vtot.lat=[Vtot.lat V.lat];
%     Vtot.lon=[Vtot.lon V.lon ];

    
end
    Vtot.z=V.z;
    
% edit out some bad data times
idb=isin(Vtot.dnum,[datenum(2015,8,28,4,30,0) datenum(2015,8,28,6,36,0)]);
Vtot.u(:,idb)=nan;
Vtot.v(:,idb)=nan;

clear V
V=Vtot;
save('/Volumes/scienceparty_share/data/sentinel_1min.mat','V')

%% plot the combined file

figure(1);clf

subplot(211)
ezpc(Vtot.dnum,Vtot.z,Vtot.u)
caxis([-1 1])
colorbar
colormap(bluered)
datetick('x')
SubplotLetterMW('u')

subplot(212)
ezpc(Vtot.dnum,Vtot.z,Vtot.v)
caxis([-1 1])
colorbar
colormap(bluered)
datetick('x')
SubplotLetterMW('v')

%%
