function in=space(in);
% function in=space(in) changes zeros to 32 so that character strings
% defined in raw files as 0 will become ' '

[i,j]=find(~in);
in(i,j)=in(i,j)+32;