function avg=ComputeChi_for_CTDprofile(avg,nfft,fspd,TP,good_inds,todo_inds)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% ComputeChi_for_CTDprofile.m
%
% Do calculation of chi for a ctd profile. Uses a sliding window (size
% controlled by nfft). Prepare_Avg_for_ChiCalc.m should be called before
% this function.
%
% See also Prepare_Avg_for_ChiCalc.m
%
% INPUT
% avg       : Structure made w Prepare_Avg_for_ChiCalc.m
% nfft      : # points to use in fft
% fspd      : Speed of flow past chipod 
% TP        : Temperature derivative signal from chipod (T prime)
% nfft      : # points to use in overlapping windows
% good_inds : Indices of good data (excludes depth loops in CTD)
% todo_inds : Indices to do computation on (see Prepare_Avg_for_ChiCalc).
%
% Copied from part of process_chipod_script_AP.m
%
% May 5, 2015 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

h = waitbar(0,['Computing chi ']);
for n=1:length(todo_inds)
    clear inds
    inds=todo_inds(n)-1+[1:nfft];
    
    %    if all(chidat.cal.is_good_data(inds)==1)
    %if all(chidata.is_good_data(inds)==1)
        if all(good_inds(inds)==1)
        %avg.fspd(n)=mean(chidat.cal.fspd(inds));
%        avg.fspd(n)=mean(chidata.fspd(inds)); % AP
        avg.fspd(n)=mean(fspd(inds)); % AP
        
        %         [tp_power,freq]=fast_psd(chidat.cal.T1P(inds),nfft,avg.samplerate);
        %         avg.TP1var(n)=sum(tp_power)*nanmean(diff(freq));
        
%        [tp_power,freq]=fast_psd(chidata.T1P(inds),nfft,avg.samplerate);
 %       avg.TP1var(n)=sum(tp_power)*nanmean(diff(freq));
        
                [tp_power,freq]=fast_psd(TP(inds),nfft,avg.samplerate);
        avg.TP1var(n)=sum(tp_power)*nanmean(diff(freq));
        
        if avg.TP1var(n)>1e-4
            
            % not sure what this is for...
            fixit=0;
            if fixit
                trans_fcn=0;
                trans_fcn1=0;
                thermistor_filter_order=2;
                thermistor_cutoff_frequency=32;
                analog_filter_order=4;
                analog_filter_freq=50;
                tp_power=invert_filt(freq,invert_filt(freq,tp_power,thermistor_filter_order, ...
                    thermistor_cutoff_frequency),analog_filter_order,analog_filter_freq);
            end
            
            [chi1,epsil1,k,spec,kk,speck,stats]=get_chipod_chi(freq,tp_power,abs(avg.fspd(n)),avg.nu(n),...
                avg.tdif(n),avg.dTdz(n),'nsqr',avg.N2(n));
            
            avg.chi1(n)=chi1(1);
            avg.eps1(n)=epsil1(1);
            avg.KT1(n)=0.5*chi1(1)/avg.dTdz(n)^2;
            
        else
            %disp('fail2')
        end
    else
        % disp('fail1')
    end
    
    if ~mod(n,10)
        waitbar(n/length(todo_inds),h);
    end
    
end
delete(h)

return
%%