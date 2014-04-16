function [pcb firmware osc u0 y c d t sensor]= headerfile( s_uchar )
y=zeros(1,3);
c=zeros(1,3);
d=zeros(1,2);
t=zeros(1,5);
pcb=0;
osc=0;
firmware=0;
u0=0;
printit=0;

% for i= 1: length(s_uchar)-1
%     if (s_uchar(i) < 32   )  ||  (s_uchar(i) > 126 ) s_uchar(i) =32;
%     end
%     tline(i)= cast(s_uchar(i) , 'char') ;
% end
% tline(length(s_uchar))= 0;
s_uchar(s_uchar<32 | s_uchar>126)=32;
tline=cast(s_uchar,'char');

s=  regexp(tline, 'qqq'  );
useroffset=s;  % related to length of typed user input
pcb=tline(1: s+2);
pcb(s+3)= 0 ;
if( printit) disp(sprintf('pcb= %s',pcb)); end

s=  regexp(tline, 'Version'  );
if( ~isempty(s)  )
    s2=  regexp(tline, ' Main '  );
    firmware= tline(s : s2-1);
    if( printit) disp(sprintf('firm= %s',firmware)); end
end

tag= 'Frequency:';  add= 'osc'; tag2='Sensor';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    s=s+ length(tag);
    s2=  regexp(tline, tag2  );
    osc= str2num(tline( s: s2-1));
    pp(add, osc, printit);
end


tag= '00B0:';  add= 'sensor'; tag2='00C0';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    sensor= parse2( tline, tag, tag2 );
    pp(add, sensor, printit);
end

tag= '01E0:'; add= 'u0'; tag2='01F0';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    u0= parse2( tline, tag, tag2 );
    pp(add, u0, printit);
end

tag= '01F0:'; add= 'y1'; tag2='0200';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    y(1)= parse2( tline, tag, tag2 );
    pp(add, y(1), printit);
end

tag= '0200:'; add= 'y1'; tag2='0210';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    y(2)= parse2( tline, tag, tag2 );
    pp(add, y(2), printit);
end

tag= '0210:'; add= 'y3'; tag2='0220:';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    y(3)= parse2( tline, tag, tag2 );
    pp(add, y(3), printit);
end


tag= '0220:'; add= 'c1'; tag2='0230:';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    c(1)= parse2( tline, tag, tag2 );
    pp(add, c(1), printit);
end

tag= '0230:'; add= 'c2'; tag2='0240:';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    c(2)= parse2( tline, tag, tag2 );
    pp(add, c(2), printit);
end

tag= '0240:'; add= 'c3'; tag2='0250:';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    c(3)= parse2( tline, tag, tag2 );
    pp(add, c(3), printit);
end


tag= '0250:'; add= 'd1'; tag2='0260:';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    d(1)= parse2( tline, tag, tag2 );
    pp(add, d(1), printit);
end

tag= '0260:'; add= 'd2'; tag2='0270:';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    d(2)= parse2( tline, tag, tag2 );
    pp(add, d(2), printit);
end

tag= '0270:'; add= 't1'; tag2='0280:';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    t(1)= parse2( tline, tag, tag2 );
    pp(add, t(1), printit);
end

tag= '0280:'; add= 't2'; tag2='0290:';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    t(2)= parse2( tline, tag, tag2 );
    pp(add, t(2), printit);
end

tag= '0290:'; add= 't3'; tag2='02A0:';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    t(3)= parse2( tline, tag, tag2 );
    pp(add, t(3), printit);
end


tag= '02A0:'; add= 't4'; tag2='02B0:';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    t(4)= parse2( tline, tag, tag2 );
    pp(add, t(4), printit);
end

tag= '02B0:'; add= 't5'; tag2='02C0:';
s=  regexp(tline, tag  );
if( ~isempty(s)  )
    t(5)= parse2( tline, tag, tag2 );
    pp(add, t(5), printit);
end


end

function [u]= prse (tline)
s=  regexp(tline, ':');
s2=tline(s+1:end);
s= strtrim(s2);
u= str2double(s);
end

function  pp ( name,  vfloat, printit)
if(printit)
    disp(sprintf('%s %f', name, vfloat));
end
end

function [u]= parse2 (tline, tag1, tag2)
s=  regexp(tline, tag1  );
s=s+ length(tag1);
s2=  regexp(tline, tag2  );
s3=tline(s: s2-1 );
s4= strtrim(s3);
u= str2double(s4);
end


