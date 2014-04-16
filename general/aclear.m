function aclear(varargin)
% ACLEAR 'Anti' clear
% Clears all variables except for those specified.
% 
% ACLEAR has three forms:
% ACLEAR var1 var2 var3
% ACLEAR({'var1' 'var2' 'var3'})
% ACLEAR('var1','var2','var3')
% 
% Each of these forms will clear all variables in the current workspace
% EXCEPT for var1, var2 and var3. 
% 

if length(varargin)==1 && iscell(varargin{1})
  keep=varargin{1};
else
  keep=varargin;
end

% What variables exist:
vars=evalin('caller','who');

% What variables ARE we clearing?:
clr=setdiff(vars,keep);

if isempty(clr) % Nothing to clear.
  return
end

% Catenate the string:
str='clear';
for i0=1:length(clr)
  str=[str ' ' clr{i0}];
end

% Clear the variables:
evalin('caller',str)

