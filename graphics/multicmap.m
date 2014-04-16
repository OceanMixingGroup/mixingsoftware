function [cmp,caxis1,caxis2,caxis3,caxis4,caxis5,caxis6]=...
  multicmap(arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10,arg11,arg12);
%
% MULTICMAP - concatenate as many as six colourmaps and calculate caxes.
%
% [cmp,caxis1,...,caxis6]=...
%     multicmap(cmp1,...,cmp6,caxis1,...caxis6);
%
% returns a concatenated colourmap cmp and the caxis that will need to be
% appended to each axis in order to get the mapping into the colormap to
% work properly.  
%
% i.e. 
%  >> [cmp,cax1,cax2]=multicmap(jet(64),bone(64),[1 10],[10 50]);
%  >> colormap(cmp);
%  >> subplot(2,1,1); surface(A); caxis(cax1);
%  >> subplot(2,1,2); surface(B); caxis(cax2);
%
%  should yield the images in A and B coloured by jet and bone respectively.
%  You will run into problems if A is greater than 10, or B is less than 50,
%  in which case it is advisable to trim the data before sending it to image
%  (or contour etc).  However, there is a buffer built into the colormap to
%  accomodate reasonable excursions from the caxis entry.
%
%  colorbar for subplot(2,1,1) should be difined as follows:
%  >> hcb=colorbar;
%  >> set(hcb,'ylim',[1 10]);
%  
%  where [1 10] are the original (before merging) caxes for subplot(2,1,2)
%
%  SEE ALSO:  COLORMAP SURFACE IMAGESC EXTCONTOUR JET (etc)
%  J. Klymak Jan 97
%  A. Perlin Jul 05 - the old version did not work in Matlab 7. This one
%  does work in Matlab 7. Hopefully it works in older versions too.
%  It also doesn't jume the memory
%######### EXAMPLE OF MULTICMAP USE #####################################
%        % make multicolormap 
%        close all;
%        [cmp,caxU,caxEPS,caxRi]=multicmap(redblue2,jet,jet,...
%            [-1 1],[-10 -6],[-1.2 0]); 
%
%        % this is necessary for merging colormaps
%        ind=find(adcp.u>1); adcp.v(ind)=1;
%        ind=find(adcp.u<-1); adcp.v(ind)=-1;
%        
%        ind=find(summ.EPSILON>10^(-6)); summ.EPSILON(ind)=10^(-6);
%        ind=find(summ.EPSILON<10^(-10)); summ.EPSILON(ind)=10^(-10);
%        
%        ind=find(summ.Ri>10^0); summ.Ri(ind)=10^0;
%        ind=find(summ.Ri<10^(-1.2)); summ.Ri(ind)=10^(-1.2);
%        
%        % plot multicolormap figure
%        figure(1);
%        colormap(cmp);
%      
%        subplot(3,1,1)
%        pcolor(adcp.x,adcp.depth,adcp.u); shading flat
%        caxis(caxU);
%        hcb=colorbar;
%        set(hcb,'ylim',[-1 1]);
% 	
%        subplot(3,1,2)
%        pcolor(sum.x,summ.depth,log10(sum.EPSILON)); shading flat
%        caxis(caxEPS);
%        hcb=colorbar;
%        set(hcb,'ylim',[-10 -6]);
% 	
%        subplot(3,1,3)
%        pcolor(sum.x,summ.depth,log10(sum.Ri)); shading flat
%        caxis(caxRi);
%        hcb=colorbar;
%        set(hcb,'ylim',[-1.2 0]);
 %######################################################################



close all;
nout=nargin/2;
if nargout ~= nout+1
  error(...
      'Usage:[cmp,caxis1,...,caxis4]=multicmap(cmp1,...,cmp4,caxis1,...caxis4)');
end;
for i=1:nout
  eval(['cmp',int2str(i),'=arg',int2str(i),';']);
  eval(['cax',int2str(i),'=arg',int2str(nout+i),';']);
end;

% first concatenate the colormaps...
cmp=[];
for i=1:nout
  eval(['cm=cmp',int2str(i),';']);
  [m,n]=size(cm);
  cmp=[cmp;cm];  
end;

CmLength   = size(cmp,1);% Colormap length
BeginSlot=0;EndSlot=0;
for i=1:nout
    eval(['cm=cmp',int2str(i),';']);
    eval(['ca=cax',int2str(i),';']);
    len=size(cm,1);
    BeginSlot=EndSlot+1;
    EndSlot=BeginSlot+len-1;
    CDmin=ca(1);
    CDmax=ca(2);
    eval(['caxis',int2str(i),'=newclim(BeginSlot,EndSlot,CDmin,CDmax,CmLength);']); 
end

function CLim = newclim(BeginSlot,EndSlot,CDmin,CDmax,CmLength)
%                Convert slot number and range
%                to percent of colormap
PBeginSlot    = (BeginSlot - 1) / (CmLength - 1);
PEndSlot      = (EndSlot - 1) / (CmLength - 1);
PCmRange      = PEndSlot - PBeginSlot;
%                Determine range and min and max 
%                of new CLim values
DataRange     = CDmax - CDmin;
ClimRange     = DataRange / PCmRange;
NewCmin       = CDmin - (PBeginSlot * ClimRange);
NewCmax       = CDmax + (1 - PEndSlot) * ClimRange;
CLim          = [NewCmin,NewCmax];

