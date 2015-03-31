%% Load an individual file and plot

clear avg
up_down_big

for a=102%1:length(CTD_list)
    
    cast_suffix_tmp=CTD_list(a).name;
    cast_suffix=cast_suffix_tmp(end-8:end-6);
    processed_file=[chi_processed_path 'chi_' short_labs{up_down_big} '/avg/avg_' ...
        cast_suffix '_' short_labs{up_down_big} '.mat']
    
    if exist(processed_file) %& ~ismember(a,badinds{up_down_big})
        disp('file found')
        load(processed_file)
        
        
        % Now plot up the results
        
        figure(6);clf
        
        subplot(131)
        plot(log10(avg.chi1),avg.P),axis ij
        xlabel('log10(avg chi)')
        grid on
        
        subplot(132)
        plot(log10(avg.KT1),avg.P),axis ij
        xlabel('log10(avg Kt1)')
        grid on
        
        subplot(133)
        plot(log10(abs(avg.dTdz)),avg.P),axis ij
        xlabel('log10(avg dTdz)')
        grid on
        
        pause(0.5)
        
    end
    
end

end
%%
%chi_processed_path='../data/ttide/processed/';


clear big tmp

tfields={'chi1','eps1','chi2','eps2','KT1','KT2','datenum','P','N2','dTdz','fspd','T','S','P','theta','sigma',...
    'TP1var','TP2var'}
del_p=20;
p_vec=[del_p/2:del_p:7000];
n_profiles=150
for n=1:length(tfields)
    tmp.(tfields{n})=NaN*ones(length(p_vec),n_profiles);
end
tmp.lat=NaN*ones(1,n_profiles);
tmp.lon=NaN*ones(1,n_profiles);


big(1)=tmp;
big(2)=tmp;
%badinds={[21 93],[52 84:n_profiles]}
%badinds=[]
try delete(h), catch, end
h=waitbar(0,'waiting')
a
for up_down_big=1%:2
    for a=7:154
        
        % 		cast_suffix=num2str(1000+a); cast_suffix=cast_suffix(2:4);
        cast_suffix_tmp=CTD_list(a).name;
        cast_suffix=cast_suffix_tmp(end-8:end-6);
        processed_file=[chi_processed_path 'chi_' short_labs{up_down_big} '/avg/avg_' ...
            cast_suffix '_' short_labs{up_down_big} '.mat'];
        if exist(processed_file) %& ~ismember(a,badinds{up_down_big})
            disp('file found')
            load(processed_file)
            avg.chi1(isnan(avg.chi1))=0;
            avg.chi2(isnan(avg.chi2))=0;
            avg.eps1(isnan(avg.eps1))=0;
            avg.eps2(isnan(avg.eps2))=0;
            avg.KT1(isnan(avg.KT1))=0;
            avg.KT2(isnan(avg.KT2))=0;
            big(up_down_big).lat(a)=nanmean(ctd.lat);
            big(up_down_big).lon(a)=nanmean(ctd.lon);
            bad_KT=find((avg.dTdz./avg.N2)<300 | (avg.dTdz<1e-4));
            %			bad_chi=[]
            for c=5:6 %1:length(tfields)
                avg.(tfields{c})(bad_KT)=NaN;
            end
            
            for b=1:length(p_vec)
                tinds=find(avg.P>(p_vec(b)-del_p) & avg.P<(p_vec(b)+del_p));
                for c=1:length(tfields)
                    big(up_down_big).(tfields{c})(b,a)=nanmean(avg.(tfields{c})(tinds));
                end
            end
        else
            
        end
        waitbar(a/104,h);
    end
    
    big(up_down_big).lat=interp_missing_data(big(up_down_big).lat);
    big(up_down_big).lon=interp_missing_data(big(up_down_big).lon);
end

delete(h)
% pcolor(big(2).eps1),shading flat
%%
%if 1
clf
ranges=[34:38],cols='rbgmk';
ranges=[1:5]
for a=1%:4
    ix=ranges(a);
    figure
    subplot(121)
    plot((big(2).datenum(:,ix)-big(2).datenum(1,ix))*24,big(2).P(:,ix),cols(a))
    hold on
    subplot(122)
    plot((big(2).datenum(:,ix)-big(2).datenum(1,ix))*24,big(2).fspd(:,ix),cols(a))
    hold on
end
%end

