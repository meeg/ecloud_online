function rawData2Tensor(dataTarget,varargin)
% RAWDATA2TENSOR Directory recursive conversion of raw data to tensor
%   rawData2Tensor(dataTarget) converts the dataTarget from a raw data
%   file to the longitudinally aligned, equalized, tensor format we like
%   to work with. The dataTarget can be either a file or folder. If a
%   folder, it will recurse down, and convert all files contained therein.
%
%   rawData2Tensor(dataTarget,window) specifies the save window to be
%   used. By default, we capture 4ns before the bunch centroid, and 6ns
%   after.
%
%	See also loadEcloudData, recover_signal_new, find_bunch_new


% Define the version number of the current process.
version = 1.9043;

% 1.9043 - Removal of peakdet on interestingSample routine, instead using
% only valid samples for matched filtering
% 1.9041 - Tweaks on 1.904 for possibly wider improved performance.
% 1.904 - Move to using modified interestingSample routine, using peakdet
% from the public domain internet
% 1.903 - A bunch of fixes developed by going through the error logs
% from runs from 1.902. Including lengthing the default preWindow,
% discovering the effects of beam dumps, and other problems.
% 1.902 - Adjusted loadTekWfm to properly grab the appropriate (...,
% didn't finish writing this comment?). Also, found bug where it
% wouldn't actually find a new trigger level, as it never cleared the
% old one.
% 1.901 - Fixed a semicolon on fftw
% 1.90 - Final candidate
% 1.802 - Saving off 1.801
% 1.801 - Adjusted single bunch selection algorith to pick the section
% of interesting samples with the largest absolute value sample.
% 1.80 - Fixed major bug in bunch loss routine, as it had been basing
% it off of an old roughBunchLocations, rather than the last estimated
% position. Also, switching to new routine for equalization, where it
% is on a per folder basis of channel settings, and attenuation
% settings
% 1.70 - Adjusted centroid movement tolerances to include absolute
% variation and longitudinal velocity.
% 1.63 - Many performance tweaks, including significant hard coding of
% basic codes such as mean, stdeviations, etc.
% 1.62 - Reverting to no noise detection, so we are sure to capture all
% details of bunch loss and dirty injections
% 1.611 - Modification to save of every turn's length in ns, number of
% bunches, and it's noise level
% 1.61 - Tuning on turn noisiness detection
% 1.606 - Included check at completion of alignment section for large
% synchrotron centroid movement. An error is thrown on this condition.
% In doing so, discovered some errors in synchrotron movement. Fixed by
% reducing the range in the findDullSamples routine in find_bunch_new
% from 2x to 1x the stdev.
% 1.605 - Moved saving data to single precision format
% 1.604 - Moved the matched filtering trigger level to be based on the
% minimum of the filtered signal as opposed to the base signal
% 1.603 - Commented out all the keyboards and replaced by errors,
% additionally, added a printout of the noise level if we're in the
% interstitial region. Did this for ease of batch job before Alex's
% September 5 vacation.
% 1.602 - Moved the trigger level alpha to 4, and then 3.5
% 1.601 - Bug fixes in the matched filter adjustment algorithm, further
% decomposition. May run the whole way?
% 1.60 - Moving the matched filter to a statistically driven matched
% filter. We start with our expected signal shape, and then do a
% statistically driven estimation of what the filter should be.
% 1.59 - Bug fixes on the noise detection algorithm, some more
% decomposition in find_bunch_new. The Final Version of this
% 1.58 - New noise detection algorithm. This is based on a white noise
% detection method, and evaluates whether the signal is close to white,
% or not very. A limit is set between the empirical CDF and a gaussian
% based on the average and the empirical std, and based on this power
% we decide whether it is noise or not.
% 1.57 - A bunch of stuff, but the new one is the new bunch detection
% code using a matched filter.
% 1.56 - caught a bad bug in the alignment code: when the window is too
% long, the estimate was used instead of the calculated centroid
% 1.55 - Implemented bessel low pass filtering @ 800MHz
% -----
% 1.5 - implemented versioning system



% First check to see if we're looking at a directory or file
if isdir(dataTarget)
	%%% Directory
	% If we're looking at a directory, call this function recursively
	% on all the contents of this directory in it
	
	% Trim any trailing fileseps (should there be any in the target)
	if(dataTarget(end) == filesep)
		dataTarget = dataTarget(1:end-1);
	end
	
	% Tell user what we're doing
	disp([dataTarget ' is a directory, recursing']), disp('')
	
	% Get the targets in this directory
	targets = dir(dataTarget);
	
	for i = 3:length(targets) % ignore the '.' and '..' entries
		nextTarget = [dataTarget filesep targets(i).name];
		
		if strcmp(targets(i).name(1),'.')
			% We're looking at an invisible file, so don't do anything
		elseif nargin == 1
			rawData2Tensor(nextTarget)
		elseif nargin == 2
			rawdata2Tensor(nextTarget,varargin{1})
		elseif nargin == 3
			rawData2Tensor(nextTarget,varargin{1},varargin{2})
		end
	end
	fprintf('%s directory done\n',dataTarget);
elseif exist(dataTarget,'file')
	%%% File
	% We're looking at a file, we need to either convert it, or not
	% convert it.
	
	% Grab the fileparts should we need them
	[~, ~, extName] = fileparts(dataTarget);
	
	% Set the time window to save into the tensor
	if nargin == 2
		% use what input was input
		preWindow = varargin{1}(1); postWindow = varargin{1}(2);
	else
		% use the default
		preWindow = 6e-9; postWindow = 6e-9;
	end
	
	% Get the output path
	outputName = getOutputPath(dataTarget);
	if isempty(outputName)
		return
	end
	
	% See what to do with this file
	if ~strcmpi(extName,'.csv') && ~strcmpi(extName,'.sdds') && ~strcmpi(extName,'.wfm')
		% The file is not in one of our data formats, so do nothing
	elseif exist([outputName '.mat'],'file') == 2 && isCurrentFormat([outputName '.mat'],version)
		% We've already converted this file
		disp([dataTarget ' converted & current'])
	else
		% if none of the above conditions are true, then we can and should
		% convert this file
		try
			% Try to convert the data
			convertData(dataTarget,outputName,version,preWindow,postWindow);
		catch exception
			% Catch known Errors, and log the message to stdout
			handleError(exception);
		end
	end
else
	% We've been handed something that is neither a file nor a directory,
	% which should never happen. So throw an error
	error('rawData2Tensor:badDataTarget',['We should never see a dataTarget '...
		'which is neither a file nor a directory, yet this has happened']);
end
end

function convertData(inputFile,outputFile,version,preWindow,postWindow)
% CONVERTDATA converts the input file to the output file.
%   This is the subfunction where the real conversion takes place. It loads in the data file from the inputFile location, and then will save it off to the outputFile location.

% Start the timer
tic

% Grab the fileparts should we need them
[pathName, ~, ~] = fileparts(inputFile);

% Display what we're trying to import
fprintf('%s',inputFile)

% Import the Raw data
fprintf(', loading')
[deltaRaw sigmaRaw time meta] = loadEcloudData(inputFile);

% Equalize Data
fprintf(', EQing %0.1fbuc x %uturn',meta.nPoints*meta.sampleTime*1e9/25,meta.nTurns)
[deltaPROC sigmaPROC] = equalizeSignal(deltaRaw,sigmaRaw,time,meta);

% Isolate bunches from equalized signal and longitudinally align them
fprintf(', aligning')
[delta,sigma,centroids,meta] = ...
	turns2bunches(deltaPROC,sigmaPROC,time,meta,...
	preWindow,postWindow);

% Check if our destination folder exists
if exist(strrep(pathName,'DataRaw','DataProcessed'),'dir')
	% it does exist, so do nothing
elseif exist(strrep(pathName,'DataRaw','DataProcessed'),'file')
	% it exists, but it is a file and not a folder, so error
	error(['Cannot write to ' strrep(pathName,'DataRaw','DataProcessed')])
else
	% It doesn't exist, so make our folder
	mkdir(strrep(pathName,'DataRaw','DataProcessed'));
end

% Convert data to lower precision for smaller data size
delta = single(delta);
sigma = single(sigma);
centroids = single(centroids);

% Load the folder metadata
folderMetadataVersion = loadFolderMetadataVersion(inputFile);
metadataVersion = folderMetadataVersion;

% Save off Tensor to the data processed folder
fprintf(', saving %ubun x %uturn x %gns',meta.nBunches,meta.nTurns,1e9*meta.sampleTime*meta.nSlices)
save(outputFile,...
	'version','metadataVersion','delta','sigma','centroids','meta')

% Show we're done
fprintf(', done in %0.0f:%04.1f\n',floor(toc/60),toc-60*floor(toc/60));

end

function outputPath = getOutputPath(inputFile)
% GETOUTPUTNAME Determines output filename & location for a given input file
%   Takes the input file path and returns an output file path. Accounts for different input formats (i.e. .wfm where we have appended stuff)
% Determine information about the current file under target
[pathName, fileName, extName] = fileparts(inputFile);

% Determine the appropriate output file name
if strcmpi(extName,'.wfm')
	% We have the two input file Tek WFM format
	
	% Break out if we're looking at a delta channel, as we only want to
	% look at one of the channels (the sigma channel) so we can save
	% compute time
	load([pathName filesep 'folderMetadata'],'folderMetadata')
	for i = 1:length(folderMetadata)
		if strcmpi(fileName(end-2:end),folderMetadata(i).deltaChannel)
			outputPath = [];
			return
		end
	end
	
else
	% We have the 1 file input formats,
	
	% Just use the input file name
	outputFileName = fileName;
end

% Construct the final output path
outputPath = [strrep(pathName,'DataRaw','DataProcessed') ...
	filesep fileName];
end

function current = isCurrentFormat(filename,currentConversionVersion)
% ISCURRENTFORMAT checks format of a specified .MAT file
%   This file was written to ensure a uniform file format across all saved
%   files. Otherwise, an old file could persist through several updates
%   without being updated.

% Load the version variables from the file to be converted and the
try
	load(filename,'version','metadataVersion')
	folderMetadataVersion = loadFolderMetadataVersion(filename);
catch
	current = false;
	return
end

% Check to see that we really loaded all the variables we wanted to
if ~exist('version','var') || ~exist('metadataVersion','var')
	% One of our variables was not returned
	current = false;
	return
end

% Check to see if the converted file is using the latest conversion
% software and metadata
if version == currentConversionVersion && metadataVersion == folderMetadataVersion
	current = true;
	return
else
	current = false;
	return
end

end

function handleError(exception)
% HANDLEERROR This function handles known errors.
if strcmp(exception.identifier,'loadAcqirisSDDS:BadFile') ...
		|| strcmp(exception.identifier,'loadAcqirisCSV:badDataRead') ...
		|| strcmp(exception.identifier,'loadTekWfm:badDataRead')
	disp(', bad file read')
elseif strcmp(exception.identifier,'loadTekWfm:noMatchingFile')
	disp(', no matching file')
elseif strcmp(exception.identifier,'loadTekWfm:deltaSigmaMismatch')
	disp(', something is different between delta and sigma')
elseif strcmp(exception.identifier,'loadAcqirisCSV:differentTimeVectors') ...
		|| strcmp(exception.identifier,'loadAcqirisSDDS:differentTimeBases')
	disp(', Time vectors don''t match')
elseif strcmp(exception.identifier,'turns2bunches:bunchTooEarly')
	disp(', bunch too early')
elseif strcmp(exception.identifier,'turns2bunches:bunchTooLate')
	disp(', bunch too late')
elseif strcmp(exception.identifier,'turns2bunches:differentBunchCount')
	disp(', bunch count changes per turn???')
elseif strcmp(exception.identifier,'turns2bunches:noBunches')
	disp(', no bunches')
elseif strcmp(exception.identifier,'turns2bunches:beamDump')
	fprintf(', beam dump on %s\n',exception.message)
elseif strcmp(exception.identifier,'turns2bunches:largeCentroidMovement')
	fprintf(', %s centroid movement impossible\n',exception.message)
elseif strcmp(exception.identifier,'findInterestingSamples:samplesAtBeginning')
	disp(', interesting samples at beginning, bad file?')
else
	% Unknown error so let it propagate.
	fprintf('\n');
	rethrow(exception);
end
end

function folderMetadataVersion = loadFolderMetadataVersion(path)
% load the folderMetadata for the specified path
load([strrep(fileparts(path),'DataProcessed','DataRaw') filesep 'folderMetadata.mat'])
end
