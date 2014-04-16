#ifndef	SODAD_TDS_PARAM
#define	SODAD_TDS_PARAM

/**********************************************/
/*	the following structures are from past sensors that are not used in this version*/
typedef struct ctd_data{
	char	ctd_str[40];
	long	pressure;
	long	temperature;
	long	conductivity;
	long	voltage1;	/*	remote temperature for SHEBA*/
	long	voltage2;
	long	voltage3;
	long	voltage4;
}ctd_data,*ctd_dataPtr;

typedef struct pressure_data{
	char	pressure_str[40];
	short	pressure1;
	short	pressure1_flag;
	short	pressure1_ID;
	short	pressure2;
	short	pressure2_flag;
	short	pressure2_ID;
	short	pressure3;
	short	pressure3_flag;
	short	pressure3_ID;
	short	pressure4;
	short	pressure4_flag;
	short	pressure4_ID;
	/*	units*/
	float	pressure1_units;
	float	pressure2_units;
	float	pressure3_units;
	float	pressure4_units;
}pressure_data,*pressure_dataPtr;

typedef struct nav_data{
	char	data_str[30];
	float	heading;
	float	pitch;
	float	roll;
}nav_data,*nav_dataPtr;

typedef struct accel_data{
	char	accel_str[40];
	short	accel1;
	short	accel1_flag;
	short	accel1_ID;
	short	accel2;
	short	accel2_flag;
	short	accel2_ID;
	short	accel3;
	short	accel3_flag;
	short	accel3_ID;
	short	accel4;
	short	accel4_flag;
	short	accel4_ID;
}accel_data,*accel_dataPtr;

/**********************************************/


/*	the following is the structure for the g12 raw data as it comes*/
/*		out of the ashtech (sentence:  $PASHR,PBN,blah-blah)*/
typedef struct pbnData{
	long			rcvtime;		/*	milliseconds of week of GPS time*/
	char			sitename[4];	/*	set by default to '????'*/
	double			navx;			/*	antenna pos ECEF x coordinate in meters (Earth Centered, Earth Fixed == ECEF)*/
	double			navy;			/*	antenna pos ECEF y coordinate in meters*/
	double			navz;			/*	antenna pos ECEF z coordinate in meters*/
	float			navt;			/*	receiver clock offset in meters*/
	float			navxdot;		/*	antenna x velocity in meters per second*/
	float			navydot;		/*	antenna y velocity in meters per second*/
	float			navzdot;		/*	antenna z velocity in meters per second*/
	float			navtdot;		/*	receiver clock drift in meters per second*/
	unsigned short	pdop;			/*	PDOP * 100	(PDOP == )*/
	unsigned short	checksum;		/*	checksum:  structure divided into 27 unsigned shorts*/
									/*		summed, take least significant 16 bits*/
}pbnData,*pbnDataPtr;

typedef struct g12_zda{
	char			timedate[10];
	char			day[3];
	char			month[3];
	char			year[5];
	char			LTZ_h[4];
	char			LTZ_m[3];
	unsigned long	tmarks;
	short			yr;
	float			LTZ;
}g12_zda,*g12_zdaPtr;

typedef struct gpsG12{
	unsigned long	UTC;
	float			velocity;
	float			latitude;
	float			longitude;
}gpsG12,*gpsG12Ptr;

