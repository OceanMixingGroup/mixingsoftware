function response=my_filter(b,freqs);
% function to use to compute nonlinear transfer functions using
% beta is a four element argument where b(1) is the order of the first
% filter, b(2) is its cutoff frequency,  b(3) is the order of the second
% filter, b(4) is its cutoff frequency; If b is a 2-element vector, we
% apply just one filter.
%   $Revision: 1.1.1.1 $  $Date: 2008/01/31 20:22:42 $
% Originally J.Nash

    if length(b)==2
      b(3)=1;,b(4)=Inf;
    end
    
    n_order1=b(1);
    n_order2=b(3);
    f_cut1=b(2);
    f_cut2=b(4);
    out=ones(size(freqs))./(1+(freqs./f_cut1).^(2*n_order1));
    response=out./(1+(freqs./f_cut2).^(2*n_order2));
    
