/*
 * FILE: readbiodrv.c
 *
 * usage:	[pings,time,pos,head] = readbiodrv(inputFileName, dx, dz)
 *
 * where:
 *    inputFileName is the Biosonics file to be read,
 *    dx is a horizontal decimation factor, and
 *    dz a vertical decimation factor.
 *
 * pings is a structure with ping information,
 * time is a structure with time info,
 * pos a structure with position info, and
 * head a structure with some header info.
 *
 * See fastreadbio.m for how to use the output meaningfully.
 *
 *
 *-Updated by G. Avicola and R. Kreth 2006-08-06.  Fixed Jody's math.
 *-Updated by A. Kelbert in September 2008. Fixed Greg's GPS parsing.
 *-Updated by E. Shroyer in June 2009. Compile on 64 bit system.
 *-Updated by E E Shroyer III 2009-06-24 General refactor of code for maintanability
 *             - Defined tuple type and function for reading Biosinics file
 *             - Renamed variables for clarity where possible
 *             - Added comments on flow control particularly around mexErrMsgTxt to
 *               show more clearly that this results in a return to MatLab
 *             - Defined channel descriptor type and function for reading it
 *             - Contemplated college students allergy to hitting space key (a=b+1)  Why not (a = b + 1)?
 *
 */

/* $Author: aperlin $ $Date: 2008/10/07 16:38:53 $ $Revision: 1.4 $*/

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <mex.h>

#define MAXSIZE 65530

#define DEBUG_OUTPUT 0 /* Set this to one (1) to enable debug output blocks */

typedef          char   int8;
typedef unsigned char  uint8;
typedef          short  int16;
typedef unsigned short uint16;
typedef          int    int32;
typedef unsigned int   uint32;

/*
 * Return Codes for functions like readTuple
 */
#define BIO_EOF_FOUND 1      /* The end of the file was reached */

#define BIO_READ_ERROR -1    /* There was an error reading the file */
#define BIO_SIZE_ERROR -2    /* The size of a tuple was too large */
#define BIO_CHECK_ERROR -3   /* The size of the tuple and the check for the tuple did not agree */
#define BIO_INVALID_TYPE -4  /* The tuple had an invalid type for processing */
#define BIO_BAD_CHANNEL -5   /* The channel that was selected was out of range */
#define BIO_NULL_PONTER -6   /* The pointer we tried to use was NULL */
#define BIO_BAD_SIGNATURE -7 /* The signature tuple had bad signature data */
#define BIO_ERROR_RLE     -8 /* The RLE decompression failed */

/*
 * Tuple Type
 * Our file is made up of tuples that have a 4 byte header, N bytes of data
 * and a 2 byte padding at the end.  The first 2 bytes of the header indicates
 * how many bytes of data there are.  The second 2 bytes of the header indicates
 * the type of the tuple.
 */
typedef struct TUPLE {
    unsigned short size;
    unsigned short type;
    unsigned char data[MAXSIZE];
    unsigned short check;
} Tuple;

#define SLOTS 32
int empty = 0;
uint16 tTypes[SLOTS];
uint32 tCounts[SLOTS];
uint32 total = 0;

const char *typeNames[] = {"Unknown", "Signature", "V3 Header", "V2 Header", "Channel Descriptor",
"Single-Beam Ping", "Dual-Beam Ping", "Split-Beam Ping", "Time", "Position",
"Navigation String", "End of File"};
char *typeName(uint16 tType) {
    switch (tType) {
        case 0xFFFF:
            return typeNames[1];
        case 0x001E:
            return typeNames[2];
        case 0x0018:
            return typeNames[3];
        case 0x0118:
        case 0x011A:
            return typeNames[4];
        case 0x0015:
            return typeNames[5];
        case 0x001C:
            return typeNames[6];
        case 0x001D:
            return typeNames[7];
        case 0x000F:
        case 0x0020:
            return typeNames[8];
        case 0x000E:
            return typeNames[9];
        case 0x0011:
            return typeNames[10];
        case 0xFFFE:
            return typeNames[11];
    }
    return typeNames[0];
}
void initStats() {
    memset(tTypes, 0, SLOTS * sizeof(uint16));
    memset(tCounts, 0, SLOTS * sizeof(uint32));
    total = 0;
    empty = 0;
}

void countTuple(Tuple *tuple) {
    int i;
    int slot = -1;
    
    for (i = 0; i < SLOTS; i++) {
        if (tTypes[i] == tuple->type) {
            slot = i;
            break;
        }
    }
    
    if (slot >= 0) {
        tCounts[i]++;
    }
    else {
        tTypes[empty] = tuple->type;
        tCounts[empty] = 1;
        empty++;
    }
    
    total++;
}


