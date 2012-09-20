%BAYER_MOSAIC - Converts an RGB image into a Bayer raw image by selecting only
%               those pixels from a channel specified by pattern.
%
% If the colors of a Bayer raw need to be processed separately, then the data
% should be demosaiced then processed. The processed data can then be
% re-mosaiced back into a Bayer raw using this function.
%
% Syntax:  R = bayer_mosaic(img, pattern)
%
% Inputs:
%    img - an image matrix or an image's filename.
%    pattern - the desired Bayer filter pattern of the output image.
%
% Outputs:
%    R - MxNx1 image matrix with combined red, green, and blue channels.
%
% Example:
%    F = bayer_demosaic('path/myfilename.PGM', 'gbrg', true);
%    mn = reshape(image_mean(F), [1 1 3]);
%    Fgray = F./repmat(mn, [size(F,1), size(F,2), 1]);
%    B = bayer_mosaic(Fgray, 'gbrg');
%
% Other m-files required: access_bayer_pattern, myimread
% Subfunctions: none
% MAT-files required: none
%
% See also: BAYER_DEMOSAIC, ACCESS_BAYER_PATTERN
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function R = bayer_mosaic(img, pattern)

	if (nargin < 1 || nargin > 2 || isempty(img))
		usage('bayer_mosaic(img, pattern)');
	end

	if (~exist('pattern','var') || isempty(pattern))
		pattern = access_bayer_pattern();
		if isempty(pattern)
			error(['bayer_mosaic: neither parameter pattern nor ' ...
			       'access_bayer_pattern() are set.']);
		end
	end


	if ischar(img)
		I = myimread(img);
	else
		I = double(img);
	end

	[h, w, nd] = size(I);

	if (nd ~= 3)
		error('bayer_mosaic: image data must be MxNx3.');
	end

	% Transform pattern string into 2x2 cell array, one letter per cell.
	% This gives us easy to use start indices through strcmp.
	bfp = mat2cell(reshape(pattern, [2,2]).', [1,1], [1,1]);

	%red
	Red = zeros(h, w);
	[bi,bj]=find(strcmpi(bfp, 'r'));
	ri = bi:2:h;
	cj = bj:2:w;
	Red(ri, cj) = I(ri, cj, 1);

	%green
	Green = zeros(h, w);
	[bi,bj]=find(strcmpi(bfp, 'g')); % two green filters
	ri = bi(1):2:h;
	cj = bj(1):2:w;
	Green(ri, cj) = I(ri, cj, 2);

	ri = bi(2):2:h;
	cj = bj(2):2:w;
	Green(ri, cj) = I(ri, cj, 2);

	%blue
	Blue = zeros(h, w);
	[bi,bj]=find(strcmpi(bfp, 'b'));
	ri = bi:2:h;
	cj = bj:2:w;
	Blue(ri, cj) = I(ri, cj, 3);

	R = Red + Green + Blue;

end
