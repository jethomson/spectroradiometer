%SRGB2LIN - Converts an image from sRGB to linear RGB.
%
% Syntax:  I = sRGB2lin(img)
%
% Inputs:
%    img   - an image matrix or an image's filename. Must be 8 bit.
%
% Outputs:
%    Ilin  - an image matrix containing data in linear RGB.
%
% Example:
%
%
% Other m-files required: frame_read
% Subfunctions: none
% MAT-files required: none
%
% See also: none
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function Ilin = sRGB2lin(img)

	if (nargin ~= 1)
		usage('sRGB2lin(img)');
	end

	if ischar(img)
		Isrgb = frame_read(img);
	else
		Isrgb = double(img);
	end

	I = Isrgb/255;
	clear Isrgb;
	[h, w, d] = size(I);
	Ilin = zeros(h,w,d);
	a = 0.055;
	toe = (I <= 0.04045);
	pow = (I > 0.04045);

	%Ilin = (I./12.92).*(I <= 0.04045) + (((I + a)/(1+a)).^2.4).*(I > 0.04045);
	Ilin(toe) = (I(toe)./12.92);
	Ilin(pow) = (((I(pow) + a)/(1+a)).^2.4);
	Ilin = 255*Ilin;

end
