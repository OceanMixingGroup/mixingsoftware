function [ newname ] = chivert( data1, data2 )
% CHIVERT concatonates data in two chipod files
%   Detailed explanation goes here

field = fieldnames(data1);
for i=1:length(field)
%     newname.P = vertcat(data1.P,data2.P)
     eval(['newname.' field{i} ' = vertcat(data1.' field{i} ',data2.' field{i} ');'])
end

