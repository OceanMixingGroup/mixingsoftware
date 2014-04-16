function st=gappy_std(in)

ind=find(~isnan(in));
st=std(in);