/*
	Data types for Revelle:
	
		Ã G12
			time mark
			time host

		Ã gg24 data

		¥ Gyro heading
		
		¥ TSS
			pitch
			roll

		¥ ADAM 5000
		Ã	Slot 0 (4017H)
				accel 1
				accel 2
				accel 3
				accel 4
				pressure 1
				pressure 2
		Ã	Slot 2 (4013)
				temperature 1
				temperature 2
*/
/*	a UDP packet can be no larger than 256 bytes, as I recall*/
typedef struct TDS_Data{
	unsigned long	packet_ID;
	unsigned long	time_mark;
	unsigned long	time_host;
	long			time_mark_year;
	short			pkt_period_ms;
	long			gps_rcvtime;		/*	milliseconds of week of GPS time*/
	double			gps_navx;			/*	antenna pos ECEF x coordinate in meters (Earth Centered, Earth Fixed == ECEF)*/
	double			gps_navy;			/*	antenna pos ECEF y coordinate in meters*/
	double			gps_navz;			/*	antenna pos ECEF z coordinate in meters*/
	float			gps_navt;			/*	receiver clock offset in meters*/
	float			gps_navxdot;		/*	antenna x velocity in meters per second*/
	float			gps_navydot;		/*	antenna y velocity in meters per second*/
	float			gps_navzdot;		/*	antenna z velocity in meters per second*/
	float			gps_navtdot;		/*	receiver clock drift in meters per second*/
	unsigned short	pdop;				/*	PDOP * 100	(PDOP == )*/
	float			heading_cos;
	float			heading_sin;
	/*char			status;				//  a new var: status of heading - MNB 03/15/01*/
	float			accel_port_for;		/*	¡ Tilt from vertical*/
	float			accel_stbd_for;		/*	¡ Tilt from vertical*/
	float			accel_port_aft;		/*	¡ Tilt from vertical*/
	float			accel_stbd_aft;		/*	¡ Tilt from vertical*/
	float			openA2D1;			/*	volts*/
	float			openA2D2;			/*	volts*/
	float			pressure_port;		/*	volts*/
	float			pressure_stbd;		/*	volts*/
	float			temperature_port;	/*	¡C*/
	float			temperature_stbd;	/*	¡C*/
	float			temperature_spare;	/*	¡C*/
	float			tss_pitch;
	float			tss_roll;
	float			tss_heave;
	float			tss_vAccel;
	float			tss_hAccel;
	float			pcode_lat;		/*	ddmm.mmmm*/
	float			pcode_lon;		/*	ddmm.mmmm*/
	float			pcode_sog;		/*	cm/s*/
	float			pcode_cogT_cos;	/*	degrees, true*/
	float			pcode_cogT_sin;	/*	degrees, true*/
	float			pcode_time;		/*	hhmmss.ss*/
	long			pcode_flag;		/*	0: not navigating, 2: cdma (low res), 3: pcode (high res)*/
	float			pcode_lat_fraction;
	float			pcode_lon_fraction;
	float			ADU2_receive_time;	/*ashtech ADU2 GPS receive time in seconds*/
	float			ADU2_heading_cos;	/*ashtech ADU2 heading cosine*/
	float			ADU2_heading_sin;	/*ashtech ADU2 heading cosine*/
	float			ADU2_pitch;			/*ashtech ADU2 pitch in degrees*/
	float			ADU2_roll;			/*ashtech ADU2 pitch in degrees*/
	float			ADU2_mrms;			/*ashtech ADU2 measurement RMS error in meters*/
	float			ADU2_brms;			/*ashtech ADU2 baseline RMS error in meters*/
	float			ADU2_attitude_reset_flag;/*ashtech ADU2 attitude reset flag*/
	double			pcode_dlat;
	double			pcode_dlon;
}TDS_Data,*TDS_DataPtr;

typedef struct TDS_DataAvg{
	float			packet_ID;
	float			time_mark;
	float			time_host;
	float			time_mark_year;
	float			pkt_period_ms;
	float			gps_rcvtime;		/*	milliseconds of week of GPS time*/
	float			gps_navx;			/*	antenna pos ECEF x coordinate in meters (Earth Centered, Earth Fixed == ECEF)*/
	float			gps_navy;			/*	antenna pos ECEF y coordinate in meters*/
	float			gps_navz;			/*	antenna pos ECEF z coordinate in meters*/
	float			gps_navt;			/*	receiver clock offset in meters*/
	float			gps_navxdot;		/*	antenna x velocity in meters per second*/
	float			gps_navydot;		/*	antenna y velocity in meters per second*/
	float			gps_navzdot;		/*	antenna z velocity in meters per second*/
	float			gps_navtdot;		/*	receiver clock drift in meters per second*/
	float			pdop;				/*	PDOP * 100	(PDOP == )*/
	float			heading_cos;
	float			heading_sin;
	float			accel_port_for;
	float			accel_stbd_for;
	float			accel_port_aft;
	float			accel_stbd_aft;
	float			openA2D1;
	float			openA2D2;
	float			pressure_port;
	float			pressure_stbd;
	float			temperature_port;
	float			temperature_stbd;
	float			temperature_spare;
	float			tss_pitch;
	float			tss_roll;
	float			tss_heave;
	float			tss_vAccel;
	float			tss_hAccel;
	float			pcode_lat;		/*	ddmm.mmmm*/
	float			pcode_lon;		/*	ddmm.mmmm*/
	float			pcode_sog;		/*	cm/s*/
	float			pcode_cogT_cos;	/*	degrees, true*/
	float			pcode_cogT_sin;	/*	degrees, true*/
	float			pcode_time;		/*	hhmmss.ss*/
	float			pcode_flag;		/*	0: not navigating, 2: cdma (low res), 3: pcode (high res)*/
	float			pcode_lat_fraction;
	float			pcode_lon_fraction;
	float			ADU2_receive_time;	/*ashtech ADU2 GPS receive time in seconds*/
	float			ADU2_heading_cos;	/*ashtech ADU2 heading cosine*/
	float			ADU2_heading_sin;	/*ashtech ADU2 heading cosine*/
	float			ADU2_pitch;			/*ashtech ADU2 pitch in degrees*/
	float			ADU2_roll;			/*ashtech ADU2 pitch in degrees*/
	float			ADU2_mrms;			/*ashtech ADU2 measurement RMS error in meters*/
	float			ADU2_brms;			/*ashtech ADU2 baseline RMS error in meters*/
	float			ADU2_attitude_reset_flag;/*ashtech ADU2 attitude reset flag*/
	double			pcode_dlat;
	double			pcode_dlon;
}TDS_DataAvg,*TDS_DataAvgPtr;


#endif
