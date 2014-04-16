function ppodheader=pp6header(fid)
% function ppodheader=loadppodheader(fid)
% Read PPOD header data structure from opened file defined by fid
% and convert to mat  ppod header structure.
% Split out from Sasha's raw_load_ppod() by MJB on 5/16/12
% Read 7747 characters, although the header is actually 8192, some are 
% reserved at end
    [header position]=textscan(fid,'%c',7747);
    aa=char(header)';
   % now find the character position of the start of each field
    in0=strfind(aa,'qqq');
    in1=strfind(aa,'FirmwareVersion');
    in2=strfind(aa,'PPODSerialNumber:');
    in3=strfind(aa,'MainOscillatorFrequency:');
    in4=strfind(aa,'SensorCalibrationData');
    in5=strfind(aa,'00B0:');
    in6=strfind(aa,'00C0:');
    in7=strfind(aa,'01E0:');
    in8=strfind(aa,'01F0:');
    in9=strfind(aa,'0200:');
    in10=strfind(aa,'0210:');
    in11=strfind(aa,'0220:');
    in12=strfind(aa,'0230:');
    in13=strfind(aa,'0240:');
    in14=strfind(aa,'0250:');
    in15=strfind(aa,'0260:');
    in16=strfind(aa,'0270:');
    in17=strfind(aa,'0280:');
    in18=strfind(aa,'0290:');
    in19=strfind(aa,'02A0:');
    in20=strfind(aa,'02B0:');
    in21=strfind(aa,'02C0:');
    if ~isempty(in2)
        ppodheader.firmware=aa(in1+15:in2-1);
        ppodheader.pcb=aa(in2+17:in3-1);
    else
        ppodheader.firmware=aa(in1+15:in3-1);
        ppodheader.pcb=aa(in0-4:in0-1);
    end
    ppodheader.sensor=aa(in5+5:in6-1);
    % read the single U0 coefficient
    ppodheader.parocoefs.U0=str2num(aa(in7+5:in8-1));
    % read 3 Y coefficients
    ppodheader.parocoefs.Y=[str2num(aa(in8+5:in9-1)) ...
        str2num(aa(in9+5:in10-1)) str2num(aa(in10+5:in11-1))];
    % read 3 C Coefficients
    ppodheader.parocoefs.C=[str2num(aa(in11+5:in12-1)) ...
        str2num(aa(in12+5:in13-1)) str2num(aa(in13+5:in14-1))];
    % Read 2 D Coefficients
    ppodheader.parocoefs.D=[str2num(aa(in14+5:in15-1)) ...
        str2num(aa(in15+5:in16-1))];
    %  Read 5 T coefficients
    ppodheader.parocoefs.T=[str2num(aa(in16+5:in17-1)) ...
        str2num(aa(in17+5:in18-1)) str2num(aa(in18+5:in19-1)) ...
        str2num(aa(in19+5:in20-1)) str2num(aa(in20+5:in21-1))];
    % read the OSFREQ
    ppodheader.OSFREQ=str2num(aa(in3+24:in4-1));
end  %% of function pp6header 
                    
                    