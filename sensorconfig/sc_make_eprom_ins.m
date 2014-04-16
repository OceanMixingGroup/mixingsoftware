function inst=sc_make_eprom_ins(filespec);
% function make_eprom_ins(fname);
% Translate a special xls file into an ins and a eprom file.
%
% The worksheet must follow the following rules:
%
% Workbook layout: There needs to be a "Sheet2" and a "Sheet4".
%
% Sheet2: There are 4 string/value pairs.  The string is in the first
%   column.  The value in the next non empty cell on the same row after the
%   string.  The pairs are:  "Instrument name", string; "Baudrate",
%   number; "Sample Rate", number (Hz); Number Sensors, number.
%
%  Somewhere else in the spreadsheet there are columns with the following
%  seven headings:
%    "Ch.", "Hex", "Signal", "Modulas", "Filter", "Circuit", "Offset"
%  under these headings there is a column of data.   The program will
%  look down the column of data until the first blank under "Ch." is
%  found.
%
% Sheet4: There are six necvessary headings:
%   "Module Number", "Sensor ID", "Coef 0", "Coef 1", "Coef 2", "Coef 3"
% As below each si a column of values.   They will stop being read when
% the first blank is found in the "Module Number" column.

% $Author: aperlin $ $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:52 $ 
% Originally, J. Klymak

