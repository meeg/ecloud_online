function [delta sigma time meta] = loadTekWfm(filename)
% LOADTEKWFM Loads Tektronix raw waveform file
%    [delta sigma time meta] = loadTekWfm(filename)
%
%    Loads the filename and outputs arrays of delta & sigma, a time vector,
%    and a meta structure of all the metainformation.
%
%    The arrays are turns x points.
%
%	This function uses the codes developed by Riccardo
%
%	See also loadEcloudData

addpath('./procTekData/')

% Check the number of outputs to make sure we're not losing data.
if nargout < 2
	error('Not enough outputs!')
elseif nargout == 2
	warning('loadTekWfm:outputsNotCaptured','Time & metadata output not captured')
elseif nargout == 3
	warning('loadTekWfm:outputsNotCaptured','metadata output not captured. Are you really sure??')
end

% Load the metadata from the local folder
[path file] = fileparts(filename);
if isempty(path)
    load('folderMetadata')
else
    load([path filesep 'folderMetadata'])
end

% Figure out what scope channel we're looking at
fileChannel = file(end-2:end);

% Which pickup pair could this correspond to?
for i = 1:length(folderMetadata)
	% Check against sigmaChannel
	if strcmp(fileChannel,folderMetadata(i).sigmaChannel)
		tekMetadata = folderMetadata(i);
		break;
	end
	
	% Check against deltaChannel
	if strcmp(fileChannel, folderMetadata(i).deltaChannel)
		tekMetadata = folderMetadata(i);
		break
	end
end

% Grab Pickup from metadata file
meta.pickup = tekMetadata.pickup;

% Grab Attenuation settings from metadata file
meta.attenuation.preHybrid		= tekMetadata.attenuation.preHybrid;
meta.attenuation.hybridCommon	= tekMetadata.attenuation.hybridCommon;
meta.attenuation.sigma			= tekMetadata.attenuation.sigma;
meta.attenuation.delta			= tekMetadata.attenuation.delta;


% First, find the matching file for delta/sigma
if ~isempty(findstr(filename,tekMetadata.deltaChannel))
	% We have the delta channel as our target. however, we only want to
	% start processing the sigma channels, by doing this, we reduce the
	% number of errors thrown by bad processing jobs (we only get one, not
	% two.
	
	% 	error('loadTekWfm:wrongChannelIn','Only SIGMA channel input is acceptable');
	
	% We have the sigma channel name in
	sigmaName = strrep(filename,tekMetadata.deltaChannel,tekMetadata.sigmaChannel);
	deltaName = filename;
	
	% Check we have the delta channel
	if ~exist(sigmaName,'file')
		error('loadTekWfm:noMatchingFile','Matching file does not exist')
	end
elseif  ~isempty(findstr(filename,tekMetadata.sigmaChannel))
	% We have the sigma channel name in
	sigmaName = filename;
	deltaName = strrep(filename,tekMetadata.sigmaChannel,tekMetadata.deltaChannel);
	
	% Check we have the delta channel
	if ~exist(deltaName,'file')
		error('loadTekWfm:noMatchingFile','Matching file does not exist')
	end
else
	error('loadTekWfm:unknownChannel','We don''t know what channel this is')
end

%%% Load in the data to memory
%
try
	delta_struct = wfmread(deltaName);
	sigma_struct = wfmread(sigmaName);
catch exception
	error('loadTekWfm:badDataRead','we got a bad file read')
end

% Extract basic metadata
if delta_struct.points == sigma_struct.points && delta_struct.frames == sigma_struct.frames
							  meta.nPoints = delta_struct.points;
							 meta.nTurns = delta_struct.frames;
else
	error('loadTekWfm:deltaSigmaMismatch','Something in the Delta and sigma inputs doesn''t match')
end

%%% Import the data to our standardized format

% Get the main data channels, and convert them into real volts
delta = delta_struct.v * delta_struct.waveheader.exp_dim_1_dim_scale ...
	+ delta_struct.waveheader.exp_dim_1_dim_offset;
sigma = sigma_struct.v * sigma_struct.waveheader.exp_dim_1_dim_scale ...
	+ sigma_struct.waveheader.exp_dim_1_dim_offset;

% Timebases
time = delta_struct.waveheader.imp_dim_1_dim_scale * (0:meta.nPoints-1) ...
	+ delta_struct.waveheader.imp_dim_1_dim_offset;
meta.sampleTime = delta_struct.waveheader.imp_dim_1_dim_scale;

% frame struct extraction:
% frame has these fields
% real_point_offset - all zeros?
% tt_offset - trigger error? in samples?
% frac_sec - some sort of absoulte time?   \ _ do these to sum to absolute time?
% gmt_sec - absolute time relative to GMT? /
frameStruct = cell2mat(squeeze(struct2cell(delta_struct.frame)));

% Sampling errors
meta.trigger.error = frameStruct(2,:);
