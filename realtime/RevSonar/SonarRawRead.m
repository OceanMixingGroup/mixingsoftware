function sonar = PinkelRread(fname);
% function sonar = PinkelRread(fname);
% read in Pinkel sonar data....
%
% File have a leader header and then a certain number of records.  Each
% record consists of a header, a covariance matrix, and an intensity
% matrix.
  

  fin = fopen(fname,'r','ieee-be');

  sonar = [];

  sonarheaderlayouts
  % read the das header at the beginning of each file.   
  [m,n]=size(daslayout)
  for i=1:m
    sonar.dasinfo.(daslayout{i,2}) = fread(fin,daslayout{i,3},daslayout{i,1});
  end;

  % error four bits! Why?
  fread(fin,4,'char')
  
  pos = ftell(fin)  
  sonar.head = [];
  
  num = 0;
  nbins = sonar.dasinfo.nbins;

  cov = NaN*ones(4,nbins*2,1000);
  covn = NaN*ones(4,nbins*2,1000);
  int = NaN*ones(4,nbins,1000);
  sn = NaN*ones(4,nbins,1000);
  % jan = NaN*ones(4,nbins,10000); % this is empty, so toss...
  
  % preallocate...
  
  while ~feof(fin);
    fprintf(1,'.');
    num = num+1;
    
    % now read the first record header/data pair...
    [m,n]=size(headlayout);
    for i=1:m
      
      dat = fread(fin,headlayout{i,3},headlayout{i,1});
      if isempty(dat)
        num = num-1;
        keyboard;
        return;
      end;
      sonar.head.(headlayout{i,2})(:,num) = dat;  
    end;  
    extra = sonar.dasinfo.rec_header_size-sonar.dasinfo.rheadersize;
    % fread(fin,extra,'char')
    dat=fread(fin,4*nbins*2,'float');
    sonar.cov(:,:,num) = reshape(dat,nbins*2,4)'; 
    sonar.int(:,:,num) = fread(fin,[nbins,4],'float')';
    sonar.covn(:,:,num) = fread(fin,[nbins*2,4],'float')';
    sonar.sn(:,:,num) = fread(fin,[nbins,4],'float')';
    jan = fread(fin,[nbins,4],'float');
%    ftell(fin)-3976
%    sonar.dasinfo.reclength
    
  end;
    keyboard;
  return;
