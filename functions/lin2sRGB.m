%LIN2SRGB - Converts an image from linear RGB to sRGB.
%
%
% Syntax:  I = lin2sRGB(img)
%
% Inputs:
%    img   - an image matrix or an image's filename. Must be 8 bit.
%
% Outputs:
%    Isrgb - an image matrix containing data in sRGB.
%
% Example:
%
%
% Other m-files required: frame_read
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

function Isrgb = lin2sRGB(img)

	if (nargin ~= 1)
		usage('lin2sRGB(img)');
	end

	if ischar(img)
		Ilin = frame_read(img);
	else
		Ilin = double(img);
	end

	I = Ilin/255;
	clear Ilin;
	[h, w, nd] = size(I);
	Isrgb = zeros(h,w,nd);
	a = 0.055;
	toe = (I <= 0.003130805);
	pow = (I > 0.003130805);

	Isrgb(toe) = (12.92*I(toe));
	Isrgb(pow) = ((I(pow).^(1/2.4))*(1+a))-a;
	Isrgb = 255*Isrgb;

end