% most of the functions are included below the main one.  The largest
% exception is sc_readexcel.m...
    
  sheet2name = 'Sheet2';
  sheet4name = 'Sheet4';
  
  if nargin<1 | isempty(filespec);
    [fname, fpath] = uigetfile('*.xls');
    if fpath == 0; return; end
    filespec = fullfile(fpath,fname);
  else
    [fpath,fname,fext] = fileparts(filespec);
    if isempty(fpath); fpath = pwd; end
    if isempty(fext); fext = '.ppt'; end
    filespec = fullfile(fpath,[fname,fext]);
  end

  [pathname,fnameroot,e]=fileparts(filespec);
  %
  B=sc_readexcel(filespec,sheet2name);

  % the first few lines are instrument stuff...
  % get the instrument name:
  iname = findkeystr('Instrum',B);
  inst.inst_name(1:16)=0;
  inst.inst_name(1:length(iname)) = iname;
 
  % get the Baud  
  inst.baudrate = findkeynum('Baud',B);
  inst.samplerate = findkeynum('Sample',B);
  inst.num_sensors = findkeynum('Number Sen',B);

  % find row and column of "Ch."....
  [i,j] = getrowcolumn('Ch.',B);

  Ch = cell2mat(B(i+1:end,j)); 
  % find the number of channels. Look until the first empty cell.
  in = find(isnan(Ch));
  if ~isempty(in)
    Ch = Ch(1:(in(1)-1));
  end;
  %
  Nchans = length(Ch);   
  fprintf(1,'Looking for %d channels on sheet %s\n',Nchans,sheet2name)
  
  % column two is hexidecimal.   
  [i,j] = getrowcolumn('Hex',B);  
  Hex = B((1:Nchans)+i,j);
  for i=1:length(Hex)
    Hexnum(i) = hex2dec(num2str(Hex{i}));
  end;
  
  % Column 3 is the Signal name
  ind = 1:Nchans;
  [i,j] = getrowcolumn('Signal',B);
  Signal = getallstr(B(ind+i,j));
  % getallstr will return cells of strings
  [i,j] = getrowcolumn('Modulas',B);
  Modulas = getallnum(B(ind+i,j));
  % get allnum will return a matrix of numbers. NaN for empty cells.
  [i,j] = getrowcolumn('Filter',B);
  Filter = getallnum(B(ind+i,j));
  [i,j] = getrowcolumn('Circuit',B);
  Circuit = getallstr(B(ind+i,j));
  [i,j] = getrowcolumn('Offset',B);
  Offset = getallnum(B(ind+i,j));
  
  % print out what we have found...
  for i=[1:5 Nchans-5:Nchans]
    fprintf(1,'%4d %2x %7s %03d %010f %7s %d\n',Ch(i),...
            Hexnum(i),['"' Signal{i} '"'],Modulas(i),Filter(i),['"' Circuit{i} '"'],Offset(i))
  end;

  % check that the modulas/offset pairs for each channel make sense....
  good=checkoffsets(Signal,Offset,Modulas,inst.num_sensors,...
                    sprintf('%s/%s',pathname,fnameroot));
  
  % If not good, suggest alternative offsets....
  if ~good
    GoodOffset=getoffsets(Signal,Modulas);
    bad = find(GoodOffset<0);GoodOffset(bad)=NaN;
    writeoffsets(Signal,GoodOffset,Modulas,inst.num_sensors,...
                 sprintf('%s/%s',pathname,fnameroot));
    error('Bad offsets were found in spreadsheet');
  end;
  
  % write the eprom
  epromname = sprintf('%s/%s.epr',pathname,fnameroot);
  write_eprom(Hexnum,Modulas,Offset,epromname,Signal);

  % read the Circuit info from sheet 4...
  B=sc_readexcel(filespec,sheet4name);
  [i,j] = getrowcolumn('Module Number',B);
  Modulename = getallstr(B((i+1):end,1));
  % find the first empty cell under "Module Number"
  for i=1:length(Modulename)
    if isempty(Modulename{i})
      break;
    end;
  end;
  Nmods = i-1;
  Modulname=Modulename(1:Nmods);
  fprintf(1,'Looking for %d Module/Sensor pairs on %s\n',Nmods,sheet4name);

  % get the module information....
  ind = 1:Nmods;
  [i,j] = getrowcolumn('Sensor ID',B);  
  SensorID = getallstr(B(i+ind,j));
  [i,j] = getrowcolumn('Coef 0',B);      
  Coef(:,1) = getallnum(B(i+ind,j));
  [i,j] = getrowcolumn('Coef 1',B);      
  Coef(:,2) = getallnum(B(i+ind,j));
  [i,j] = getrowcolumn('Coef 2',B);      
  Coef(:,3) = getallnum(B(i+ind,j));
  [i,j] = getrowcolumn('Coef 3',B);      
  Coef(:,4) = getallnum(B(i+ind,j));
  for i=[1:5 Nmods-5:Nmods]
    fprintf(1,'%4d: %7s %7s %10f %10f %10f %10f\n',i,Modulename{i},SensorID{i},Coef(i,:))
  end;
  
  % make the sensor information....
  % make blank sensor structure....
  blanksensor.sensor_name=zeros(1,8);
  blanksensor.module_num=zeros(1,10);
  blanksensor.filter_freq=0;
  blanksensor.das_channel_num=0;
  blanksensor.offset=0;
  blanksensor.modulas=0;
  blanksensor.num_probes=0;
  for j=1:9
    blanksensor.probes{j}.sensor_id = zeros(1,12);
    blanksensor.probes{j}.coef(1:5) = 0;
  end;
  for i=1:64
    inst.sensor{i}=blanksensor;
  end;
  
  bad = find(isnan(Filter));Filter(bad)=0;
  bad = find(isnan(Offset));Offset(bad)=0;
  bad = find(isnan(Modulas));Modulas(bad)=0;

  i=0;
  for k=1:64
    i=k;
    inst.sensor{k}.sensor_name=zeros(1,8);
    if ~isempty(Signal{k})
      inst.sensor{i}.sensor_name(1:length(Signal{k})) = Signal{k};
      inst.sensor{i}.sensor_name(end) = 0;
      inst.sensor{i}.sensor_name = inst.sensor{i}.sensor_name(1:8);
      inst.sensor{i}.sensor_name(end) = 0;
      inst.sensor{i}.module_num=zeros(1,10);
      inst.sensor{i}.module_num(1:length(Circuit{k})) = Circuit{k};
      inst.sensor{i}.module_num(end) = 0;
      inst.sensor{i}.filter_freq=Filter(k);
      inst.sensor{i}.das_channel_num=Hexnum(k);
      inst.sensor{i}.offset=Offset(k);
      inst.sensor{i}.modulas=Modulas(k);
      
      % now look on sheet4 for the module number corresponding to
      % this modulenumber....
      if ~isempty(deblank(char(inst.sensor{i}.module_num)))
        in = find(strcmp(upper(deblank(char(inst.sensor{i}.module_num))), ...
                         upper(Modulename)));
        if length(in)==0;
          fprintf(1,...
           '%8s has module name %8s, but no entry was found on %s \n',...
                  char(inst.sensor{i}.sensor_name),char(inst.sensor{i}.module_num),sheet4name);
        end;
        inst.sensor{i}.num_probes=length(in);
      end;
      
      % make nine blank probes
      for j=1:9
        inst.sensor{i}.probes{j}.sensor_id = zeros(1,12);
        inst.sensor{i}.probes{j}.coef(1:5) = 0;
      end;

      % fill in the information from sheet 4 into the inst structure...
      for j=1:length(in)
        inst.sensor{i}.probes{j}.sensor_id(1:length(SensorID{in(j)})) = ...
            SensorID{in(j)};
        % make sure the end of string is zero
        inst.sensor{i}.probes{j}.sensor_id(end) = 0;
        inst.sensor{i}.probes{j}.coef(1:4) = Coef(in(j),1:4);
      end;
    else
      % leave the sensor blank...
    end; % is empty Signal...
  end;
  
  % write the ins file....
  insname = sprintf('%s/%s.ins',pathname,fnameroot);
  write_insfile(inst,insname);
  return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function write_insfile(inst,fname);
  % this makes an ins file....    
    fout = fopen(fname,'wb');
    
    fwrite(fout,inst.inst_name,'uchar');
    fwrite(fout,inst.baudrate,'long');
    fwrite(fout,inst.samplerate,'float');
    fwrite(fout,inst.num_sensors,'short');
    % write out 64 sensors....
    for i=1:64
      fwrite(fout,inst.sensor{i}.sensor_name,'char');
      fwrite(fout,inst.sensor{i}.module_num,'char');
      fwrite(fout,inst.sensor{i}.filter_freq,'float');
      fwrite(fout,inst.sensor{i}.das_channel_num,'short');
      fwrite(fout,inst.sensor{i}.offset,'short');
      fwrite(fout,inst.sensor{i}.modulas,'short');
      fwrite(fout,inst.sensor{i}.num_probes,'short');
      for j=1:9
	fwrite(fout,inst.sensor{i}.probes{j}.sensor_id,'char');
	fwrite(fout,inst.sensor{i}.probes{j}.coef,'float');
      end;
    end;
    
    fclose(fout);
    
    
  return;
 
  
  
