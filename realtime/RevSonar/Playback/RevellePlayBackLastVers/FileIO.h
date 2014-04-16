/*
 *  FileIO.h
 *  playback.pb
 *
 *  Created by mnbui on Thu Jan 10 2002.
 *  Copyright (c) 2001 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef __FILEIO_H__
#define __FILEIO_H__

#include <stdio.h>
long filesize(FILE*);
void filecopy(FILE*, FILE*);
#endif
