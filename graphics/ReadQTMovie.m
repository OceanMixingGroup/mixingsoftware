% im = ReadQTMovie(cmd, arg)
% Read images and sound from a QuickTime movie.
% Syntax: im = ReadQTMovie(cmd, arg)
%        The following commands are supported:
%        start filename - Open the indicated file and parse
%               its contents.  Must be called first.
%        getframe num - Return the image indicated by this
%               frame number.   Returns an empty matrix if this frame
%		does not exist.
%	 getsound - Get all the sound for this movie
% 	 getsoundsr - Get the sample rate for the sound in this movie
%        close - Close this movie.
% Note: This code can only read movies compressed with the JPEG image
% format.  Motion JPEG and the other more advanced codecs are NOT supported.

% Malcolm Slaney - Interval Research Corporation - August 13, 1999
% (c) Copyright Malcolm Slaney, Interval Research, March 1999.

% This is experimental software and is being provided to Licensee
% 'AS IS.'  Although the software has been tested on Macintosh, SGI, 
% Linux, and Windows machines, Interval makes no warranties relating
% to the software's performance on these or any other platforms.
%
% Disclaimer
% THIS SOFTWARE IS BEING PROVIDED TO YOU 'AS IS.'  INTERVAL MAKES
% NO EXPRESS, IMPLIED OR STATUTORY WARRANTY OF ANY KIND FOR THE
% SOFTWARE INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY OF
% PERFORMANCE, MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
% IN NO EVENT WILL INTERVAL BE LIABLE TO LICENSEE OR ANY THIRD
% PARTY FOR ANY DAMAGES, INCLUDING LOST PROFITS OR OTHER INCIDENTAL
% OR CONSEQUENTIAL DAMAGES, EVEN IF INTERVAL HAS BEEN ADVISED OF
% THE POSSIBLITY THEREOF.
%
%   This software program is owned by Interval Research
% Corporation, but may be used, reproduced, modified and
% distributed by Licensee.  Licensee agrees that any copies of the
% software program will contain the same proprietary notices and
% warranty disclaimers which appear in this software program.
%

% The QuickTime movie format is documented in the appendix to the Inside 
% Macintosh: QuickTime book or at this URL
%http://developer.apple.com/techpubs/quicktime/qtdevdocs/REF/refFileFormat96.htm
%
% Note, only a single track of audio and video is supported.  This 
% QuickTime movies can get arbitrarily complicated, with masks and all sorts
% of random media in them.  This routine only reads the simplest kind of 
% movies, and does not give access to the detailed timing information.

function im = ReadQTMovie(cmd, arg)
global movieStatus;

if nargin < 1
	ReadQTMovie('help')
	return;
end

if exist('movieStatus') ~= 1 | isempty(movieStatus)
	% disp('Creating new movieStatus variable');
	movieStatus = struct('sound_stco', [], ...
				'sound_stsc', [], ...
				'sound_stsz', [], ...
				'sound_stts', [], ...
				'video_stco', [], ...
				'video_stsc', [], ...
				'video_stsz', [], ...
				'video_stts', [], ...
				'frame_pos', [], ...
				'frame_desc', [], ...
				'handler', 'none', ...
				'timeScale', [], ...
				'name', [], ...
				'videoDescription', [], ...
				'soundDescription', [], ...
				'fp', -1 ...
				);
end

switch lower(cmd)
case 'help'
	fprintf('Syntax: im = ReadQTMovie(cmd, arg)\n');
	fprintf('The following commands are supported:\n');
	fprintf('	start filename - Open the indicated file and parse\n');
	fprintf('		its contents.  Must be called first.\n');
	fprintf('	getframe num - Return the image indicated by this\n');
	fprintf('		frame number \n');
	fprintf('	getsound - Get all the movie''s sound.\n');
	fprintf('	getsamplerate - Get the sound''s sample rate.\n');
	fprintf('	describe - Show debugging information.\n');
	fprintf('	close - Close this movie.\n');

