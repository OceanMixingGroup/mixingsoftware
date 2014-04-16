% plot marliin/ seabird data

ps=input('enter start profile -->  ');
pf=input('enter end profile -->  ');

iprof=[ps:pf];

id_m=[];
id_s=[];
for ip=iprof
   id_m=[id_m find(floor(marlin.ptime)==ip)];
   id_s=[id_s find(floor(sbd.ptime)==ip)];
end

id_mrln=find(marlin.ptime>ps & marlin.ptime<pf);
id_sbd=find(sbd.ptime>ps & sbd.ptime<pf);

length(id_m)
length(id_s)

figure(7)
plot(marlin.ptime(id_m),1.82*(marlin.t2(id_m)-mean(marlin.t2(isnan(marlin.t2)==0))), ...
   sbd.ptime(id_s),sbd.temp(id_s)-mean(sbd.temp),'r');grid

%axis([ps pf -1 3])