%%
load ../bathymetry/cast_info.mat
d=2600;
good_inds=[1:86 88:94];

thechi=min(big(1).chi1,big(2).chi1);
thekt=(min(big(1).KT1,big(2).KT1)+max(big(1).KT1,big(2).KT1))/2;
theeps=max(big(1).eps1,big(2).eps1);
theT=min(big(1).T,big(2).T);
theS=min(big(1).S,big(2).S);
thep=max(big(1).P,big(2).P);
thelat=max(big(1).lat,big(2).lat);
tmp2=conv2(thechi,ones(3,1)/3,'same');
tmp3=conv2(thekt,ones(3,1)/3,'same');
tmp4=conv2(theeps,ones(3,1)/3,'same');
figure(111)
clf
subplot(311)
%pcolor(thelat(good_inds),thep(:,good_inds),theT(:,good_inds)),axis ij,caxis([0 10]),shading flat
pcolor(thelat(good_inds),thep(:,good_inds),theS(:,good_inds)),axis ij,caxis([34.2 35.5]),shading flat
hold on,
hh=area(cast.newlat(2:end),-cast.new_H(2:end),6020), set(hh,'facecolor',.75*[1 1 1],'linewidth',2)
ylim([0 d])
fix_fig2,jtext('Salinity',.01,1.07,'fontsize',14),my_colorbar([],[],'S [psu] ')
subplot(312)
pcolor(thelat(good_inds),thep(:,good_inds),log10(tmp2(:,good_inds))),axis ij,caxis([-11.5 -7]),shading flat
hold on,
hh=area(cast.newlat(2:end),-cast.new_H(2:end),6020), set(hh,'facecolor',.75*[1 1 1],'linewidth',2)
ylim([0 d])
fix_fig2,jtext('Thermal Dissipation Rate',.01,1.07,'fontsize',14),my_colorbar([],[],'log_{10} \chi [K^2/s] ')
xl=xlim;
subplot(313)
pcolor(thelat(good_inds),thep(:,good_inds),log10(tmp3(:,good_inds))),axis ij,caxis([-5 -2.5]),shading flat
hold on,
hh=area(cast.newlat(2:end),-cast.new_H(2:end),6020), set(hh,'facecolor',.75*[1 1 1],'linewidth',2)
ylim([0 d])
fix_fig2,jtext('Observed Turbulent Diffusivity ',.01,1.07,'fontsize',14),my_colorbar([],[],'log_{10} K_T [m^2/s] ')
set(gca,'xticklabelmode','auto')
%pcolor(thelat(good_inds),thep(:,good_inds),log10(tmp4(:,good_inds))),axis ij,caxis([-11 -8]),shading flat
set(gcf,'renderer','zbuffer')
xlabel('latitude'),ylabel('depth [m]')
% dual_print_pdf2('final_plot','same')

print('-dpng',[fig_path  'chi_' short_labs{up_down_big} '/cast_' cast_suffix 'chi'])




%%
figure
inds=find(~isnan(big(1).lat));
pcolor(log10(big(1).chi1(:,inds))),shading flat
caxis([-9 -7])
%%
if 0
    figure(103)
    subplot(211)
    pcolor(big(1).lat,big(1).P,log10(big(1).chi1)),axis ij,caxis([-11 -7]),shading flat
    subplot(212)
    pcolor(big(1).lat,big(2).P,log10(big(2).chi1)),axis ij,caxis([-11 -7]),shading flat
    
    %%
    figure(104)
    subplot(211)
    pcolor(big(1).lat,big(1).P,log10(big(1).KT1)),axis ij,caxis([-5 -2]),shading flat
    subplot(212)
    pcolor(big(1).lat,big(2).P,log10(big(2).KT1)),axis ij,caxis([-5 -2]),shading flat
    
    
    figure(105)
    subplot(211)
    pcolor(big(1).lat,big(1).P,log10(big(1).eps1)),axis ij,caxis([-10 -7]),shading flat
    subplot(212)
    pcolor(big(1).lat,big(2).P,log10(big(2).eps1)),axis ij,caxis([-10 -7]),shading flat
    
    
    chi_tmp=min(big(1).chi1,big(2).chi1);
    eps_tmp=min(big(1).eps1,big(2).eps1);
    KT_tmp=min(big(1).KT1,big(2).KT1);
    
    
end