case 'close'
	if movieStatus.fp >= 0
		try
			fclose(movieStatus.fp),
		catch
		end
	end
	movieStatus.fp = -1;
	movieStatus = [];
	
case {'start','name'}
	if movieStatus.fp >= 0
		try
			fclose(movieStatus.fp),
		catch
		end
	end

	name = arg;
	movieStatus.name = name;
	fp = fopen(name, 'rb', 'b');		% Big-endian file reading
	if fp < 0
		error('Can not open file name.');
	end
	movieStatus.fp = fp;
	movieStatus.sound_stco = [];
	movieStatus.sound_stsc = [];
	movieStatus.sound_stsz = [];
	movieStatus.sound_stts = [];
	movieStatus.video_stco = [];
	movieStatus.video_stsc = [];
	movieStatus.video_stsz = [];
	movieStatus.video_stts = [];
	movieStatus.videoDescription = [];
	movieStatus.soundDescription = [];
	movieStatus.frame_pos = [];
	movieStatus.frame_desc = [];

	while ParseAtom(fp) > 0
		;
	end
	FindVideoFrames;
	im = movieStatus;
case {'findframe','getframe'}
	if nargin < 2
		error('Missing frame number in ReadQTMovie(''findframe'',#)')'
	end
	num = arg;

	if num < 1 | num > length(movieStatus.frame_pos)
		im = [];
		return;
	end

	desc_index =  movieStatus.frame_desc(num)+1;
	if length(movieStatus.videoDescription) > 1
		vs = movieStatus.videoDescription(desc_index);
	else
		vs = movieStatus.videoDescription;
	end
	switch vs.type
	case 'jpeg',
		;				% OK, go for it.
%	case 'mjpa',				% Just for testing
%		;
	otherwise,
		error(['Can not decode a ' vs.type ' field of video.']);
	end

	im = GrabFrameFromMovie(movieStatus.fp, movieStatus.frame_pos(num), ...
		movieStatus.video_stsz(num));

						% Read the raw compressed
						% image data from the QT
						% file.
case 'getcompressedframe',
	if nargin < 2
		error('Missing frame number in ReadQTMovie(''findframe'',#)')'
	end
	num = arg;

	if num < 1 | num > length(movieStatus.frame_pos)
		im = [];
		return;
	end

	desc_index =  movieStatus.frame_desc(num)+1;
	if length(movieStatus.videoDescription) > 1
		vs = movieStatus.videoDescription(desc_index);
	else
		vs = movieStatus.videoDescription;
	end

	fseek(movieStatus.fp, movieStatus.frame_pos(num), 'bof');
	im = fread(movieStatus.fp, movieStatus.video_stsz(num), 'uchar');

case 'getsound',
	if nargin < 2
		im = FindSound;
	else
		im = FindSound(arg(1), arg(2));
	end
case 'getsoundsr',
	im = [];
	if HaveSoundTrack
		for i=1:length(movieStatus.soundDescription)
			sr = movieStatus.soundDescription(i).sample_rate;
			if ~isempty(sr)
				im = sr;
				break
			end
		end
	end
