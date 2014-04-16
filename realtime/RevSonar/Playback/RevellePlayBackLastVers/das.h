/*
 *  das.h
 *  playback.pb
 *
 *  Created by mnbui on Wed Jan 09 2002.
 *  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __DAS__
#define __DAS__

#include	<string.h>
#include	<strings.h>
#include	<stdlib.h>
#include 	<memory.h>
#include 	<stdio.h>
/*#include	<err.h>
*/
#include	"data_param.h"

#define NBEAMS	4	/*for Revelle 45k Test Trip NEMA BOX SYSTEM, 4 beams*/

#define	NCHANNELS_50kHz		16
#define	NCHANNELS_140kHz	4

#define	SONAR_50kHz	0
/*#define	SONAR_140kHz	1
*/

/*	data processing structures and parameters*/

typedef struct mode{
	long start_time;        /*	transmit start time*/
	long bit_width;         /*	transmit bit width*/
	char code[32];          /*	transmit code string*/
	long tone_reps;         /*	transmit repeats*/
	long trep_period;       /*	transmit repeat period      */
	long n_bits;            /*	code length*/
	long code_reps;         /*	 # of subcode repeats*/
    long lagzero;           /*	1 = calculate time lag zero*/
	long nsamp;             /*	 # of AD samples to process*/
	long ncsamp;            /*	number of complex samples (.5*nsamp)*/
	long tlag;              /*	time lag (code bits)*/
	long ravg;              /*	 # of AD samples per range bin*/
	long nbins;             /*	 # of range bins*/
 	long incoffset;          /*	offset (bytes) to start of incoherent covariances*/
	long incsize;            /*	size (elems) of incoherent covariance buffer*/
	long covsize;           /*	size (elems) of covarince buffers*/
	float bin_size;			/*	range bin size in meters*/
	long intsize;			/*	size of intesity buffer(elements)*/
	long bit_smoothing_fact;
	long dac_slct;
	long gate_slct;
	long sn_size;
	long jan_size;
	long filter_type;	/* M.A.G 8/23/00 selector for which filter to use 0 for no filter 1 for cheby etc*/
	long baseband_type;	/* M.A.G 8/23/00  selector for which baseband to use*/
	long spare8;
	long spare9;
	long spare10;
	long spare11;
	long spare12;	
	long spare13;
	long spare14;
	long spare15;
	long spare16;		
}mode;
typedef struct hware{
	unsigned long	recv_param;/*	receiver cal & power control word*/
	long			recv_param_enable;	/*	receiver cal & power control word enable*/
}hware;

/*	auxilliary data structure (for tds data, a/d data, whatever) which will be*/
/*		included with each rheader*/
typedef struct aux_data{
	/*	ctd 1 data*/
	float			pressure_1;		/*	pressure*/
	float			temperature_1;	/*	temperature from built in thermistor*/
	float			conductivity_1;	/*	conductivity*/
	float			voltage1_1;		/*	temperature from aux thermistor*/
	float			freq_corr1_1;	/*	frequency correction 1*/
	float			freq_corr2_1;	/*	frequency correction 2*/
	/*	ctd 2 data*/
	float			pressure_2;		/*	pressure*/
	float			temperature_2;	/*	temperature from built in thermistor*/
	float			conductivity_2;	/*	conductivity*/
	float			voltage1_2;		/*	temperature from aux thermistor*/
	float			freq_corr1_2;	/*	frequency correction 1*/
	float			freq_corr2_2;	/*	frequency correction 2*/
	/*	precision nav data */
	float			cos_head;
	float			sin_head;
	float			tilt;
	float			roll;
	/*	gg24 data*/
	double			navx;			/*	antenna pos ECEF x coordinate in meters (Earth Centered, Earth Fixed == ECEF)*/
	double			navy;			/*	antenna pos ECEF y coordinate in meters*/
	double			navz;			/*	antenna pos ECEF z coordinate in meters*/
	float			navt;			/*	receiver clock offset in meters*/
	float			navxdot;		/*	antenna x velocity in meters per second*/
	float			navydot;		/*	antenna y velocity in meters per second*/
	float			navzdot;		/*	antenna z velocity in meters per second*/
	float			navtdot;		/*	receiver clock drift in meters per second*/
	float			pdop;			/*	PDOP * 100	(PDOP == )*/
	/*	ARL*/
	/*	accelerometers*/
	float			accel_x_port;
	float			accel_y_port;
	float			accel_x_stbd;
	float			accel_y_stbd;
	/*	ship's heading*/
	float			cos_heading;
	float			sin_heading;
	/*	spares*/
	float			spare[10];
}aux_data,*aux_dataPtr;

typedef struct processing_status{
	unsigned long	stat_0;
	unsigned long	stat_1;
	unsigned long	stat_2;
	unsigned long	stat_3;
	unsigned long	stat_4;
	unsigned long	stat_5;
	unsigned long	stat_6;
	unsigned long	stat_7;
	long			ptime_0;	/*	process times*/
	long			ptime_1;
	long			ptime_2;
	long			ptime_3;
	long			ptime_4;
	long			ptime_5;
	long			ptime_6;
	long			ptime_7;
	float			channel_mean[10];
	float			channel_eq[5];
	float			mean_cov[10];
	unsigned long	timemark;	/*	timemark for motion correction*/
	float			pitch;
	float			roll;
	float			cos_heading;
	float			sin_heading;
	long			spare[6];
}processing_status;