function write_eprom(Hex,Modulas,Offset,epromname,Signal);
  
  hexfile = zeros(1,2048);
  len = 256;
  mainoff = hex2dec('400')+1;
  Offset=Offset+mainoff;
  pp = 0*[0:len-1];
  for i=1:length(Hex);
    if ~isnan(Modulas(i)+Offset(i)) & Modulas(i)>0
      pos = [0:256./Modulas(i):len]+Offset(i);
      in = find(pos-mainoff<len);
      pos = pos(in);
      if sum(pp(pos-mainoff+1))==0
	    pp(pos-mainoff+1)=i;
      else
        % find the overlap....
        in = find(pp(pos-mainoff+1)~=0)
        error(sprintf('%s reusing position %d previously used by %s\nUse checkoffsets.m to see the allotment.\nUse makeoffsets.m to make a list of offsets that works.', ...
                      Signal{i},pos(in(1))-mainoff,Signal{pp(pos(in(1))-mainoff+1)}));
      end;
      
      ppos{i}=pos;
      hexfile(pos) = Hex(i);   
    end;
    
  end;
  feprom = fopen(epromname,'wb');
  if feprom<1
    error('Could not open %s',epromname);
  end;
  
  fwrite(feprom,hexfile,'uchar');
  fclose(feprom);
  
function str=findkeystr(key,B)
% finds the keyword and then returns the position and the next non empty
% data...
  
 i=0;str=[];
  while isempty(str)
    i=i+1;
    if(strncmp(B(i,1),key,length(key)))
      j = 1;
      while isempty(str)
        j=j+1;
        if ~isempty(B{i,j})
          str=B{i,j};
        end;
      end;
      
    end;    
  end;

function str=findkeynum(key,B)
% finds the keyword and then returns the position and the next non empty
% data...
  
 i=0;str=[];
  while isempty(str)
    i=i+1;
    if(strncmp(B(i,1),key,length(key)))
      j = 1;
      while isempty(str)
        j=j+1;
        if ~isnan(B{i,j})
          str=B{i,j};
        end;
      end;
    end;    
  end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [i,j]=getrowcolumn(str,B);
  done=0;
  for i=1:size(B,1)
    for j=1:size(B,2);
      if strncmp(B{i,j},str,length(str));
        done=1;
        break;
      end;
    end;
    if done
      break;
    end;
  end;
  if ((i==size(B,1)) &(j==size(B,2)))
    if strncmp(B{i,j},str,length(str))
      return;
    else
      error(sprintf('Could not find %s in the worksheet',str));
    end;
  end
return;  