case {'info','describe'},
	fprintf('Movie information for %s:\n', movieStatus.name);
	fprintf('\tTime Scale: %d ticks per second\n', movieStatus.timeScale);
	fprintf('\tVideo information:\n');
	fprintf('\t\tNumber of frames: %d\n', length(movieStatus.video_stsz));
	fprintf('\t\tNumber of chunk offset atoms (stco): %d\n', ...
		length(movieStatus.video_stco));
	fprintf('\t\tNumber of sample to chunk atoms (stsc): %d\n', ...
		length(movieStatus.video_stsc));
	for i=1:min(4,size(movieStatus.video_stsc,2));
		fprintf('\t\t\tfirst sample %d, %d samples/chunk, type %d\n',...
			movieStatus.video_stsc(1,i), ...
			movieStatus.video_stsc(2,i), ...
			movieStatus.video_stsc(3,i));
	end
	fprintf('\t\tNumber of sample size atoms (stsz): %d\n', ...
		length(movieStatus.video_stsz));
	fprintf('\t\t\t');
	for i=1:min(8,length(movieStatus.video_stsz))
		if i > 1
			fprintf(', ');
		end
		fprintf('%d', movieStatus.video_stsz(i));
	end
	fprintf('\n');
	fprintf('\t\tNumber of sample to time atoms (stts): %d\n', ...
		length(movieStatus.video_stts));
	for i=1:min(3,size(movieStatus.video_stts,2))
		fprintf('\t\t\t%d frames separated by %d ticks', ...
			movieStatus.video_stts(1,i), ...
			movieStatus.video_stts(2,i));
		fprintf(' (%g ms)\n', ...
			movieStatus.video_stts(2,i)/movieStatus.timeScale*1000);
	end
	for i=1:length(movieStatus.videoDescription)
		if ~isempty(movieStatus.videoDescription(i).type)
			fprintf('\t\tTrack %d Format: %s\n', i-1, ...
				movieStatus.videoDescription(i).type);
			fprintf('\t\t\t%d x %d, tqual is %d, squal is %d.\n',...
				movieStatus.videoDescription(i).width, ...
				movieStatus.videoDescription(i).height, ...
				movieStatus.videoDescription(i).tqual, ...
				movieStatus.videoDescription(i).squal);
		end
	end

	fprintf('\tSound information:\n');
	fprintf('\t\tNumber of chunk offset atoms (stco): %d\n', ...
		length(movieStatus.sound_stco));
	fprintf('\t\tNumber of sample to chunk atoms (stsc): %d\n', ...
		length(movieStatus.sound_stsc));
	for i=1:min(4,size(movieStatus.sound_stsc,2));
		fprintf('\t\t\tfirst sample %d, %d samples/chunk, type %d\n',...
			movieStatus.sound_stsc(1,i), ...
			movieStatus.sound_stsc(2,i), ...
			movieStatus.sound_stsc(3,i));
	end
	fprintf('\t\tNumber of sample size atoms (stsz): %d\n', ...
		length(movieStatus.sound_stsz));
	fprintf('\t\t\t');
	for i=1:min(8,length(movieStatus.sound_stsz))
		if i > 1
			fprintf(', ');
		end
		fprintf('%d', movieStatus.sound_stsz(i));
	end
	fprintf('\n');
	fprintf('\t\tNumber of sample to time atoms (stts): %d\n', ...
		length(movieStatus.sound_stts));
	for i=1:min(3,size(movieStatus.sound_stts,2))
		fprintf('\t\t\t%d frames separated by %d ticks', ...
			movieStatus.sound_stts(1,i), ...
			movieStatus.sound_stts(2,i));
		fprintf(' (%g ms)\n', ...
			movieStatus.sound_stts(2,i)/movieStatus.timeScale*1000);

	end
	for i=1:length(movieStatus.soundDescription)
		if ~isempty(movieStatus.soundDescription(i).type)
			fprintf('\t\tTrack %d Format: %s\n', i-1, ...
				movieStatus.soundDescription(i).type);
			fprintf('\t\t\t%d channel, %d bits/sample, %d Hz\n',...
				movieStatus.soundDescription(i).channels, ...
				movieStatus.soundDescription(i).bits, ...
				movieStatus.soundDescription(i).sample_rate);
				
		end
	end

otherwise
	error('Unknown command to ReadQTMovie')
end




%%%%%%%%%%%%%%%  FindVideoFrames  %%%%%%%%%%%%%%%%%
% Go through the structures we've read in and find all the video
% frames.  Mostly this means figuring out where each frame of video
% starts in the file.
function FindVideoFrames
global movieStatus
pos = [];
description_index = [];
current_stsc_index = 1;
current_frame = 1;
						% For each chunk of data 
						% (as indicated by chunk offset
						% list.)
