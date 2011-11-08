function [delta time meta] = rawData2Tensor(dataTarget,varargin)
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


% Based on the following version of rawData2Tensor:
version = 1.9043;


% First check to see if we're looking at a directory or file
if exist(dataTarget,'file')
	%%% File
	% We're looking at a file, we need to either convert it, or not
	% convert it.
	
	% Grab the fileparts should we need them
	[~, ~, extName] = fileparts(dataTarget);
	
	% See what to do with this file
	if ~strcmpi(extName,'.wfm')
		% The file is not in one of our data formats, so do nothing
	else
		% if none of the above conditions are true, then we can and should
		% convert this file
		%try
			% Try to convert the data
			[delta time meta] = convertData(dataTarget,version);
		%catch exception
			% Catch known Errors, and log the message to stdout
		%	handleError(exception);
		%end
	end
else
	% We've been handed something that is neither a file nor a directory,
	% which should never happen. So throw an error
	error('rawData2Tensor:badDataTarget',['We should never see a dataTarget '...
		'which is neither a file nor a directory, yet this has happened']);
end
end

function [delta time meta] = convertData(inputFile,version)
% CONVERTDATA converts the input file to the output file.
%   This is the subfunction where the real conversion takes place. It loads in the data file from the inputFile location, and then will save it off to the outputFile location.

% Start the timer
tic

% Grab the fileparts should we need them
[pathName, ~, ~] = fileparts(inputFile);

% Display what we're trying to import
printf('Loading input file: %s\n',inputFile)

% Import the Raw data
[deltaRaw time meta] = loadTekWfm(inputFile);

printf('Done loading, %.2f seconds elapsed\n',toc);

% Equalize Data
printf('EQing %dpts x %uturn\n',meta.nPoints,meta.nTurns)
[delta] = equalizeSignal(deltaRaw,meta);

printf('Done equalizing, %.2f seconds elapsed\n',toc);

% Show we're done
fprintf('Done in %0.0f:%04.1f\n',floor(toc/60),toc-60*floor(toc/60));

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
