function in=qv_space(in);
[i,j]=find(~in);
in(i,j)=in(i,j)+32;