for c=1:length(movieStatus.video_stco)
						% Where does this chunk of 
						% data sit in the file?
	chunk_pos = movieStatus.video_stco(c);
						% Check to see whether we move
						% to the next stsc record 
						% (which tells us how many
						% samples per chunk and their
						% description index.)
	if current_stsc_index < size(movieStatus.video_stsc,2)
		if c >= movieStatus.video_stsc(1,current_stsc_index+1)
			current_stsc_index = current_stsc_index+1;
		end
	end
						% OK, now we know how many
						% samples we have in the
						% current chunk.
	frames_per_chunk = movieStatus.video_stsc(2,current_stsc_index);
						% Get the sizes of the samples
						% for this chunk
	sizes = movieStatus.video_stsz(current_frame: ...
			(current_frame+frames_per_chunk-1))';
						
						% Now create a list of 
						% starting positions.  If there
						% is only one, then it is
						% easy.  Otherwise, we need
						% to sum the sizes and add to 
						% the start.
	if frames_per_chunk > 1
		pos = [pos chunk_pos chunk_pos+cumsum(sizes(1:end-1))];
	else
		pos = [pos chunk_pos];
	end
						% OK, we've processed 
						% another "frames_per_chunk"
						% samples by doing this
						% chunk.
	current_frame = current_frame + frames_per_chunk;
						% Also keep track of which 
						% sample description 
						% corresponds to each frame.
	description_index = [description_index ones(1,length(sizes)) * ...
			movieStatus.video_stsc(3,current_stsc_index)];
end
movieStatus.frame_pos = pos;
movieStatus.frame_desc = description_index;

%%%%%%%%%%%%%%%  FindSound  %%%%%%%%%%%%%%%%%
function sound = FindSound(firstSample, lastSample)
global movieStatus
current_stsc_index = 1;				% Sample to Chunk Index
totalLength = 0;				% Total length of sound
chunk_pos = zeros(1,length(movieStatus.sound_stco));
chunk_desc = chunk_pos;
chunk_frames = chunk_pos;

						% Get the sizes of the samples
if length(movieStatus.sound_stsz) > 1
	warning('Got an stsz atom I don''t know what to do with.\n');
end
sizes = movieStatus.sound_stsz(1);

						% For each chunk of data 
						% (as indicated by chunk offset
						% list.)
for c=1:length(movieStatus.sound_stco)
						% Where does this chunk of 
						% data sit in the file?
	chunk_pos(c) = movieStatus.sound_stco(c);
						% Check to see whether we move
						% to the next stsc record 
						% (which tells us how many
						% samples per chunk and their
						% description index.)
	if current_stsc_index < size(movieStatus.sound_stsc,2)
		if c >= movieStatus.sound_stsc(1,current_stsc_index+1)
			current_stsc_index = current_stsc_index+1;
		end
	end
						% OK, now we know how many
						% samples we have in the
						% current chunk.
	chunk_frames(c) = movieStatus.sound_stsc(2,current_stsc_index);

	chunk_desc(c) = movieStatus.sound_stsc(3,current_stsc_index)+1;
						% Massive hack.  Quicktime
						% does something when the 
						% stsc specifies a sound 
						% description that doesn't 
						% exist.  I have seen this, 
						% but I don't know what Apple
						% does.  I just set the 
						% number back to what I
						% have.
	if (chunk_desc(c) > length(movieStatus.soundDescription))
		chunk_desc(c) = length(movieStatus.soundDescription);
		disp('Adjusting sound description id in FindSound.');
	end

	ch = movieStatus.soundDescription(chunk_desc(c)).channels;
	if c == 1
		channels = ch;
	elseif channels ~= ch
		er = fprintf('Channel count changed %d to %d at chunk %d.\n',...
			channels, ch, c);
		error(er);
	end
	totalLength = totalLength + sizes*chunk_frames(c);
