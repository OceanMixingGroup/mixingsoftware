function pathstr=MakeChiPathStr(Params)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function pathstr=MakeChiPathStr(Params)
%
% Return pathstr based on Params for CTD-chipod data
%
%--------------------
% 06/22/16 - A.Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% add in defaults?

pathstr=['zsm' num2str(Params.z_smooth) 'm_fmax' num2str(Params.fmax) 'Hz_respcorr' num2str(Params.resp_corr) '_fc_' num2str(Params.fc) 'hz_gamma' num2str(Params.gamma*100)];

%%