%%%%%%%%%%%%%%%%%
function dat=getallstr(B)
  dat = B;
  for i=1:length(dat)
      dat{i}=num2str(B{i});
  end;
  
return;
%%%%%%%%%%%%%%%%%
function dat=getallnum(B)
  dat = B;
  for i=1:length(dat)
    if isstr(B{i})
      dat{i}=str2num(B{i});
    end;
    if isempty(dat{i})
      dat{i}=NaN;
    end;
  end;
  dat = cell2mat(dat);
return;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function good=checkoffsets(signal,offsets,modulas,numsensors,fnameroot)  
  len=256;
  
  pp = 0*[0:len-1];
  for i=1:5
    str{i}(1:256,1:12)=' ';
  end;
  bad=0;
  for i=1:64
    pos = [0:len./modulas(i):len]+offsets(i);
    in = find(pos<len);
    pos = pos(in);
    for j=1:length(pos);
      k = 1;
      while length(deblank(str{k}(pos(j)+1,:)))>0;
	k = k+1;
      end;     
      if k>1
	bad=bad+1;
      end;
      str{k}(pos(j)+1,1:length(signal{i}))=signal{i};
      mod(k,pos(j)+1) = modulas(i);
    end;
  end;
  flist = fopen(sprintf('%s_signalpositions.txt',fnameroot),'w');
  for i=1:len
    fprintf(flist,'%03d ',i-1);
    for j=1:5
      if ~isempty(deblank(str{j}(i,:)))
	fprintf(flist,'%s  %02d ',str{j}(i,:),mod(j,i));
      else
	fprintf(flist,'%s    ',str{j}(i,:));
      end;
    end;
    fprintf(flist,'\n');
  end;
  fclose(flist);
  if bad==0
    fprintf(1,'There are NO errors noted in the eprom position\n'); 
  else;
   type(sprintf('%s_signalpositions.txt',fnameroot));
   fprintf(1,'There are %d errors in the signal positions - see above\n',bad); 
  end;
  good=~bad;
  fprintf(1,'These signal positions are listed in signalpositions.txt\n'); 
  return;
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5  
function offset=getoffsets(Signal,Modulas);
  
  len=256;
  
  [M,ii]=sort(Modulas);
  M = flipud(M);
  S=flipud(Signal(ii));
  % SYNC needs to be at 255.
  syncpos = find(strcmp(S,'SYNC'));

  in = find(~strcmp(S,'SYNC'));
  M = M(in);
  S=S(in);
  
  filled=zeros(1,255);
  offset=zeros(length(M)+1,1);
  % SYNC needs to be at 255.
  offset(syncpos) = 127;
  for i=1:length(M)
    if ~isnan(M(i))&M(i)>0
      pos = 0:256/M(i):255;
      offset(i)=1;
      pp = pos(find(pos+offset(i)<256))+offset(i);
      while sum(filled(pp))>0
	offset(i)=offset(i)+1;
	pp = pos(find(pos+offset(i)<256))+offset(i);
      end;
      filled(pp)=filled(pp)+1;
    end;
  end;
  offset(ii)=flipud(offset)-1;
  
  return;
    
function writeoffsets(signal,offsets,modulas,numsensors,fname)  
  len=256;
  
  for i=1:length(modulas)
    if modulas(i)>0
      pos = [0:len./modulas(i):len]+offsets(i);
      in = find(pos<len);
      pos = pos(in);
      for j=1:length(pos);
	str(pos(j)+1,1:12)=' ';
	str(pos(j)+1,1:length(signal{i}))=signal{i};
      end;
    end;
  end;
  flist = fopen(sprintf('%s_signalpositions.txt',fname),'w');
  for i=1:size(str,1)
    fprintf(flist,'%03d %s\n',i-1,str(i,:));
  end;
  fclose(flist);

  
  foffsets = fopen(sprintf('%s_signaloffsets.txt',fname),'w');
  for i=1:length(modulas)
    if offsets(i)>-1
      fprintf(foffsets,'%d\n',offsets(i));
    else
      fprintf(foffsets,' \n',offsets(i));
    end;
    
  end;
  
  fclose(foffsets);
  type(sprintf('%s_signaloffsets.txt',fname));
  fprintf(1,'Suggested signal offsets are listed in %s_signaloffsets.txt\n',fname); 
  fprintf(1,'Corresponding signal positions are listed in %s_signalpositions.txt\n',fname); 
  
 % keyboard;
  return;
  
