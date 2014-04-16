/*
 * FILE: readbiodrv.c
 *
 * usage:
 *
 * [pings,time,pos,head]=readbiodrv(fname,dx,dz)
 *
 * where: fname is the Biosonics file to be read, dx is a horizontal
 * decimation factor and dz a vertical decimation factor.  pings is
 * atructure with ping information, time is a structure with time info,
 * pos a structure with position info, and head a structure with some
 * header info.  See fastreadbio.m for how to use the output
 * meaningfully.
 *
 *-Updated by G. Avicola and R. Kreth 2006-08-06.  Fixed Jody's math.
 *The original output was being written as pings.samples.  However pings.samples
 *is a 16bit integer which is to small to hold the true output, which is 4095.*2.^15.
 *Therefore, we introduce a new variable, samples32, which is a 32 bit integer.  We then decimate
 *as needed and output the data through the 32 bit integer 'out'.
 *pings.samples is no longer output, instead, we output pings.out.  As a result
 *we now need to update fast_read_bio.m
 *Also, I have much improved the code comments so as to improve code clarity.
 *
 * Updated by A. Kelbert in September 2008. Fixed Greg's GPS parsing
 * Updated by E. Shroyer in June 2009 with help from her brother and J. Early-->
 *    Generalized code to compile on 64 bit unix.
 *      To compile:
 *
 *   >> mex readbiodrv.c
 *
 *
 */

/* $Author: aperlin $ $Date: 2008/10/07 16:38:53 $ $Revision: 1.4 $
 */

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "mex.h"

#define MAXSIZE 65530