end
						
if nargin < 1
	firstSample = 0;
end
if nargin < 2
	lastSample = totalLength;
end
fprintf('Getting sound from sample %d to %d from %d total samples.\n', ...
	firstSample, lastSample, totalLength);
	
sound = zeros(lastSample-firstSample+1, channels);
inputPos = 1;
outputPos = 1;
for c=1:length(chunk_desc)
	desc = chunk_desc(c);
	inputCnt = sizes * chunk_frames(c);
	if inputPos+inputCnt-1 >= firstSample & inputPos <= lastSample

		skip = max(0, firstSample - inputPos);
		outputCnt = min(inputCnt-skip, size(sound,1) - outputPos + 1);
		% fprintf('Chunk %d, skipping %d samples and grabbing %d.\n',...
		% 	c, skip, outputCnt);
		% fprintf(' inputPos is %d, outputPos is %d.\n', ...
	 	%	inputPos, outputPos);
		fseek(movieStatus.fp, chunk_pos(c), 'bof');
		switch movieStatus.soundDescription(desc).type
		case 'raw ',
			chunk = fread(movieStatus.fp,inputCnt*channels,'uchar');
			chunk = (chunk-128)/128;
		case 'twos',
			chunk = fread(movieStatus.fp,inputCnt*channels,'int16');
			chunk = chunk/32768;
		otherwise,
			error('Unknown sound format');
		end
		chunk = reshape(chunk, channels, inputCnt)';
		chunkEnd = outputPos+outputCnt-1;
		if chunkEnd > size(sound,1)
			error('Internal Error: chunkEnd got too big.');
		end
		sound(outputPos:chunkEnd,:) = chunk(skip+1:skip+outputCnt,:);
		outputPos = outputPos + outputCnt;
	end
	inputPos = inputPos + inputCnt;
end
		

%%%%%%%%%%%%%%%  GrabFrameFromMovie %%%%%%%%%%%%%%%%%
function im = GrabFrameFromMovie(fp, pos, framelen)
global movieStatus

imageTmp = tempname;
tempfp = fopen(imageTmp, 'wb');
if tempfp < 0
	error ('Could not open temporary file for grabbing QT movie frame.');
end

fseek(fp, pos, 'bof');
lensofar = 0;
while lensofar < framelen
	data = fread(fp, min(1024*16, framelen-lensofar), 'uchar');
	if isempty(data)
		break;
	end
	cnt = fwrite(tempfp, data, 'uchar');
	lensofar = lensofar + cnt;
end
fclose(tempfp);
im = imread(imageTmp);
delete(imageTmp);

%%%%%%%%%%%%%%%  HaveVideoTrack %%%%%%%%%%%%%%%%%
function res = HaveVideoTrack()
global movieStatus
res = ~isempty(movieStatus.video_stco) & ~isempty(movieStatus.video_stsc) & ...
		~isempty(movieStatus.video_stsz);

%%%%%%%%%%%%%%%  HaveSoundTrack %%%%%%%%%%%%%%%%%
function res = HaveSoundTrack()
global movieStatus
res = ~isempty(movieStatus.sound_stco) & ~isempty(movieStatus.sound_stsc) & ...
		~isempty(movieStatus.sound_stsz);



	

%%%%%%%%%%%%%%%  DuplicateTrack (error message) %%%%%%%%%%%%%%%%%
function DuplicateTrack(mode, atom)
fprintf('Found duplicate %s track in QuickTime movie (%s atom).\n',mode,atom);
error('Unable to process duplicate tracks.');
			

%%%%%%%%%%%%%%%  ParseAtom (just one) %%%%%%%%%%%%%%%%%
function size = ParseAtom(fp)
global movieStatus
size = Read32Bits(fp);
type = Read4ByteString(fp);
place = 8;

