
function plot_avg_file(fnm)
%This function plots the chipod summary plot from a deployment
%To run this program, the summary files should have been generated already
%and saved in the deployment directory's quick_summary folder
%Inputs 

%       fnm = full path with file name (optional)
%Example:
%       plot_avg_file()  A window pops up and you can select the mat file
%     OR
%       plot_avg_file('\\ganges\data\chipod\Pirata22\quick_summary\10W\526_quick_summary.mat')

%Change the parameters that are commented in BOLD
%This also calls quick_ticks.m function that should be in the same path
%Pavan Vutukur 
%Ocean Mixing Group

if nargout<2
  % if no output arguments, assume that we want the globalized
  % version.  
  global avg;
end 
avg=[];
if nargin<1
    [filename,pathname]=uigetfile('*.mat','Load MAT File');
    fnm=[pathname filename]; %fnm has pathname and filename in a single
    %string text
    if filename==0
        error('File not found')
        return;
    end
end

load(fnm,'avg'); %loads the summary file with structure avg

%CHANGE START AND END DATES OF DEPLOYMENT
clf;
t.t1 = avg.time(1);
t.t2 = avg.time(end);
labl=(['Chipod # ',num2str(avg.chipod),'  Deployed: ',...
    datestr(t.t1,'dd-mmm-yy'),'   ','Recovered: ',datestr(t.t2,'dd-mmm-yy')]);
figure(1)

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.98]);

%plot Pressure data
subaxis(8,1,1,'SpacingVert',0,'ML',0.05,'MR',00.02,'MT',0.08);
%SET ATMOSPHERIC PRESSURE IN PSI
atm = 14.29;
plot(avg.time,(avg.P-atm)./1.47,'b')
%CHANGE THE LIMITS AND TICKS 
quick_ticks(t,0,40,4,36,8);%ylim1,ylim2,ytick1,ytick2,tick_div
top_ax = gca;
taX= top_ax.XAxis;
set(taX,'tickdir','in');
ylabel('P dBar');

title(['Summary Plot for ',labl]);

%Plot Accelerometer AX and AY data (tilts in degrees)
subaxis(8,1,2,'SpacingVert',0,'ML',0.05,'MR',0.02,'MB',0.08);
plot(avg.time,avg.AX,'k',avg.time,avg.AY,'r');
%CHANGE THE LIMITS AND TICKS
quick_ticks(t,-20,20,-15,15,7.5); %ylim1,ylim2,ytick1,ytick2,tick_div
legend('Ax','Ay','Location','northeast'); legend boxoff;
ylabel('A_{XY} (Tilt^\circ)');


%Plot Accelerometer AZ data tilts in degress
subaxis(8,1,3,'SpacingVert',0,'ML',0.05,'MR',0.02);
plot(avg.time,avg.AZ,'b');
%CHANGE THE LIMITS AND TICKS
quick_ticks(t,-1.03,-0.94,-1.01,-0.95,0.02);%ylim1,ylim2,ytick1,ytick2,tick_div
ylabel('A_Z (g_{force})');

%Plot Chipod T1 and T2 in Celsius
subaxis(8,1,4,'SpacingVert',0,'ML',0.05,'MR',0.02);
plot(avg.time,avg.T1,'k',avg.time,avg.T2,'r');
%CHANGE THE LIMITS AND TICKS
quick_ticks(t,5,35,10,30,10); %ylim1,ylim2,ytick1,ytick2,tick_div
if isfield(avg,'sensor_id')
    legend(strcat('T1:',{' '},convertCharsToStrings(avg.sensor_id.T1(1,:))), strcat('T2:',{' '},convertCharsToStrings(avg.sensor_id.T2(1,:))),'Location','northeast'); 
    legend boxoff;
else
    legend('T1','T2','Location','northeast'); legend boxoff;
end

ylabel('T (^\circC)');

%Plot chipod TP variance data
subaxis(8,1,5,'SpacingVert',0,'ML',0.05,'MR',0.02);
plot(avg.time,avg.T1P,'k',avg.time,avg.T2P,'r'); %Plotting in log scale
%CHANGE THE LIMITS AND TICKS
tp_idx = 1e-9; %Just change this value to update TP Limit and Ticks
quick_ticks(t,0,tp_idx,0.1*tp_idx,0.9*tp_idx,0.4*tp_idx);
%ylim1,ylim2,ytick1,ytick2,tick_div
legend('T1P','T2P','Location','northeast'); legend boxoff;
ylabel('TP \sigma^{2} (V)');

%Plot Pitot voltage 
subaxis(8,1,6,'SpacingVert',0,'ML',0.05,'MR',0.02);
plot(avg.time,avg.W,'b');
%CHANGE THE LIMITS AND TICKS
quick_ticks(t,0,4,0.5,3.5,1.5);%ylim1,ylim2,ytick1,ytick2,tick_div
ylabel('Pitot (V)')

%Plot digital and analog voltage data
subaxis(8,1,7,'SpacingVert',0,'ML',0.05,'MR',0.02);
plot(avg.time,(avg.V)./1000,'r');
hold on;
% plot(avg.time,(avg.Va+1.8),'k'); %for current limiting diode
plot(avg.time,((avg.Va./0.5537)+.418)); %for schottky diode
%CHANGE THE LIMITS AND TICKS
quick_ticks(t,4,8,4.5,7.5,1.5);%ylim1,ylim2,ytick1,ytick2,tick_div
ylabel({'Batt (V)'});
legend('Digital', 'Analog');

%plot compass data
subaxis(8,1,8,'SpacingVert',0,'ML',0.05,'MR',0.02);
plot(avg.time,avg.CMP,'k');
%DO NOT CHANGE COMPASS LIMITS AND TICKS
quick_ticks(t,0,360,90,270,90);%ylim1,ylim2,ytick1,ytick2,tick_div
datetick('x','keeplimits');
ylabel('CMP^\circ');

%This will save the figure in .png format maintaining the same file 
%name as summary file
fname=(['summary_',num2str(avg.chipod)]);
print([pathname fname], '-dpng','-r300');
end




