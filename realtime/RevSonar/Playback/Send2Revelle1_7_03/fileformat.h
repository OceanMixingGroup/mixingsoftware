typedef struct rheader{
	long 			rec_num;
	unsigned long		timemark;		/*	timemark from hydra sonar record*/
	unsigned long		host_time;		/*	from time_address*/
	long 			timestatus;	 	/*	tests if buffer is synchronous */
	processing_status	p_status;
	TDS_Data		data;			/*	tds data*/
}rheader;
