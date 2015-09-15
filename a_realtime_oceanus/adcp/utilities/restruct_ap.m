function [data, config] = restruct_ap(instclass, dd, varargin)
% [dd, config] = restruct(instclass, data, varargin)
% index is indices: step, range, or list
% reshape things to output one structure with vel, amp, cor, pg, temperature,etc
% varargin can be  'irange' (index start and end)
%                  'ilist' (indices)
%                  'step' (subsample whole thing by this)
%                  'ddayrange' (ddrange start and end)
% Modified by A. Perlin 12-Mar-2013 to correct for misalignment of 
% the transducer and the GPS antenna:
%                  'dx'  - athwardships:                               0
%                        delta_x is the athwartships
%                        distance from the antenna
%                        to the transducer; positive if
%                        the transducer is to starboard
%                        of the antenna.
%                  'dy' - along the fore-aft axis:                    0
%                        delta_y is the forward distance 
%                        from the antenna to the transducer; 
%                        positive if the transducer is
%                        forward of the antenna, negative 
%                        otherwise.
% Modified by A. Perlin 12-Mar-2013 to use bottomtrack instead of ship  
% speed to get ocean velocities: 
%                  'use_bottom'  1 (yes) or 0 (no)                              0


doconfig = 0;
if (nargout == 2)
   doconfig = 1;
end
if ~isstruct(dd) | isemptys(dd) 
   data = [];
   config =[];
   return
end

if isa(instclass, 'bb')
   inst = 'BB';
elseif isa(instclass, 'nb')
   inst = 'NB';
elseif isa(instclass, 'wh')
   inst = 'WH';
elseif isa(instclass, 'os')
   inst = 'OS';
elseif isa(instclass, 'son')
   inst = 'SON';
elseif isa(instclass, 'hr')
   inst = 'HDSS';
elseif isa(instclass, 'hr2')
   inst = 'HDSS2';
elseif isa(instclass, 'hr3')
   inst = 'HDSS3';
elseif isa(instclass, 'hr4')
   inst = 'HDSS4';
else
   help restruct
   error('choices for instclass are wh, bb, nb, and os, son, hr, hr2, hr3, hr4')
end




cfg.irange =  [];
cfg.ilist =     [];
cfg.ddayrange = [];
cfg.step =   1;
cfg.dx = 0;
cfg.dy = 0;
cfg.use_bottom = 0;
cfg = fillstruct(cfg, varargin, 0);


index = [1:length(dd.dday)]';
%% should replace this with get_ilist.m:
if (~isemptys(cfg.irange)),index = [cfg.irange(1):cfg.step:cfg.irange(2)]; end
if (~isemptys(cfg.ilist)),       index = cfg.ilist; end
if (~isemptys(cfg.ddayrange))
   [junk, first_index] = min(abs(dd.dday - cfg.ddayrange(1)));
   [junk, last_index]  = min(abs(dd.dday - cfg.ddayrange(end)));
   index = [first_index:cfg.step:last_index]';
end


data.dday = dd.dday(index);
data.ens_num = dd.ens_num(index);

nbins = length(dd.depth);

% assume a 3-dimensional arrays are [nbins X nbeams X nprofs]

fnames = fieldnames(dd);
for fnamei = 1:length(fnames)
   fname =  fnames{fnamei};
   fval = getfield(dd, fname);
   if length(size(fval)) == 3
      data=setfield(data, fname, fval(:,:,index));

      [nbins, nbeams, nprofs] = size(fval);
      for beami = 1:nbeams
         newname = sprintf('%s%d', fname, beami);
         data = setfield(data, newname, squeeze(fval(:, beami, index)));
      end
   end
   data.bins = [1:nbins]';
end

if isfield(dd, 'nav')
   if length(find(~isnan(dd.nav.txy2(1,:))) > 1) 
      isnav = 1;
   else
      isnav = 0;
   end
else
   isnav = 0;
end



if ~isfield(dd, 'corr_dday')
   if isfield(dd, 'nav')
      if isnav==1
         dd.corr_dday = dd.nav.txy2(1,:);
      end
   end
end


