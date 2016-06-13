function var=NANinterp(var,silent)
%function var=NANinterp(var,silent)
%Given a time series with NaN's, interpolate through the gaps.
%This works by finding the Nan's, repeatedly inspecting it for contiguous spans,
%and interpolating through these.  
%specify silent = 1 (default=0) to supress telling how many gaps were removed. 
%MHA 08/08/02
%
%
if nargin < 2
    silent=0;
end
%var=wind.uwnd(1:100);
%var=[NaN 1 2 1 NaN 3 3 NaN NaN 1 2];
%varold=var;
ind=find(isnan(var));



indg=find(~isnan(var));
if isempty(indg)
    return;
end
[m,n]=size(ind);
%This vector contains the list of the ind vector whose indices are contiguous. 
%disp(['Series contains ' num2str(length(ind)) ' gaps.'])
%Start with the first gap
counter=0;
while ~isempty(ind)
    c=1;
    %Then the point before must be good
    i1=ind(c)-1;
    %Then find the next good point
    i2=indg(min(find(indg>ind(c))));
    
    if i1==0
        %fill in the first value
        var(i1+1:i2-1)=var(i2);
    elseif isempty(i2)
        var(i1+1:end)=var(i1);
    else
        %interpolate the values between
        nbad=length((i1+1:i2-1));
        var(i1+1:i2-1)=var(i1)+(1:nbad)/(nbad+1)*(var(i2)-var(i1));
    end
    %now 
    ind=find(isnan(var));
    indg=find(~isnan(var));
    counter=counter+1;
    %Then repeat
end

if silent == 0
disp(['Removed ' num2str(counter) ' gaps.'])
end
%plot((1:length(var)),var,(1:length(var)),varold)
