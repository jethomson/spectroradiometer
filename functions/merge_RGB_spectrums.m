%MERGE_RGB_SPECTRUMS - Combines the red, green, and blue channels of a spectrum
%                      by adding them together (averaging where they overlap)
%                      to get a single spectrum that covers the entire
%                      range of wavelengths.
%
% When a spectrum covers a wide range of wavelengths it will be recorded by
% more than on of the camera's color channels. This functions merges the
% spectrum seen by each color channel into a single spectrum.
%
%
% Syntax:  Zgray = merge_RGB_spectrums(Zrgb)
%
% Inputs:
%    Zrgb - an RGB spectrum
%
% Outputs:
%    Zgray - the result of merging each channel of the RGB spectrum by either
%            summing or averaging depending on how the data in each channel
%            overlaps data in the other channels.
%
% Example:
%    none
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function Zgray = merge_RGB_spectrums(Zrgb)

	if (nargin ~= 1 || isempty(Zrgb))
		usage('merge_RGB_spectrums(Zrgb)');
	end

	Ftri = triang(5);
	Ftri = Ftri./sum(Ftri);

	I = Zrgb~=0; % create a matrix that is 1 where Zrgb is non-zero.

	% D is 0 when all channels are zero, 1 when no channels overlap,
	% 2 when two channels overlap, and 3 when all channels overlap.
	D = sum(I,2);
	% where D is 0 change it to 1, this prevents dividing by zero.
	D(D==0) = 1;

	% where a channel doesn't overlap (i.e. D is 1) no change results,
	% but when a channel overlaps another channel (i.e. D > 1) they
	% will be averaged.
	Zgray = sum(Zrgb,2)./D;
	Zgray = filtfilt(Ftri, 1, Zgray);

end

