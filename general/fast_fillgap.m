function [ out ] = fast_interp_missing_data( in, maxgap )
% This code linearly interpolates to fill in NaNs in an array.
%
% [ out ] = fast_interp_missing_data( in, maxgap )
%
% in     = input array (Nx1 or 1xN in size)
% maxgap = maximum number of NaNs over which to fill (if you want to
%          interpolate over ALL gaps, set maxgap = 1
% out    = output array (same size as 'in')
%
% this code does not extrapolate if there are NaNs at the ends of the array
%
% if you have a matrix, call this function within a for-loop, to loop through
% either column-wise or row-wise
%
% The goal is for this code to run much faster than other codes like
% interp_missing_data and fillgap by using the 'find' command way less
% often and by reducing the number of loops
%
% see also interp_misssing_data, extrapolate_data, fillgap, fillgap2d


N = length(in);
out = in;

% get a logical array that gives the positions of the NaNs
% NaNs == 0, goodvalues == 1
nanind = ~isnan(in);

% start at position 2 (because if position 1 is NaN we ignore it)
istart = 2;
while istart + maxgap < N
    % if position ii is a NaN...
    if nanind(istart) == 0
        % and if the NaNs following position ii span less than maxgap...
        if sum(nanind(istart:(istart+maxgap-1))) >= 1
            % find the position of the NaN before the next good data point
            iend = find(nanind(istart+1:end) == 1, 1, 'first') + istart - 1;
            % linearly interpolate between ii-1 to iend+1 to find values for
            % the NaNs that span from ii to iend
            gaplen = iend - istart + 1;
            fillvals = interp1([1 gaplen+2],in([istart-1 iend+1]),1:gaplen+2);
            % fillvals contains the good values before and after the NaNs
            out(istart:iend) = fillvals(2:end-1);
            
            % set the counter to be iend+2
            istart = iend + 2;
            
        % if the NaNs following ii span MORE than maxgap, 
        else
            % find the index after the NaNs with a good value
            istart = find(nanind(istart+1:end) == 1, 1, 'first') + istart;
            
        end
    % if position ii is NOT a NaN...    
    else
        % simply advance to the next position
        istart = istart + 1;        
    end
           
end


