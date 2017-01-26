function [X] = qbutter(X,coff,varargin)
%% [X] = qbutter(X,coff) 
%   provides a quick low-pass filter on X with the cut-off-frequenzy coff
%   considering only the non-nan values in X
% [X] = qbutter(X,coff,'high')
%   provides a quick high-pass
% [X] = qbutter(X,clow, chigh)
%   bandpassfilter 

if(coff>=1)  % incase the cutoff is 1 than don't do any filtering
    return
end 

X = double(X);  % convert X to double
mask = ~isnan(X);
do_filt = sum(mask)>=6; % there need to be at least 6 good data points in the time series

switch nargin
    case 2
        [b,a] = butter(2,coff,'low');
         if do_filt
            X(mask) = filtfilt(b,a,X(mask));  
         end
    case 3
        if(varargin{1} == 'high')
            [b,a] = butter(2,coff,'high');
            if do_filt
               X(mask) = filtfilt(b,a,X(mask));  
            end
              X(mask) = filtfilt(b,a,X(mask));
        elseif( isnumeric(varargin{1}) & varargin{1}<coff )
            [b,a] = butter(2, [varargin{1} coff]);
            if do_filt
               X(mask) = filtfilt(b,a,X(mask));  
            end
        else
            disp('!!!!!!!!!!!Wrong INPUT ARGUMENTS!!!!!!!!')
        end
    otherwise
        disp('!!!!!!!!!!!wrong number of INPUT ARGUMENTS!!!!!!!!')
end 
