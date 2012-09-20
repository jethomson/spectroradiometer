%IMAGE_MEAN - Finds the mean of each channel of an image.
%
% Syntax:  m = image_mean(img, h, w)
%
% Inputs:
%    img - an image matrix or an image's filename.
%    h   - the height of the image centered region used to compute the mean. if
%          h is 'full' and w is empty, then the entire image is used to compute
%          the mean. default: 250.
%    w   - the width of the image centered region used to compute the mean.
%          default: 250.
%
% Outputs:
%    m - the mean of the median of each column of the region specified by h and
%        w.
%
% Example:
%    m = image_mean('path/filename');
%    h=100; w=h; m=image_mean(I, h, w);
%
% Other m-files required: frame_read
% Subfunctions: none
% MAT-files required: none
%
% See also: FRAME_READ
%
% Author: Jonathan Thomson
% Work:
% E-mail:
% Website: http://jethomson.wordpress.com
%
function m = image_mean(img, h, w)

	if (nargin < 1 || nargin > 3 || isempty(img))
		usage('image_mean(img, h, w)');
	end

	if ischar(img)
		[ign, ign, ext] = fileparts(img);
		I = frame_read(img);
	else
		ext = '';
		I = double(img);
	end

	if (~exist('h','var') || isempty(h))
		h = 250;
	end

	if (~exist('w','var') || isempty(w))
		w = 250;
	end

	% if not told to take the mean of the entire image, then crop it.
	if (strcmpi(h,'full') ~= 1)
		[imgh, imgw, nd] = size(I);
		r0 = round((imgh-h)/2)+1;
		c0 = round((imgw-w)/2)+1;
		I = I(r0:(r0+h-1),c0:(c0+w-1),:);
	end

	m = mean(median(I));
	m = reshape(m, [1 nd]); %from 1x1x3 to 1x3

end
