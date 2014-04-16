% function [sontek]= get_speed(ip)
%	reads speed_tow* 
%  extracts filtered speed from .5 before to .5 after file ip
%	the reason is to do a smooth interp
%	ip - profile number
%	speedf is the filtered speed
%	pt is ptime_adp - units of decimal profile #

function [sontek] = get_speedf(ip,it)

   str_ip=num2str(10000+ip);
   str_it=num2str(100+it);

	fnam=['d:\analysis\m99b\adp\mat_files\speed_tow',str_it(2:3)];
   eval(['load ' fnam])   
   id=find(ptime_adp >= ip-.5 & ptime_adp < ip+1.5);
   
   sontek.speed=speedf(id);
	sontek.ptime=ptime_adp(id);