/*
 * readTuple
 *
 * inputFile - a file that has been opened with fopen as a binary file "rb"
 * tuple - a pointer to tuple data to read into.
 *
 * Given a file that is opened for binary reading, load the next tuple from the file.
 * The format of a tuple is 2 bytes of size, 2 bytes of type, N bytes of data where N
 * is specified by size, and 2 bytes of padding.  The tuple passed in will always be
 * erased before any data is loaded.
 *
 * Returns 0 if successful, otherwise an error code of BIO_READ_ERROR, BIO_SIZE_ERROR or BIO_CHECK_ERROR
 */
int readTuple(FILE *inputFile, Tuple *tuple) {
    unsigned short tempSize = 0;
    int numberBytes = 0;
    int nRead = 0;
    
    /* Zero all data in the tuple before we get going */
    memset(tuple, 0, sizeof(Tuple));
    
    /* Read the size of the tuple (2 bytes) */
    numberBytes = 2;
    nRead = fread(&tempSize, 1, numberBytes, inputFile);
    if (nRead != numberBytes) return BIO_READ_ERROR; /* Failed to read the tuple size */
    if (tempSize >= MAXSIZE) return  BIO_SIZE_ERROR; /* Failed the max size check */
    tuple->size = tempSize;
    
    /* Read the type of the tuple (2 bytes) */
    numberBytes = 2;
    nRead = fread(&(tuple->type), 1, numberBytes, inputFile);
    if (nRead != numberBytes) return BIO_READ_ERROR; /* Failed to read the tuple type */
    
#ifdef DEBUG_OUTPUT
countTuple(tuple);
#endif

/* Read the data (N bytes where N = tuple->size)*/
numberBytes = tuple->size;
if (numberBytes > 0) {
    nRead = fread(tuple->data, 1, numberBytes, inputFile); /* tuple->data is an array so we do not need to turn it into a pointer */
    if (nRead != numberBytes) return BIO_READ_ERROR; /* Failed to read the tuple data */
}

/* Read the padding (2 bytes) */
numberBytes = 2;
nRead = fread(&(tuple->check), 1, numberBytes, inputFile);
if (nRead != numberBytes) return BIO_READ_ERROR; /* Failed to read the tuple padding */

/* Check the size */
if (tuple->check != (tuple->size + 6)) return BIO_CHECK_ERROR;

/* Check to see if we are at the end of the file */
if (tuple->type == 0xFFFE) return BIO_EOF_FOUND;

return 0;
}

/*
 * Signature Tuple
 * This tuple is the first tuple in valid DT4 files
 */
typedef struct SIGNATURE{
    uint16 signature1; /* First file signature always 0xADFF */
    uint8  unused[8];  /* Eight unused bytes */
    uint32 signature2; /* Second file signature always 0xFE82111 */
    uint8  major;      /* The major version number 0x02 */
    uint8  minor;      /* The minor version number 0x01 or 0x02 */
} Signature;

/*
 * loadSignature
 * (IN)  tuple - The tuple to try to load as a signature
 * (OUT) signature - The signature struct to populate from the tuple
 *
 * Returns 0 if successful
 * BIO_INVALID_TYPE - The tuple type was not a valid signature type
 * BIO_BAD_SIGNATURE - The tuple did not have the correct signature1 or signature2
 */
int loadSignature(Tuple *tuple, Signature *signature) {
    /* Check the type */
    if (tuple->type != 0xFFFF) return BIO_INVALID_TYPE;
    
    /* Clear the signature struct */
    memset(signature, 0, sizeof(Signature));
    
    /* Load the data */
    signature->signature1 = *((uint16 *)(tuple->data + 0));
    memcpy(signature->unused, tuple->data + 2, 8); /* 8 bytes of unused data */
    signature->signature2 = *((uint32 *)(tuple->data + 10));
    signature->major = *((uint8 *)(tuple->data + 14));
    signature->minor = *((uint8 *)(tuple->data + 15));
    
    /* Check signature1 and signature2 */
    if (signature->signature1 != 0xADFF) return BIO_BAD_SIGNATURE;
    if (signature->signature2 != 0xFEF82111) return BIO_BAD_SIGNATURE;
    
    return 0;
}

/*
 * Header Tuple
 * Handles both V2 and V3 File Headers (V2 does not have the power)
 */
typedef struct HEADER{
    char  version[3];      /* Version as either "V3" or "V2" */
    uint16 absorption;      /* Absorption coefficient in 0.0001 dB/m */
    uint16 soundVelocity;   /* Sound velocity */
    int16 temperature;     /* Temperature of water in 0.01 degrees C */
    uint16 salinity;        /* Salinity of water in 0.01 ppt */
    int16 power;           /* Transmit power in 0.1 db */
    uint16 channels;        /* Number of channels */
}Header;
/*
 * loadHeader
 * (IN) tuple - The tuple to parse for header information
 * (OUT) header - The header information we parsed
 *
 * Returns 0 if successful
 * BIO_INVALID_TYPE if the type of the tuple is not a header tuple
 */
