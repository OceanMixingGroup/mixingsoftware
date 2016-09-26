function SS=GetSSbathy(lonrange,latrange)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% SS=GetSSbathy(lonrange,latrange)
%
% Get Smith/Sandwell bathymmetry for a specified region.
%
% INPUT
%   - lonrange [minlon maxlon]
%   - latrange [minlat maxlat]
%
% OUTPUT
%
%   SS : Structure with bathymetry data
%     - depth [m]- matrix of depths (lat X lon)
%     - lat - Vector of lats
%     - lon - Vector of lons
%
% Calls:
%   - extract_1m.m
%
%-------------
% 07/21/12 A.Pickering  - andypicke@gmail.com
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

%addpath('/Users/Andy/Cruises_Research/Data/SmithSandwell/')

[bathy,vlat,vlon] = extract_1m([latrange lonrange],1);

SS=struct('depth',bathy,'lat',vlat,'lon',vlon);
SS.info=['Made ' date ];
SS.source='SmithSandwell';
SS.MakeInfo=['Made ' date ' w/ GetSSbathy.m'];

%%