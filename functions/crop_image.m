%CROP_IMAGE - Crops an image to the region of interest specified by roi.
%
%
% Syntax:  I = crop_image(img, roi)
%
% Inputs:
%   img - image file or image data matrix.
%   roi - specifies the region of interest to crop the image to.
%
% Outputs:
%       I - the cropped image.
%
% Example:
%       y0 = 1175; h = 500;
%       I  = crop_image(img, [y0, h]);
%
% Other m-files required: frame_read
% Subfunctions: none
% MAT-files required: none
%
% See also: FRAME_READ
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function I = crop_image(img, roi)

	if (nargin < 1 || nargin > 2 || isempty(img))
		usage('crop_image(img, roi)');
	end

	if (ischar(img) == 1)
		I = frame_read(img);
	else
		I = double(img);
	end

	if (~exist('roi','var') || isempty(roi))
		roi = [0, 0, 0, 0];
	end

	if (roi(1) == 0)
		roi(1) = 1;
	end

	if (length(roi) < 2 || roi(2) == 0)
		roi(2) = size(I,1);
	end

	if (length(roi) < 3 || roi(3) == 0)
		roi(3) = 1;
	end

	if (length(roi) < 4 || roi(4) == 0)
		roi(4) = size(I,2);
	end

	y0 = roi(1);
	h = roi(2);
	x0 = roi(3);
	w = roi(4);

	I = I(y0:y0+(h-1), (x0:x0+(w-1)), :);

end
