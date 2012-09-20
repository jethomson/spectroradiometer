%IMAGE2SPECTRUM - Converts a photograph of refracted light (a spectrograph)
%                 into a column array or a matrix of three column arrays of
%                 data points that represent the light's spectrum (a
%                 spectrogram).
%
% It's not necessary to use every row of a spectrograph to derive the
% spectrogram. Although every column is always used. To specify a horizontal
% slice (region of interest), use the optional argument roi.
%
% Syntax:  Z = image2spectrum(img, color, roi)
%
% Inputs:
%    img   - an image matrix or an image's filename.
%    color - valid arguments are 'gray' and 'rgb'. If 'rgb' is given then Z
%            is returned as a matrix of three column vectors, with the
%            columns being separate red, green, and blue spectrograms. If
%            'gray' is given, a single spectrogram that is the average of the
%            red, green and blue spectrograms is returned. If a grayscale
%            image is given, while color is set to 'rgb' a gray spectrogram
%            is still returned. default is 'rgb'
%    roi   - region of interest of spectrograph to process.
%            roi(1), y0 is the first row of the horizontal slice. default: 1.
%            roi(2), h is the height of the region, the final row is y0+h-1.
%            default: image height.
%
% Outputs:
%    Z - a column array or a matrix of three column arrays of data points
%        that represent the photographed light's spectrum (a spectrogram).
%
% Example:
%    Z = image2spectrum('path/filename');
%    h=100; y0=(size(I,1)-h)/2; Z=image2spectrum(I, 'gray', [y0, h]);
%
% Other m-files required: frame_read
% Subfunctions: none
% MAT-files required: none
%
% See also: WAVELENGTH_CALIBRATE
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function Z = image2spectrum(img, color, roi)

	if (nargin < 1 || nargin > 3 || isempty(img))
		usage('image2spectrum(img, color, roi)');
	end

	if (ischar(img) == 1)
		I = frame_read(img);
	else
		I = double(img);
	end

	if (~exist('color','var') || isempty(color))
		color = 'rgb';
	end

	if (~exist('roi','var') || isempty(roi))
		roi = [0, 0];
	end



	if (roi(1) == 0)
		roi(1) = 1;
	end

	if (length(roi) < 2 || roi(2) == 0)
		roi(2) = size(I,1);
	end

	y0 = roi(1);
	h = roi(2);

	S = I(y0:y0+(h-1), :, :);

	% The averaging function must be explicitly told to average columnwise
	% by being passed 1 as the second argument. This prevents incorrectly
	% averaging a vector when h is 1.
	% If img is the result of averaging many images then mean and median produce
	% nearly the same result. median should reduce the effect of hot pixels
	% better than mean. However, if img is a single image then mean produces a
	% a more accurate spectrum.
	Z = mean(S, 1);
	%Z = median(S, 1); % ignores hot pixels.

	Z = reshape(Z, [size(Z, 2), size(Z, 3)]); %from 1xwidthx3 to widthx3

	if (strcmpi(color,'gray') || strcmpi(color,'grey'))
		Z = mean(Z, 2);
	end

end
