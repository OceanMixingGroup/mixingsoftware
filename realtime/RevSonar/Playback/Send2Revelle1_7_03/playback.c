/******************************************************************************************************
**Filename: fileInOut2.c
**Date: 01/09/2001
**Author: Mai Bui
**Description: this file open "data.in" file for reading data and write these data into 
**             another file "data.out", application runs on Unix
**	base on display runs on MacOS
**Usage: playback filenameIn.dat
**Date: start at 01/09/02
******************************************************************************************************/
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<math.h>
#include"das.h"
#include"tds_utils.h"
#include"FileIO.h"

#define SECS_PER_DAY 86400.0

/* global variables */
static long	recs_done_cov = 0;
static long	recs_done_covn = 0;
static long recs_done_int = 0;

const long	HeaderSize = 64;
long		esamples;
long		echannels; 
dasrec dasRec;
rheader rh;
data_param dp;
short done;


typedef struct {
     long type;   /* type*/
     long mrows;  /* row dimension*/
     long ncols;  /* column dimension*/
     long imagf;  /* flag indicating imag part*/
     long namlen; /* name length (including NULL)*/
} Fmatrix;

/* playback structure*/
typedef struct playparams
{
	long beg_rec;
	long end_rec;
	long n_avg;
	long max_rec;
	long start_rec;
	float bwfilt;
	float bwthresh;
	long matcov_flag;
	long matcovn_flag;
	long matint_flag;
	long vel_flag;
	long matenv_flag;
	long matpos_flag;
	long mode_num;
	long janus_flag;
	long header_flag;
	long	SlowPlottingDown;
	float	SlowAmount;
}playparams;


int average_header(TDS_Data* data,TDS_Data* avg_data,float *matbuff,long recnum,playparams *pp,FILE* fp,long *avgs_done);
int average_cov(float *cbuff,float *cabuff,float *matbuff,float *matbuff_header,long recnum,playparams *pp,FILE* fp, int cov);
int average_int(float *ibuff,float *iabuff,float *matbuff,float *matbuff_header,long recnum,playparams *pp,FILE* fp);
void calcdas(dasrec* dr,data_param* dp);
void calcenv();
void createOutFilename(char*, char*);
FILE* open_writeHeader2Matfile(long, long, long, long, char*, char*);
int write_header(rheader* rh,float* matbuff,FILE* fp);
int WriteMatHeader(long type,char* pname,long mrows,long ncols,long imagf,FILE* fp);
void	ChkFileEnd(playparams *pp,FILE* dfp,FILE* vfp,long *Diskrecnum);