int loadHeader(Tuple *tuple, Header *header) {
    /* Check the type */
    if ((tuple->type != 0x001E) && (tuple->type != 0x0018)) return BIO_INVALID_TYPE;
    
    /* Clear the header */
    memset(header, 0, sizeof(Header));
    
    /* Load the header (Shared Processing)*/
    header->absorption = *((uint16 *)(tuple->data + 0));
    header->soundVelocity = *((uint16 *)(tuple->data + 2));
    header->temperature = *((int16 *)(tuple->data + 4));
    header->salinity = *((uint16 *)(tuple->data + 6));
    if (tuple->type == 0x001E) {
        /* Version 3 Processing */
        header->version[0] = 'V';
        header->version[1] = '3';
        header->power = *((int16 *)(tuple->data + 8));
        header->channels = *((uint16 *)(tuple->data + 10));
    }
    else {
        /* Version 2 Procesion */
        header->version[0] = 'V';
        header->version[1] = '2';
        header->channels = *((uint16 *)(tuple->data + 8));
    }
    
    return 0;
}

/*
 * ChannelDescriptor Type
 * Encapsulation of several values associated with the channel descriptor tuple.  There should
 * only be one of these channel descriptor tuples in our measurements
 */
typedef struct CHANNELDESCRIPTOR{
    unsigned int pings;
    unsigned short samples;
    unsigned short samplePeriod;
    unsigned short pulseLength;
    unsigned short pingRate;
    unsigned short initialBlanking;
} ChannelDescriptor;

/*
 * readChannelDescriptor
 *
 * inputFile - a file that has been opened with fopen as a binary file "rb"
 * channelDescriptor - a pointer to ChannelDescriptor data to read into.
 *
 * Given a file that is opened for binary reading, load the next tuple from the file as
 * a channel descriptor.  Internally this is calling readTuple and will return the same
 * error codes as it does.
 *
 * Returns 0 if successful, otherwise an error code of BIO_READ_ERROR, BIO_SIZE_ERROR or BIO_CHECK_ERROR
 */
int readChannelDescriptor(FILE *inputFile, ChannelDescriptor *channelDescriptor) {
    Tuple tuple;
    int nResult;
    
    /* Clear the channelDescriptor */
    memset(channelDescriptor, 0, sizeof(ChannelDescriptor));
    
    /* Load the tuple */
    nResult = readTuple(inputFile, &tuple);
    if (nResult) return nResult; /* There was an error */
    
    /* Assign the values to the Channel Descriptor */
    memcpy(&(channelDescriptor->pings), &(tuple.data[2]), sizeof(unsigned int));
    memcpy(&(channelDescriptor->samples), &(tuple.data[6]), sizeof(unsigned short));
    memcpy(&(channelDescriptor->samplePeriod), &(tuple.data[8]), sizeof(unsigned short));
    memcpy(&(channelDescriptor->pulseLength), &(tuple.data[12]), sizeof(unsigned short));
    memcpy(&(channelDescriptor->pingRate), &(tuple.data[14]), sizeof(unsigned short));
    memcpy(&(channelDescriptor->initialBlanking), &(tuple.data[16]), sizeof(unsigned short));
    
    return 0;
}

/*
 * Ping Type
 * If a tuple is a Ping type (x0015), then the tuple.data will have the following format
 * uint16 channel ID - If there is more than one channel in the file, then this number will vary, (Only 1 channel for us) [tuple.data + 0]
 * uint32 ping ID - The number of the ping [tuple.data + 2]
 * uint32 system time - A number representing the time of this ping (Not exactly sure how?) [tuple.data + 6]
 * uint16 samples - The number of samples in this ping
 * uint16[channelDescriptor.samples] - An array of unsigned shorts representing the samples. [tuple.data + 12]
 */
typedef struct PING{
    uint16 channel;  /* The channel number */
    uint32 id;     /* The ping number */
    uint32 time;   /* The time for the ping */
    uint16 samples; /* The number of samples in the ping */
    uint16 data[MAXSIZE];  /* The data for the ping */
} Ping;

