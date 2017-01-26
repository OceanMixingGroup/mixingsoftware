function [x , M] = grid_instruments(Xs, Ms, xl, dx)
%%
%  
%     This function puts all the different vectors in Ms on
%     the same x vector starting at xl(1) and ending at xl(2)
%     wiht step width dx
%
%     INPUT
%        Xs{i}    :  Cell array with x vectors 
%        Ms{i}    :  Cell array with vlues vectors 
%        xl       :  xlims 
%        dx       :  step width
%
%     OUTPUT
%        x        :  xl(1):dx:xl(2)
%        M        :  matrix of values
%
%   created by: 
%        Johannes Becherer
%        Fri Sep 30 11:49:04 PDT 2016


%_____________________x vector______________________

x = xl(1):dx:xl(2);

%_____________________intrep data______________________

M = nan(length(x), length(Ms));

Ni = length(Ms);
for i=1:Ni
    ii = ~isnan(Ms{i});
   M(:,i) = interp1( Xs{i}(ii), Ms{i}(ii), x );   
end   
