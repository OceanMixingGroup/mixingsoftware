% function [prefixRMC,timeRMC,ActiveRMC,lat,latdirRMC,lon,londirRMC,spdKnots,AngleDeg,DateRMC] = ReadGarmin(serGPS)
function [GPS_in] = ReadGarmin(serGPS)
% Reads a streaming GPS.   If no data, does not wait, returns nans.
%  Note that this code never crashes.   Even if the GPS unit dies or gets unplugged, or cant find satelites.  

% serial port must first be initialized using initializeGarmin
% inputs: serGPS (from initializeGarmin)
% Outputs:  x (lon) and y(lat) 
 
%%  initialize to nan, will have something to return even if serial comms fail
lat =nan; lon = nan; 
pause(1.2);
%% IF THERE IS NO DATA?
if (get(serGPS, 'BytesAvailable')==0)
    disp('Data not avail yet.   Try again or check transmitter.');
    return
end
 
%% IF THERE IS DATA
while (get(serGPS, 'BytesAvailable')~=0)
 try
    % read until terminator
    sentence = fscanf(serGPS, '%s');
    Ns = length(sentence);
    GPS_in = struct();
    
        % Make sure header is there
        if strcmp(sentence(1:6),'$GPRMC') 
            [prefixRMC,timeRMC,ActiveRMC,lat,latdirRMC,lon,londirRMC,spdKnots,AngleDeg,DateRMC] = strread(sentence, '%s%s%s%s%s%s%s%s%s%s', 1, 'delimiter', ',');
            
		%  these cases mean that the GPS can't find satelities 
  %  (status not equal to A (active)
  % or the sentence wasn't long enough to fill in lat and lon
            if isempty(lat)||(ActiveRMC{1} ~='A')
                lat = nan;
            end
            if isempty(lon)||(ActiveRMC{1} ~='A')
                lon = nan;
            end
        end
        
        if strcmp(sentence(1:6), '$GPGGA')
            F = sentence;
           
        end
        
           
  
catch ERR_MSG
      % if something didn't work correctly the error message displays
      disp('Error in GPS Data string! Retrying Again')
    
end
 
end
            GPS_in.time = timeRMC;
            GPS_in.lat = lat;
            GPS_in.latDir = latdirRMC;
            GPS_in.lon = lon;
            GPS_in.lonDir = londirRMC;
            GPS_in.speedKnts = spdKnots;
            GPS_in.AngleDeg = AngleDeg;
            GPS_in.date = DateRMC;
            GPS_in.F = F;   
          
            
%             fclose(serGPS);
%             delete(serGPS);
%             clear(serGPS);
