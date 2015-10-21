%~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% PlotRawADCPData.m
%
% Plot raw ADCP data for ASIRI 2015 sidepole (beam correlation,amp,etc)
%
% Moved this code from process_pole_Aug2015_ASIRI_v4.m
%
%----------------
% 10/21/15 - A.Pickering - 
%~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
% option to make some plots of raw data
makeplots=0
if makeplots==1
    
    % plot beam velocities
    
    close all
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    
    subplot(411)
    ezpc(A.dnum,A.z,squeeze(A.vel(1,:,:))/1e3)
    caxis(2*[-1 1])
    colorbar
    datetick('x')
    SubplotLetterMW('bm1')
    
    subplot(412)
    ezpc(A.dnum,A.z,squeeze(A.vel(2,:,:))/1e3)
    caxis(2*[-1 1])
    colorbar
    datetick('x')
    SubplotLetterMW('bm2');
    
    subplot(413)
    ezpc(A.dnum,A.z,squeeze(A.vel(3,:,:))/1e3)
    caxis(2*[-1 1])
    colorbar
    datetick('x')
    SubplotLetterMW('bm3');
    
    subplot(414)
    ezpc(A.dnum,A.z,squeeze(A.vel(4,:,:))/1e3)
    caxis(2*[-1 1])
    colorbar
    datetick('x')
    SubplotLetterMW('bm4');
    
    
    %
    % plot beam intensities
    
    close all
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    
    subplot(411)
    ezpc(A.dnum,A.z,squeeze(A.int(1,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm1');
    title('beam intensity')
    
    subplot(412)
    ezpc(A.dnum,A.z,squeeze(A.int(2,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm2');
    
    subplot(413)
    ezpc(A.dnum,A.z,squeeze(A.int(3,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm3');
    
    subplot(414)
    ezpc(A.dnum,A.z,squeeze(A.int(4,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm4');
    
    
    % plot beam correlations
    
    close all
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    
    subplot(411)
    ezpc(A.dnum,A.z,squeeze(A.cor(1,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm1');
    title('beam correlations')
    
    subplot(412)
    ezpc(A.dnum,A.z,squeeze(A.cor(2,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm2');
    
    subplot(413)
    ezpc(A.dnum,A.z,squeeze(A.cor(3,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm3')
    
    subplot(414)
    ezpc(A.dnum,A.z,squeeze(A.cor(4,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm4');
    
    % *** pgood is all zeros?
    
    % %% plotpgood
    
    close all
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    
    subplot(411)
    ezpc(A.dnum,A.z,squeeze(A.pgood(1,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm1');
    title('beam % good')
    
    subplot(412)
    ezpc(A.dnum,A.z,squeeze(A.pgood(2,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm2');
    
    subplot(413)
    ezpc(A.dnum,A.z,squeeze(A.pgood(3,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm3');
    
    subplot(414)
    ezpc(A.dnum,A.z,squeeze(A.pgood(4,:,:)))
    colorbar
    datetick('x')
    SubplotLetterMW('bm4');
    
end % makeplots

%%