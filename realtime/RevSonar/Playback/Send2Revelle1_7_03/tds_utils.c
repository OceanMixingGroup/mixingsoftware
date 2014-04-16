/*
 *  tds_utils.c
 *  playback.pb
 *
 *  Created by mnbui on Thu Jan 10 2002.
 *  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
 *
 */
#include <math.h>
#include "tds_utils.h"

void	accum_tds_data(TDS_Data* data,TDS_Data* dataIn)
{
	data->packet_ID += dataIn->packet_ID;
	data->time_mark += dataIn->time_mark;
	data->time_host += dataIn->time_host;
	data->pkt_period_ms +=dataIn->pkt_period_ms;
	data->gps_rcvtime +=dataIn->gps_rcvtime;
	data->gps_navx += dataIn->gps_navx;
	data->gps_navy += dataIn->gps_navy;
	data->gps_navz += dataIn->gps_navz;
	data->gps_navt += dataIn->gps_navt;
	data->gps_navxdot += dataIn->gps_navxdot;
	data->gps_navydot += dataIn->gps_navydot;
	data->gps_navzdot += dataIn->gps_navzdot;
	data->gps_navtdot += dataIn->gps_navtdot;
	data->pdop += dataIn->pdop;
	data->heading_cos += dataIn->heading_cos;
	data->heading_sin += dataIn->heading_sin;
	data->accel_port_for += dataIn->accel_port_for;
	data->accel_stbd_for += dataIn->accel_stbd_for;
	data->accel_port_aft += dataIn->accel_port_aft;
	data->accel_stbd_aft += dataIn->accel_stbd_aft;
	data->openA2D1 += dataIn->openA2D1;
	data->openA2D2 += dataIn->openA2D2;
	data->pressure_port += dataIn->pressure_port;
	data->pressure_stbd += dataIn->pressure_stbd;
	data->temperature_port += dataIn->temperature_port;
	data->temperature_stbd += dataIn->temperature_stbd;
	data->temperature_spare += dataIn->temperature_spare;
	data->tss_pitch += dataIn->tss_pitch;
	data->tss_roll += dataIn->tss_roll;
	data->tss_heave += dataIn->tss_heave;
	data->tss_vAccel += dataIn->tss_vAccel;
	data->tss_hAccel += dataIn->tss_hAccel;
	data->pcode_dlat += dataIn->pcode_lat;	/* store lat and lon into doubles for averaging*/
	data->pcode_dlon += dataIn->pcode_lon;	
	data->pcode_sog += dataIn->pcode_sog;
	data->pcode_cogT_cos += dataIn->pcode_cogT_cos;
	data->pcode_cogT_sin += dataIn->pcode_cogT_sin;
	data->pcode_time += dataIn->pcode_time;
	data->pcode_flag += dataIn->pcode_flag;
	data->time_mark_year += dataIn->time_mark_year;
	
	data->ADU2_receive_time+= dataIn->ADU2_receive_time;/*ashtech ADU2 GPS receive time*/
	data->ADU2_heading_cos+= dataIn->ADU2_heading_cos;	/*ashtech ADU2 heading cosine in radians*/
	data->ADU2_heading_sin+= dataIn->ADU2_heading_sin;	/*ashtech ADU2 heading cosine in radians*/
	data->ADU2_pitch+= dataIn->ADU2_pitch;				/*ashtech ADU2 pitch in degrees*/
	data->ADU2_roll+= dataIn->ADU2_roll;				/*ashtech ADU2 pitch in degrees*/
	data->ADU2_mrms+= dataIn->ADU2_mrms;				/*ashtech ADU2 measurement RMS error*/
	data->ADU2_brms+= dataIn->ADU2_brms;				/*ashtech ADU2 baseline RMS error*/
	data->ADU2_attitude_reset_flag+= dataIn->ADU2_attitude_reset_flag;/*ashtech ADU2 attitude reset flag*/
}

void	copy_tds_data(TDS_Data* dataOut,TDS_Data* dataIn)
{
	long	k;
	char*	dataInPtr = (char*)dataIn;
	char*	dataOutPtr = (char*)dataOut;
	
	for(k=0;k<sizeof(TDS_Data);k++)
		*dataOutPtr++ = *dataInPtr++;
}

void	normalize_tds_data(TDS_Data* data,long norm_factor)
{
	double ip;
	data->packet_ID			/=	norm_factor;
	data->time_mark			/=	norm_factor;
	data->time_host			/=	norm_factor;
	data->pkt_period_ms		/=	norm_factor;
	data->gps_rcvtime		/=	norm_factor;
	data->gps_navx			/=	norm_factor;
	data->gps_navy			/=	norm_factor;
	data->gps_navz			/=	norm_factor;
	data->gps_navt			/=	norm_factor;
	data->gps_navxdot		/=	norm_factor;
	data->gps_navydot		/=	norm_factor;
	data->gps_navzdot		/=	norm_factor;
	data->gps_navtdot		/=	norm_factor;
	data->pdop				/=	norm_factor;
	data->heading_cos		/=	norm_factor;
	data->heading_sin		/=	norm_factor;
	data->accel_port_for	/=	norm_factor;
	data->accel_stbd_for	/=	norm_factor;
	data->accel_port_aft	/=	norm_factor;
	data->accel_stbd_aft	/=	norm_factor;
	data->openA2D1			/=	norm_factor;
	data->openA2D2			/=	norm_factor;
	data->pressure_port		/=	norm_factor;
	data->pressure_stbd		/=	norm_factor;
	data->temperature_port	/=	norm_factor;
	data->temperature_stbd	/=	norm_factor;
	data->temperature_spare	/=	norm_factor;
	data->tss_pitch			/=	norm_factor;
	data->tss_roll			/=	norm_factor;
	data->tss_heave			/=	norm_factor;
	data->tss_vAccel		/=	norm_factor;
	data->tss_hAccel		/=	norm_factor;
	data->pcode_dlat		/=	norm_factor;
	data->pcode_dlon		/=	norm_factor;
	data->pcode_lat	 =	data->pcode_dlat;/* data is stored as doubles in dlat and dlon*/
 	data->pcode_lon	 =	data->pcode_dlon;
	data->pcode_lat_fraction =	modf(data->pcode_dlat,&ip);/* data is stored as doubles in dlat and dlon*/
 	data->pcode_lon_fraction =	modf(data->pcode_dlon,&ip);
	
	data->pcode_sog			/=	norm_factor;
	data->pcode_cogT_cos	/=	norm_factor;
	data->pcode_cogT_sin	/=	norm_factor;
	data->pcode_time		/=	norm_factor;
	data->pcode_flag		/=	norm_factor;
	data->time_mark_year	/=	norm_factor;
	
	data->ADU2_receive_time	/=	norm_factor;
	data->ADU2_heading_cos	/=	norm_factor;
	data->ADU2_heading_sin	/=	norm_factor;
	data->ADU2_pitch		/=	norm_factor;
	data->ADU2_roll			/=	norm_factor;
	data->ADU2_mrms			/=	norm_factor;
	data->ADU2_brms			/=	norm_factor;
	data->ADU2_attitude_reset_flag			/=	norm_factor;
}

