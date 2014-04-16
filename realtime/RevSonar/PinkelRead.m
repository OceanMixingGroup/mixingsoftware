function sonar = PinkelRead(fname);
% function sonar = PinkelRead(fname);
% read in Pinkel sonar data....
% 
% This routine reads in one file from the Revelle's Doppler Sonar and
% creates a Matlab structure of all the information.  
%
% See Also: RevGetBeamVels.m, RevBeamtoShip.m, RevAvgandTrim.m, and 

%
% File have a leader header and then a certain number of records.  Each
% record consists of a header, a covariance matrix, and an intensity
% matrix.
  

  fin = fopen(fname,'r','ieee-be');
  if fin<0
    error(sprintf('Could not open %s',fname));
  end;
  

  sonar = [];

  % this has the layout of the sonar file structures.  Based on
  % Playback/das.h and Playback/tds_utils.h.  The structures had to be
  % careful to take into account unpacked structures created by the Mac.
  sonarheaderlayouts
  % read the das header at the beginning of each file.   
  [m,n]=size(daslayout);
  for i=1:m
    sonar.dasinfo.(daslayout{i,2}) = fread(fin,daslayout{i,3},daslayout{i,1});
  end;
  
  % Now read each record.  Each record has a header (defined in
  % sonarheaderlayouts) a covariance matrix (nbeams x nbins x 2)
  % an intensity matrix (nbeams x nbins)
  % a normalized covariance matrix (nbeams x nbins x 2)
  % a signal to noise matrix (nbeams x nbins)
  % a janus mantrix (nbeams x nbins);
  sonar.head = [];
  
  num = 0;
  nbins = sonar.dasinfo.nbins;

  % preallocate.  This speeds thinsg up a lot.  If you make your files
  % bigger, increase this #...
  sonar.cov = NaN*ones(4,nbins*2,1000);
  sonar.covn = NaN*ones(4,nbins*2,1000);
  sonar.int = NaN*ones(4,nbins,1000);
  sonar.sn = NaN*ones(4,nbins,1000);
  % jan = NaN*ones(4,nbins,10000); % this is empty, so toss...  
  
  
  while ~feof(fin);
    num = num+1;
    if mod(num,10)==0
      fprintf(1,'.');
    end;
    % now read the first record header/data pair...
    [m,n]=size(headlayout);
    for i=1:m
      dat = fread(fin,headlayout{i,3},headlayout{i,1});
      if isempty(dat)
        % this happens because the Mac uses two characters for EOF...Ugh.
        num = num-1;
        % trim
        sonar.cov = sonar.cov(:,:,1:num);
        sonar.int = sonar.int(:,:,1:num);
        sonar.covn = sonar.covn(:,:,1:num);
        sonar.sn = sonar.sn(:,:,1:num);
        return;
      end;
      sonar.head.(headlayout{i,2})(:,num) = dat;  
    end;  

    dat=fread(fin,4*nbins*2,'float');
    sonar.cov(:,:,num) = reshape(dat,nbins*2,4)'; 
    sonar.int(:,:,num) = fread(fin,[nbins,4],'float')';
    sonar.covn(:,:,num) = fread(fin,[nbins*2,4],'float')';
    sonar.sn(:,:,num) = fread(fin,[nbins,4],'float')';
    jan = fread(fin,[nbins,4],'float');
    
  end;
  return;
