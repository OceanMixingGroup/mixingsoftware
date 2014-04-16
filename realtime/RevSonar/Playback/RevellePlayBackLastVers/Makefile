CC = cc
CFLAGS = -O
FILES = FileIO.c tds_utils.c playback.c
HEADERS = FileIO.h data_param.h das.h tds_structs.h tds_utils.h
INCLUDE = -L FileIO.h -L data_param.h -L das.h -L tds_structs.h -L tds_utils.h
OBJECTS = tds_utils.o FileIO.o

# FileIO.c tds_utils.c playback.c

all = playback

playback: $(OBJECTS) 
	$(CC) playback.c -o playback $(OBJECTS) -lm

tds_utils.o: $(HEADERS) 

FileIO.o: $(HEADERS) 

clean:
	rm *.o
	rm playback 