int main(int argc, char *argv[])
{
	FILE *fpIn, *fpOut_header=NULL, *fpOut_cov=NULL, *fpOut_int=NULL, *fpOut_covn=NULL;
	char fileIn[256]="\0";
	char fileOut[256] = "\0";
	char prefix[256] = "\0";
	char* str="\0";
	int i,j;
        int retval;
        playparams pp;
        long count, total_rec;
        short err;
        short *databuff;
        float *cbuff=NULL, *cabuff=NULL, *matbuff_cov=NULL, *matbuff_header = NULL;
        float *matbuff_int=NULL, *iabuff=NULL, *ibuff=NULL;
        float *matbuff_covn=NULL, *cnabuff=NULL, *cnbuff=NULL;
   	long databuffsize,recnum=0,nrecs=0,nitems=0,filelength,cov_length,col_length,col_length_int,row_length;
        TDS_Data *headerBuff = NULL, *headeravgBuff = NULL;
	long	Diskrecnum=0, numrec=0;
        
	long	head_avg_cnt = 0;
        char ans;
        
	if (argc != 2)
	{
		printf("Usage: playback filenameIn.dat\n");
		exit(1);
	}
	printf("This appl reading data and create a matfile\n");

	strcpy(fileIn,argv[1]);
printf("fileIn = %s\n", fileIn);
        /* get file name from the user*/
        printf("What matfile do you want to be created?\n");
        printf("    \"aux\" file?        (1 for yes, 0 for no):  ");
        scanf("%d",&pp.header_flag);
        printf("    \"covariance\" file? (1 for yes, 0 for no):  ");
        scanf("%d",&pp.matcov_flag);
        printf("    \"intensity\" file?  (1 for yes, 0 for no):  ");
        scanf("%d",&pp.matint_flag);
        printf("    \"nomalized covariance\" file? (1 for yes, 0 for no):  ");
        scanf("%d",&pp.matcovn_flag);

	/* open file for reading*/
        printf("Open data file for reading ...\n");

	if((fpIn = fopen(fileIn, "r")) == NULL)
	{
          fprintf(stderr,"Could not open file for reading\n");
          return 1;
        }

        /* 1. READ THE DATA ONE TIME TO GET DATA SIZE (not include dasrec and header information)*/
        /* read dasrec information*/
        count = sizeof(dasrec);
        if(fread(&dasRec, 1, count, fpIn)==0)
            fprintf(stderr, "Could not read dasrec from data file\n");
        /* read a header*/
        count = sizeof(rheader);
        if(fread(&rh, 1, count, fpIn)==0)
            fprintf(stderr, "Could not read header from data file\n");
        /* read to the end of the file, get file's size*/
        filelength = filesize(fpIn);

        /* initialize playback parameters*/
        pp.beg_rec = rh.rec_num;
       	pp.start_rec = rh.rec_num;
	pp.max_rec = (filelength - sizeof(dasrec))/dasRec.reclength + rh.rec_num;
	pp.end_rec = pp.max_rec;
	pp.vel_flag = 0;
	pp.n_avg = 1;

        total_rec = pp.end_rec - pp.beg_rec;

        printf("In the data file %s, it has %d records\n", fileIn, total_rec);
  
        if (total_rec==0)
        {
           if (fpIn) fclose(fpIn);
           return 1;
        }

        printf("How many records do you want to read (from 0 ->  %d): ",total_rec);
        scanf("%d", &numrec);
        printf("How many records will be averaged into one value (from 1 -> %d): ",total_rec);
        scanf("%d", &pp.n_avg); 
       
        pp.end_rec = pp.beg_rec + numrec;
        
	nrecs = pp.end_rec - pp.beg_rec;
        /* initialize some param in dasRec and dp structure that will be used later*/
        calcdas(&dasRec,&dp);

        /* allocate for databuff*/
        databuffsize = dasRec.databuffsize;
        databuff = (short*)calloc(databuffsize, sizeof(short));

	if(pp.vel_flag)	/* set buffer size appropriate to velocity or covariance - not use velocity*/
		cov_length = dasRec.m.covsize / 2;
	else
		cov_length = dasRec.m.covsize;
	col_length = cov_length + HeaderSize;
	row_length = nrecs/pp.n_avg;
	col_length_int = dasRec.m.intsize + HeaderSize;

        matbuff_header = (float*)calloc(HeaderSize, sizeof(float));
        headeravgBuff = (TDS_Data*)calloc(1, sizeof(TDS_Data));
 
        /* 2. WRITE DASREC INFORMATION AND DATA NAME INTO THE MAT FILES*/
        /* create the matfile and write dasrec (Fmatrix information) and data name into the files*/
        if (pp.header_flag)
        {
            strcpy(fileOut,"auxdata");
            /* construct Output files' name*/
            createOutFilename(fileIn, fileOut);
            /* open file for writting Fmatrix and header information*/
            if((fpOut_header = open_writeHeader2Matfile(1010, HeaderSize, row_length, 0, "auxdata", fileOut)) == NULL)
            {
                fprintf(stderr, "Could not open or write the header for auxdata mat file\n");
                pp.header_flag = 0;
            }   
        }

        if (pp.matcov_flag)
        {
            strcpy(fileOut,"cov");
            /* construct Output files' name*/
            createOutFilename(fileIn, fileOut);
            /* open file for writting Fmatrix and header information*/
            if((fpOut_cov = open_writeHeader2Matfile(1010, col_length, row_length, 0, "cov", fileOut)) == NULL)
            {
                fprintf(stderr, "Could not open or write the header for cov mat file\n");
                pp.matcov_flag = 0;
            }   
            else
            {
                matbuff_cov = (float*)calloc(cov_length, sizeof(float));
                cabuff = (float*)calloc(dasRec.m.covsize, sizeof(float));
                cbuff = (float*)databuff;				/* cov buffer*/
            }

        }
        if (pp.matint_flag)
        {
            strcpy(fileOut,"int");
            /* construct Output files' name*/
            createOutFilename(fileIn, fileOut);
            /* open file for writting Fmatrix and header information*/
            if((fpOut_int = open_writeHeader2Matfile(1010, col_length_int, row_length, 0, "int", fileOut)) == NULL)
            {
                fprintf(stderr, "Could not open or write the header for int mat file\n");
                pp.matint_flag = 0;
            }   
            else
            {
                matbuff_int = (float*)calloc(dasRec.m.intsize, sizeof(float));
                iabuff = (float*)calloc(dasRec.m.intsize, sizeof(float));
                ibuff = (float*)databuff + dasRec.m.covsize;				
            }

        }
	if(pp.matcovn_flag)	
	{
            strcpy(fileOut,"covn");
            /* construct Output files' name*/
            createOutFilename(fileIn, fileOut);
            /* open file for writting Fmatrix and header information*/
            if((fpOut_covn = open_writeHeader2Matfile(1010, col_length, row_length, 0, "covn", fileOut)) == NULL)
            {
                fprintf(stderr, "Could not open or write the header for covn mat file\n");
                pp.matcovn_flag=0;
            }   
            else
            {
                matbuff_covn = (float*)calloc(cov_length,sizeof(float));
                cnabuff = (float*)calloc(dasRec.m.covsize,sizeof(float));
                cnbuff = (float*)databuff + dasRec.m.covsize + dasRec.m.intsize;
            }
	}
       
        done = 0;
        do
        {
            if(done) break;

            /* set file position to next record*/
            fseek(fpIn, (((Diskrecnum+pp.beg_rec-pp.start_rec)*dasRec.reclength) + sizeof(dasrec)), SEEK_SET);

            /* read the header*/
            count = sizeof(rheader);
            if((err = fread(&rh, count, 1, fpIn))==0)
            {
                fprintf(stderr, "Could not read the header of the data file from main playback\n");
                done = 1;
                break;
            }
           /* read the Sonar data*/
            count = databuffsize;
            if((err = fread(databuff, count, 1, fpIn))==0)
            {
                fprintf(stderr, "Could not read the Sonar data file from main playback\n");
                done = 1;
                break;
            }

            ibuff = (float*)databuff + dasRec.m.covsize;	/* int buffer*/
            cnbuff = (float*)databuff + dasRec.m.covsize + dasRec.m.intsize;	/* nomalized cov buffer*/
            headerBuff = (TDS_Data*)&(rh.data);			/* header buffer*/
            
            /* process data: average and write these data into every single files*/
            /* write timemark into header allways*/
            average_header(headerBuff,headeravgBuff,matbuff_header,recnum,&pp,fpOut_header,&head_avg_cnt);
            /* for cov, int, covn : write time stamp and average data*/
            if (pp.matcov_flag)
                average_cov(cbuff,cabuff,matbuff_cov,matbuff_header,recnum,&pp,fpOut_cov, 1);	/* 1 for covariance*/
            /* for intensity*/
            if (pp.matint_flag)
                average_int(ibuff,iabuff,matbuff_int,matbuff_header,recnum,&pp,fpOut_int);
            /* for nomalized covariance*/
            if (pp.matcovn_flag)
                average_cov(cnbuff,cnabuff,matbuff_covn,matbuff_header,recnum,&pp,fpOut_covn, 0);	/* 0 for n-covariance*/

            recnum++;
            Diskrecnum++;
            if(recnum==nrecs)
                    done=1;
        }while(!done);
        
        /* finally, write the mat reader at the end of the output file*/
	if(fpOut_header)
	{
		if((retval = WriteMatHeader(1010,"auxdata",HeaderSize,head_avg_cnt,0,fpOut_header))==0)
			return 1;
/*                printf("done for writting auxdata data, Fmatrix and data name at the end: %d bytes\n", retval);*/
                printf("Done for written auxdata data\n");
		fclose(fpOut_header);
	}
	if(fpOut_cov)
	{
		if((retval = WriteMatHeader(1010,"cov",col_length,recs_done_cov,0,fpOut_cov))==0)
                    return 1;
/*                printf("done for writting cov data, Fmatrix and data name at the end: %d bytes\n", retval);*/
                printf("Done for written covariance data\n");
                fclose(fpOut_cov);
	}
	if(fpOut_int)
	{
		if((retval = WriteMatHeader(1010,"int",col_length_int,recs_done_int,0,fpOut_int))==0)
			return 1;
/*                printf("done for writting int data, Fmatrix and data name at the end: %d bytes\n", retval);*/
                printf("Done for written intensity data\n");
		fclose(fpOut_int);
	}
	if(fpOut_covn)
	{
                if((retval = WriteMatHeader(1010,"covn",col_length,recs_done_covn,0,fpOut_covn))==0)
			return 1;
/*                printf("done for writting covn data, Fmatrix and data name at the end: %d bytes\n", retval);*/
                printf("Done for written nomalized covariance data\n");
		fclose(fpOut_covn);
	}
        

	/* free all pointers*/
        if (databuff) free(databuff);

        /* header buffs*/
        if (matbuff_header) free(matbuff_header);
        if (headeravgBuff) free(headeravgBuff);

        /* cov buffs*/
        if (matbuff_cov) free(matbuff_cov);
        if (cabuff) free(cabuff);

        /* int buffs*/
        if (matbuff_int) free(matbuff_int);
        if (iabuff) free(iabuff);

        /* nomalized cov buffs*/
        if (matbuff_covn) free(matbuff_covn);
        if (cnabuff) free(cnabuff);
        
        if (fpIn) fclose(fpIn);
	return 0;
}

