function sb=read_seabird_for_chiTcalibration(varargin)
% function sb=read_seabird_for_Tcalibration(varargin)
% reads seabird ASCII files for calibration T sensors of Chipod
% input parameters are the file names of seabird data 
% there could be two files (for calibration of two thermistors T1 & T2),
% or one file

fname1=char(varargin(1));
fid1=fopen(fname1,'r');
sb.time1=[];
sb.t1=[];
sb.count1=[];
i=0;
k=0;
temp=1;
while ~feof(fid1)
    check=1;
    i=i+1;
    m=0;
    dd=textscan(fid1,'%s',1,'delimiter','\r');
    a=char(dd{:});
    if ~isempty(a)
        ts=datenum(a(end-18:end),'mm/dd/yyyy HH:MM:SS');
        junk=fgetl(fid1);
        while check
            temp=fgetl(fid1);
            k=k+1;m=m+1;
            if (temp(1)~='#' && temp(1)~='%')
                sb.t1(k)=str2num(temp);
                sb.count1(k)=i;
            else
                sb.t1(k)=str2num(temp(end-13:end-8));
                sb.count1(k)=i;
                a=temp;
                tf=datenum(a(14:33),'mm/dd/yyyy HH:MM:SS');
                check=0;
            end
        end
        sb.time1=[sb.time1 ts+(tf-ts)/(m-1).*[0:m-1]];
    else
        break
    end
end
fclose(fid1);
if length(varargin)==2 % two files
    fname2=char(varargin(2));
    fid2=fopen(fname2,'r');
    sb.time2=[];
    sb.t2=[];
    sb.count2=[];
    i=0;
    k=0;
    temp=1;
    while ~feof(fid2)
        check=1;
        i=i+1;
        m=0;
        dd=textscan(fid2,'%s',1,'delimiter','\r');
        a=char(dd{:});
        if ~isempty(a)
            ts=datenum(a(end-18:end),'mm/dd/yyyy HH:MM:SS');
            junk=fgetl(fid2);
            while check
                temp=fgetl(fid2);
                k=k+1;m=m+1;
                if (temp(1)~='#' && temp(1)~='%')
                    sb.t2(k)=str2num(temp);
                    sb.count2(k)=i;
                else
                    sb.t2(k)=str2num(temp(end-13:end-8));
                    sb.count2(k)=i;
                    a=temp;
                    tf=datenum(a(14:33),'mm/dd/yyyy HH:MM:SS');
                    check=0;
                end
            end
            sb.time2=[sb.time2 ts+(tf-ts)/(m-1).*[0:m-1]];
        else
            break
        end
    end
    fclose(fid2);
end

