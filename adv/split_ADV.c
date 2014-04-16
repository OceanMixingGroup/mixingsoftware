/*
 * FILE: split_ADV.c

usage:

	split_ADV(directory,extension,startfile#,endfile#,samplefreq)

where: 
 *directory: the directory in which the persistor ADV files are located, and the output files will be written to.  Input persistor files should be of type ########.YYY  where ########
 *is the unique time stamp written by the persistor and the YYY is the file extention for that instrument.  
 *Extension: see above, YYY
 *startfile#: first filename in sequence (enter as a string)
 *endfile#: last filename in sequence (enter as a string)
 *samplefreq: sample frequency set on ADV
 *
 *Thus to process files named 01011111.CH1 to 01011234.CH1 you would use the command:
 *split_ADV('c:\directory\offiles','CH1','01011111','01011234',9.96);
 *
 *program will output ADV files suitable for reading in read_adv.m.  Each file will include 36000 ADV data per file.  Files will be written as OUTZZZZ.adv where ZZZZ is a number starting
 *from 0000 and counting upwards.
 *
 *
 *      To compile:
 *
 *   >> mex split_ADV.c (Must include ansi_c.h and stdio.h if not in path) 
 *
 *
 */

/* $Author: aperlin $ $Date: 2008/01/31 20:22:41 $ $Revision: 1.1.1.1 $
 */

/*#include <ansi_c.h>*/
#include <stdio.h>	
#include "mex.h"