/*****************************************************************************************************
Function Name: average_header() 
Description:  
	Average number of record's header
Date: 01/9/02
*****************************************************************************************************/
int	average_header(TDS_Data* data,TDS_Data* avg_data,float *matbuff,long recnum,playparams *pp,FILE* fp,long *avgs_done)
{
	float	pdop_filt = 400;
        int retval;
	
	if(recnum % pp->n_avg)		/* accumulate buffer*/
		accum_tds_data(avg_data,data);
	else				/* initialize buffer*/
		copy_tds_data(avg_data,data);
	if(((recnum+1)%pp->n_avg)==0)	/* fill matbuff and write out if header file choosen*/
	{
		normalize_tds_data(avg_data,pp->n_avg);/* normalize tds data*/

		*(matbuff+3) = avg_data->heading_cos;
		*(matbuff+4) = avg_data->heading_sin;
		*(matbuff+5) = avg_data->tss_pitch;
		*(matbuff+6) = avg_data->tss_roll;										
		*(matbuff+7) = avg_data->gps_navx;
		*(matbuff+8) = avg_data->gps_navy;										
		*(matbuff+9) = avg_data->gps_navz;
		*(matbuff+10) = avg_data->gps_navt;
		*(matbuff+11) = avg_data->gps_navxdot;
		*(matbuff+12) = avg_data->gps_navydot;
		*(matbuff+13) = avg_data->gps_navzdot;
		*(matbuff+14) = avg_data->gps_navtdot;
		*(matbuff+15) = avg_data->pdop;
		*(matbuff+16) = avg_data->pressure_port;
		*(matbuff+17) = avg_data->pressure_stbd;
		*(matbuff+18) = avg_data->temperature_port;
		*(matbuff+19) = avg_data->temperature_stbd;
		*(matbuff+20) =	avg_data->accel_port_for;
		*(matbuff+21) =	avg_data->accel_stbd_for;
		*(matbuff+22) =	avg_data->accel_port_aft;
		*(matbuff+23) =	avg_data->accel_stbd_aft;
		*(matbuff+24) = avg_data->tss_vAccel;
		*(matbuff+25) = avg_data->tss_hAccel;
		*(matbuff+26) = avg_data->pcode_lat;
		*(matbuff+27) = avg_data->pcode_lon;
		*(matbuff+28) = avg_data->pcode_sog;
		*(matbuff+29) = avg_data->pcode_cogT_cos;
		*(matbuff+30) = avg_data->pcode_cogT_sin;
		*(matbuff+31) = avg_data->pcode_time;
		*(matbuff+32) = avg_data->pcode_flag;
		*(matbuff+33) = avg_data->time_mark_year;
		*(matbuff+34) = avg_data->pcode_lat_fraction;
		*(matbuff+35) = avg_data->pcode_lon_fraction;
		*(matbuff+36) = avg_data->ADU2_receive_time;
		*(matbuff+37) = avg_data->ADU2_heading_cos;
		*(matbuff+38) = avg_data->ADU2_heading_sin;
		*(matbuff+39) = avg_data->ADU2_mrms;
		*(matbuff+40) = avg_data->ADU2_brms;
		*(matbuff+41) = avg_data->ADU2_attitude_reset_flag;
		
		if(fp)
		{
			if ((retval = write_header(&rh,matbuff,fp))==0)
                        {
                            fprintf(stderr, "Could not write timemark into the header mat file\n");
                            return retval;
                        }
		}
		(*avgs_done)++;
	}
        return retval;
}
/***************************************************************************************************
Function Name: average_cov() 
Description:  
	Average records' covariance (cov=1) or nomalized covariance (cov=0) data
Date: 01/9/02
***************************************************************************************************/
int average_cov(float *cbuff,float *cabuff,float *matbuff,float *matbuff_header,long recnum,playparams *pp,FILE* fp,int cov)
{
	long			i,j,count;
	float			*cbuffptr,*cabuffptr,*matbuffptr,*crptr,*cqptr,jday,jsecs;
	float			*cr0ptr,*cr1ptr,*cr2ptr,*cr3ptr;
	float			*cq0ptr,*cq1ptr,*cq2ptr,*cq3ptr;
	float			v0,v1,v2,v3,u,v;
	float			sn,cs;
	float			*matbuffuptr,*matbuffvptr,*matbuffw1ptr,*matbuffw2ptr;
	unsigned long	secs;
        int retval=0;

        cbuffptr = cbuff;
	cabuffptr = cabuff;
	if(recnum % pp->n_avg)		/* accumulate buffer*/
	{
            for(i=0;i<dasRec.m.covsize;i++)
            {
                    *cabuffptr++ = *cabuffptr + *cbuffptr++;
            }
	}
	else
	{
            for(i=0;i<dasRec.m.covsize;i++)/*	initialize buffer*/
            {
                    *cabuffptr++ =  *cbuffptr++;
            }
	}
	if(((recnum+1)%pp->n_avg)==0)/*	fill matbuff and write out*/
	{
            /* increase cov or covn number count*/
            if (cov)
                recs_done_cov++;
            else 
                recs_done_covn++;

            if ((retval = write_header(&rh,matbuff_header,fp))==0)
            {
                fprintf(stderr, "Could not write timemark int into the cov mat file\n");
                return retval;
            }
            for(i=0;i<dp.nbeams;i++)
            {
                crptr = cabuff+ (i * dasRec.m.nbins * 2)+1;
                cqptr = crptr + dasRec.m.nbins;
                for(j=0;j<dasRec.m.nbins-2;j++)
                {
                    *crptr++ = *crptr + *(crptr +1);
                    *cqptr++ = *cqptr + *(cqptr +1);
                }
            }
            if(pp->vel_flag)
            {
                if(!pp->janus_flag)
                {
                    matbuffptr = matbuff;
                    for(i=0;i<dp.nbeams;i++)
                    {
                        crptr=cabuff+ (i * dasRec.m.nbins * 2);
                        cqptr=crptr + dasRec.m.nbins;
                        for(j=0;j<dasRec.m.nbins;j++)
                        {
                                *matbuffptr++ = dasRec.mc.vcalib*atan2(*cqptr++,*crptr++);
                        }
                    }
                    count=dasRec.m.intsize*sizeof(float);/*	set count to real velocity size*/
                }
                else 
                {
                    matbuffuptr = matbuff;
                    matbuffvptr = matbuff + (dasRec.m.nbins);
                    matbuffw1ptr = matbuff + (2 * dasRec.m.nbins);
                    matbuffw2ptr = matbuff + (3 * dasRec.m.nbins);
                    cr0ptr=cabuff;
                    cq0ptr=cr0ptr + dasRec.m.nbins;
                    cr1ptr=cabuff + (dasRec.m.nbins * 2);
                    cq1ptr=cr1ptr + dasRec.m.nbins;
                    cr2ptr=cabuff + (2 * dasRec.m.nbins * 2);
                    cq2ptr=cr2ptr + dasRec.m.nbins;
                    cr3ptr=cabuff + (3 * dasRec.m.nbins * 2);
                    cq3ptr=cr3ptr + dasRec.m.nbins;

                    sn = rh.data.heading_sin;	/*	v sonar points -pi/4 relative to ship*/
                    cs = rh.data.heading_cos;

                    for(j=0;j<dasRec.m.nbins;j++)
                    {
                        v0 = dasRec.mc.vcalib*atan2(*cq0ptr++,*cr0ptr++);
                        v1 = dasRec.mc.vcalib*atan2(*cq1ptr++,*cr1ptr++);
                        v2 = dasRec.mc.vcalib*atan2(*cq2ptr++,*cr2ptr++);
                        v3 = dasRec.mc.vcalib*atan2(*cq3ptr++,*cr3ptr++);

                        u = dasRec.mc.jcal1*(v3-v1);
                        v = dasRec.mc.jcal1*(v2-v0);
                        *matbuffuptr++  = u*cs + v*sn;			/*	u*/
                        *matbuffvptr++  = v*cs - u*sn;			/*	v*/
                        *matbuffw1ptr++ = dasRec.mc.jcal2*(v0+v2);	/*	w1*/
                        *matbuffw2ptr++ = dasRec.mc.jcal2*(v1+v3);	/*	w2*/
                    }
                    count = dasRec.m.intsize*sizeof(float);/*	set count to real velocity size*/
                }
            }
            else
            {
                matbuffptr = matbuff;
                cabuffptr = cabuff;
                for(i=0;i<dasRec.m.covsize;i++)
                        *matbuffptr++ = *cabuffptr++;
                count = dasRec.m.covsize*sizeof(float);/*	set count to complex covariance size*/
            }
            if ((retval = fwrite(matbuff,1,count,fp)) == 0)
            {
                fprintf(stderr, "Could not write average cov into the cov mat file\n");
                return retval;
            }
        }
        return 1;
}
/****************************************************************************************************
Function Name: average_int() 
Description:  
	Average records' intensity data
Date: 01/11/02
****************************************************************************************************/

