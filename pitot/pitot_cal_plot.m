clear all
close all

unitnum = input('Enter the Pitot Tube unit number: ','s')

cd('\\ganges\data\ASIRI14\SOLO Chipod\calibrations\pitot tube\')
[file path] = uigetfile('*.txt','Select Dynamic Port Cal data file');
[dyn.Pa, dyn.V, dyn.diff] = textread([path file],'%f %f %f');

[file path] = uigetfile('*.txt','Select Pitch Cal data file');
[pitch.deg, pitch.V] = textread([path file],'%f %f');

cd('\\ganges\data\ASIRI14\SOLO Chipod\calibrations\pitot tube\')
[file path] = uigetfile('*.mat','Select Pressure Cal data file');
cd(path)
load(file)
Pcal = ptest;
clear ptest

cd('\\ganges\data\ASIRI14\SOLO Chipod\calibrations\pitot tube\')
[file path] = uigetfile('*.mat','Select Temp Cal data file');
cd(path)
load(file)
Tcal = ptest;
clear ptest

%%
close all

% fit for Dynamic Port Cal
dyn.fit = polyfit(dyn.V,dyn.Pa,1);
dyn.fitV = [min(dyn.V),max(dyn.V)];
dyn.fitP = polyval(dyn.fit,dyn.fitV);

% fit for Pitch Cal (+/-30deg)
pup=find(pitch.deg == 30);
pdwn=find(pitch.deg == -30);
pitch.fit = polyfit(pitch.deg(pup:pdwn),pitch.V(pup:pdwn),1);
pitch.fitV = polyval(pitch.fit,pitch.deg(pup:pdwn));

% calculate averaged points for temp cal curve
numpts=50; % number of points to average
t=[Tcal.tstart:-1:Tcal.tend+1];
for i = 1:Tcal.tstart-Tcal.tend
    count = find(Tcal.temp<t(i),1);
    Tcal.vpoints(i) = mean(Tcal.pitot(count-numpts:count+numpts));
    Tcal.tpoints(i) = mean(Tcal.temp(count-numpts:count+numpts));
end

% fit for Common Mode Temp Cal
Tcal.fit = polyfit(Tcal.tpoints,Tcal.vpoints,1);
Tcal.fitV = polyval(Tcal.fit,Tcal.tpoints);

% calculate averaged points for pressure cal curve
p=[300:-10:10];
for i = 1:length(p)
    count = find(Pcal.press(numpts+1:length(Pcal.press))<p(i),1)+numpts;
    Pcal.vpoints(i) = mean(Pcal.pitot(count-numpts:count+numpts));
    Pcal.ppoints(i) = mean(Pcal.press(count-numpts:count+numpts));
    Pcal.tpoints(i) = mean(Pcal.temp(count-numpts:count+numpts));
end

% fit for Common Mode Pressure Cal
Pcal.fit = polyfit(Pcal.ppoints,Pcal.vpoints,1);
Pcal.fitV = polyval(Pcal.fit,Pcal.ppoints);

%% figures

figure
subplot(2,2,1)
hold on
plot(dyn.V,dyn.Pa,'o')
plot(dyn.fitV,dyn.fitP,'k')
xlabel('Pitot Output (V)')
ylabel('Pressure (Pa)')
title(['Dynamic Port',10, num2str(dyn.fit(1)) '(Pa/V) \cdot V + ' num2str(dyn.fit(2))])
ylim([-1000 4000])

subplot(2,2,2)
hold on
plot(pitch.deg,pitch.V,'o')
plot(pitch.deg(pup:pdwn),pitch.fitV,'k')
ylabel('Pitot Output (V)')
xlabel('Pitch (deg)')
title(['Common Mode Pitch',10, num2str(pitch.fit(1)) '(V/deg) \cdot deg + ' num2str(pitch.fit(2))])
xlim([-90 90])

subplot(2,2,3)
hold on
plot(Tcal.tpoints,Tcal.vpoints,'o')
plot(Tcal.tpoints,Tcal.fitV,'k')
ylabel('Pitot Output (V)')
xlabel('Temperature (C)')
title(['Common Mode Temperature',10, num2str(Tcal.fit(1)) '(V/^oC) \cdot T + ' num2str(Tcal.fit(2))])
xlim([5 35])

subplot(2,2,4)
hold on
plot(Pcal.ppoints,Pcal.vpoints,'o')
plot(Pcal.ppoints,Pcal.fitV,'k')
ylabel('Pitot Output (V)')
xlabel('Pressure (psi)')
title(['Common Mode Pressure',10, num2str(Pcal.fit(1)) '(V/psi) \cdot P + ' num2str(Pcal.fit(2))])
xlim([0 300])

ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
text(0.5, 1,['\bf Pitot Tube ' unitnum ' , plot created ' datestr(datenum(clock))],'HorizontalAlignment','center','VerticalAlignment', 'top')

cd('\\ganges\data\ASIRI14\SOLO Chipod\calibrations\pitot tube\')
print(gcf,'-dpng','-r200',[unitnum '_' datestr(datenum(clock),'ddmmmyyyy_HHMM')]);