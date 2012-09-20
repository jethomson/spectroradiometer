%ENSEMBLE_AVERAGE - Averages an ensemble of spectrographs.
%
% An ensemble is a group of spectrographs taken of the same subject under the
% same conditions. By averaging together an ensemble the SNR of the resulting
% spectrograph (A) will be improved by a factor of sqrt(n) compared to the SNR
% of a single spectrograph, where n is the number of spectrographs in ensemble.
%
% Syntax:  A = ensemble_average(imgdir)
%
% Inputs:
%   imgdir - directory containing the ensemble. imgdir should only contain
%            one type of file.
%
% Outputs:
%       A - the average of the ensemble of spectrographs.
%
% Example:
%      none
%
% Other m-files required: pop_dirname, myimread
% Subfunctions: none
% MAT-files required: none
%
% See also: POP_DIRNAME, MYIMREAD
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

% NOTES: Doing a median combine would be better than simply taking the mean, but
%        more resource intensive.

function A = ensemble_average(imgdir)

	if (nargin < 1 || nargin > 2 || isempty(imgdir))
		usage('ensemble_average(imgdir)');
	end

	s = filesep;
	A = 0;

	[ftype, pdirpath] = pop_dirname(imgdir);
	edir = [pdirpath s ftype];
	ext = ['.' ftype];
	D = dir([edir s '*' ext]);
	nimgs = length(D);

	if (nimgs == 0)
		error(['ensemble_average: ' edir ...
		      ' contains no files of type ' ftype]);
	else
		E = 0;
		ensemble = {D.name};

		for li = 1:nimgs
			I = myimread([edir s ensemble{li}]);
			I = double(I);
			E = E + I;
		end
		A = E/nimgs;  % average the ensemble of images
	end

end