int average_int(float *ibuff,float *iabuff,float *matbuff,float *matbuff_header,long recnum,playparams *pp,FILE* fp)
{
	long		i,count;
	float		*ibuffptr,*iabuffptr,*matbuffptr,jday,jsecs;
	float		norm_fac;
	unsigned long	secs;
	float		xnorm;
        int 		retval=0;

	ibuffptr = ibuff;
	iabuffptr = iabuff;

	if(recnum % pp->n_avg)/*	accumulate buffer*/
	{
		for(i=0;i<dasRec.m.intsize;i++)
		{
			*iabuffptr++ = *iabuffptr + *ibuffptr++;
		}
	}
	else
	{
		for(i=0;i<dasRec.m.intsize;i++)/*	initialize buffer*/
		{
			*iabuffptr++ =  *ibuffptr++;
		}
	}
	if(((recnum+1)%pp->n_avg)==0)/*	fill matbuff and write out*/
	{
		recs_done_int++;

		if ((retval = write_header(&rh,matbuff_header,fp))==0)
                {
                    fprintf(stderr, "Could not write the time mark for int file\n");
                    return retval;
                }

		matbuffptr = matbuff;
		iabuffptr=iabuff;
		norm_fac = 1.0;
		xnorm = 1.0/(dasRec.n_seq*dasRec.m.ravg);
		for(i=0;i<dasRec.m.intsize;i++)
			*matbuffptr++ = (float)log10(norm_fac*(*iabuffptr++));
		/*count = dasRec.m.intsize*sizeof(float);//	set count to intensity buffer size*/
		count = dasRec.m.intsize;/*	set count to intensity buffer*/
                if ((retval = fwrite(matbuff,sizeof(float),count,fp))==0)
                {
                    fprintf(stderr, "Could not write average int into the int mat file\n");
                    return retval;
                }
	}
        return retval;
}