void mexFunction(int		nlhs,
		 mxArray	*plhs[],
		 int		argc,
		 const mxArray *argv[]
		 )
{


	 int testbool,start,stop,filecount;			  
	 int i,j,headcnt,countchar,bytelen,outnum,innum,place,timecount;
     unsigned int dtime,dt1,dt2,dt3,dt4;
	 char dirname[300],extension[10],address[340],filename[40],nextfile[40],openfile[40];
	 unsigned char outbuffer[22],inbuffer[10000],grab[4096];
	 unsigned char junk[100],test,time[4];
     float samplefreq;
	 FILE *FLIST; 
	 FILE *OPENADV;
	 FILE *WRITEADV;
	 

						   
     /*samplefreq=9.96;*/
	 /* check to see if input arguements were given*/
	 if (argc!=5) {
	 	printf("Incorrect # of input arguements.\n");
	 	scanf("%s",address);     
	 	return;
	 }
	 
	 /*directory name*/
	 mxGetString(argv[0],dirname,(mxGetM(argv[0])*mxGetN(argv[0])*sizeof(mxChar))+1);
	 strcat(dirname,"\\");
     
	 /*extension name (given by the persistor)*/
	 strcpy(extension,".");
     mxGetString(argv[1],junk,(mxGetM(argv[1])*mxGetN(argv[1])*sizeof(mxChar))+1);
     strcat(extension,junk);
	 
	 /*startfile#*/
	 mxGetString(argv[2],junk,(mxGetM(argv[2])*mxGetN(argv[2])*sizeof(mxChar))+1);
     sscanf(junk,"%d",&start);

	 /*stopfile#*/
	 mxGetString(argv[3],junk,(mxGetM(argv[3])*mxGetN(argv[3])*sizeof(mxChar))+1);
     sscanf(junk,"%d",&stop);
     
     samplefreq=(float)mxGetScalar(argv[4]);
	 			
	 /* Open the first file on the list for preprocessing:*/
	 filecount=start;
	 sprintf(openfile,"%08d%s",filecount,extension);	 	 		
	 strcpy(address,dirname);
	 strcat(address,openfile);
	 OPENADV=fopen(address,"rb");

     if (OPENADV==NULL){
     	printf("Cannot find ADV file: %s\n",filename);
     	scanf("%s",address);     
	 	return;
     }
	 
	 /* lets find the length of the data files (headcnt) the persistor wrote  */
	 		   
	 fread(junk,1,12,OPENADV);
     headcnt=fgetc(OPENADV)*256;
     headcnt=headcnt+fgetc(OPENADV);
     headcnt=headcnt+14;
     printf("Persistor Data Length: %d\n",headcnt);
     
     /*Strip the next 11 bytes off (useless echo of command to start)*/
     fread(junk,1,11,OPENADV); 
     
     
	 /*next, we find out  the ADV data length (bytelen)*/  
	 i=fgetc(OPENADV);

     if (i==129) {
     	printf("Instrument type is ADV with No Sensors ( 18 byte record length)\n");
     	bytelen=18;
     } else if (i==131) {
     	printf("Instrument type is ADV with Compass ( 24 byte record length)\n");
     	bytelen=24;
     } else if (i==133) {
     	printf("Instrument type is ADV with TempPres Sensor ( 22 byte record length)\n");
     	bytelen=22;
     } else if (i==135) {
     	printf("Instrument type is ADV with TempPres Sensor and Compass ( 28 byte record length)\n");
     	bytelen=28;
     } else if (i==143) {
     	printf("Instrument type is ADV with TempPres Sensor Compass and external sensor( 32 byte record length)\n");
     	bytelen=32;
     } else {	
        printf("Cannot read ADV file: %s\n",filename);
     	scanf("%s",address);     
	 	return;
     }
	 
	 printf("ADV Data Length: %d\n\n",bytelen); 
	 fclose(OPENADV);

	 /*------------------------------------------------------------------------------------------*/
	 /* OK, we are done with the preliminaries.. now to read in data and export into a new file  */
	 /*------------------------------------------------------------------------------------------*/
	 
	 innum=0;outnum=0;testbool=0;
	 OPENADV=fopen(address,"rb");
	 printf("Opening file %s for reading\n",openfile);       
	 
	 sprintf(openfile,"OUT%04d%s",outnum,extension);
	 strcpy(address,dirname);
	 strcat(address,openfile);
	 printf("Opening file %s for writing, #%d\n",openfile,innum);
	 
	 WRITEADV=fopen(address,"wb");

	 /*strip chars from record and put into buffer (initialize the buffer)*/
	 countchar=fread(&grab[0],1,4096,OPENADV);

	 /*strip off header and read start time - write output header*/
	 
	 time[0]=grab[4];time[1]=grab[5];time[2]=grab[6];time[3]=grab[7];
     
     dtime=time[0]*256*256*256+time[1]*256*256+time[2]*256+time[3];
     
     dt1=dtime/(256*256*256);
     dt2=(dtime%(256*256*256))/(256*256);
     dt3=(dtime%(256*256*256)%(256*256))/256;
     dt4=dtime%(256*256*256)%(256*256)%256;
     
     time[0]=dt1;time[1]=dt2;time[2]=dt3;time[3]=dt4;
     printf("%4s\n",time);

    
	 timecount=0;
	 sprintf(junk,"Unix_st:%s   Unix_en:+36000 samples",time);  
	 fwrite(junk,1,40,WRITEADV);
	 								  
	 memcpy(inbuffer,&grab[25],countchar-25);countchar=countchar-25;
     										   
     do {
     	
     	if (countchar>=bytelen&innum<36000) {
     	
     		/*strip out all good data until file is smaller than a single data entry*/
     		
     		fwrite(inbuffer,1,bytelen,WRITEADV);
     		memcpy(inbuffer,&inbuffer[bytelen],countchar-bytelen);countchar=countchar-bytelen;
     		innum++;
     		timecount++;
     		
     		
     	} else if (countchar<bytelen) { 
     	
     		/* Read in next header+data group */
     		
     		j=fread(&grab[0],1,4096,OPENADV);
                 		
     		/* If no data left in file, open next file to read */ 
     		if (j==0) fclose(OPENADV);
     		
     		while (j==0) {
     			
     			 
     			
     			filecount++;
     			
     			if (filecount>stop) {
    				fclose(WRITEADV);
     				printf("Last file processed:\n");
     				scanf("%s",address); 
	 				return;
	 			}
	 			
	 			sprintf(openfile,"%08d%s",filecount,extension);	 
	 			strcpy(address,dirname);
	 			strcat(address,openfile);
	 			
	 			  
			    OPENADV=fopen(address,"rb");
			    
			    if (OPENADV!=NULL) {
			    	 
			    	printf("Opening file %s for reading\n",openfile); 
                    j=fread(&grab[0],1,4096,OPENADV);
                }

     		} 
     		
     		/* Store new time in case its needed */
     		time[0]=grab[4];time[1]=grab[5];time[2]=grab[6];time[3]=grab[7]; 
     		timecount=0;
     		
     		/* strip off header */
     		memcpy(grab,&grab[14],j-14);j=j-14;
     		
     		/*concat onto buffer*/
     		memcpy(&inbuffer[countchar],grab,j);countchar=countchar+j;
     		
     		
     	} else {
     		
     		/*close this ADVWRITE file, open the next ADVWRITE file*/
     		
     		fclose(WRITEADV);innum=0;
     		outnum++;
     		
     		sprintf(openfile,"OUT%04d%s",outnum,extension);
	 		strcpy(address,dirname);
	 		strcat(address,openfile);
	 		printf("Opening file %s for writing, #%d\n",openfile,outnum);
	 
	 		WRITEADV=fopen(address,"wb");
	 		
            /*add timestamp*/
            
  	 		dtime=time[0]*256*256*256+time[1]*256*256+time[2]*256+time[3]+(int)((float)(timecount)/(float)(samplefreq));
      
            dt1=dtime/(256*256*256);
            dt2=(dtime%(256*256*256))/(256*256);
            dt3=(dtime%(256*256*256)%(256*256))/256;
            dt4=dtime%(256*256*256)%(256*256)%256;
            
            time[0]=dt1;time[1]=dt2;time[2]=dt3;time[3]=dt4;
    
	 		sprintf(junk,"Unix_st:%s   Unix_en:+36000 samples",(time));   
	 		fwrite(junk,1,40,WRITEADV);
	 		
	 	}
     		
     	
     	
     		
     
     
     
     } while (testbool<8);
     
     
	   		   
	 
	 fclose(OPENADV);
	 fclose(WRITEADV);
	 
	 scanf("%s",address);             
	 
}
	 
	 
	 

	
	
	
	 
	 
	 	
		

