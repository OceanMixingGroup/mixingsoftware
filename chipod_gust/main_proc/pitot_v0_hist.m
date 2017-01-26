function [V0] = pitot_v0_hist(W, cal, varargin)
%%  [V0] = pitot_v0_hist(W, cal, [do_plot])
%     
%     This function is meant to estimate V0 based on the maximum occurence (- 1cm/s)
%
%     INPUT
%        W      :  raw voltage of Pitot tube calibrated for T and P 
%        cal    :  calibration structure for Pitot voltage
%        do_plot: if 1 than shows a histogram
%
%     OUTPUT
%        V0    :  guess for V0 based on historgram of data 
%
%   created by: 
%        Johannes Becherer
%        Thu Nov 17 11:15:15 PST 2016


if nargin < 2                  
   do_plot = 0;
else
   do_plot = varargin{1};
end



 vals = [0:.002:2];

 [n,edges] = histcounts(W, vals);

 [nmax, i] = max(n);
 V0 = vals(i);

 % substract 1cm/s seems aitary but matches observations better
 V0 = V0 - 5/cal.Vs;


 if do_plot
    figure
      histogram(W, vals)
      hold all;
      plot([1 1]*V0, [0 1]*nmax, 'r');
   end