%%%%% do time series
if (isfield(dd, 'corr_dday')),   data.corr_dday = dd.corr_dday(index);  end
if (isfield(dd, 'heading_used')), data.heading_used = dd.heading_used(index);end
if (isfield(dd, 'heading')),   data.heading = dd.heading(index);  end
if (isfield(dd, 'pitch')),    data.pitch   = dd.pitch(index);   end
if (isfield(dd, 'roll')),     data.roll = dd.roll(index);       end
if (isfield(dd, 'pitch_used')),data.pitch_used = dd.pitch_used(index);   end
if (isfield(dd, 'roll_used')), data.roll_used = dd.roll_used(index);       end
if (isfield(dd, 'ashtech')), 
   if ~isstruct(dd.ashtech)  ,  data.ashtech = dd.ashtech(index);  end
end
if (isfield(dd, 'temperature')), data.temperature = dd.temperature(index); end
if (isfield(dd, 'soundspeed')),   data.soundspeed = dd.soundspeed(index); end
if (isfield(dd, 'pressure')),  data.pressure = dd.pressure(index); end

if strcmp(dd.config.coordsystem, 'earth')
   if isfield(dd, 'enu') 
      fprintf('\nfield ''enu'' exists; no need to create variable manually\n')
   else
      dd.enu = dd.vel;
   end
   %% take out the field called 'vel' so it's less confusing.
   dd = rmfield(dd, 'vel');
end


%%%%% get the serial fields -- transfer them across
instfields = get_instfields('instfields', 1);     % {'gyro','ashtech',...} 
for fieldi = 1:length(instfields)    %eg. ashtech (the name)
   if isfield(dd, instfields{fieldi})
      instname = instfields{fieldi}; 
      inststruct = getfield(dd, instname);  %ashtech (the structure)
      if isstruct(inststruct)
         data = setfield(data, instname, inststruct);
      end
   end
end


%% for ENX files
if strcmp(dd.config.coordsystem,'earth')  
    if ~isfield(dd, 'enu')
        dd.enu = dd.vel;
    end
end
if (isfield(dd, 'enu'))
   data.umeas=squeeze(dd.enu(:,1,index));
   data.vmeas=squeeze(dd.enu(:,2,index));
   data.wmeas=squeeze(dd.enu(:,3,index));
   [nbins, nfields, nprofs] = size(dd.enu);
   if nfields > 3
       data.emeas=squeeze(dd.enu(:,4,index));       
   end
   data.cuv = data.umeas + i*data.vmeas;
end

if (isfield(dd, 'xyze'))
   data.emeas=squeeze(dd.xyze(:,4,index));
end


if isnav == 1
   %%%% Added by A. Perlin 12-Mar-2013 to correct for misalignment of %%%%
   %%%% the transducer and the GPS antenna %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   theta = - dd.heading* (pi/180);
   
   delta = (cfg.dx +1i*cfg.dy)*exp(1i*theta);
   corx_m =real(delta);
   cory_m = imag(delta);
   
   % transform meters to decimal degrees
   corx_deg = m_to_lon(corx_m',dd.nav.txy2(3,:)');
   cory_deg = m_to_lat(cory_m',dd.nav.txy2(3,:)');
   
   % apply correction to the fixes
   dd.nav.txy1(2:3,:)=dd.nav.txy1(2:3,:)+[corx_deg';cory_deg'];
   dd.nav.txy1(2,:)=fillgap(dd.nav.txy1(2,:)); 
   dd.nav.txy1(3,:)=fillgap(dd.nav.txy1(3,:)); 
   dd.nav.txy2=dd.nav.txy1;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   data.nav = dd.nav;
   [data.mps, xx, yy, data.cog] = ...
       ll2mps(dd.nav.txy2(1,index), ...
              dd.nav.txy2(2,index), dd.nav.txy2(3,index));
   data.lon = unwrap_lon(dd.nav.txy2(2,:));
   data.lat = dd.nav.txy2(3,:);
   if ~cfg.use_bottom
       data.uship = diff(xx)./(86400*diff(dd.nav.txy2(1,index)));
       data.vship = diff(yy)./(86400*diff(dd.nav.txy2(1,index)));
       
       data.uship = [data.uship(1) data.uship];
       data.vship = [data.vship(1) data.vship];
   else
       data.uship = -dd.bt.enu(1,:);
       data.vship = -dd.bt.enu(2,:);
   end
   
   if isfield(data, 'umeas')
      data.uabs = data.umeas + repmat(data.uship, nbins, 1);
      data.vabs = data.vmeas + repmat(data.vship, nbins, 1);
   end
