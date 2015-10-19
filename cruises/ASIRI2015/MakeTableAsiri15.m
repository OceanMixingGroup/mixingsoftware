%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% MakeTableAsiri15.m
%
% Make a latex table for ASIRI 2015 Deployments. Uses info from 
% Asiri2015IndexFile.mat (see ASIRI_IndexFile.m)
%
%-------------
% 10/17/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

load('Asiri2015IndexFile.mat')
 
gnames={'Bow','Ross','Reel'}; % instrument names
and=' & '; 
NL=' \hline ' ; % new line
clc

% loop through instruments
for whfld=1:length(gnames)
   
    disp([gnames{whfld} and and NL])
    
    Nrows=length(AIndex.(gnames{whfld}));
    
    % each deployment for this instrument
    for whrow=1:Nrows    
        disp([AIndex.(gnames{whfld})(whrow).name and datestr(AIndex.(gnames{whfld})(whrow).st) and datestr(AIndex.(gnames{whfld})(whrow).et) NL ])
    end
    
    disp([NL NL])
    
end

 %%