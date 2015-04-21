% ctd_switch
% switch T-C pairs

switch icast
  case 1
    % t1, c2 good
    c1 = data.c1;
    data.c1 = data.c2;
    data.c2 = c1;
    clear c1
end