typedef struct rheader{
	long 			rec_num;
	unsigned long		timemark;		/*	timemark from hydra sonar record*/
	unsigned long		host_time;		/*	from time_address*/
	long 			timestatus;	 	/*	tests if buffer is synchronous */
	processing_status	p_status;
	TDS_Data		data;			/*	tds data*/
}rheader;

typedef struct aux{
	long start_time;
	long pulse_width;
	long n_reps;
	long rep_period;
	long out_select;
	long spare1;
	long spare2;
	long spare3;
	long spare4;
	long spare5;
	long spare6;
	long spare7;
	long spare8;
}aux;	
typedef struct env{
	long sample_period;
	long n_channels;
	long n_samples;
	long autotime;
	long n_eavg;
	long slot;
	long burstrate;
	long adin;
	long ext_trig;
	long ext_clock;
	long ext_sync;
	long gain[16];
	char descript[16][32];
}env;
typedef struct SerialHeading
	{
		short	qlink;
		short	slot;
		short	port;
		short	baud;
		short	drv_refnum;
		short	drv_refnum_out;
		char	*ser_buf_place;
		short	kill;
		short	InitDone;
		short	ioBuffer_Read;
}SerialHeading;

/* copy from "cmnstrct.h" file - 1/9/02 MNB*/
typedef	struct	cntrlr_stat
{
	long	status;
	long	power[16];
	long	seq_num;
	long	power_level[2];
}cntrlr_stat;

/* copy from "Controller.h" file - 1/9/02 MNB*/
typedef struct controller_params{
	short			portNum;/*	0 modem port, 1 printer port*/
	unsigned short	baudRate;	/*	1200 == 1200, etc.*/
	cntrlr_stat		cont_stat;
}controller_params;

typedef struct HardwareParams{			/*	new structure -- cpn*/
	unsigned long		physicalRAM;	/*	amount of physical RAM present in computer*/
	long				numBuffs2Alloc;
	long				minBuffs2Alloc;
	SerialHeading		heading;
	controller_params	controller_info;
}HardwareParams,*HardwareParamsPtr;

typedef struct	YearDay{
	long	year;
	float	day;
} YearDay, *YearDayPtr;

/*	Global Data for entire SECS system*/
typedef struct dasrec{
    long			das_serialNum;		/*	serial number*/
    unsigned long		time;				/*	time*/
    long			dasrec_size;		/*	header size */
    long			rec_header_size;	/*	record header size (bytes)*/
    long			reclength;			/*	record size (bytes)*/
    char			run_name[76];
    long			sample_period;		/*	sample periods in milliseconds*/
    long			seq_length;			/*	sequence length (samples)*/
    long			ad_samples;			/*	# of samples to record*/
    long			n_seq; 				/*	# of sequences per ensemble*/
    long			n_ensmb;			/*	# of ensembles to record*/
    long			xmitfreq;			/*	transmit frequency, hz*/
    long			mixfreq;			/*	mixer frequency, hz	*/
    long			n_modes;			/*	# of modes, currently  one mode*/
    long			n_aux;				/*	# of auxillary controls*/
    long			rec_sens;			/*	1 = record sensors*/
    long			rec_janus;			/*	1 = record janus doppler*/
    long			rec_slant;			/*	1 = record slant doppler*/
    long			rec_raw;			/*	1 = record raw data*/
    char			run_notes[1024];	/*	run notes*/
    long			nx;					/*	# of xducers, from start-up file*/
    long			x[16];				/*	active xducers (A/D channel)*/
    long			databuffsize;		/*	size of data buffer    */
    long			rheadersize;		/*	size of rheader*/
    long			envbuffsize;		/*	environmental data buffer size*/
    long			relay_delay;
    long			autorelay;
/*    Boolean			TDS_on;		//TDS Code 12 December, 1996 ÑÑ cpn	flag to enable TDS system*/
/*    Boolean			TDS_sync;	//TDS Code 12 December, 1996 ÑÑ cpn	flag to sync to TDS time mark*/
    char			TDS_on;		/* use char for Boolean type - 1/9/02 MNB*/
    char			TDS_sync;	
    long			n_time_marks;		/*	number of time marks per sequence*/
    long			TDSrecs;		/*	number of TDS records appended to each data record*/
    long			TDSbuffsize;
    long			TDS_hold_off;	/*	number of milliseconds to hold off at the end of the sequence*/
    long			sync_mode;	/*	controller sync mode -- 0: no sync 1: standard sync */
    long			post_xmt_gate_delay;
    long			xtal_freq;
    struct			mode m;
    struct			aux a[4];
    struct			env  e;
    struct			hware h;
/*    struct			plotstruct p;*/
    char			sizeplotstruct[1200];	/* 1/9/02*/
    struct			motion mc;
    long			coprcsr_installed;	/*	whether or not have a coprocessor board*/
    long			testDataMode;		/*	generate test data*/
    long			cntrlr_installed;
    long			warnmin;
    unsigned long	start_DateTime;		/*	run start time*/
    char			sodad_version_str[25];
    char			hydra_version_str[25];
    HardwareParams	hardware;
    beam_seg_params	segment_param[NBEAMS];
    long			combine_segments;
    long 			UserLevel;			/*	Simple User Interface == 1, Advanced == 0*/
    long			PowerLevel;			/*	Power Level last set in controller.*/
    long			SonarType;			/*	switch for sonar:  0 == 50kHz, 1 == 140 kHz*/
    short			MaxPower;
    short			spare3;
    long			spare4;
    long			spare5;
    long			spare6;
    long			spare7;
    long			spare8;
    long			spare9;
    long			spare10;
    long			spare11;
    long			spare12;
    long			spare13;
    long			spare14;
    float			max_FileSize;
} dasrec;
#endif
