function [out]=fillgap2d(in,dim)
%function [out]=fillgap(in,dim);
%fills gaps in 2D matrixes by linearly interpolating
% along dimension dim
% default dim=1;
% works with both real and complex vectors
%
% see also interp_missing_data, extrapolate_data, fillgap

if nargin<2
  dim=1;
end
out=NaN*in;
if dim==1
    for i=1:size(in,2)
        if any(imag(in(:,i)))
            good1=find(~isnan(real(in(:,i))));
            good2=find(~isnan(imag(in(:,i))));
            if length(good1)>1
                out(:,i)=complex(interp1(good1,real(in(good1,i)),[1:size(in,1)]),...
                    interp1(good2,imag(in(good2,i)),[1:size(in,1)]));
            else
                out(:,i)=in(:,i);
            end
        else
            good=find(~isnan(in(:,i)));
            if length(good)>1
                out(:,i)=interp1(good,in(good,i),[1:size(in,1)]);
            else
                out(:,i)=in(:,i);
            end
        end
    end
elseif dim==2
    for i=1:size(in,1)
        if any(imag(in(i,:)))
            good1=find(~isnan(real(in(i,:))));
            good2=find(~isnan(imag(in(i,:))));
            if length(good1)>1
                out(i,:)=complex(interp1(good1,real(in(i,good1)),[1:size(in,2)]),...
                    interp1(good2,imag(in(i,good2)),[1:size(in,2)]));
            else
                out(i,:)=in(i,:);
            end
        else
            good=find(~isnan(in(i,:)));
            if length(good)>1
                out(i,:)=interp1(good,in(i,good),[1:size(in,2)]);
            else
                out(i,:)=in(i,:);
            end
        end
    end
else
    disp('Only 2D matrixes are allowed! Data is left intact.')
end




