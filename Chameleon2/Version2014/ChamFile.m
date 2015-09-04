% Chamname = ['0';'0';'0';'0';'0'];
function [out1,out2] = ChamFile(handles)
load ('Chamname.mat');
ch_sz = size(Chamname,1);
a = zeros(5,1);
for ii = 1:ch_sz
        a(ii) = str2num(Chamname(ii,1));
end
if (a(1)==9) && (a(2)==9) && (a(3)==9) && (a(4)==9) && (a(5) == 9)
    print('threshold reached');

elseif (a(1)==9) && (a(2)==9) && (a(3)==9) && (a(4) == 9) && (a(5)<9)
    a(1) = 0;
    a(2) = 0;
    a(3) = 0;
    a(4) = 0;
    a(5) = a(5)+1;

elseif (a(1)==9) && (a(2)==9) && (a(3)== 9) && (a(4)<9)
    a(4) = a(4)+1;
    a(1) = 0;
    a(2) = 0;
    a(3) = 0;

elseif (a(1)==9) && (a(2)==9) && (a(3) <9)
        a(3) = a(3)+1;
        a(2) = 0;
        a(1) = 0;
elseif (a(1) == 9)&& (a(2) <9)
    a(2) = a(2)+1;
    a(1) = 0;
elseif (a(1)<9)
    a(1) = a(1)+1;
        
end
Chamname = num2str(a);
out1 = sprintf('%s%s',Chamname(5),Chamname(4));
out2 = sprintf('%s%s%s',Chamname(3),Chamname(2),Chamname(1));
save('Chamname.mat');
end