else
   data.nav = NaN;
   data.mps = NaN;
   data.cog = NaN;
   data.lon = NaN;
   data.lat = NaN;
   data.uship = NaN;
   data.uship = NaN;
   data.vship = NaN;
   data.vship = NaN;
end

if isfield(data, 'uabs') & ...
   isfield(data, 'vabs') 
   if isfield(data, 'heading_used') 
     [data.fabs, data.pabs] = uv2fp(data.uabs, data.vabs, data.heading_used);
   elseif isfield(data, 'heading') 
     [data.fabs, data.pabs] = uv2fp(data.uabs, data.vabs, data.heading);
   end
end


data.config =  dd.config;
if (isfield(dd,'bt'))
   data.bt.vel   = dd.bt.vel(:,index);
   data.bt.range  = dd.bt.range(:,index);
   if isfield(dd.bt, 'status'), data.bt.status = dd.bt.status(index);  end
   if isfield(dd.bt, 'cor'),    data.bt.cor    = dd.bt.cor(:,index);   end
   if isfield(dd.bt, 'sdb'),    data.bt.sdb    = dd.bt.sdb(:,index);   end
   if isfield(dd.bt, 'amp'),    data.bt.amp    = dd.bt.amp(:,index);   end
   if isfield(dd.bt, 'sn'),     data.bt.sn     = dd.bt.sn(:,index);   end
   if isfield(dd.bt, 'int'),    data.bt.int    = dd.bt.int(:,index);   end
   if isfield(dd.bt, 'rssi'),   data.bt.rssi   = dd.bt.rssi(:,index);  end
   if isfield(dd.bt, 'pg'),     data.bt.pg     = dd.bt.pg(:,index);    end   
   if isfield(dd.bt, 'enu'),    data.bt.enu    = dd.bt.enu(:,index);   end   
end

if isfield(dd, 'hdss_vars')
   data.hdss_vars = dd.hdss_vars;
end

if isfield(dd, 'dasinfo')
   data.dasinfo = dd.dasinfo;
end


if isfield(dd, 'params')
   data.params = dd.params;
end


if (isfield(dd, 'depth'))
   data.depth = dd.depth;
end

%do this on the final product
if (isfield(data, 'umeas'))
   rads = repmat((90-data.heading)*pi/180,length(data.umeas(:,1)),1);
   %foreport of measured vel
   fp = (data.umeas(:,index) + i*data.vmeas(:,index)).*exp(-i*rads);
   data.fmeas = real(fp);
   data.pmeas = imag(fp);
end

