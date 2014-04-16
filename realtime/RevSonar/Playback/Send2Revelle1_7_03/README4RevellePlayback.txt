   
   1. Run Playback under OSX 10.2: use terminal
	% playback datafilename
	
	Important: Rember provide the full path of the application "playback" and "datafilename"
		 e.g: %/Users/guest/Send2Revelle1_7_03/playback /Users/guest/Data/140kHz_15jun01\[2001:252.788]
	    In order to do it, you have two ways:
	    Either: a. On The Finder window, click on application "playback" drag into terminal, 
                       press bar for a space and  click on data file name, drag it into the terminal for its parameter.
            Or:     b. In the terminal, type a full path name both of software name ("playback") and datafilename.  
                       Note: type "\" before "[" of the data file name.

	- The playback application will ask you input few parameters look like:
		What matfile do you want to be created?
		    "aux" file?        (1 for yes, 0 for no):  1            (enter 1 for example)
		    "covariance" file? (1 for yes, 0 for no):  1            (enter 1 for example)
		    "intensity" file?  (1 for yes, 0 for no):  1            (enter 1 for example)
		    "nomalized covariance" file? (1 for yes, 0 for no):  1  (enter 1 for example)
		Open data file for reading ...
		How many records do you want to read (from 0 ->  2430): 5    (enter 5 for example)
		How many records will be averaged into one ensemble (from 1 -> 2430): 1  (enter 1 for example)
	And finally, it prints out when it is done:
		Done for written auxdata data
		Done for written covariance data
		Done for written intensity data
		Done for written nomalized covariance data
 
	- The mat files will be stored in the same directory as the playback application.
	- In MatLab: load the matfile with the option -mat before plot or analyze them.

   2. Structure for mat file data (REVELLE Sonar): 
        example:
		plot(auxdata(index,sampleNumber));
	with index is defined:
	    A. Header file: 
                1  = Time mark; 		/* (float)((rh->timemark & 0xffff0000) >> 16);	high bytes*/
                2  = Time mark; 		/* (float)(rh->timemark & 0x0000ffff);	low bytes*/
                3  = Julian day;

		4  = avg_data->heading_cos;
		5  = avg_data->heading_sin;
		6  = avg_data->tss_pitch;
		7  = avg_data->tss_roll;									
		8  = avg_data->gps_navx;
		9  = avg_data->gps_navy;									
		10 = avg_data->gps_navz;
		11 = avg_data->gps_navt;
		12 = avg_data->gps_navxdot;
		13 = avg_data->gps_navydot;
		14 = avg_data->gps_navzdot;
		15 = avg_data->gps_navtdot;
		16 = avg_data->pdop;
		17 = avg_data->pressure_port;
		18 = avg_data->pressure_stbd;
		19 = avg_data->temperature_port;
		20 = avg_data->temperature_stbd;
		21 = avg_data->accel_port_for;
		22 = avg_data->accel_stbd_for;
		23 = avg_data->accel_port_aft;
		24 = avg_data->accel_stbd_aft;
		25 = avg_data->tss_vAccel;
		26 = avg_data->tss_hAccel;
		27 = avg_data->pcode_lat;
		28 = avg_data->pcode_lon;
		29 = avg_data->pcode_sog;
		30 = avg_data->pcode_cogT_cos;
		31 = avg_data->pcode_cogT_sin;
		32 = avg_data->pcode_time;
		33 = avg_data->pcode_flag;
		34 = avg_data->time_mark_year;
		35 = avg_data->pcode_lat_fraction;
		36 = avg_data->pcode_lon_fraction;
		37 = avg_data->ADU2_receive_time;
		38 = avg_data->ADU2_heading_cos;
		39 = avg_data->ADU2_heading_sin;
		40 = avg_data->ADU2_mrms;
		41 = avg_data->ADU2_brms;
		42 = avg_data->ADU2_attitude_reset_flag;

		43 -> 64 are unused
	   
	   B. Data:
		65 -> the end are data.	(except "auxdata" file only has 64 index)
