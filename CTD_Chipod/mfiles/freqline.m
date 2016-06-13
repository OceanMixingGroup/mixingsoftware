function h=freqline(fl,sty)
%function freqline(fi,sty)
%Place a vertical line at the location specified by fl.
%
%MHA 03/04
%01/05: return the handle.
%
if nargin < 2
sty='k--';
end

xv=[fl fl]';
yl=ones(size(xv))*ylim;
hold on
h=loglog(xv,yl',sty);
hold off
%%
