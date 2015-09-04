% Chamname = ['0';'0';'0';'0';];
function [out1,out2] = ChamFile(handles)
load ('C:\work\mixingsoftware\Chameleon2\Chamname.mat');
ch_sz = size(Chamname,1);
a = zeros(4,1);
for ii = 1:ch_sz
        a(ii) = str2num(Chamname(ii,1));
end
if (a(1)==9) && (a(2)==9) && (a(3)==9) && (a(4)==9) 
    print('threshold reached');

elseif (a(1)==9) && (a(2)==9) && (a(3)==9) && (a(4) < 9)
    a(1) = 0;
    a(2) = 0;
    a(3) = 0;
    a(4) = a(4)+1;
 

elseif (a(1)==9) && (a(2)==9) && (a(3)< 9) 
    a(3) = a(3)+1;
    a(1) = 0;
    a(2) = 0;
    

elseif (a(1)==9) && (a(2) < 9) 
       a(2) = a(2)+1;
       a(1) = 0;
elseif (a(1)<9)
       a(1) = a(1)+1;
end
Chamname = num2str(a);
out1 = sprintf('%s',Chamname(4));
out2 = sprintf('%s%s%s',Chamname(3),Chamname(2),Chamname(1));
save('C:\work\mixingsoftware\Chameleon2\Chamname.mat');
end