if (doconfig)

   %initialize some default titles and limits 

   config.title.vel1            = sprintf('%s BEAM 1 VELOCITY (m/s)', inst);
   config.title.vel2            = sprintf('%s BEAM 2 VELOCITY (m/s)', inst);
   config.title.vel3            = sprintf('%s BEAM 3 VELOCITY (m/s)', inst);
   config.title.vel4            = sprintf('%s BEAM 4 VELOCITY (m/s)', inst);

   config.title.cor1            = sprintf('%s BEAM 1 CORRELATION', inst);
   config.title.cor2            = sprintf('%s BEAM 2 CORRELATION', inst);
   config.title.cor3            = sprintf('%s BEAM 3 CORRELATION', inst);
   config.title.cor4            = sprintf('%s BEAM 4 CORRELATION', inst);

   config.title.sw1            = sprintf('%s BEAM 1 SPECTRAL WIDTH', inst);
   config.title.sw2            = sprintf('%s BEAM 2 SPECTRAL WIDTH', inst);
   config.title.sw3            = sprintf('%s BEAM 3 SPECTRAL WIDTH', inst);
   config.title.sw4            = sprintf('%s BEAM 4 SPECTRAL WIDTH', inst);

   config.title.amp1            = sprintf('%s BEAM 1 AMPLITUDE', inst);
   config.title.amp2            = sprintf('%s BEAM 2 AMPLITUDE', inst);
   config.title.amp3            = sprintf('%s BEAM 3 AMPLITUDE', inst);
   config.title.amp4            = sprintf('%s BEAM 4 AMPLITUDE', inst);

   config.title.int1            = sprintf('%s BEAM 1 INTENSITY', inst);
   config.title.int2            = sprintf('%s BEAM 2 INTENSITY', inst);
   config.title.int3            = sprintf('%s BEAM 3 INTENSITY', inst);
   config.title.int4            = sprintf('%s BEAM 4 INTENSITY', inst);

   config.title.sn1            = sprintf('%s BEAM 1 SIGNAL/NOISE', inst);
   config.title.sn2            = sprintf('%s BEAM 2 SIGNAL/NOISE', inst);
   config.title.sn3            = sprintf('%s BEAM 3 SIGNAL/NOISE', inst);
   config.title.sn4            = sprintf('%s BEAM 4 SIGNAL/NOISE', inst);

   config.title.sdb1            = sprintf('%s BEAM 1 SOUND (dB)', inst);
   config.title.sdb2            = sprintf('%s BEAM 2 SOUND (dB)', inst);
   config.title.sdb3            = sprintf('%s BEAM 3 SOUND (dB)', inst);
   config.title.sdb4            = sprintf('%s BEAM 4 SOUND (dB)', inst);

   config.title.rssi1            = sprintf('%s BEAM 1 RSSI', inst);
   config.title.rssi2            = sprintf('%s BEAM 2 RSSI', inst);
   config.title.rssi3            = sprintf('%s BEAM 3 RSSI', inst);
   config.title.rssi4            = sprintf('%s BEAM 4 RSSI', inst);

   config.title.umeas            = sprintf('%s MEAS U (m/s)', inst);
   config.title.vmeas            = sprintf('%s MEAS V (m/s)', inst);
   config.title.wmeas            = sprintf('%s MEAS W (m/s)', inst);
   config.title.emeas            = sprintf('%s ERROR VEL (m/s)', inst);


   config.minclipval.vel1 = -6;    config.maxclipval.vel1 =  6;
   config.minclipval.vel2 = -6;    config.maxclipval.vel2 =  6;
   config.minclipval.vel3 = -6;    config.maxclipval.vel3 =  6;
   config.minclipval.vel4 = -6;    config.maxclipval.vel4 =  6;


   config.minclipval.amp1 = 10;    config.maxclipval.amp1 =  200;
   config.minclipval.amp2 = 10;    config.maxclipval.amp2 =  200;
   config.minclipval.amp3 = 10;    config.maxclipval.amp3 =  200;
   config.minclipval.amp4 = 10;    config.maxclipval.amp4 =  200;

 
   if isa(instclass,'wh')
      config.minclipval.amp1 = 10;    config.maxclipval.amp1 =  160;
      config.minclipval.amp2 = 10;    config.maxclipval.amp2 =  160;
      config.minclipval.amp3 = 10;    config.maxclipval.amp3 =  160;
      config.minclipval.amp4 = 10;    config.maxclipval.amp4 =  160;
   end
 
   config.minclipval.rssi1 = 10;    config.maxclipval.rssi1 =  200;
   config.minclipval.rssi2 = 10;    config.maxclipval.rssi2 =  200;
   config.minclipval.rssi3 = 10;    config.maxclipval.rssi3 =  200;
   config.minclipval.rssi4 = 10;    config.maxclipval.rssi4 =  200;


   config.minclipval.cor1 = 20;    config.maxclipval.cor1 =  260;
   config.minclipval.cor2 = 20;    config.maxclipval.cor2 =  260;
   config.minclipval.cor3 = 20;    config.maxclipval.cor3 =  260;
   config.minclipval.cor4 = 20;    config.maxclipval.cor4 =  260;

   config.minclipval.sw1 = 20;    config.maxclipval.sw1 =  260;
   config.minclipval.sw2 = 20;    config.maxclipval.sw2 =  260;
   config.minclipval.sw3 = 20;    config.maxclipval.sw3 =  260;
   config.minclipval.sw4 = 20;    config.maxclipval.sw4 =  260;

   config.minclipval.umeas = -6;    config.maxclipval.umeas =  6;
   config.minclipval.vmeas = -6;    config.maxclipval.vmeas =  6;
   config.minclipval.wmeas = -6;    config.maxclipval.wmeas =  6;
   config.minclipval.emeas = -6;    config.maxclipval.emeas =  6;


   config.comment = '';
end
