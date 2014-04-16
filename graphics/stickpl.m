function hh=stickpl(cm,varargin);
% STICKPL Creates a stickplot
%  STICKPL(CM) creates a stickplot of the data in
%  structure CM. Sticks are plotted so that a current
%  in a NE direction appears at an angle of 45 degrees.
%  STICKPL(CM,DATELIMS) plots only current vector
%  over a time DATELIMS(1)<time<DATELIMS(2). Set to
%  [-Inf Inf] or [] for auto-scaling (default).
%  STICKPL(CM,DATLIMS,SPLIMS) sets the yaxis limits to
%  [-SPLIMS SPLIMS] (if SPLIMS is a scalar) or SPLIMS
%  if it is a vector.
%
%  STICKPL(CM,...,'property','value','property','value,...)
%  can be used to set line properties of the sticks.
%
%  If you have a raw U/V time series (instead of a structure
%  CM) then call
%  STICKPL(U,V,T,...other args as before) with columns vectors
%  U and V (m/s) and T (decimal days).
%
%  For ADCP data, call
%  STICKPL(ADCP,CELL,...) to make a stickplot of the depthscells in the
%  ADCP structure specified by the vector CELLS.
%
%  See also TPOLAR, PVDIAG, RDCM, RDRADCP
%
% R. Pawlowicz 6/Sep/99
%     3/Oct/99  - many changes in operation and calling sequence
%     30/Oct/99 - changes to allow for cm and adcp structures. 
% A.Perlin 21 Apr 2011
%     Fixed obsolete function finite --> isfinite 
%     and modified stickpl so that it now accepts both 
%     row and column vectors as inputs
%     PLEASE NOTE:
%     1. Figure and subplot size MUST be set BEFORE stickpl is used
%     otherwise it would result in wrong orientation of sticks.
%     2. 'ylim' must be set inside stickpl or automatick scaling should be
%     used , otherwise it would change stick orientation.
%     EXAMPLE:
%     load('\\mserver\data2\st10\processed\adcp\st10_30sec.mat')
%     ts=datenum(2010,6,10);
%     tf=ts+0.05;
%     bin=5;
%     f1=figure(1);clf
%     set(f1,'position',[100 100 500 800])
%     sp(1)=subplot(2,1,1);
%     set(sp(1),'position',[0.1 0.6 0.7 0.3])
%     stickpl(adcp.u(bin,:),adcp.v(bin,:),adcp.time,[ts tf],[-0.02 0.5],'color','r');
%     kdatetick


% Parse input structure
if isstruct(cm),
 switch cm.config.name,
   case 'current meter',
     [U,V]=spdir2uv(cm.speed,cm.dir);
     mtime=cm.mtime;
     yunit='cm/s';
   case {'wh-adcp','bb-adcp'}
     cells=varargin{1};varargin(1)=[];
     U=cm.east_vel(cells,:)';
     V=cm.north_vel(cells,:)';
     mtime=cm.mtime';
     yunit='m/s';
   otherwise
     error('Unrecognized input format');
 end;
else,  % U,V,T given.
  U=cm;if size(U,1)==1;U=U';end
  V=varargin{1};if size(V,1)==1;V=V';end
  mtime=varargin{2};if size(mtime,1)==1;mtime=mtime';end
  varargin(1:2)=[];
  yunit='m/s';
end;

% Parse datlims

datelims=[];
if length(varargin)>0 & isnumeric(varargin{1}),
  datelims=varargin{1};
  varargin(1)=[];
end;

% Auto-scaling
if isempty(datelims) | all(datelims==[-Inf Inf]),
  datelims=[ min(mtime) max(mtime)];
  datelims=datelims+[-1 1]*.05*diff(datelims);
end;

% Have we set ylims?

yfac=[];
if length(varargin)>0 & isnumeric(varargin{1}),
  yfac=varargin{1}; % Strip it off
  varargin(1)=[];   % ..and remove from the arglist.
end;
if length(yfac)==1,
 yfac=[-1 1]*abs(yfac);
end;

% Find elements in time window

kk=mtime>datelims(1) & mtime<datelims(2);


% Get ratio of plot window

old_units = get ( gca, 'Units' );
set ( gca, 'Units', 'Pixels' );
pos = get ( gca, 'Position' );
set ( gca, 'Units', old_units );

if isempty(yfac),
  ylim=[min(0,min(V(isfinite(V)))) max(0,max(V(isfinite(V))))];
  ylim=ylim+[-1 1]*0.05*diff(ylim);
else
  ylim=yfac;
end;

scale_fac = (diff(datelims)/diff(ylim)) * (pos(4)/pos(3));

% For multiple lines we get colourorder
lcols=get(gca,'colororder');
hold_state=ishold;

for l=1:size(U,2);

  % Vectors go from (time,0) to (time+U,V) with
  % that cfac appearing. A third row of NaNs is added...

  X=[1;1;NaN]*mtime(kk)' + [0;1;NaN]*U(kk,l)'*scale_fac;
  Y=[0;1;NaN]*V(kk,l)';

  % So we can plot all the arrows as one long vector
  % with drawing breaks given by NaN (much faster than
  % drawing all the individual vectors separately)
  
  % Also, set colours to a default ordering (can be overriden
  % by varagin{:} specs)
  
  hh=plot(X(:),Y(:),'color',lcols(rem(l-1,size(lcols,1))+1,:),varargin{:});
  hold on;
end;

% Return to previous hold state.
if hold_state~=1, hold off; end;

set(gca,'xlim',datelims,'ylim',ylim);
ylabel(['speed (' yunit ')']);

set(gca,'tag','Stickplot');

