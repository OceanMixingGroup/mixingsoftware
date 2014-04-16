function [out]=fillgap(in,extrap,method)
% function [out]=fillgap(in,extrap,method)
% fills gaps in data set by linearly interpolating
% works with both real and complex vectors
% extrap is an optional argument 
% if extrap=1, fillgap will extrapolate to NaN tails 
% using linear method (argument method=='linear')
% or closest not-NaN's
% if argument method is empty, closest not-NaN's will be used
%
% see also interp_missing_data, extrapolate_data, fillgap2d

if  nargin==1
    extrap=0;
end
if nargin==2
    method='closest';
end
if any(imag(in))
    good1=find(~isnan(real(in)));
    if length(good1)>=2
        good2=find(~isnan(imag(in)));
        if extrap==0
            out=complex(interp1(good1,real(in(good1)),[1:length(in)]),...
                interp1(good2,imag(in(good2)),[1:length(in)]));
        elseif extrap==1 && strmatch('cl',method)
            out=complex(interp1(good1,real(in(good1)),[1:length(in)]),...
                interp1(good2,imag(in(good2)),[1:length(in)]));
            s=max(good1(1),good2(1));
            if s>1
                out(1:s-1)=complex(real(out(s)),imag(out(s)));
            end
            s=min(good1(end),good2(end));
            if s<length(out)
                out(s+1:end)=complex(real(out(s)),imag(out(s)));
            end
        elseif extrap==1 && strmatch('li',method)
            out=complex(interp1(good1,real(in(good1)),[1:length(in)],'linear','extrap'),...
                interp1(good2,imag(in(good2)),[1:length(in)]),'linear','extrap');
        end
        if size(in,1)>size(in,2); out=out'; end
    else
        out=in;
    end
else
    good=find(~isnan(in));
    if length(good)>=2
        if extrap==0
            out=interp1(good,in(good),[1:length(in)]);
        elseif extrap==1 && ~isempty(strmatch('cl',method))
            out=interp1(good,in(good),[1:length(in)]);
            s=good(1);
            if s>1
                out(1:s-1)=out(s);
            end
            s=min(good(end));
            if s<length(out)
                out(s+1:end)=out(s);
            end
        elseif extrap==1 && ~isempty(strmatch('li',method))
            out=interp1(good,in(good),[1:length(in)],'linear','extrap');
        end
        if size(in,1)>size(in,2); out=out'; end
    else
        out=in;
    end
end