int rleDecompress(Ping *ping, ChannelDescriptor *channel, uint16 *output) {
    uint16 x;
    int i, k, n;
    
    k = 0;
    for (i = 0; i < ping->samples; ++i) {
        x = ping->data[i];
        if ((x & 0xFF00) == 0xFF00) /* Check for start of RLE Zeroes*/ {
            n = (x & 0x00FF) + 2;
            /* x represens a run of n successive 0x00 samples.  Insert them into the output array */
            while (n > 0) {
                if (k < channel->samples) {
                    /* Zero the element and change the loop counters */
                    output[k] = 0x0000;
                    k = k + 1;
                    n = n - 1;
                }
                else {
                    /* Try to decompress RLE outisde the sample size */
                    return BIO_ERROR_RLE;
                }
            }
        }
        else {
            if (k < channel->samples) {
                /* No RLE on anything else so just copy 1 for 1 */
                output[k] = x;
                k = k + 1;
            }
            else {
                /* Try to copy outside the sample size */
                return BIO_ERROR_RLE;
            }
        }
    }
    
    /* Fill the rest of the samples with 0 */
    while (k < channel->samples) {
        output[k] = 0x0000;
        k = k + 1;
    }
    
    return 0;
}

/*
 * loadPing
 *
 * tuple - (IN) a Tuple that has been loaded in from the file
 * ping - (OUT) a Ping you wish to populate from the tuple
 *
 * Try to load the tuple.data into the ping
 * Returns 0 if successful, otherwise non-zero
 */
int loadPing(Tuple *tuple, Ping *ping) {
    /* Check the type to prevent stupidity */
    if (tuple->type != 0x0015) return BIO_INVALID_TYPE;
    
    /* Clear out the ping */
    memset(ping, 0, sizeof(Ping));
    
    /* Read in the channel number */
    ping->channel = *((uint16 *)(tuple->data + 0));
    
    ping->id = *((uint32 *)(tuple->data + 2));
    ping->time = *((uint32 *)(tuple->data + 6));
    ping->samples = *((uint16 *)(tuple->data + 10));
    memcpy(ping->data, (tuple->data + 12), ping->samples * sizeof(uint16));
    
    return 0;
}

/*
 * setValue_INT16
 * outputStructArray - a structure array with the field to be set
 * fieldName - the name of the field in the structure array
 * value - the value to be set
 *
 * Create a 1x1 array and store the value in the specified field of the struct array
 */
int setValue_INT16(mxArray *outStructArray, char *fieldName, int16 value) {
    mxArray *output;
    int16 *pointer;
    
    /* Create an array to hold the data */
    output = mxCreateNumericMatrix(1, 1, mxINT16_CLASS, mxREAL);
    
    /* Get a pointer and set the data */
    pointer = (int16 *)mxGetPr(output);
    *pointer = value;
    
    /* Populate the field with the new array */
    mxSetField(outStructArray, 0, fieldName, output);
    
    return 0;
}


/*
 * setValue_UINT16
 * outputStructArray - a structure array with the field to be set
 * fieldName - the name of the field in the structure array
 * value - the value to be set
 *
 * Create a 1x1 array and store the value in the specified field of the struct array
 */
int setValue_UINT16(mxArray *outStructArray, char *fieldName, uint16 value) {
    mxArray *output;
    uint16 *pointer;
    
    /* Create an array to hold the data */
    output = mxCreateNumericMatrix(1, 1, mxUINT16_CLASS, mxREAL);
    
    /* Get a pointer and set the data */
    pointer = (uint16 *)mxGetPr(output);
    *pointer = value;
    
    /* Populate the field with the new array */
    mxSetField(outStructArray, 0, fieldName, output);
    
    return 0;
}
/*
 * setValue_UINT32
 * outputStructArray - a structure array with the field to be set
 * fieldName - the name of the field in the structure array
 * value - the value to be set
 *
 * Create a 1x1 array and store the value in the specified field of the struct array
 */
int setValue_UINT32(mxArray *outStructArray, char *fieldName, uint32 value) {
    mxArray *output;
    uint32 *pointer;
    
    /* Create an array to hold the data */
    output = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
    
    /* Get a pointer and set the data */
    pointer = (uint32 *)mxGetPr(output);
    *pointer = value;
    
    /* Populate the field with the new array */
    mxSetField(outStructArray, 0, fieldName, output);
    
    return 0;
}

/*
 * setValues_UINT8
 * outStructArray - a structure array
 * fieldName - The field in the structure array
 * values - an array of uint8
 * nValues - number of elements to copy
 *
 * Copies an array of integers into the specified field of a structure array
 */
int setValues_UINT8(mxArray *outStructArray, char *fieldName, uint8 *values, uint32 nValues) {
    mxArray *output;
    uint8 *pointer;
    unsigned int i;
    
    /* Make the output array */
    output = mxCreateNumericMatrix(1, nValues, mxUINT8_CLASS, mxREAL);
    
    /* Grab the pointer to the first element of the output */
    pointer = (uint8 *)mxGetPr(output); /* Get the pointer to the first (and only) element */
    if (pointer == NULL) return BIO_NULL_PONTER;
    
    /* Copy the values item by item */
    for (i = 0; i < nValues; i++) {
        pointer[i] = values[i];
    }
    
    /* Move the new array into the output structure */
    mxSetField(outStructArray, 0, fieldName, output);
    return 0;
}

