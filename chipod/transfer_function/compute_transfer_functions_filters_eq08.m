% function compute_transfer_functions_filters(dpath)
% compute_transfer_functions_filters(dpath)
% compute transfer functions and saves them in directory
% dpath/transfer_fcn/
% dpath - path to where directory with raw data saved, i.e.
% i.e. dpath='\\mserver\Data\yq06b\uitik\';
% first one needs to run plot_data_select_patch.m to capture the
% spectra.  These are saved into saves and their names are contained
% within filename_list.mat
%   $Revision: 1.3 $  $Date: 2009/06/12 18:38:55 $
% Originally J.Nash
clear all;
% dpath='c:\work\aperlin\chipod\tao_aug06\mfiles\transfer_fcn\';
dpath='c:\work\eq08\chipods\transfer\';
clear transfer transfer2

load([dpath '\saves\filename_list'])
% bad_files={'yq06b64_p_9','yq06b68_p_9','yq06b69_p_10',...
%     'yq06b23_p_9','yq06b16_p_10','yq06b10_p_6','yq06b14_p_9',...
%     'yq06b27_p_9','yq06b36_p_9'};
bad_files={'YQ08a33_p_7','YQ08a40_p_8','YQ08a44_p_8','YQ08a54_p_7','YQ08a60_p_7',...
    'YQ08a62_p_7','YQ08a63_p_7','YQ08a68_p_8','YQ08a70_p_7','YQ08a82_p_8','YQ08a98_p_8',...
    'YQ08a107_p_7','YQ08a125_p_8','YQ08a135_p_8','YQ08a140_p_8','YQ08a141_p_8','YQ08a161_p_7',...
    'YQ08a181_p_9','YQ08a189_p_5','YQ08a193_p_6','YQ08a245_p_8','YQ08a268_p_8','YQ08a310_p_7'};
cd c:\work\eq08\mfiles\chipod\transfer_fcn\
probnames
filenames=setdiff(filenames,bad_files);
sns=[];
if isfield(ch,'t1'); sns=[sns '1']; end
if isfield(ch,'t2'); sns=[sns '2']; end
if isfield(ch,'t3'); sns=[sns '3']; end
if isfield(ch,'t4'); sns=[sns '4']; end
for a=1:length(filenames)
    in=find(filenames{a}=='_');
    filenum(a)=str2num(filenames{a}(length(deployment)+1:in(1)-1));
end

% figure(1)
col='gbmcky';
for b=1:length(filemins)
    inds=find(filenum<=filemaxs(b) & filenum>=filemins(b));
    uktot=0;
    for i=1:length(sns)
        eval(['c' sns(i) 'tot=0;']);
    end
    ntot=0;
    aaa=0;
    newfreqs=[1 2 4 8 16:16:144];
    for a=1:length(inds)
        load([dpath '/saves/' filenames{inds(a)} '.mat'])
        hold off
%         h(1)=loglog(freq.UKTCP,power.UKTCP,col(1));
%         hold on
%         leg={'UKTCP'};
%         for i=1:length(sns)
%             h(i+1)=loglog(freq.(['CHT' sns(i) 'P']),power.(['CHT' sns(i) 'P']),col(i+1));
%             leg=[leg {['CHT' sns(i) 'P']}];
%         end
%         legend(h,leg);
%         title(filenames{inds(a)},'interpreter','none')

        if length(power.UKTCP)==512
            aaa=aaa+1;
            eval(['freqs=freq.CHT' sns(1) 'P;']);
%             uktot=uktot+power.UKTCP*length(indices.P);
            if length(freq.UKTCP)~=length(freq.CHT1P)
                power.UKTCP=interp1(freq.UKTCP,power.UKTCP,freq.CHT1P);
                freq.UKTCP=freq.CHT1P;
            end
            for i=1:length(sns)
%                 eval(['c' sns(i) 'tot=c' sns(i) 'tot+power.CHT' sns(i) 'P*length(indices.P);']);
                % correction for 140 Hz analog filters on uc-cham
                eval(['ttt=invert_filt(freqs,power.CHT' sns(i) 'P,2,140);']);
                temp.(['p' char(eval(['ch.t' sns(i) '(b)']))]){aaa}=spctm_avg(ttt./power.UKTCP,freqs,newfreqs);
                temp1.(['p' char(eval(['ch.t' sns(i) '(b)']))]){aaa}=ttt./power.UKTCP;
                tttt=temp1.(['p' char(eval(['ch.t' sns(i) '(b)']))]){aaa}*length(indices.P);
                eval(['c' sns(i) 'tot=c' sns(i) 'tot+tttt;']);
                temp2.(['p' char(eval(['ch.t' sns(i) '(b)']))]){aaa}=filenames{inds(a)};
            end
            ntot=ntot+length(indices.P);
        end
    end