/**************************************************************
Function Name: caldas() 
Description:  
	    initialize of elements in das struct 
Date: 01/9/02
**************************************************************/
void calcdas(dasrec* dr,data_param* dp)
{

    dr->m.nsamp	= dr->ad_samples; 		/* make mode samples = number of input samples  ????*/
    dr->m.ncsamp = dr->m.nsamp/2;		/* # of complex samples per sequence*/

    /*	¥	move over segment shading parameters*/
    if(dr->SonarType == SONAR_50kHz)
    {
            dp->combine_segments = dr->combine_segments;
            if(dp->combine_segments == 1)
            {
                    dp->nbeams = 4;
            }
            else
                    dp->nbeams = 16;
    }
    else
    {
            dp->nbeams = 4;			/*	# of beams*/
    }
    
    dr->m.nbins	= (dr->m.ncsamp/dr->m.ravg)-1;	   /* # range bins samples per lag*/
    dr->m.covsize = dr->m.nbins * dp->nbeams * 2;  /* size of single  covariance buffer(elements)*/
    dr->m.intsize = dr->m.nbins * dp->nbeams;      /* size of single intensity buffer(elements)*/
    dr->m.sn_size = dr->m.nbins * dp->nbeams;	   /* size of single signal to noise buffer*/
    dr->m.jan_size = dr->m.nbins * 4;		   /* size of single janus buffer*/
    if(dr->SonarType == SONAR_50kHz)		   /* have 50kHz sonar*/
        dr->nx = NCHANNELS_50kHz;		   /* number of a/d channels to aquire must be even*/
    else					   /* 50kHz: 16, 40kHz: 4*/
        dr->nx = NCHANNELS_140kHz;
    /*	size of incoherent buffer(elements)	*/
    dr->m.incsize = 2*dr->m.covsize + dr->m.intsize + dr->m.sn_size + dr->m.jan_size;	
    dp->rec_raw	= dr->rec_raw;			   /* data mode, 0 = raw, 1 = processed*/
    dp->nx = dr->nx;				   /* # of channels (red boards * 2)*/
    dr->envbuffsize=0;
    echannels = 0;
    esamples = 0;
    if(dr->rec_raw)
            dr->databuffsize	=	(dr->nx*dr->m.nsamp*2);
    else
            dr->databuffsize	=	(dr->m.incsize)*sizeof(float);	/* for the whole data(cov,int,sn,jan)*/
}
/**************************************************************
Function Name: ChkFileEnd() 
Description:  
	    initialize of elements in das struct 
Date: 01/9/02
**************************************************************/
void	ChkFileEnd(playparams *pp,FILE* dfp,FILE* vfp,long *Diskrecnum)
{
	long		oldrec,count,filelength;

	if( rh.rec_num == (pp->max_rec-1))
	{
                fprintf(stderr, "Choose the Next Data File\n");
		*Diskrecnum = 0;
	}
}

