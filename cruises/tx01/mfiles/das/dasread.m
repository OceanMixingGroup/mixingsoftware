function das=dasread(fname);
  
result=dlmread(fname,',',1,0);

nfields = size(result,2);
str=[];
for i=1:nfields
  str = [str ',%s'];
end;
str=str(2:end);

fin = fopen(fname);

junk=fscanf(fin,'%s,',1);
for i=1:nfields-1
 newpos = min(find(junk==','));
 record{i}=junk(1:newpos-1);
 junk=junk(newpos+1:end);
end;
record{i+1}=junk(newpos:end);


fclose(fin);
tdas=[];
for i=1:length(record)
  tdas=setfield(tdas,record{i},result(:,i)');
end;

das.record_number = tdas.record_number;
das.datenum = datenum(2001,1,1,0,0,0)-1+tdas.truetime_day+...
    tdas.truetime_hour/24+tdas.truetime_minute/(60*24);

das.lon = tdas.pcode_long_deg+sign(tdas.pcode_long_deg).*...
	  tdas.pcode_long_min/60;
das.lat = tdas.pcode_lat_deg+tdas.pcode_lat_min/60;

das.echohf = tdas.echosounder_hf_value;
das.echolf = tdas.echosounder_lf_value;
das.barom = tdas.barometer;

das.ft_temp = tdas.water_temp_seabird_flothru;
das.ft_cond = tdas.conductivity_seabird_flothru;
das.ft_sal = tdas.computed_salinity_flothru;




