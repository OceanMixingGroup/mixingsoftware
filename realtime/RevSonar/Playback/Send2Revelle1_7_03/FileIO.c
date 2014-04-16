/*
 *  FileIO.c
 *  playback.pb
 *
 *  Created by mnbui on Thu Jan 10 2002.
 *  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
 *
 */
#include "FileIO.h"

/**************************************************************
Function Name: filesize
Description: get size of the file from the current position in the file
**************************************************************/
long filesize(FILE* fpIn)
{
    long filesize = 0;
    int i;
    while(i=getc(fpIn)!=EOF)
        filesize++;
    return filesize;
}


/**************************************************************
Function Name: filecopy
Description: copy from stream pointed to by fpIn, 
             stroring them at the location given by fpOut
**************************************************************/
void filecopy(FILE* fpIn, FILE* fpOut)
{
	int i;
	while((i=getc(fpIn))!=EOF)
	    putc(i,fpOut);
}