/**************************************************************
Function Name: createOutFilename(char*, char*)
Description:  get the file name from user and chop the date of the file name, 
	      create the output file name with concated date. 
              Ex: data[01/04/2002] -> create output filename: matfile[01/04/2002]
Date: 01/4/02
**************************************************************/
void createOutFilename(char *fileIn, char *fileOut)
{
	int i, j;
	char prefix[20]="\0";

	/* get prefix of the file Input*/
	i = j = 0;
	while(*fileIn)
	{
             if (*fileIn=='[')
		while(*fileIn)
		    prefix[j++] = *fileIn++;
	     else
		*fileIn++;
	}
	prefix[j] = '\0';	/* terminate prefix string*/
        i = strlen(fileOut);

        /* concat prefix to fileOut name*/
        j = 0;
        while(prefix[j]!='\0')
                fileOut[i++] = prefix[j++];
        fileOut[i] = '\0';
}

/**************************************************************
Function Name: open_writeMatfile()  
Description: open the file and write header information and data name
**************************************************************/
FILE* open_writeHeader2Matfile(
long type,      /* Type flag: Normally 0 for PC, 1000 for Sun, Mac, and	 */
		/*	 Apollo, 2000 for VAX D-float, 3000 for VAX G-float    */
		/*	 Add 1 for text variables.	 */
		/*	 Add 10 for single precision */
		/*	 See LOAD in reference section of guide for more info. */
long mrows,	/*	 row dimension */
long ncols,	/*	 column dimension */
long imagf,	/*	 imaginary flag */
char *pname,	/*	 pointer to matrix name */
char *fileOut)	/*   file name	*/
{
	Fmatrix mheader;
	long mn;
	FILE* fpOut=NULL;
	long count;
	size_t retval;
	
	mheader.type = type;
	mheader.mrows = mrows;
	mheader.ncols = ncols;
	mheader.imagf = imagf;
	mheader.namlen = strlen(pname) + 1;
	mn = mheader.mrows * mheader.ncols;

        if((fpOut = fopen(fileOut, "w")) == NULL)
	{
          fprintf(stderr,"Could not open file for writting\n");
	}
	else
	{
	   /* write header (Fmatrix) into mat file*/
	   count = sizeof(Fmatrix);
	    if((retval = fwrite(&mheader, 1, count,fpOut))==0)
                fprintf(stderr,"Could not write the header into the mat file - in open_writeMat routine\n");
            else
            {
/*                fprintf(stderr,"In open_writeMatfile, written fmatrix into %s file %d bytes\n", fileOut, retval);*/
                /* next, write the file's name*/
                count = sizeof(char)*(long)mheader.namlen;
                if ((retval = fwrite(pname,1,count,fpOut))==0)
                    fprintf(stderr,"Could not write the file name into the mat file - in open_writeMat routine\n");
/*                else printf("In open_writeMatfile, written data name into %s file %d bytes\n", fileOut, retval);*/
            }
        }
	return(fpOut);
}

