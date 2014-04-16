function [ind, tog]=find_top(tp_ser,p_ser)

% function [ind, tog]=find_top detects the position of the top
% based on data.TP and data.P.  This returns IND, the index of pressure
% corresponding to the top, and tog='y' if the top was found and 'n' if we
% missed it (ie., there was no detectable temperature derivative near the
% surface) 
%
% It looks for the last point having abs(tp)<thres_tp in a region very close to
% the top.  Requires P to have a positive linear calibration coefficient.
%
% if alternative series are to be used, call as [ind,tog]=FIND_TOP('TP2','P2')
% 
% written by Jonathan Nash, Oct 1998
global data head

if exist('tp_ser','var')
  eval(['tp=data.' upper(tp_ser) ';'])
else
  tp=data.TP;
end
if exist('p_ser','var')
  eval(['p_const=.69*head.coef.' upper(p_ser) '(2);'])
  eval(['p=data.' upper(p_ser) ';'])
else
  p=data.P;
  p_const=.69*head.coef.P(2);
end

if size(p,2)==2
  p=ch(p);
end
if size(tp,2)==2
  tp=ch(tp);
end

% This is the tp threshold  (in volts)
thres_tp=.02;

% This is the distance between the pressure sensor and thermistor [m]
distance=0.22;

% This is the voltage offset between min(data.P) and where we first start
% to look for temperature signal:
thres_p=distance/(2*p_const); % the 2 gives half the distance between p and t.

% first decimate the tp series
tpp=tp(1:length(tp)/length(p):length(tp));

% Now the maximum possible index would be:
ind_max=min(find(p<(min(p)+thres_p)));

% now we find the last possible value of tp which is less than our
% threshold, as long as it isn't past the maximum possible index, as
% determined above. 
ind=max(find(abs(tpp(1:ind_max))<thres_tp));

% If this index is the last one, then we've failed:
if ind==ind_max
  tog='n';
else
  tog='y';
end
