/*
 * FILE: split_ADP.c

usage:

	split_ADP(directory,extension,startfile#,endfile#)

where: 
 *directory: the directory in which the persistor ADV files are located, and the output files will be written to.  Input persistor files should be of type ########.YYY  where ########
 *is the unique time stamp written by the persistor and the YYY is the file extention for that instrument.  
 *Extension: see above, YYY
 *startfile#: first filename in sequence (enter as a string)
 *endfile#: last filename in sequence (enter as a string)
 *
 *Thus to process files named 01011111.CH1 to 01011234.CH1 you would use the command:
 *split_ADP('c:\directory\offiles','CH1','01011111','01011234');
 *
 *program will output ADV files suitable for reading in read_adv.m.  Each file will include 36000 ADV data per file.  Files will be written as OUTZZZZ.adv where ZZZZ is a number starting
 *from 0000 and counting upwards.
 *
 *
 *      To compile:
 *
 *   >> mex split_ADP.c (Must include ansi_c.h and stdio.h if not in path) 
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
	 unsigned int* p_timed;
	 char dirname[300],extension[10],address[340],filename[40],nextfile[40],openfile[40];
	 unsigned char outbuffer[22],inbuffer[10000],grab[4096],header[416];
	 unsigned char junk[100],test,time[4];
	 unsigned char* p_time;
	 FILE *FLIST; 
	 FILE *OPENADP;
	 FILE *WRITEADP;
	 

						   
	 /* check to see if input arguements were given*/
	 if (argc!=4) {
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
     
          
     /*OPEN Header File*/
     strcpy(address,dirname);
     strcat(address,"ADPheader.inf");
     OPENADP=fopen(address,"rb");
     fread(&header[0],1,416,OPENADP);
     fclose(OPENADP);
     
 	 /* Open the first file on the list for preprocessing:*/
	 filecount=start;
	 sprintf(openfile,"%08d%s",filecount,extension);
     strcpy(address,dirname);
     strcat(address,openfile);
     OPENADP=fopen(address,"rb");

     if (OPENADP==NULL){
     	printf("Cannot find ADP file: %s\n",address);
     	return;
     }
	 
	 /* lets find the length of the data files (headcnt) the persistor wrote  */
	 		   
	 fread(junk,1,12,OPENADP);
     headcnt=fgetc(OPENADP)*256;
     headcnt=headcnt+fgetc(OPENADP);
     headcnt=headcnt+14;
     printf("Persistor Data Length: %d\n",headcnt);
     
     /*Strip bytes until first synchar A5(hex) */
     i=0;
     do {
         j=fgetc(OPENADP);
         i++;
     }while (j!=165);
    
     
     
     /*find next syncchar*/  
     
     i=0;
     do {
         j=fgetc(OPENADP);
         i++;
     } while (j!=165);
     
     bytelen=i;
     
	 printf("ADP Data Length: %d\n\n",bytelen); 
	 fclose(OPENADP);
        
   
	 /*------------------------------------------------------------------------------------------*/
	 /* OK, we are done with the preliminaries.. now to read in data and export into a new file  */
	 /*------------------------------------------------------------------------------------------*/
	 
	 innum=0;outnum=0;testbool=0;
	 OPENADP=fopen(address,"rb");
	 printf("Opening file %s for reading\n",openfile);       
	 
	 sprintf(openfile,"OUT%04d.adp",outnum);
	 strcpy(address,dirname);
	 strcat(address,openfile);
	 printf("Opening file %s for writing, #%d\n",openfile,innum);
	 
	 WRITEADP=fopen(address,"wb");
     
     /*put header onto ADP file*/
     fwrite(header,1,416,WRITEADP);
     
	 /*strip chars from record and put into buffer (initialize the buffer)*/
	 countchar=fread(&grab[0],1,4096,OPENADP);

	 /*strip off header*/
	 	 								  
	 memcpy(inbuffer,&grab[26],countchar-26);countchar=countchar-26;
     										   
     do {
     	
     	if (countchar>=bytelen&innum<3600) {
     	
     		/*strip out all good data until file is smaller than a single data entry*/
     		
     		fwrite(inbuffer,1,bytelen,WRITEADP);
     		memcpy(inbuffer,&inbuffer[bytelen],countchar-bytelen);countchar=countchar-bytelen;
     		innum++;
     		timecount++;
     		
     		
     	} else if (countchar<bytelen) { 
     	
     		/* Read in next header+data group */
     		
     		j=fread(&grab[0],1,4096,OPENADP);
                 		
     		/* If no data left in file, open next file to read */ 
     		if (j==0) fclose(OPENADP);
     		
     		while (j==0) {
     			
     			 
     			
     			filecount++;
     			
     			if (filecount>stop) {
    				fclose(WRITEADP);
     				printf("Last file processed:\n");
     				scanf("%s",address); 
	 				return;
	 			}
	 			
	 			sprintf(openfile,"%08d%s",filecount,extension);	 
	 			strcpy(address,dirname);
	 			strcat(address,openfile);
	 			
	 			  
			    OPENADP=fopen(address,"rb");
			    
			    if (OPENADP!=NULL) {
			    	 
			    	printf("Opening file %s for reading\n",openfile); 
                    j=fread(&grab[0],1,4096,OPENADP);
                }

     		} 
     		
     		/* strip off header */
     		memcpy(grab,&grab[14],j-14);j=j-14;
     		
     		/*concat onto buffer*/
     		memcpy(&inbuffer[countchar],grab,j);countchar=countchar+j;
     		
     		
     	} else {
     		
     		/*close this ADPWRITE file, open the next ADPWRITE file*/
     		
     		fclose(WRITEADP);innum=0;
     		outnum++;
     		
     		sprintf(openfile,"OUT%04d.adp",outnum);
	 		strcpy(address,dirname);
	 		strcat(address,openfile);
	 		printf("Opening file %s for writing, #%d\n",openfile,outnum);
	 
	 		WRITEADP=fopen(address,"wb");
            
            /*write header*/
            fwrite(header,1,416,WRITEADP);
	 		
	 	}
     		
     	
     	
     		
     
     
     
     } while (testbool<8);
     
     
	   		   
	 
	 fclose(OPENADP);
	 fclose(WRITEADP);
	 
	 scanf("%s",address);             
	 
}
	 

	
	
	
	 
	 
	 	
		