void mexFunction(int		nlhs,
        mxArray	*plhs[],
        int		nrhs,
        const mxArray	*prhs[]
        ) {
    char  fname[256];
    mxArray *pings;
    mxArray *timestr;
    mxArray *pos;
    mxArray *head;
    mxArray *fout;
    /* Output fields, number and names */
    int    nfields = 3;
    const char  *fieldnames[]={"out", "systime", "pingnum"};
    /* Position output fields, number and names*/
    int    nposfields = 4;
    const char    *posnames[]   = {"navtime", "lon", "lat", "systime"};
    /*Time output fields, number and names*/
    int    ntimefields = 3;
    const char    *timenames[]   = {"systime", "time", "subseconds"};
    /*Head output fields, number and names*/
    int    nheadfields = 6;
    const char    *headnames[]   = {"pulselength", "pingrate", "initialblanking", "absorption",
    "soundvel", "sampleperiod"};
    FILE   *fin;
    unsigned short   tupleType;
    unsigned short   tupleCount;
    unsigned short   tuplePadding;
    unsigned short   channel, nsamples;
    
    /*data input*/
    unsigned short   *samples;
    unsigned int     *samples32=0;
    unsigned int      dat=0;
    /*data output*/
    unsigned int    *out=0;
    unsigned int     *newsystime=0;
    unsigned short   mantissa, exponent;
    unsigned short   *ptr;
    unsigned int     *uintptr=0;
    int              *intptr=0;
    unsigned char    *charptr;
    unsigned short   sampleperiod;
    unsigned  int    *pingnum=0, *systime=0;
    unsigned int     latestsystime=0;
    unsigned int     npings=0;
    char             tupleData[MAXSIZE];
    int              pingno=0, timeno=0, i=0, posno=0, starti=0, stopi=0, startj=0, stopj=0;
    int              ii=0, jj=0, j=0, thepos=0, ppos=0, mytupleCount=0;
    unsigned short   nx=0, nz=0;
    unsigned int     dati=0;
    /* time stuff */
    unsigned int     time[MAXSIZE];
    unsigned int     timesystime[MAXSIZE];
    unsigned char    subsecond[MAXSIZE];
    /* position stuff */
    int              latitude[MAXSIZE];
    int              longitude[MAXSIZE];
    unsigned int     possystime[MAXSIZE];
    unsigned int     navtime[MAXSIZE];
    /* header stuff */
    unsigned short   absorption;
    unsigned short   soundvel;
/*
    short            temperature;
    unsigned short   salinity;
    short            powersetting;
*/
    /* channel descriptor */
    unsigned short   pulselength;
    unsigned short   pingrate;
    unsigned short   initialblanking;
    unsigned short   dx, dz;
    /* gps string parsing */
    const char       delimiters[] = "$,";
    char             *gpsstring;
    char             *gpsfield, gpstemp[8];
    float            gpsvalue;
    int              igps=0;
    
    
    double f;
    
    if(nrhs != 3) {
        mexErrMsgTxt("Error: readbiodrv needs 3 input arguments.");
    }
    
    mxGetString(prhs[0], fname, (mxGetM(prhs[0])*mxGetN(prhs[0])*sizeof(mxChar))+1);
    dx=(unsigned short)mxGetScalar(prhs[1]);
    dz=(unsigned short)mxGetScalar(prhs[2]);
    
    /*----------------------------------------------------*/
    /* open the file */
    fin=fopen(fname, "rb");
    
    /* read in the first tuple... */
    fread(&tupleCount, sizeof(tupleCount), 1, fin);
    if (tupleCount>=MAXSIZE) {
        mexPrintf("%d %d %d\n", tuplePadding, tupleCount, MAXSIZE);
        mexErrMsgTxt("READBIODRV: first tupleCount too big.");
    }
    fread(&tupleType, sizeof(tupleType), 1, fin);
    fread(tupleData, sizeof(char), tupleCount, fin);
    fread(&tuplePadding, sizeof(unsigned short), 1, fin);
    
    /* HEADER tuple..., read in the header data */
    fread(&tupleCount, sizeof(tupleCount), 1, fin);
    
    fread(&tupleType, sizeof(tupleType), 1, fin);
    fread(tupleData, sizeof(char), tupleCount, fin);
    fread(&tuplePadding, sizeof(unsigned short), 1, fin);
    memcpy(&absorption, &tupleData[0], sizeof(absorption));
    memcpy(&soundvel, &tupleData[2], sizeof(soundvel));
    
/*
    printf("absorption= %d\n", absorption);
    printf("soundvel= %d\n", soundvel);
    printf("size of absorption= %d\n", sizeof(absorption));
*/
    
    /* CHANNEL DESCRIPTOR tuple...  read in the number of channels (for us, always 1) */
    fread(&tupleCount, sizeof(tupleCount), 1, fin);
    if (tupleCount>=MAXSIZE) {
        mexErrMsgTxt("READBIODRV: Decrtiptor tupleCount too big.");
    }
    fread(&tupleType, sizeof(tupleType), 1, fin);
    fread(tupleData, sizeof(char), tupleCount, fin);
    fread(&tuplePadding, sizeof(unsigned short), 1, fin);
    
    /* assign ping variables their data for each channel */
    memcpy(&npings, &tupleData[2], sizeof(npings));
    memcpy(&nsamples, &tupleData[6], sizeof(nsamples));
    memcpy(&sampleperiod, &tupleData[8], sizeof(sampleperiod));
    memcpy(&pulselength, &tupleData[12], sizeof(pulselength));
    memcpy(&pingrate, &tupleData[14], sizeof(pingrate));
    memcpy(&initialblanking, &tupleData[16], sizeof(pingrate));
    
    /* allocate the sample array  */
    pingnum=(unsigned int*)mxMalloc(sizeof(unsigned int)*npings);
    systime=(unsigned int*)mxMalloc(sizeof(unsigned int)*npings);
    samples=(unsigned short*)mxMalloc(sizeof(unsigned short)*nsamples*npings);
    samples32=(unsigned int*)mxMalloc(sizeof(unsigned int)*nsamples*npings);
    
    
    /* start reading in each tuple in order */
    while (fread(&tupleCount, sizeof(tupleCount), 1, fin)) {
        if (tupleCount>=MAXSIZE) {
            mexPrintf("%d %d %d %d %d\n", tuplePadding, tupleCount, pingno, MAXSIZE, (tupleCount>=MAXSIZE));
            mexErrMsgTxt("READBIODRV: tupleCount in middle too big.");
        }
        fread(&tupleType, sizeof(tupleType), 1, fin);
        fread(tupleData, sizeof(char), tupleCount, fin);
        fread(&tuplePadding, sizeof(unsigned short), 1, fin);
        mytupleCount++;
        
        if (tuplePadding!=tupleCount+6) {
            mexPrintf("%d %d %d\n", tuplePadding, tupleCount, pingno);
            mexPrintf("READBIODRV: tupleCount and tuplePadding do not match - corrupt file.");
            fseek(fin, 0, SEEK_END);
        }
        
        /* ping tuple if tupleType = x0015 */
        if (tupleType==0x0015) {
            memcpy(&channel, &tupleData[0], sizeof(channel));
            memcpy(&pingnum[pingno], &tupleData[2], sizeof(int));
            memcpy(&systime[pingno], &tupleData[6], sizeof(int));
            
            latestsystime=systime[pingno];
            
            /* read in ping data and put into sample matrix */
            memcpy(&samples[pingno*nsamples], &tupleData[12], sizeof(short)*nsamples);
            pingno=pingno+1;
        }
        
        /*if type x000F its a time tuple*/
        else if  (tupleType==0x000F) {
            memcpy(&time[timeno], &tupleData[0], sizeof(int));
            memcpy(&(subsecond[timeno]), &tupleData[5], sizeof(subsecond[timeno]));
            memcpy(&(timesystime[timeno]), &tupleData[6], sizeof(timesystime[timeno]));
            
            latestsystime=timesystime[timeno];
            timeno = timeno+1;
        }
        
        /*if its type x0011 its a GPS ASCII tuple*/
        else if (tupleType==0x0011) {
            gpsstring = tupleData;
            igps = 1;
            gpsfield = strtok(gpsstring, delimiters);
            while ((gpsfield != NULL) && (strcmp(gpsfield, "GPGGA") != 0)) {
                gpsfield = strtok(NULL, delimiters);  /* stops when GPGGA is read */
                igps += 1;
            }
            
            /*read in timestamp
            Ray says, 'Not enough error checking in here!  Some other postdoc will probably have to generalize this."
            Greg replies, 'I don't care, because I'm on a ship, and its late, and this is going to work."
            Anya says, 'Oh well... it's not the first Sunday that I waste debugging other peoples' code...
                At least it should be robust enough now."
            Emily's brother says this file is crap.
             */
            
            possystime[posno]=latestsystime;
            
            gpsfield = strtok(NULL, delimiters);    /* gpsfield => time */
            
            navtime[posno]=0;
            navtime[posno]=navtime[posno]+(unsigned int)(*(gpsfield)-48)*10*3600;
            navtime[posno]=navtime[posno]+(unsigned int)(*(gpsfield+1)-48)*3600;
            navtime[posno]=navtime[posno]+(unsigned int)(*(gpsfield+2)-48)*10*60;
            navtime[posno]=navtime[posno]+(unsigned int)(*(gpsfield+3)-48)*60;
            navtime[posno]=navtime[posno]+(unsigned int)(*(gpsfield+4)-48)*10;
            navtime[posno]=navtime[posno]+(unsigned int)(*(gpsfield+5)-48);
            
            gpsfield = strtok(NULL, delimiters);    /* gpsfield => latitude (magnitude) */
            
            /*read in latitude*/
            latitude[posno]=0;
            latitude[posno]=latitude[posno]+(unsigned int)(*(gpsfield)-48)*10*100000*60;
            latitude[posno]=latitude[posno]+(unsigned int)(*(gpsfield+1)-48)*100000*60;
            if(EOF == sscanf(gpsfield+2, "%f", &gpsvalue)) {
                mexErrMsgTxt("Unable to read latitude in minutes");
            }
            latitude[posno]=latitude[posno]+gpsvalue*100000;
            
            gpsfield = strtok(NULL, delimiters);    /* gpsfield => latitude (direction) */
            /*north or south?*/
            if (toupper(*(gpsfield))=='S') {
                latitude[posno]=latitude[posno]*-1;
            }
            
            gpsfield = strtok(NULL, delimiters);    /* gpsfield => longitude (magnitude) */
            
            /*read in longitude*/
            longitude[posno]=0;
            longitude[posno]=longitude[posno]+(unsigned int)(*(gpsfield)-48)*100*100000*60;
            longitude[posno]=longitude[posno]+(unsigned int)(*(gpsfield+1)-48)*10*100000*60;
            longitude[posno]=longitude[posno]+(unsigned int)(*(gpsfield+2)-48)*100000*60;
            if(EOF == sscanf(gpsfield+3, "%f", &gpsvalue)) {
                mexErrMsgTxt("Unable to read longitude in minutes");
            }
            longitude[posno]=longitude[posno]+gpsvalue*100000;
            
            gpsfield = strtok(NULL, delimiters);    /* gpsfield => longitude (direction) */
            /*east or west?*/
            if (toupper(*(gpsfield))=='W') {
                longitude[posno]=longitude[posno]*-1;
            }
            
            f = 1e-5/60.0;
            
            posno = posno+1;       
        } 
    }
    fclose(fin);
    
    /*----------------------------------------------------------*/
    /*all data is now loaded - compute output data from ping samples */
    /* The data is stored in a 16 bit float - the first four bits are the exponent,
     *the last 12 bits are the mantissa, where the biosonics output is M * 2^E */
    for (i=0;i<npings*nsamples;i++){
        /* Find mantissa - we clear the exponent byte and compute*/
        mantissa = samples[i] & 0x0FFF;
        /*find exponent - bit shift 12 bits to the right (clearing mantissa)*/
        exponent = samples[i]>>12;
        /*output is a 32 bit integer which is M*2.^E, here computed as manitssa bitshifted by exponent*/
        samples32[i] =(unsigned int)(mantissa << exponent);
    }
    
    /*aloc a new array so we can decimate the samples32 data and output it*/
    nx = (unsigned short)floor((double)(npings/dx));
    nz = (unsigned short)floor((double)(nsamples/dz));
    out = mxMalloc(nz*nx*sizeof(unsigned int));
    newsystime = mxMalloc(nx*sizeof(unsigned int));
    
    for (i=0;i<nx;i++){
        for (j=0;j<nz;j++){
            thepos = i*nz+j;
            starti = i*dx;
            stopi  = (i+1)*dx;
            startj = j*dz;
            stopj  = (j+1)*dz;
            dat=0;
            
            for (ii=starti;ii<stopi;ii++){
                for (jj=startj;jj<stopj;jj++){
                    ppos = ii*nsamples+jj;
                    dat = dat+samples32[ppos];
                }
            }
            dat = dat/(unsigned int)(dx*dz);
            out[thepos] = (unsigned int)dat;
          }
    }
    
    
    for (i=0;i<npings/dx;i++){
        newsystime[i] = systime[i*dx+(int)floor((double)dx/2)];
    }
    
    
    /* that should be it.  Now lets write it out somehow.*/
    
    pings=mxCreateStructMatrix(1, 1, nfields, fieldnames);
    timestr=mxCreateStructMatrix(1, 1, ntimefields, timenames);
    pos=mxCreateStructMatrix(1, 1, nposfields, posnames);
    head=mxCreateStructMatrix(1, 1, nheadfields, headnames);
    
    
    /* now fill these in.  Ummm, how?  */
    
    fout = mxCreateNumericMatrix(nsamples/dz, npings/dx, mxUINT32_CLASS, mxREAL);
    intptr = (unsigned int*)mxGetPr(fout);
    memcpy(intptr, out, (nx)*(nz)*sizeof(unsigned int));
    mxSetField(pings, 0, "out", fout);
    
    fout = mxCreateNumericMatrix(1, nx, mxUINT32_CLASS, mxREAL);
    intptr = (unsigned int*)mxGetPr(fout);
    memcpy(intptr, pingnum, nx*sizeof(unsigned int));
    mxSetField(pings, 0, "pingnum", fout);
    
    fout = mxCreateNumericMatrix(1, npings/dx, mxUINT32_CLASS, mxREAL);
    intptr = (unsigned int*)mxGetPr(fout);
    memcpy(intptr, newsystime, nx*sizeof(unsigned int));
    mxSetField(pings, 0, "systime", fout);
    
    /* timestr */
    fout = mxCreateNumericMatrix(1, timeno, mxUINT32_CLASS, mxREAL);
    intptr = (unsigned int*)mxGetPr(fout);
    memcpy(intptr, timesystime, timeno*sizeof(unsigned int));
    mxSetField(timestr, 0, "systime", fout);
    
    fout = mxCreateNumericMatrix(1, timeno, mxUINT32_CLASS, mxREAL);
    intptr = (unsigned int*)mxGetPr(fout);
    memcpy(intptr, time, timeno*sizeof(unsigned int));
    mxSetField(timestr, 0, "time", fout);
    
    fout = mxCreateNumericMatrix(1, timeno, mxUINT8_CLASS, mxREAL);
    charptr = (unsigned char*)mxGetPr(fout);
    memcpy(charptr, subsecond, timeno*sizeof(unsigned char));
    mxSetField(timestr, 0, "subseconds", fout);
    
    /* pos */
    fout = mxCreateNumericMatrix(1, posno, mxUINT32_CLASS, mxREAL);
    uintptr = (unsigned int*)mxGetPr(fout);
    memcpy(uintptr, navtime, posno*sizeof(unsigned int));
    mxSetField(pos, 0, "navtime", fout);
    
    fout = mxCreateNumericMatrix(1, posno, mxINT32_CLASS, mxREAL);
    intptr = (int*)mxGetPr(fout);
    memcpy(intptr, longitude, posno*sizeof(int));
    mxSetField(pos, 0, "lon", fout);
    
    fout = mxCreateNumericMatrix(1, posno, mxINT32_CLASS, mxREAL);
    intptr = (int*)mxGetPr(fout);
    memcpy(intptr, latitude, posno*sizeof(int));
    mxSetField(pos, 0, "lat", fout);
    
    fout = mxCreateNumericMatrix(1, posno, mxUINT32_CLASS, mxREAL);
    uintptr = (unsigned int*)mxGetPr(fout);
    memcpy(uintptr, possystime, posno*sizeof(unsigned int));
    mxSetField(pos, 0, "systime", fout);
    
    /* header stuff */
    fout = mxCreateNumericMatrix(1, 1, mxUINT16_CLASS, mxREAL);
    ptr = (unsigned short*)mxGetPr(fout);
    memcpy(ptr, &pulselength, sizeof(unsigned short));
    mxSetField(head, 0, "pulselength", fout);
    
    fout = mxCreateNumericMatrix(1, 1, mxUINT16_CLASS, mxREAL);
    ptr = (unsigned short*)mxGetPr(fout);
    memcpy(ptr, &pingrate, sizeof(unsigned short));
    mxSetField(head, 0, "pingrate", fout);
    
    fout = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    uintptr = (unsigned int*)mxGetPr(fout);
    dati = (unsigned int)sampleperiod*dz;
    memcpy(uintptr, &dati, sizeof(unsigned int));
    mxSetField(head, 0, "sampleperiod", fout);
    
    fout = mxCreateNumericMatrix(1, 1, mxUINT16_CLASS, mxREAL);
    ptr = (unsigned short*)mxGetPr(fout);
    initialblanking = (100*initialblanking)/dz;
    memcpy(ptr, &initialblanking, sizeof(unsigned short));
    mxSetField(head, 0, "initialblanking", fout);
    
    fout = mxCreateNumericMatrix(1, 1, mxUINT16_CLASS, mxREAL);
    ptr = (unsigned short*)mxGetPr(fout);
    memcpy(ptr, &absorption, sizeof(unsigned short));
    mxSetField(head, 0, "absorption", fout);
    
    fout = mxCreateNumericMatrix(1, 1, mxUINT16_CLASS, mxREAL);
    ptr = (unsigned short*)mxGetPr(fout);
    memcpy(ptr, &soundvel, sizeof(unsigned short));
    mxSetField(head, 0, "soundvel", fout);
    
    /*
  fout = mxCreateNumericMatrix(1,1,mxUINT16_CLASS,mxREAL);
  ptr = (unsigned short*)mxGetPr(fout);
  memcpy(ptr,&salinity,sizeof(unsigned short));
  mxSetField(head,0,"salinity",fout);
 
  fout = mxCreateNumericMatrix(1,1,mxINT16_CLASS,mxREAL);
  ptr = (short*)mxGetPr(fout);
  memcpy(ptr,&temperature,sizeof(short));
  mxSetField(head,0,"temperature",fout);
 
  fout = mxCreateNumericMatrix(1,1,mxINT16_CLASS,mxREAL);
  ptr = (short*)mxGetPr(fout);
  memcpy(ptr,&powersetting,sizeof(short));
  mxSetField(head,0,"powersettings",fout);
     */
    
    plhs[0]=pings;
    plhs[1]=timestr;
    plhs[2]=pos;
    plhs[3]=head;
    
}