if isempty(size)
	size = 0;
	return;
end

% fprintf('Parsing a %s atom with size of %d.\n', type, size);
switch type
case 'dref',
	Read32Bits(fp, 2);
	place = place + 8;
	while place < size
		place = place + ParseAtom(fp);
	end
case {'edts','mdia','minf','moov','stbl'},
	while place < size
		place = place + ParseAtom(fp);
	end
case 'trak',
	while place < size
		place = place + ParseAtom(fp);
	end
	
% http://developer.apple.com/techpubs/quicktime/qtdevdocs/REF/
%	refFileFormat96.1b.htm#29160
case 'hdlr',
	Read32Bits(fp);
	type = Read4ByteString(fp);
	sub = Read4ByteString(fp);
	place = place + 12;
	% fprintf('Got a %s hdlr\n', type);
	if strcmp(type, 'mhlr')
		movieStatus.handler = sub;
	end
case 'mvhd',
	Read32Bits(fp, 3);
	movieStatus.timeScale = Read32Bits(fp);
	place = place + 16;
% http://developer.apple.com/techpubs/quicktime/qtdevdocs/REF/
% 	refFileFormat96.2d.htm
case 'stco',
	Read32Bits(fp);
	count = Read32Bits(fp);
	place = place + 8;
	% fprintf('Processing %s, got %d stco\n', movieStatus.handler,...
	% 	count);
	switch movieStatus.handler
	case 'soun', 
		if isempty(movieStatus.sound_stco)
			movieStatus.sound_stco = Read32Bits(fp, count);
		else
			DuplicateTrack('sound','stco');
		end
	case 'vide', 
		if isempty(movieStatus.video_stco)
			movieStatus.video_stco = Read32Bits(fp, count);
		else
			DuplicateTrack('video','stco');
		end
	end
	place = place + 4 * count;
% http://developer.apple.com/techpubs/quicktime/qtdevdocs/REF/
%	refFileFormat96.2b.htm
% This chunk contains the following three items for each sequence of chunks
%	First Chunk Number
%	Number of Samples per Chunk
%	Chunk Tag Number
% When we look for a chunk, we have to count through the entries in this
% table until we've found the right chunk.
case 'stsc',
	Read32Bits(fp);
	count = Read32Bits(fp);
	place = place + 8;
	% fprintf('Processing %s, got %d stsc\n', movieStatus.handler,...
	% 	count);
	data = Read32Bits(fp, count*3);
	switch movieStatus.handler
	case 'soun', 
		if isempty(movieStatus.sound_stsc)
			movieStatus.sound_stsc = reshape(data,3,count);
		else
			DuplicateTrack('sound','stsc');
		end
	case 'vide', 
		if isempty(movieStatus.video_stsc)
			movieStatus.video_stsc = reshape(data,3,count);
		else
			DuplicateTrack('video','stsc');
		end
	end
	place = place + 4 * 3 * count;
% http://developer.apple.com/techpubs/quicktime/qtdevdocs/REF/
%	refFileFormat96.28.htm
case 'stsd',
	Read32Bits(fp);
	count = Read32Bits(fp);
	place = place + 8;
	for i=1:count
		place = place + ParseSampleDescription(fp);
	end
case 'stts',
	Read32Bits(fp);
	count = Read32Bits(fp);
	place = place + 8;
	data = Read32Bits(fp, count*2);
	place = place + 2*count*4;
	switch movieStatus.handler
	case 'soun', 
		if isempty(movieStatus.sound_stts)
			movieStatus.sound_stts = reshape(data,2,count);
		else
			DuplicateTrack('sound','stts');
		end
	case 'vide', 
		if isempty(movieStatus.video_stts)
			movieStatus.video_stts = reshape(data,2,count);
		else
			DuplicateTrack('video','stts');
		end
	end

