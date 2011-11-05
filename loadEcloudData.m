function [delta time meta] = loadEcloudData(filename)
% LOADECLOUDDATA Flexible loading of the raw datastructures
%   [delta sigma time meta] = loadEcloudData(filename)
% 
%   Loads the filename (csv, sdds, or wfm) and outputs arrays of delta &
%   sigma, a time vector, and a meta structure of all the metainformation.
% 
%   The arrays are turns x points.
%	
%	loadEcloudData loads the appropriate subfunction
%	
%	See also loadAcqirisSDDS, loadAcqirisCSV, loadTekWfm

[~, ~, ext] = fileparts(filename);

% Check the number of outputs to make sure we're not losing data.
if nargout < 1
	error('Not enough outputs!')
elseif nargout == 1
	warning('loadEcloudData:outputsNotCaptured','Time & metadata output not captured')
elseif nargout == 2
	warning('loadEcloudData:outputsNotCaptured','metadata output not captured. Are you really sure??')
end

switch ext
	case '.sdds'
		[delta time meta] = loadAcqirisSDDS(filename);
	case '.csv'
		[delta time meta] = loadAcqirisCSV(filename);
	case '.wfm'
		[delta time meta] = loadTekWfm(filename);
end

end