/*
 * setValues_INT32
 */
int setValues_INT32(mxArray *outStructArray, char *fieldName, int32 *values, uint32 nValues) {
    mxArray *output;
    int32 *pointer;
    unsigned int i;
    
    /* Make the output array */
    output = mxCreateNumericMatrix(1, nValues, mxINT32_CLASS, mxREAL);
    
    /* Grab the pointer to the first element of the output */
    pointer = (int32 *)mxGetPr(output); /* Get the pointer to the first (and only) element */
    if (pointer == NULL) return BIO_NULL_PONTER;
    
    /* Copy the values item by item */
    for (i = 0; i < nValues; i++) {
        pointer[i] = values[i];
    }
    
    /* Move the new array into the output structure */
    mxSetField(outStructArray, 0, fieldName, output);
    return 0;
}

/*
 * setValues_UINT32
 */
int setValues_UINT32(mxArray *outStructArray, char *fieldName, uint32 *values, uint32 nValues) {
    mxArray *output;
    uint32 *pointer;
    unsigned int i;
    
    /* Make the output array */
    output = mxCreateNumericMatrix(1, nValues, mxUINT32_CLASS, mxREAL);
    
    /* Grab the pointer to the first element of the output */
    pointer = (uint32 *)mxGetPr(output); /* Get the pointer to the first (and only) element */
    if (pointer == NULL) return BIO_NULL_PONTER;
    
    /* Copy the values item by item */
    for (i = 0; i < nValues; i++) {
        pointer[i] = values[i];
    }
    
    /* Move the new array into the output structure */
    mxSetField(outStructArray, 0, fieldName, output);
    return 0;
}


