function cfg=MakeCtdConfigFromXMLCON(confile)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function cfg=MakeCtdConfigFromXMLCON(confile)
%
% Reads the Seabird .xmlcon CTD configuration file and create a structure
% 'cfg' with calibration coeffiencients needed to process the raw data.
%
% Currently only does temp and cond. (not oxygen etc.). Only tested for a
% few files, it is possible it won't work on others and we will need to
% make the code 'smarter'.
%
% Modified from ' load_CTD_coefficients' by J. Nash.
%
% 28 April 2015 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

D = parseXML(confile);

%%
if exist('coef','var')
    clear coef
end
coef=[];
for a=2
    for b=34
        BB=D.Children(a).Children(b);
        for c=2:2:26
            CC=BB.Children(c);
            for d=2
                DD=CC.Children(d);
                this_name=DD.Name;
                if isfield(coef,this_name)
                    coef.([this_name '1'])=coef.(this_name);
                    coef=rmfield(coef,this_name)
                    this_name=[this_name '2'];
                end
                for e=2:2:length(DD.Children)
                    EE=DD.Children(e);
                    if EE.Name(1)~='#';
                        if ~isempty(EE.Children)
                            try
                                coef.(this_name).(EE.Name)=eval(EE.Children(1).Data);
                            catch
                                coef.(this_name).(EE.Name)=EE.Children(1).Data;
                            end
                            if length(EE.Children)>1
                                for f=2:2:length(EE.Children)
                                    FF=EE.Children(f);
                                    if ~isempty(FF.Children)
                                        try
                                            if isfield(coef.(this_name).(EE.Name),FF.Name)
                                                disp(coef.(this_name).(EE.Name))
                                                FF.name
                                                paus
                                            end
                                            coef.(this_name).(EE.Name)
                                            FF.Name
                                            coef.(this_name).(EE.Name).(FF.Name)=eval(FF.Children(1).Data);
                                        catch
                                            coef.(this_name).(EE.Name).(FF.Name)=FF.Children(1).Data;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

%%

% ctd
cfg.ctdsn = '1';

x=coef.ConductivitySensor1;
% c1
cfg.c1sn = x.SerialNumber; %aw
cfg.c1date = x.CalibrationDate;
x=coef.ConductivitySensor1.Coefficients;
cfg.c1cal.ghij = [x.G x.H x.I x.J];
cfg.c1cal.ctpcor = [x.CTcor x.CPcor];


% t1
x=coef.TemperatureSensor1;
cfg.t1sn = x.SerialNumber; %aw
cfg.t1cal.ghij = [x.G x.H x.I x.J];
cfg.t1cal.f0 = x.F0;
cfg.t1date = x.CalibrationDate;

x=coef.ConductivitySensor2;
% c2
cfg.c2sn = x.SerialNumber; %aw
cfg.c2date = x.CalibrationDate;
x=coef.ConductivitySensor2.Coefficients;
cfg.c2cal.ghij = [x.G x.H x.I x.J];
cfg.c2cal.ctpcor = [x.CTcor x.CPcor];


% t2
% t1
x=coef.TemperatureSensor2;
cfg.t2sn = x.SerialNumber; %aw
cfg.t2cal.ghij = [x.G x.H x.I x.J];
cfg.t2cal.f0 = x.F0;
cfg.t2date = x.CalibrationDate;

% p
x=coef.PressureSensor;
cfg.psn = x.SerialNumber;	%AW
cfg.pcal.c = [x.C1 x.C2 x.C3];
cfg.pcal.d = [x.D1 x.D2];
cfg.pcal.t = [x.T1 x.T2 x.T3 x.T4 x.T5];
cfg.pcal.AD590 = [x.AD590M x.AD590B];
cfg.pcal.linear = [x.Slope x.Offset];
cfg.pdate = x.CalibrationDate;
%%
% oxygen ***JONATHAN Couldn't figure out this - I think we're using different calibration coefficients...)
% x=coef.OxygenSensor;
% cfg.oxsn = x.SerialNumber;
% cfg.oxdate = x.CalibrationDate;
% x=coef.OxygenSensor.CalibrationCoefficients;
% cfg.oxcal.soc = x.Soc;
% cfg.oxcal.boc = 0.0;
% cfg.oxcal.tcor = 0.0009;
% cfg.oxcal.pcor = 1.35e-004;
% cfg.oxcal.voffset = -0.5165;

%%
%%