clear all;
set_nbadcp;                           
                           
cd(workdir);   
size1=0;size2=0;
while 1
    d1=dir([rawdir 'pingdata.*']);
    d2=dir([todir '\pingdata.*']);
    lend1=length(d1); lend2=length(d2);
    if isempty(d2)
        start=1;
    else
        if d1(lend2).bytes~=d2(lend2).bytes
            start=lend2;
        else
            start=lend2+1;
        end
    end
    % d = dirdiff([rawdir 'pingdata.*'],[todir '\pingdata.*']);

    for i=start:lend1
        % copyfile([rawdir d{i}],todir);
        eval(['!copy ' rawdir d1(i).name ' ' todir]);
    end;
  
    % process data...
    ii=[];p=[];
    d2=dir([todir '\pingdata.*']);
    if d2(end-1).bytes~size1
        ii=[ii str2num(d2(end-1).name(end-2:end))];
    end
    if d2(end).bytes~size2
        ii=[ii str2num(d2(end).name(end-2:end))];
    end
    size1=d2(end-1).bytes;size2=d2(end).bytes;
    d3=dir([transdir prefix '*']);
    for i=1:length(d2)
        r(i)=str2num(d2(i).name(end-2:end));
    end
    for i=1:length(d3)
        p(i)=str2num(d3(i).name(end-7:end-5));
    end
    iii=setdiff(r,p); iii=setdiff(iii,ii);
    iii=[ii iii];
    for i=iii
        ind=find(r==i);
        d2(ind).name
        % fnum = d{i}(end-2:end);
        fname = [todir '\' d2(ind).name]; 
        torun = sprintf('!%sxlate2 %s %s -fq150 -rpht -ra',xlatedir,fname,prefix) 
        eval(torun);
    end;     
    fprintf(1,'Pausing\n');
    for i=1:300
        pause(1)
    end;
end;