
  headlayout = {
      'long' 			'rec_num' 1;
      'unsigned long'		'timemark' 1;	%	/*	timemark from hydra sonar record*/
      'unsigned long'		'host_time' 1;	%	/*	from time_address*/
      'long' 			'timestatus' 1;	 %	/*	tests if ...   
      % processing_status:
      'unsigned long'	'stat_0' 1;
      'unsigned long'	'stat_1'  1;
      'unsigned long'	'stat_2' 1;
      'unsigned long'	'stat_3' 1;
      'unsigned long'	'stat_4' 1;
      'unsigned long'	'stat_5' 1;
      'unsigned long'	'stat_6' 1;
      'unsigned long'	'stat_7' 1;
      'long'			'ptime_0' 1;	%/*	process times*/
      'long'			'ptime_1' 1;
      'long'			'ptime_2' 1;
      'long'			'ptime_3' 1;
      'long'			'ptime_4' 1;
      'long'			'ptime_5' 1;
      'long'			'ptime_6' 1;
      'long'			'ptime_7' 1;
      'float'			'channel_mean' 10;
      'float'			'channel_eq' 5;
      'float'			'mean_cov' 10 ;
      'unsigned long'	'timemark' 1;	% /*	timemark for motion correction*/
      'float'			'pitch' 1;
      'float'			'roll' 1;
      'float'			'cos_heading' 1;
      'float'			'sin_heading' 1;
      'long'			'spare' 6;
    % TDS_Data		data;	
      'unsigned long'	'packet_ID' 1;
      'unsigned long'	'time_mark' 1;
      'unsigned long'	'time_host' 1;
      'long'			'time_mark_year' 1;
      'short'			'pkt_period_ms' 1;
      'short'                   'boo' 1;
      'long'			'gps_rcvtime' 1;		%/*	milliseconds of week of GPS time*/
      'double'			'gps_navx' 1;	%/*	antenna pos ECEF x coordinate in meters (Earth Centered, Earth Fixed == ECEF)*/
      'double'			'gps_navy' 1;			%/*	antenna pos ECEF y coordinate in meters*/
      'double'			'gps_navz' 1;			%/*	antenna pos ECEF z coordinate in meters*/
      'float'			'gps_navt' 1;			%/*	receiver clock offset in meters*/
      'float'			'gps_navxdot' 1;		%/*	antenna x velocity in meters per second*/
      'float'			'gps_navydot' 1; 		%/*	antenna y velocity in meters per second*/
      'float'			'gps_navzdot' 1;		%/*	antenna z velocity in meters per second*/
      'float'			'gps_navtdot' 1; 		%/*	receiver clock drift in meters per second*/
      'unsigned short'	'pdop' 1;				%/*	PDOP * 100	(PDOP == )*/
      'unsigned short'	'boo' 1;				%/*	PDOP * 100	(PDOP == )*/
      'float'			'heading_cos' 1;
      'float'			'heading_sin' 1;
      
      'float'			'accel_port_for' 1;		%/*	¡ Tilt from vertical*/
      'float'			'accel_stbd_for' 1;		%/*	¡ Tilt from vertical*/
      'float'			'accel_port_aft' 1;		%/*	¡ Tilt from vertical*/
      'float'			'accel_stbd_aft' 1;		%/*	¡ Tilt from vertical*/
      'float'			'openA2D1' 1;			%/*	volts*/
      'float'			'openA2D2' 1;			%/*	volts*/
      'float'			'pressure_port' 1;		%/*	volts*/
      'float'			'pressure_stbd' 1;		%/*	volts*/
      'float'		'temperature_port' 1;	%/*	¡C*/
      'float'			'temperature_stbd' 1;	%/*	¡C*/
      'float'			'temperature_spare' 1;	%/*	¡C*/
      'float'			'tss_pitch' 1;
      'float'			'tss_roll' 1;
      'float'			'tss_heave' 1;
      'float'			'tss_vAccel' 1;
      'float'			'tss_hAccel' 1;
      'float'			'pcode_lat' 1; 		%/*	ddmm.mmmm*/
      'float'			'pcode_lon' 1;		%/*	ddmm.mmmm*/
      'float'			'pcode_sog' 1;		%/*	cm/s*/
      'float'			'pcode_cogT_cos' 1;	%/*	degrees, true*/
      'float'			'pcode_cogT_sin' 1;	%/*	degrees, true*/
      'float'			'pcode_time' 1;		%/*	hhmmss.ss*/
      'long'			'pcode_flag' 1;		%/*	0: not navigating, 2: cdma (low res), 3: pcode (high res)*/
      'float'			'pcode_lat_fraction' 1;
      'float'			'pcode_lon_fraction' 1;
      'float'			'ADU2_receive_time' 1;	%/*ashtech ADU2 GPS receive time in seconds*/
      'float'			'ADU2_heading_cos' 1;	%/*ashtech ADU2 heading cosine*/
      'float'			'ADU2_heading_sin' 1;	%/*ashtech ADU2 heading cosine*/
      'float'			'ADU2_pitch' 1;			%/*ashtech ADU2 pitch in degrees*/
      'float'			'ADU2_roll' 1;			%/*ashtech ADU2 pitch in degrees*/
      'float'			'ADU2_mrms' 1;			%/*ashtech ADU2 measurement RMS error in meters*/
      'float'			'ADU2_brms' 1;			%/*ashtech ADU2 baseline RMS error in meters*/
      'float'			'ADU2_attitude_reset_flag' 1; %/*ashtech ADU2 attitude reset flag*/
      'double'			'pcode_dlat' 1;
      'double'			'pcode_dlon' 1;
               };
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5  
  
  daslayout = {
      'long'			'das_serialNum' 1;	%	/*	serial number*/
      'ulong'		'time' 1;			%	/*	time*/
      'long'			'dasrec_size' 1;	%	/*	header
      'long'			'rec_header_size' 1;	%/*	record header size (bytes)*/
      'long'			'reclength' 1;			%/*	record size (bytes)*/
      'char'			'run_name' 76;
      'long'			'sample_period' 1;		%/*	sample periods in milliseconds*/
      'long'			'seq_length' 1;		%	/*	sequence length (samples)*/
      'long'			'ad_samples' 1;		%	/*	# of samples to record*/
      'long'			'n_seq' 1; 			%	/*	# of sequences per ensemble*/
      'long'			'n_ensmb' 1;		%	/*	# of ensembles to record*/
      'long'			'xmitfreq' 1;		%	/*	transmit frequency, hz*/
      'long'			'mixfreq' 1;		%	/*	mixer frequency, hz	*/
      'long'			'n_modes' 1;		%	/*	# of modes, currently  one mode*/
      'long'			'n_aux' 1;			%	/*	# of auxillary controls*/
      'long'			'rec_sens' 1;		%	/*	1 = record sensors*/
      'long'			'rec_janus' 1;		%	/*	1 = record janus doppler*/
      'long'			'rec_slant' 1;		%	/*	1 = record slant doppler*/
      'long'			'rec_raw' 1;		%	/*	1 = record raw data*/
      'char'			'run_notes' 1024;	%/*	run notes*/
      'long'			'nx' 1;				%	/*	# of xducers, from start-up file*/
      'long'			'x' 16;			%	/*	active xducers (A/D channel)*/
      'long'			'databuffsize' 1;		%/*	size of data buffer    */
      'long'			'rheadersize' 1;		%/*	size of rheader*/
      'long'			'envbuffsize' 1;		%/*	environmental data buffer size*/
      'long'			'relay_delay' 1;
      'long'			'autorelay' 1;
      'char'			'TDS_on' 1;		%/* use char for Boolean type - 1/9/02 MNB*/
      'char'			'TDS_sync' 1;	
      'char'                    'junk' 2;
      'long'			'n_time_marks' 1;		%/*	number of time marks per sequence*/
      'long'			'TDSrecs' 1;		%/*	number of TDS records appended to each data record*/
      'long'			'TDSbuffsize' 1;
      'long'			'TDS_hold_off' 1;	%/*	number of milliseconds to hold off at the end of the sequence*/
      'long'			'sync_mode' 1;	%/*	controller sync mode -- 0: no sync 1: standard sync */
      'long'			'post_xmt_gate_delay' 1;
      'long'			'xtal_freq' 1;
  % struct			mode m;
      'long' 'start_time' 1;      %  /*	transmit start time*/
      'long' 'bit_width' 1;       %  /*	transmit bit width*/
      'char' 'code' 32;          %/*	transmit code string*/
      'long' 'tone_reps' 1;       %  /*	transmit repeats*/
      'long' 'trep_period' 1;     %  /*	transmit repeat period      */
      'long' 'n_bits' 1;          %  /*	code length*/
      'long' 'code_reps' 1;      %   /*	 # of subcode repeats*/
      'long' 'lagzero' 1;           %/*	1 = calculate time lag zero*/
      'long' 'nsamp' 1;             %/*	 # of AD samples to process*/
      'long' 'ncsamp' 1;            %/*	number of complex samples (.5*nsamp)*/
      'long' 'tlag' 1;              %/*	time lag (code bits)*/
      'long' 'ravg' 1;              %/*	 # of AD samples per range bin*/
      'long' 'nbins' 1;             %/*	 # of range bins*/
      'long' 'incoffset' 1;         % /*	offset (bytes) to start of incoherent covariances*/
      'long' 'incsize' 1;           % /*	size (elems) of incoherent covariance buffer*/
      'long' 'covsize' 1;          % /*	size (elems) of covarince
                                   % buffers*/
      
      'long'  'junk' 1;
      'float' 'bin_size' 1;		%	/*	range bin size in meters*/
      'long' 'intsize' 1;		%	/*	size of intesity buffer(elements)*/
      'long' 'bit_smoothing_fact' 1;
      'long' 'dac_slct' 1;
      'long' 'gate_slct' 1;
      'long' 'sn_size' 1;
      'long' 'jan_size' 1;
      'long' 'filter_type' 1;	%/* M.A.G 8/23/00 selector for which filter to use 0 for no filter 1 for cheby etc*/
      'long' 'baseband_type' 1;%	/* M.A.G 8/23/00  selector for which baseband to use*/
      'long' 'spare8' 1;
      'long' 'spare9' 1;
      'long' 'spare10' 1;
      'long' 'spare11' 1;
      'long' 'spare12' 1;	
      'long' 'spare13' 1;
      'long' 'spare14' 1;
      'long' 'spare15' 1;
      'long' 'spare16' 1;
  %%% This is the aux structure....   
  % these are the four aux structs...   
      'long' 'start_time1' 1;
      'long' 'pulse_width1' 1;
      'long' 'n_reps1' 1;
      'long' 'rep_period1' 1;
      'long' 'out_select1' 1;
      'long' 'spare1' 1;
      'long' 'spare2' 1;
      'long' 'spare3' 1;
      'long' 'spare4' 1;
      'long' 'spare5' 1;
      'long' 'spare6' 1;
      'long' 'spare7' 1;
      'long' 'spare8' 1;
      'long' 'start_time2' 1;
      'long' 'pulse_width2' 1;
      'long' 'n_reps2' 1;
      'long' 'rep_period2' 1;
      'long' 'out_select2' 1;
      'long' 'spare1' 1;
      'long' 'spare2' 1;
      'long' 'spare3' 1;
      'long' 'spare4' 1;
      'long' 'spare5' 1;
      'long' 'spare6' 1;
      'long' 'spare7' 1;
      'long' 'spare8' 1;
      'long' 'start_time3' 1;
      'long' 'pulse_width3' 1;
      'long' 'n_reps3' 1;
      'long' 'rep_period3' 1;
      'long' 'out_select3' 1;
      'long' 'spare1' 1;
      'long' 'spare2' 1;
      'long' 'spare3' 1;
      'long' 'spare4' 1;
      'long' 'spare5' 1;
      'long' 'spare6' 1;
      'long' 'spare7' 1;
      'long' 'spare8' 1;
      'long' 'start_time4' 1;
      'long' 'pulse_width4' 1;
      'long' 'n_reps4' 1;
      'long' 'rep_period4' 1;
      'long' 'out_select4' 1;
      'long' 'spare1' 1;
      'long' 'spare2' 1;
      'long' 'spare3' 1;
      'long' 'spare4' 1;
      'long' 'spare5' 1;
      'long' 'spare6' 1;
      'long' 'spare7' 1; 
      'long' 'spare8' 1;      
  %%% This is the env structure...
      'long' 'sample_period' 1;
      'long' 'n_channels' 1;
      'long' 'n_samples' 1;
      'long' 'autotime' 1;
      'long' 'n_eavg' 1;
      'long' 'slot' 1;
      'long' 'burstrate' 1;
      'long' 'adin' 1;
      'long' 'ext_trig' 1;
      'long' 'ext_clock' 1;
      'long' 'ext_sync' 1;
      'long' 'gain' 16;
      'char' 'descript' 16*32;
  % hware structure
      
      'ulong'	'recv_param' 1; %/*	receiver cal & power control word*/
      'long'			'recv_param_enable' 1;
  % end hware...    
      'char'			'sizeplotstruct' 1200;	%/* 1/9/02*/   
  % motion structure...'
      'float' 'heading_offset' 1;
      'float' 'tilt_offset1' 1;
      'float' 'tilt_offset2' 1;
      'float' 'tilt_cal1' 1;
      'float' 'tilt_cal2' 1;
      'float' 'vcalib' 1;
      'float' 'jcal1' 1;
      'float' 'jcal2' 1;
      'long' 'mvflag' 1;
      'long' 'snflag' 1;
      'long' 'dmflag' 1;
      'long' 'senseflag' 1;
      'long' 'compassflag' 1;
      'long' 'nsamps' 1;	
      'long' 'interval' 1;	
  % dnoise_params 
      'long' 'rmin' 1;		
      'long' 'rmax' 1;		
      'float' 'tfilt' 1;
  % demean_params
      'long' 'smin' 1;		
      'long' 'smax' 1;		
      'float' 'tfilt' 1;		
  % mean_vel....
      'long' 'smin' 1;	%			/*	min sample % of  full range*/
      'long' 'smax' 1;	%			/*	max sample % of  full range*/
      'float' 'tfilt' 1;
      'long'			'coprcsr_installed' 1;	%/*	whether or not have a coprocessor board*/
      'long'			'testDataMode' 1;		%/*	generate test data*/
      'long'			'cntrlr_installed' 1;
      'long'			'warnmin' 1;
      'ulong'	        'start_DateTime' 1;		%/*	run start time*/
      'char'			'sodad_version_str' 25;
      'char'			'hydra_version_str' 25;
      'char'          'junk' 2;
  % Hardware params
      'ulong'		'physicalRAM' 1;%	/*	amount of physical RAM present in computer*/
      'long'				'numBuffs2Alloc' 1;
      'long'				'minBuffs2Alloc' 1;
  % Serial Heading
      'short'	'qlink' 1;
      'short'	'slot' 1;
      'short'	'port' 1;
      'short'	'baud' 1;
      'short'	'drv_refnum' 1;
      'short'	'drv_refnum_out' 1;
      'char'	'ser_buf_place' 1;
      'char'    'junk' 1;
      'short'	'kill' 1;
      'short'	'InitDone' 1;
      'short'	'ioBuffer_Read' 1;
  % controller params...
      'short'			'portNum' 1; %/*	0 modem port, 1 printer port*/
      'ushort'	'baudRate' 1;	%/*	1200 == 1200, etc.*/
                                        % 'cntrlr_stat		cont_stat;
      'long'	'status' 1;
      'long'	'power' 16;
      'long'	'seq_num' 1;
      'long'	'power_level' 2;
      
  %    'beam_seg_params	segment_param[NBEAMS];
      'float'	'seg0_weight1' 1;
      'float'	'seg1_weight1' 1;
      'float'	'seg2_weight1' 1;
      'float'	'seg3_weight1' 1;
      'float'	'seg0_phase1' 1;
      'float'	'seg1_phase1' 1;
      'float'	'seg2_phase1' 1;
      'float'	'seg3_phase1' 1;
      'float'	'seg0_weight2' 1;
      'float'	'seg1_weight2' 1;
      'float'	'seg2_weight2' 1;
      'float'	'seg3_weight2' 1;
      'float'	'seg0_phase2' 1;
      'float'	'seg1_phase2' 1;
      'float'	'seg2_phase2' 1;
      'float'	'seg3_phase2' 1;
      'float'	'seg0_weight3' 1;
      'float'	'seg1_weight3' 1;
      'float'	'seg2_weight3' 1;
      'float'	'seg3_weight3' 1;
      'float'	'seg0_phase3' 1;
      'float'	'seg1_phase3' 1;
      'float'	'seg2_phase3' 1;
      'float'	'seg3_phase3' 1;
      'float'	'seg0_weight4' 1;
      'float'	'seg1_weight4' 1;
      'float'	'seg2_weight4' 1;
      'float'	'seg3_weight4' 1;
      'float'	'seg0_phase4' 1;
      'float'	'seg1_phase4' 1;
      'float'	'seg2_phase4' 1;
      'float'	'seg3_phase4' 1;
      'long'			'combine_segments' 1;
      'long' 			'UserLevel' 1;		%	/*	Simple User Interface == 1, Advanced == 0*/
      'long'			'PowerLevel' 1;		%	/*	Power Level last set in controller.*/
      'long'			'SonarType' 1;		%	/*	switch for sonar:  0 == 50kHz, 1 == 140 kHz*/
      'short'			'MaxPower' 1;
      'short'			'spare3' 1;
      'long'			'spare4' 1;
      'long'			'spare5' 1;
      'long'			'spare6' 1;
      'long'			'spare7' 1;
      'long'			'spare8' 1;
      'long'			'spare9' 1;
      'long'			'spare10' 1;
      'long'			'spare11' 1;
      'long'			'spare12' 1;
      'long'			'spare13' 1;
      'long'			'spare14' 1;
      'float'			'max_FileSize' 1;
              };

  
