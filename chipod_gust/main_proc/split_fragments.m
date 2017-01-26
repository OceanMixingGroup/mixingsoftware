function [I] = split_fragments(J, Nf,  varargin)
%  [I] = split_fragments( J, Nf, [No])
%     
%     This function is meant to split up all index seqments in J in pieces of size Nf
%     allowing for overlap No
%
%     INPUT
%        J     :  cell array of indecies
%        Nf    :  desired min length of consecutive index arrays
%        No    :  overlap of individual arrays (default = 0)
%        
%     OUTPUT
%        I     :  cell array of indecies of size [ Nf < length(I{i}) < 2Nf ]
%
%   created by: 
%        Johannes Becherer
%        Fri Nov 18 11:14:25 PST 2016

% define overlap
if nargin < 3                  
   No = 0;
else
   No = floor(varargin{1});
end

% catch endless loops
if No >= Nf
   warning('overlap is larger than segment length -> overlap set to 0')
   No = 0;
end

%_____________________run through input cell array______________________
i = 1;
if ~isempty(J)
   for j = 1:length(J)
      
      Nj = length(J{j});

      % check if index chain is at least Nf long
      if Nj>=Nf

         % find out how many segments fit
         Ns   = 1 + floor((Nj - Nf)/(Nf-No));

         % loop through sub-segments
         for is = 1:(Ns-1)
            I{i} = J{j}( [1:Nf] +(Nf-No)*(is-1) );
            i    = i+1;
         end

         % last sub-segment gets remaining indecies is becomes a thus a bit longer
         I{i} = J{j}( [( (Nf-No)*(Ns-1) +1 ):end] );
         i    = i+1;

            
      end

   end
else
   I = [];
end

