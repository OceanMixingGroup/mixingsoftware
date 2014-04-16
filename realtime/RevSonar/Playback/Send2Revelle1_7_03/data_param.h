/*
 *  dataparam.h
 *  playback.pb
 *
 *  Created by mnbui on Wed Jan 09 2002.
 *  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef		DATA_PARAM
#define		DATA_PARAM
#define TEST_DATA		1
#define	ACTUAL_DATA		0
/*	The structures in this file are all the structures that are shared between the*/
/*		host and the hydra coprocessor board and have to do with the data processing.*/
/**/
#include	"tds_structs.h"

/*extern const float SAngle;*/

typedef struct dnoise_params{							/*	parameters for dc noise removal*/
    long rmin;				/*	min range (bin) to compute dc*/
    long rmax;				/*	max range (bin) to compute dc*/
    float tfilt;			/*	time filter constant*/
}dnoise_params;
typedef struct demean_params{							/*	parameters for mean removal*/
    long smin;				/*	min sample % of  full range*/
    long smax;				/*	max sample % of  full range*/
    float tfilt;			/*	time filter*/
}demean_params;
typedef struct equalize_params{						/*	parameters for equalization*/
    long smin;				/*	min sample % of  full range*/
    long smax;				/*	max sample % of  full range*/
    float tfilt;			/*	time filter*/
}equalize_params;		
typedef struct mean_vel{						/*	parameters for ship's mean vel removal*/
    long smin;				/*	min sample % of  full range*/
    long smax;				/*	max sample % of  full range*/
    float tfilt;			/*	time filter*/
}mean_vel;		
typedef struct motion{
    float heading_offset;
    float tilt_offset1;
    float tilt_offset2;
    float tilt_cal1;
    float tilt_cal2;
    float vcalib;
    float jcal1;
    float jcal2;
    long mvflag;
    long snflag;
    long dmflag;
    long senseflag;
    long compassflag;
    long nsamps;	/*	number sensor samples to average */
    long interval;	/*	sensor sample skip interval */
    dnoise_params	dn;
    demean_params	dm;
    mean_vel		mv;
}motion;

typedef struct	beam_seg_params{
    float	seg0_weight;
    float	seg1_weight;
    float	seg2_weight;
    float	seg3_weight;
    float	seg0_phase;
    float	seg1_phase;
    float	seg2_phase;
    float	seg3_phase;
}beam_seg_params,*beam_seg_paramsPtr;

typedef struct data_stat_rec{
    long		seqnum;		/*	DSP sequence number*/
    long		ensnum;		/*	DSP ensemble number*/
    unsigned long	time;		/*	from time_address*/
    unsigned long	TimeMark;	/*	20 Hz time mark*/
    long		dma_time;	/*	dma xfer time of sonar data (µsecs)*/
    unsigned long	stat_0;
    unsigned long	stat_1;
    unsigned long	stat_2;
    unsigned long	stat_3;
    unsigned long	stat_4;
    unsigned long	stat_5;
    unsigned long	stat_6;
    unsigned long	stat_7;
    long		ptime_0;	/*	process times*/
    long		ptime_1;
    long		ptime_2;
    long		ptime_3;
    long		ptime_4;
    long		ptime_5;
    long		ptime_6;
    long		ptime_7;
    float		channel_mean[32];
    float		beam_eq_factor[16];
    float		mean_cov[10];
    float		timestatus;
    unsigned long	timemark;
    float		pitch;
    float		roll;
    float		cos_heading; 
    float		sin_heading; 
    long		spare1; 
    long		spare2;
    float		spare3;
    float		spare4;
    float		spare5;
    float		spare6;
    float		spare7;
    long		spare8;
    long		spare9;
    long		spare10;
    float		spare11;
    float		spare12;
    float		spare13;
    float		spare14;
    float		spare15;
    float		spare16;
    float		spare17;
    float		spare18;
    float			spare19;
    float			spare20;
    float			spare21;
    float			spare22;
    float			spare23;
    float			spare24;
    float			spare25;
    float			spare26; 
    float			spare27;
    float			spare28;
    float			spare29;
    float			spare30;
    float			spare31;
    float			spare32;
    float			spare33;
    float			spare34;
    float			spare35;
    float			spare36;
    float			spare37;
    float			spare38;
} data_stat_rec;

typedef struct data_param{
	/*	physical addresses hydra board needs for dma*/
    unsigned long*	ready_cnt_addr;		/*	pointer to physical address of ready_cnt*/
    float*			dbuff;		/*	data ring buffer MAC base physical address*/
    short*			rawdbuff;	/*	raw data ring buffer MAC base physical address*/
    data_stat_rec*	stat_rec_addr;		/*	current status rec MAC physical address*/
    /*	ready_flag is obsolete*/
    long*			ready_flag_addr;	/*	ready flag MAC physical address*/
    long*			heading_addr;		/*	ships heading MAC physical address*/
    TDS_DataPtr		tds_buff;			/*	tds circular buffer base address*/
    /*	other info hydra needs to set up and run*/
    long	test_DataMode;		/*	test_DataMode = 1 for test, 0 for real data*/
    long	buffsize;		/*	buffsize in bytes for dsp transfers*/
    long	nbuffs;			/*	number of MAC data buffers*/
    long	nx;			/*	# of xducers */
    long	x[16];			/*	active xducers (A/D channel)*/
    long	start_time;		/*	start time (in samples) to start processing*/
    long	nsamp;			/*	# of samples per sequence*/
    long	samp_period; 		/*	sample period (micorseconds)*/
    long	seq_length;		/*	sequence length (samples)*/
    long	n_seq;			/*	number of sequences per average*/
    long	nbeams;			/*	# of  beams*/
    long	nbins;			/*	# of range bins*/
    long	ravg;			/*	# of samples per range bin*/
    long	tlag;			/*	time lag for covariance estimate*/
    long	time_avg;		/*	# of sequences per ensemble*/
    long	rec_raw;		/*	data mode, 1 = raw, 0 = processed*/
    long	lagzero;			/*	1 = calculate spatial lag zero*/
    long	testmode;		/*	flag for test data mode*/
    struct motion	mc;		/*	ships motion correction parameters*/
    long	n_time_marks;		/*	number of TDS Time marks per sequence*/
    long	tds_on;			/*	tds data coming in*/
    long	tds_sync;		/*	tds time sync enabled*/
    long	RingBuffSize;		/*	number of TDS buffers*/
    beam_seg_params	seg_params[4];	/*	added for Revelle*/
    long	combine_segments;
    long	code_reps;
    long	nsegments;
    long	signoisescale;
    long	sonar_type;
    long	filter_type;  /* M.A.G 8/23/00 selector for which pre filter to use*/
    long	baseband_type;/* M.A.G 8/23/00 selector for which baseband to use*/
} data_param;

typedef struct host_mastered_data{
	unsigned long	timeMark;
	unsigned long	timeHost;
	/*	¥	Added for Revelle*/
	float	cos_heading;
	float	sin_heading;
	float	pitch;
	float	roll;
} host_mastered_data,*host_mastered_dataPtr;
#endif
