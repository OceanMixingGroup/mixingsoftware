function [avg,spec]=process_file(q);
% function [avg,spec]=process_file(q);
% process the file pointed to by fname....
% avg is the averaged aray.  Spec are some interesting spectra made
% along the way.
  

[data,head]=raw_load(q);
% trim out of sync data....
[data,bad]=issync(data,head);
if ~isempty(data.SYNC)
  % if there is some left, calibrate it
  cali_yq02_jmk_mg;
else
  avg=[];spec=[];
  return;
end;

% take some spectra of the calibrated data...

todo = {'S1','S2','S3','AX1','AY','AZ','W1'};

spec=takespectra(head,cal,todo,256);