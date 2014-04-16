function [tao]=get_tao_spd(dpath,ts,tf,depth)
% function [tao]=get_tao_spd(dpath,ts,tf,depth)
% dpath - data directory, i.e. '\\mserver\data\chipod\tao_sep05\'
% dpl - deployment name (string), i.e. 'or07b'
% ts - start time, Matlab format
% tf - finish time, Matlab format
% depth - unit depth, it is used to get current data from tao buoy
%   $Revision: 1.1.1.1 $  $Date: 2008/01/31 20:22:42 $

load([dpath '\buoy_data\tao'])
tao1=tao;
clear tao;

idt=find(tao1.cur.time>(ts-.02) & tao1.cur.time<(tf+.02));
tao.curtime=tao1.cur.time(idt);
[c,idz]=min(abs(tao1.cur.depth-depth));
tao.u=tao1.cur.u(idt,idz);
tao.v=tao1.cur.v(idt,idz);
speed2=tao.u.^2+tao.v.^2;
speed=sqrt(speed2);
tao.spd=speed;
theta=atan2(tao.u,tao.v).*180./pi;
idtheta=find(theta<0);
theta(idtheta)=theta(idtheta)+360;
tao.dir=theta;
