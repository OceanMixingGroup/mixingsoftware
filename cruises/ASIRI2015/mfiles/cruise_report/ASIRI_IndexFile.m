%~~~~~~~~~~~~~~~~~~~~~~~~
%
% ASIRI_IndexFile.m
%
% Make an Index file with names, start and end times for instruments on
% AISIR 2015 cruise including ROSS, bow chain, etc.. Format copied from
% fctd section file that Drew made.
%
% Times taken from bridge log
%
%-----------
% 10/16/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

%~ Ross

ross.start=[201508240537,201508252342,201509050300,201509071143,201509071338,201509100312,201509101103,201509140416];
ross.stop=[201508250604,201508261137,201509051039,201509071235,201509080857,201509100828,201509101144,201509141523];

for whb=1:length(ross.start)
   Ross(whb).name=['Deploy' num2str(whb)];
   Ross(whb).st=datenum(num2str(ross.start(whb)),'yyyymmddHHMM');
   Ross(whb).et=datenum(num2str(ross.stop(whb)),'yyyymmddHHMM');
end


%~ Bowchain

bow.start=[201508240415,201508280550,201508291336,201509020913,201509040612,201509061132,201509090205,201509120349,201509151914,201509171107];
bow.stop=[201508270535,201508290900,201509020344,201509031330,201509060952,201509090024,201509110133,201509150340,201509170554,201509192347];

for whb=1:length(bow.start)
   Bow(whb).name=['Deploy' num2str(whb)];
   Bow(whb).st=datenum(num2str(bow.start(whb)),'yyyymmddHHMM');
   Bow(whb).et=datenum(num2str(bow.stop(whb)),'yyyymmddHHMM');
end

%~ ReelCTD (note Alldatatimes.m contained 2 more that are not in ships log?)
reel.start=[201508271018,201508301143,201509020248,201509041442];%,201509100312,201509140416];
reel.stop=[201508280220,201508301555,201509020312,201509041513];%,201509100828,201509141523];

for whb=1:length(reel.start)
   Reel(whb).name=['Deploy' num2str(whb)];
   Reel(whb).st=datenum(num2str(reel.start(whb)),'yyyymmddHHMM');
   Reel(whb).et=datenum(num2str(reel.stop(whb)),'yyyymmddHHMM');
end

%%

AIndex=struct('Bow',Bow,'Ross',Ross,'Reel',Reel)
AIndex.MakeInfo=['Made ' datestr(now) ' w/ ASIRI_IndexFile.m']
AIndex.Info='Instrument deployment times for August 2015 ASIRI Cruise on RV Revelle (RR1513). Times from bridge log .'
save('/Users/Andy/Cruises_Research/Asiri/Local/Asiri2015IndexFile.mat','AIndex')

%%