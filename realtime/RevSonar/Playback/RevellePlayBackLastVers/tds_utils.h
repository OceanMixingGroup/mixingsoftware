/*
 *  tds_utils.h
 *  playback.pb
 *
 *  Created by mnbui on Wed Jan 09 2002.
 *  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef	TDS_UTILS
#define	TDS_UTILS
#include	<stdio.h>
#include	<string.h>
#include	"tds_structs.h"

void	accum_tds_data(TDS_Data* data,TDS_Data* dataIn);
void	normalize_tds_data(TDS_Data* data,long norm_factor);
void	copy_tds_data(TDS_Data* dataOut,TDS_Data* dataIn);
#endif