/**************************************************************
Function Name: write_header()  
Description: write header information (timemark and data)
**************************************************************/
int	write_header(rheader* rh,float* matbuff,FILE* fp)
{
	long			count;
	float			jday;
        int 			retval;
	
	jday = (float)((double)(rh->timemark) / 20.0 / 86400.0);

	*matbuff = (float)((rh->timemark & 0xffff0000) >> 16);	/*high bytes*/
	*(matbuff+1) = (float)(rh->timemark & 0x0000ffff);	/*low bytes*/
	*(matbuff+2) = jday;

	count = sizeof(float) * HeaderSize;
	if((retval=fwrite(matbuff,1,count,fp))==0)
            return 0;
        else
        return retval;
}
/**************************************************************
Function Name: writeMatheader()  
Description: copy from stream pointed to by fpIn, 
             stroring them at the location given by fpOut
Vars:
 	long type;       Type flag: 
			Normally 0 for PC, 1000 for Sun, Mac, and
			Apollo, 2000 for VAX D-float, 3000 for VAX G-float 
			Add 1 for text variables.	 
			Add 10 for single precision 
			See LOAD in reference section of guide for more info. 
	long mrows;	row dimension 
	long ncols;	column dimension 
	long imagf;	imaginary flag 
	char *pname;	pointer to matrix name 
	short refnum;	refnum of already open matfile 	
**************************************************************/
int WriteMatHeader(long type,char* pname,long mrows,long ncols,long imagf,FILE* fp)
{
	Fmatrix x;
	long count;
        int retval;
        int total = 0;
	
	x.type = type;
	x.mrows = mrows;
	x.ncols = ncols;
	x.imagf = imagf;
	x.namlen = strlen(pname) + 1;

        fseek(fp,0L,SEEK_SET);	/* set file position at start of the file for rewrite header information*/
	count = sizeof(Fmatrix);
	if((retval = fwrite(&x, 1,count,fp))==0)
        {
            fprintf(stderr,"Could not write Fmatrix for the mat header\n");
            return 0;
        }
        total = retval;
	count = sizeof(char)*(long)x.namlen;
	if((retval = fwrite(pname,1, count,fp))==0)
        {
            fprintf(stderr,"Could not write pname for the mat header\n");
            return 0;
        }
        total += retval;
        return total;
}

