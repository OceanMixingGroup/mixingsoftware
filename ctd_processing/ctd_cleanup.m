  function data = ctd_cleanup(data, icast)
% function data = ctd_cleanup(data, icast)
% 
% despike p
% eliminate data above 5 m
% remove spikes in other data
% remove smaller T, C glitches
  
figures = 0;

% switch T-C pairs
%switch icast
%  case 1
%    % t1, c2 good
%    disp('switching: c2 > c1') 
%    c1 = data.c1;
%    data.c1 = data.c2;
%    data.c2 = c1;
%    clear c1
%end

data = rmfield(data, 'modcount');
if isfield(data,'tcfit')
    tcflag=1;
    tcfit=data.tcfit;
    data=rmfield(data,'tcfit');
else
    tcflag=0;
end

% despike p
prodp = 1.0;    
diffp = 2.0;   
figure
data.p = tms_tc_glitchcorrect(data.p, diffp, prodp, 0, 0, figures);

[pmax, ipmax] = max(data.p);

% eliminate deck and near-surface data
ptop = 10; % pressure to start data
fdeep = find(data.p > ptop);
ideep = findsegments(fdeep);
ii = find(ideep.start < ipmax, 1, 'last');
jj = find(ideep.stop > ipmax, 1, 'first');
data = structcat(fieldnames(data), '', 'col', 0, data, ideep.start(ii):ideep.stop(jj));

% remove spikes
ib=find(abs(diff(data.t1))>.5); data.t1(ib)=NaN;
ib=find(abs(diff(data.t2))>.5); data.t2(ib)=NaN;

data = ctdpreen(data); % no trans, fl ***

% remove any NaNs at start
n = length(data.c1);
fnan1 = find(isnan(data.c1));
fnan2 = find(isnan(data.c2));
if ~isempty(setdiff(fnan1, fnan2))
  disp('warning: NaNs index different in data.c1 and data.c2')
end
if ~isempty(fnan1)
  inan1 = findsegments(fnan1);
  if (inan1.start ~= 1 | length(inan1.start) ~= 1)
    disp('warning: more NaNs')
  end
  data = structcat(fieldnames(data), '', 'col', 0, data, [inan1.stop(1) + 1:n]');
end

if tcflag
    data.tcfit=tcfit;
end

%%
dotime=1
if dotime==1
% time is discretized
t0=data.time-min(data.time); % time since beginning of cast
iit=min(find(diff(t0)==1));% 1 second after cast starts?
dtt=diff(t0); 
if size(find(dtt<0))~=0; 
    
    % find where time is decreasing
    ib=find(dtt<0); 
    data.time((ib+1):end)=data.time((ib+1):end)+abs(dtt(ib))+1;%original
%     data.time((ib+1):end)=data.time((ib+1):end)+abs(dtt(ib+1));% AP 23 April
end
t1=(data.time(iit+1)-iit/24-0.5):1/24:max(data.time)+1;
t1=t1(1:length(data.time)); 
data.time=t1(:);

end
%% August 2010: removed this section, was messing up the t-c fit. 
% do it later 
%
% despike T C
%prodc = 5e-7;   diffc = 1e-3;   
%prodc = 1e-7;   diffc = 5e-4;   
%prodt = 5e-5;   difft = 1e-2;   
%ibefore = 1;    iafter = 1;%
% data.c1 = tms_tc_glitchcorrect(data.c1, diffc, prodc, ibefore, iafter, figures);
% data.c2 = tms_tc_glitchcorrect(data.c2, diffc, prodc, ibefore, iafter, figures);
% data.t1 = tms_tc_glitchcorrect(data.t1, difft, prodt, ibefore, iafter, figures);
% data.t2 = tms_tc_glitchcorrect(data.t2, difft, prodt, ibefore, iafter, figures);
