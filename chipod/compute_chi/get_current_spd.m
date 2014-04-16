function [cur]=get_current_spd(dpath,ts,tf,depth,varargin)
% function [cur]=get_current_spd(dpath,ts,tf,depth)
% dpath - data directory, i.e. '\\mserver\data\chipod\tao_sep05\'
% dpl - deployment name (string), i.e. 'or07b'
% ts - start time, Matlab format
% tf - finish time, Matlab format
% depth - unit depth, it is used to get current correcpoding ADCA depth bin
% current data should be either sufficiently filtered or averaged so that
% it does not include wind waves and swell
%   $Revision: 1.6 $  $Date: 2012/10/16 21:01:22 $

if ~isempty(varargin)
    unit=num2str(varargin{1});
end
if exist([dpath '\current_data\current.mat'])
    load([dpath '\current_data\current']);
else
    load([dpath '\current_data\current_' num2str(unit)]);
end
fields=fieldnames(cur);
cur1=cur;
clear cur;
if size(cur1.u,1)<size(cur1.u,2)
    for ii=1:length(fields)
        cur1.(char(fields(ii)))=cur1.(char(fields(ii)))';
    end
end    
idt=find(cur1.time>(ts-1/24) & cur1.time<(tf+1/24));
cur.curtime=cur1.time(idt);
if size(cur1.depth,2)>1
    [c,idz]=min(abs(nanmean(cur1.depth,1)-depth));
else
    idz=1;
end
fields1=setdiff(fields,{'depth','time','readme'});
for ii=1:length(fields1)
    cur.(char(fields1(ii)))=cur1.(char(fields1(ii)))(idt,idz);
end
% speed2=cur.u.^2+cur.v.^2+cur.w.^2;
speed2=cur.u.^2+cur.v.^2;
speed=sqrt(speed2);
cur.spd=speed;
theta=atan2(cur.u,cur.v).*180./pi;
idtheta=find(theta<0);
theta(idtheta)=theta(idtheta)+360;
cur.dir=theta;
