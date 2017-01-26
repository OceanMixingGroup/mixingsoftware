function A = moving_var_angle(v,ww,ws)
%% A = moving_average(M,ww,ws)
% the function calculates a moving variance (A) for the angle vektor (v) (rad)
% with the window width (ww)
% with the window step (ws)
%  length(A) = length(v)-ww

N = length(v);

A = nan(1,round((N)/ws));


if(N > ww)
    for i = 1:length(A)
      if((ww+(i-1)*ws)<=length(v))

         v_tmp = v((1:ww)+(i-1)*ws);
         m = mean_angle(v_tmp); 

         % put v_tmp between  M+-pi
         v_tmp(v_tmp>(m+pi))   = v_tmp(v_tmp>(m+pi))-2*pi;
         v_tmp(v_tmp<(m-pi))   = v_tmp(v_tmp<(m-pi))+2*pi;

         % calculate variance around mean
         A(i) = nanvar(v_tmp);
      end
    end
else
    disp('window width is larger than vector length')
end

end