% Size of each sample of data.  Should be one entry for each video frame and 
% probably just one entry for all the sound.
% http://developer.apple.com/techpubs/quicktime/qtdevdocs/REF/
%     refFileFormat96.2c.htm
case 'stsz',
	flags = Read32Bits(fp);
	sizedata = Read32Bits(fp);
	count = Read32Bits(fp);
	place = place + 12;
	if sizedata > 0
		data = sizedata;
	else
		% fprintf('Processing %s, got %d stsz\n', ...
		% 	movieStatus.handler,  count);
		data = Read32Bits(fp, count);
		place = place + 4 * count;
	end
	switch movieStatus.handler
	case 'soun', 
		if isempty(movieStatus.sound_stsz)
			movieStatus.sound_stsz = data;
		else
			DuplicateTrack('sound','stsz');
		end
	case 'vide', 
		if isempty(movieStatus.video_stsz)
			movieStatus.video_stsz = data;
		else
			DuplicateTrack('video','stsz');
		end
	end
case {'dinf','elst','mdat','raw ','rpza', 'jpeg', 'rle ','smhd', ...
	'stgs', 'stss', 'tkhd', 'vmhd'}
				% Ignore this.. no further information
otherwise,
	% fprintf(' Ignoring a %s atom with size of %d.\n', type, size);
end
if size-place < 0
	error('got out of sync while reading QT movie.');
end
fseek(fp, size-place, 'cof');



%%%%%%%%%%%%%%%  ParseSampleDescription (just one) %%%%%%%%%%%%%%%%%
% The generic sample description atoms are described at:
% http://developer.apple.com/techpubs/quicktime/qtdevdocs/REF/
%	refFileFormat96.28.htm#pgfId=1169
function size = ParseSampleDescription(fp)
global movieStatus
size = Read32Bits(fp);
type = Read4ByteString(fp);
place = 8;

if isempty(size)
	size = 0;
	return;
end

Read16Bits(fp, 3);
reference_index = Read16Bits(fp)+1;
place = place + 8;

switch movieStatus.handler
case 'soun',
	Read32Bits(fp);			% Version/Revision
	Read32Bits(fp);			% Vendor
	num_channels = Read16Bits(fp);
	num_bits = Read16Bits(fp);
	compress_packet = Read32Bits(fp);
	sample_rate = Read32Bits(fp)/65536.0;
	place = place + 20;

	movieStatus.soundDescription(reference_index) = ...
		struct('type', type, ...
			'channels', num_channels, ...
			'bits', num_bits, ...
			'sample_rate', sample_rate);

case 'vide',
	Read32Bits(fp);			% Version/Revision
	Read32Bits(fp);			% Vendor
	tqual = Read32Bits(fp);		% Temporal Quality
	squal = Read32Bits(fp);		% Spatial Quality
	width = Read16Bits(fp);		% Width of source image
	height = Read16Bits(fp);	% Height of source image
	hres = Read16Bits(fp);
	vres = Read16Bits(fp);
	Read32Bits(fp);			% Data size (ignored)
	fcount = Read16Bits(fp);	% Frames per sample (usually 1)
	place = place + 30;

	movieStatus.videoDescription(reference_index) = ...
		struct('type', type, ...
			'tqual', tqual, ...
			'squal', squal, ...
			'width', width, ...
			'height', height);
end
if size-place < 0
	error('got out of sync while reading QT sample description.');
end
fseek(fp, size-place, 'cof');





%%%%%%%%%%%%%%%  Read32Bits  %%%%%%%%%%%%%%%%%
function i = Read32Bits(fp, count)
if nargin < 2
	count = 1;
end
i = fread(fp, count, 'int32');

%%%%%%%%%%%%%%%  Read16Bits  %%%%%%%%%%%%%%%%%
function i = Read16Bits(fp, count)
if nargin < 2
	count = 1;
end
i = fread(fp, count, 'int16');

function i = Read4ByteString(fp)
i = char(fread(fp, 4, 'int8')');