%     uk=uktot(1:length(c1tot))/ntot;
    for i=1:length(sns)
        eval(['c' sns(i) '=c' sns(i) 'tot/ntot;']);
        eval(['t' sns(i) '=spctm_avg(c' sns(i) ',freqs,newfreqs);']);
        transfer.(['p' char(eval(['ch.t' sns(i) '(b)']))])=eval(['c' sns(i)]);
        transfer2.(['p' char(eval(['ch.t' sns(i) '(b)']))])=eval(['t' sns(i)]);
    end
end

transfer.f=freqs;
transfer2.f=newfreqs;


% figure(8)
% clf
cols='rgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmck';
cls='rgbmcyk';
fn=fieldnames(transfer);
for a=1:length(fn)-1
    if ~strncmpi(fn{a},'p9999',5) && ~strcmpi(fn{a},'p0603P') && ~strcmpi(fn{a},'p0806') ...
            && ~strcmpi(fn{a},'p0820')% 9999 is marker for no-sensor, 0603P, 0806, 0820 are bad
        clear h
        figure(8),clf
        leginp='';
        for kk=1:length(temp.(fn{a}))
            if kk<=length(cls)
                h(kk)=loglog(transfer2.f,cell2mat(temp.(fn{a})(kk)),cls(kk));
            elseif kk<=2*length(cls)
                h(kk)=loglog(transfer2.f,cell2mat(temp.(fn{a})(kk)),[cls(kk-length(cls)) '--']);
            elseif kk<=3*length(cls)
                h(kk)=loglog(transfer2.f,cell2mat(temp.(fn{a})(kk)),[cls(kk-2*length(cls)) ':']);
            elseif kk<=4*length(cls)
                h(kk)=loglog(transfer2.f,cell2mat(temp.(fn{a})(kk)),[cls(kk-3*length(cls)) '.-']);
            elseif kk<=5*length(cls)
                h(kk)=loglog(transfer2.f,cell2mat(temp.(fn{a})(kk)),[cls(kk-4*length(cls)) '.--']);
            else
                h(kk)=loglog(transfer2.f,cell2mat(temp.(fn{a})(kk)),[cls(kk-5*length(cls)) '.:']);
            end
            hold on
        end
        h(kk+1)=loglog(transfer2.f,transfer2.(fn{a}),'k','linewidth',2);
        %     loglog(transfer.f,1./(1+(transfer.f/f_c).^2),'k--')
        ylabel('power attenuation H^2(f)=\Psi_{tp}/\Psi_{tcp}')
        xlabel('frequency [Hz]')
        fre=transfer2.f';
        trans=transfer2.(fn{a});cols(a);
        beta=nlinfit(fre,trans,@my_filter,[1 10]);beta=real(beta);
        filter_out=my_filter(beta,fre);
        h(kk+2)=loglog(fre,filter_out,'k--','linewidth',2);
        transfer.filter_ord.(fn{a})=beta(1);
        transfer.filter_freq.(fn{a})=beta(2);
        axis([1 300 .01 4])
        text(0.85,0.95,['n=' num2str(beta(1))],'units','normalized')
        text(0.85,0.87,['f_c=' num2str(beta(2))],'units','normalized')
        %     legend(h(a),fn(a),'location','southwest')
        ll=legend(h,[temp2.(fn{a}),{[char(fn(a)) ' smoothed mean spectra'],[char(fn(a)) ' empirical transfer function']}],'location','southwest');
        set(ll,'Interpreter','none','box','off')
        title(['Smoothed transfer spectra ' fn{a}])
        print('-dpng','-r100',[dpath 'figs\transfer_functions_smoothed_' fn{a}])
    else
        transfer.filter_ord.(fn{a})=NaN;
        transfer.filter_freq.(fn{a})=NaN;
    end
end
% figure(7)
% clf
cols='rgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmckrgbmck';
% f_c=20;
fn=fieldnames(transfer);
% for a=1:length(fn)-1
%     figure(7),clf
% %     h(a)=loglog(transfer.f,transfer.(fn{a}),cols(a));
%     loglog(transfer.f,transfer.(fn{a}),cols(a));
%     hold on
% %     loglog(transfer.f,1./(1+(transfer.f/f_c).^2),'k--')
%     ylabel('power attenuation H^2(f)=\Psi_{tp}/\Psi_{tcp}')
%     xlabel('frequency [Hz]')
%     axis([1 300 .01 2])
% %     legend(h(a),fn(a),'location','southwest')
% 
%     legend([char(fn(a)) ' raw spectra'],'location','southwest')
%     title(['Raw transfer spectra ' fn{a}])
%     print('-dpng','-r100',[dpath 'figs\transfer_functions_raw_' fn{a}])
% end
transfer.smoothed_spec=transfer2;
transfer.readme=strvcat('smoothed_spec is the smoothed version of raw transfer spectra',...
    '0603P is bad!','0820 is bad','0806 is bad');
mkdir([dpath '/transfer_fcn/']);
save([dpath '/transfer_fcn/transfer_functions'],'transfer')