/* MatLab MEX-File Interface Function */
/* The name of the function must be mexFunction.  It is the entry point from MatLab into this code */
void mexFunction(
        int  nlhs,               /* (IN)  The number of left-hand arguments or the size of the plhs array */
        mxArray  *plhs[],        /* (OUT) An array of left-hand output arguments */
        int  nrhs,               /* (IN)  The number of right-hand arguments or the size of teh prhs array */
        const  mxArray *prhs[])  /* (IN)  An array of right-hand input arguments */ {
    mxArray *pings;
    mxArray *timestr;
    mxArray *pos;
    mxArray *head;
    mxArray *fout;
    
    /* Output fields, number and names */
    int    nfields = 3;
    const char   *fieldnames[]  = {"out", "systime", "pingnum"};
    /* Position output fields, number and names*/
    int    nposfields = 4;
    const char   *posnames[]  = {"navtime", "lon", "lat", "systime"};
    /*Time output fields, number and names*/
    int    ntimefields = 3;
    const char   *timenames[]  = {"systime", "time", "subseconds"};
    /*Head output fields, number and names*/
    int    nheadfields = 10;
    const char   *headnames[]  = {"pulselength", "pingrate", "initialblanking", "absorption",
    "soundvel", "temperature", "salinity", "powersetting", "nochannels",
    "sampleperiod"};
    
    /*data input*/
    unsigned short   *samples;
    unsigned int     *samples32;
    unsigned int      dat;
    
    /*data output*/
    unsigned int     *out;
    unsigned int     *newsystime;
    unsigned short   mantissa, exponent;
    int              *intptr;
    unsigned  int    *pingnum, *systime;
    unsigned int     latestsystime;
    int              pingno, timeno, i, posno, starti, stopi, startj, stopj;
    int              ii, jj, j, thepos, ppos, mycount;
    unsigned short   nx, nz;
    unsigned int     dati;
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
    short            temperature = 4677; /* Junk values for these since we aren't loading them */
    unsigned short   salinity = 4677;
    short            powersetting = 4677;
    unsigned short   nochannels;
    /* gps string parsing */
    const char       delimiters[] = "$,";
    const char       idelimiters[] = ",";
    char             *gpsstring;
    char             *gpsfield, gpstemp[8];
    float            gpsvalue;
    int              igps;
    
    char* string1;
    char* string2;
    double f;
    
    int nResult = 0;
    int nLength = 0;
    
    /* Input to function decoded from prhs */
    char inputFileName[256];
    unsigned short dx;
    unsigned short dz;
    
    /* Variables for loading data from the input file */
    FILE *inputFile;
    Tuple tuple;
    Signature signature;
    Header header;
    ChannelDescriptor channel;
    Ping ping;
    
    /* Sample Arrays */
    unsigned int nSamples = 0;
    unsigned short *samples_uint16;
    unsigned int   *samples_uint32;
    
    initStats();
    
    /* Check the parameters */
    if (nrhs != 3) {
        mexErrMsgTxt("Error: readbiodrv requires 3 input arguments.");
    }
    
    if (nlhs != 4) {
        mexWarnMsgTxt("Error: readbiodrv require 4 output argument.");
    }
    
    /* Load the name of the input file */
    nLength = (mxGetM(prhs[0]) * mxGetN(prhs[0]) * sizeof(mxChar)) + 1;
    nResult = mxGetString(prhs[0], inputFileName, nLength); /* Returns 1 on Failure*/
    if (nResult) {
        /* Failed to read the string */
        mexErrMsgTxt("Error: readbiodrv requires that the first parameter be a string which is the path to the file to open");
    }
    
    /* Load the horizontal and vertical decimation factors converting them from double to unsinged short */
    dx = (unsigned short) mxGetScalar(prhs[1]); /* Horizontal decimation factor */
    dz = (unsigned short) mxGetScalar(prhs[2]); /* Vertical decimation factor */
    
    /* Open the input file (As read only, binary format ("rb") */
    inputFile = fopen(inputFileName, "rb");
    if (inputFile == NULL) {
        /* Failed to open the input file */
        mexErrMsgTxt("Error: readbiodrv could not open the specified input file");
    }
    
    /* Read the Signature Tuple */
    nResult = readTuple(inputFile, &tuple);
    if (nResult) {
        /* Failed to load first tuple */
        mexErrMsgTxt("Error: readbiodrv could not load Signature tuple");
    }
    nResult = loadSignature(&tuple, &signature);
    if (nResult) {
        mexPrintf("Warning: readbiodrv did not properly parse the Signature Tuple\n");
    }
    else {
        mexPrintf("%s  (DT4 Version %d.%d)\n", inputFileName, signature.major, signature.minor);
    }
    
    
    /* Read the Header Tuple and store relevant information */
    nResult = readTuple(inputFile, &tuple);
    if (nResult) {
        /* Failed to load header */
        mexErrMsgTxt("Error: readbiodrv could not load the header");
        
    }
    nResult = loadHeader(&tuple, &header);
    if (nResult) {
        mexPrintf("Warning: readbiodrv did not properly parse the Header Tuple\n");
    }
   
    absorption = header.absorption;
    soundvel = header.soundVelocity;
    

/* Read Channel Descriptor tuple */
nResult = readChannelDescriptor(inputFile, &channel);
if (nResult) {
    /* Failed to load the Channel Descriptor */
    mexErrMsgTxt("Error: readbiodrv could not load Channel Descriptor");
    return ;/* Exit Function: mexErrmsgTxt Displays string in MatLab and returns to MatLab */
}

#if DEBUG_OUTPUT
mexPrintf("Channel.pings %d\n", channel.pings);
mexPrintf("Channel.samples %d\n", channel.samples);
mexPrintf("Channel.samplePeriod %d\n", channel.samplePeriod);
mexPrintf("Channel.pulseLength %d\n", channel.pulseLength);
mexPrintf("Channel.pingRate %d\n", channel.pingRate);
mexPrintf("Channel.initialBlanking %d\n", channel.initialBlanking);
#endif

/* allocate the sample array  */
pingnum = (unsigned int*) mxMalloc(sizeof(unsigned int) * channel.pings);
systime = (unsigned int*) mxMalloc(sizeof(unsigned int) * channel.pings);

nSamples = channel.samples * channel.pings;
samples_uint16 = (unsigned short*) mxMalloc(nSamples * sizeof(unsigned short));
samples = samples_uint16;
samples_uint32 = (unsigned int*) mxMalloc(nSamples * sizeof(unsigned int));
samples32 = samples_uint32;
#if DEBUG_OUTPUT
mexPrintf("nSamples %d\n", nSamples);
#endif

pingno=0;
timeno=0;
posno=0;

mycount = 0;

/* Load each tuple */
while ((nResult = readTuple(inputFile, &tuple)) != BIO_EOF_FOUND) {
    
    if (nResult) {
        if (nResult == BIO_CHECK_ERROR) {
            /* Check error */
            mexPrintf("Ping %d  (Check %d != size %d + 6)\n", pingno, tuple.check, tuple.size);
            mexErrMsgTxt("Error: readbiodrv could not load data in while loop (BIO_CHECK_ERROR)");
        }
        else if (nResult == BIO_SIZE_ERROR) {
            /* Size error */
            mexPrintf("Ping %d  (Size %d)\n", pingno, tuple.size);
            mexErrMsgTxt("Error: readbiodrv could not load data in while loop (BIO_SIZE_ERROR)");
        }
        else if (nResult == BIO_READ_ERROR) {
            /* Read Error */
            mexErrMsgTxt("Error: readbiodrv could not read a tuple correctly");
        }
        /* Unknown error */
        mexErrMsgTxt("Error: readbiodrv could not load data in while loop");
    }
    
    mycount++;
    
    /* (x0015) ping tuple */
    if (tuple.type == 0x0015) {
        /* Load the ping from the tuple data */
        nResult = loadPing(&tuple, &ping); /* Pretending like our 1 channel is an array by setting nChannels = 1 and passing the address */
        if (nResult) {
            mexPrintf("Ping %d\n", pingno);
            mexPrintf("nResult %d\n", nResult);
            mexErrMsgTxt("Error: readbiodrv could not process the ping");
        }
        
        /* Store the values in our arrays */
        pingnum[pingno] = ping.id;
        systime[pingno] = ping.time;
        nResult = rleDecompress(&ping, &channel, &samples[pingno * channel.samples]);
        if (nResult) {
            mexPrintf("Ping %d\n", pingno);
            mexErrMsgTxt("Error: readbiodrv could not do the RLE decompress on ping data");
        }
        
        /* Update our running systime and increment the ping number */
        latestsystime = systime[pingno];
        pingno = pingno + 1;
    }
    /* (x000F) time tuple*/
    else if (tuple.type == 0x000F) {
        memcpy(&time[timeno], &(tuple.data[0]), sizeof(int));
        memcpy(&(subsecond[timeno]), &(tuple.data[5]), sizeof(subsecond[timeno]));
        memcpy(&(timesystime[timeno]), &(tuple.data[6]), sizeof(timesystime[timeno]));
        latestsystime = timesystime[timeno];
        timeno = timeno + 1;
        if (timeno >= MAXSIZE) {
            mexErrMsgTxt("Error: readbiodrv could not load the time because there are too many time inputs.");
            return ;/* Exit Function: mexErrmsgTxt Displays string in MatLab and returns to MatLab */
        }
    }
    /* (x0011) GPS ASCII tuple*/
    else if (tuple.type == 0x0011) {
        gpsstring = tuple.data;
        
        /*Here we have to make sure that there are not two sets of $GPGGA
         *strings per tuple. If there are we select the first.*/
        string1  = strstr(gpsstring, "$GPGGA");
        if (string1 == NULL) continue; /* skip this tuple */
        string2 = strstr(string1 + 6, "$GPGGA");
        if (string2 != NULL) *string2 = 0;
        
        
        igps = 1;
        
        gpsfield = strtok(gpsstring, delimiters);
        /*mexPrintf("GPS field start %s\n",gpsfield);
         * mexPrintf("next");*/
        
        
        while ((gpsfield != NULL) && (strcmp(gpsfield, "GPGGA") != 0)){
            /*mexPrintf("GPS field %d: %s\n",igps,gpsfield);*/
            gpsfield = strtok(NULL, delimiters);  /* stops when GPGGA is read */
            igps += 1;}
        
        /*read in timestamp
         * >>Ray says, "Not enough error checking in here!  Some other postdoc will probably have to
         *   generalize this."
         * >>Greg replies, "I don't care, because I'm on a ship, and its late, and this is going to
         *   work."
         * >>Anya says, "Oh well... it's not the first Sunday that I waste debugging other peoples'
         *   code...    At least it should be robust enough now."
         * Emily's brother (E E Shroyer III) says this file is crap.
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
        
        if(EOF == sscanf(gpsfield+2, "%f", &gpsvalue)){
            mexErrMsgTxt("Unable to read latitude in minutes");}
        
        latitude[posno]=latitude[posno]+gpsvalue*100000;
        gpsfield = strtok(NULL, delimiters);
        
        /* gpsfield => latitude (direction) */
        /*north or south?*/
        if (toupper(*(gpsfield))=='S') {
            latitude[posno]=latitude[posno]*-1;}
        
        gpsfield = strtok(NULL, delimiters);
        
        /* gpsfield => longitude (magnitude) */
        /*read in longitude*/
        longitude[posno]=0;
        longitude[posno]=longitude[posno]+(unsigned int)(*(gpsfield)-48)*100*100000*60;
        longitude[posno]=longitude[posno]+(unsigned int)(*(gpsfield+1)-48)*10*100000*60;
        longitude[posno]=longitude[posno]+(unsigned int)(*(gpsfield+2)-48)*100000*60;
        
        if(EOF == sscanf(gpsfield+3, "%f", &gpsvalue)){
            mexErrMsgTxt("Unable to read longitude in minutes");}
        
        longitude[posno]=longitude[posno]+gpsvalue*100000;
        gpsfield = strtok(NULL, delimiters);
        
        /* gpsfield => longitude (direction) */
        /*east or west?*/
        if (toupper(*(gpsfield))=='W') {
            longitude[posno]=longitude[posno]*-1;}
        f = 1e-5/60.0;
        
        posno = posno + 1;
    }
}

fclose(inputFile);

#if DEBUG_OUTPUT
mexPrintf("Finished reading the file\n");
mexPrintf("pingno = %d\n", pingno);
mexPrintf("timeno = %d\n", timeno);
mexPrintf("posno = %d\n", posno);

mexPrintf("File Stats:\n");
mexPrintf("  Tuple: Count\n");
for (i = 0; i < empty; i++) {
    mexPrintf("  0x%04x: %6d (%s)\n", tTypes[i], tCounts[i], typeName(tTypes[i]));
}
mexPrintf("Total: %d\n", total);
#endif

/*----------------------------------------------------------*/
/*all data is now loaded - compute output data from ping samples */
/* The data is stored in a 16 bit float - the first four bits are the exponent,
 *the last 12 bits are the mantissa, where the biosonics output is M * 2^E */
for (i = 0; i < channel.pings * channel.samples; i++) {
    /* Find mantissa - we clear the exponent byte and compute*/
    mantissa = samples[i] & 0x0FFF;
    /*find exponent - bit shift 12 bits to the right (clearing mantissa)*/
    exponent = samples[i] >> 12;
    /*output is a 32 bit integer which is M*2.^E, here computed as manitssa bitshifted by exponent*/
    samples32[i] =(unsigned int)(mantissa << exponent);
}

/*alloc a new array so we can decimate the samples32 data and output it*/
nx = (unsigned short)floor((double)(channel.pings / dx));
nz = (unsigned short)floor((double)(channel.samples / dz));
out = mxMalloc(nz * nx * sizeof(unsigned int));
newsystime = mxMalloc(nx * sizeof(unsigned int));

for (i = 0; i < nx; i++) {
    for (j = 0; j < nz; j++) {
        thepos = i * nz + j;
        starti = i * dx;
        stopi  = (i + 1) * dx;
        startj = j * dz;
        stopj  = (j + 1) * dz;
        dat = 0;
        
        for (ii = starti; ii < stopi; ii++) {
            for (jj = startj; jj < stopj; jj++) {
                ppos = ii * channel.samples + jj;
                dat = dat + samples32[ppos];
            }
        }
        dat = dat / (unsigned int)(dx * dz);
        out[thepos] = (unsigned int)dat;
        
    }
}


for (i = 0; i < (channel.pings / dx); i++){
    newsystime[i] = systime[i*dx+(int)floor((double)dx/2)];}

/* that should be it.  Now lets write it out somehow.*/
pings = mxCreateStructMatrix(1, 1, nfields, fieldnames);
timestr = mxCreateStructMatrix(1, 1, ntimefields, timenames);
pos = mxCreateStructMatrix(1, 1, nposfields, posnames);
head = mxCreateStructMatrix(1, 1, nheadfields, headnames);

/* output array field --> pings*/
fout = mxCreateNumericMatrix(nz, nx, mxUINT32_CLASS, mxREAL);
intptr = (unsigned int*)mxGetPr(fout);
memcpy(intptr, out, (nx)*(nz)*sizeof(unsigned int));
mxSetField(pings, 0, "out", fout);

/* now output all vector fields*/
setValues_UINT32(pings, "pingnum", pingnum, nx);
setValues_UINT32(pings, "systime", newsystime, nx);

/* Time Information */
setValues_UINT32(timestr, "systime", timesystime, timeno);
setValues_UINT32(timestr, "time", time, timeno);
setValues_UINT8(timestr, "subseconds", subsecond, timeno);

/* Position Information */
setValues_UINT32(pos, "navtime", navtime, posno);
setValues_INT32(pos, "lon", longitude, posno);
setValues_INT32(pos, "lat", latitude, posno);
setValues_UINT32(pos, "systime", possystime, posno);

/* Header Information */
setValue_UINT16(head, "pulselength", channel.pulseLength);
setValue_UINT16(head, "pingrate", channel.pingRate);
dati = ((unsigned int)channel.samplePeriod) * dz;
setValue_UINT32(head, "sampleperiod", dati);
setValue_UINT16(head, "initialblanking", ((100 * channel.initialBlanking) / dz));
setValue_UINT16(head, "absorption", header.absorption);
setValue_UINT16(head, "soundvel", header.soundVelocity);
setValue_UINT16(head, "salinity", header.salinity);
setValue_UINT16(head, "nochannels", header.channels);
setValue_INT16(head, "temperature", header.temperature);
setValue_INT16(head, "powersetting", header.power);

plhs[0]=pings;
plhs[1]=timestr;
plhs[2]=pos;
plhs[3]=head;

mxFree(pingnum);
mxFree(systime);
mxFree(samples);
mxFree(samples32);
}
