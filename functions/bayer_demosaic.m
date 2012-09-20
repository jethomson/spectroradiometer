%BAYER_DEMOSAIC - Converts a Bayer raw image to an MxNx3 image matrix with
%                 separate red, green, and blue channels and interpolates the
%                 unknown components of a channel from neighbors of the same
%                 channel.
%
% Syntax:  R = bayer_demosaic(img, pattern, interpolate)
%
% Inputs:
%    img - Bayer raw image's filename or an image matrix (MxNx1)
%    pattern - the Bayer filter pattern of the camera that took img.
%              default: uses value returned from access_bayer_pattern().
%    interpolate - a boolean that if true, will result in unknown R, G, or B
%                  component values being interpolated from it's most proximate
%                  neighbors of the same color, and if false, will only separate
%                  the Bayer image into channels, setting the unknown components
%                  to zero. default: true.
%
% Outputs:
%    R - MxNx3 image matrix with separate red, green, and blue channels
%
% Example:
%    R = bayer_demosaic('path/myfilename.PGM', 'gbrg', true)
%
%    pattern = determine_bayer_pattern('ref/red.PGM', 101, 5);
%    access_bayer_pattern(pattern);
%    R = bayer_raw_read(I, [], false)
%
% Other m-files required: access_bayer_pattern, myimread
% Subfunctions: bayer_interp
% MAT-files required: none
%
% See also: BAYER_MOSAIC, ACCESS_BAYER_PATTERN
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function R = bayer_demosaic(img, pattern, interpolate)

	if (nargin < 1 || nargin > 3 || isempty(img))
		usage('bayer_demosaic(img, pattern, interpolate)');
	end

	if (~exist('pattern','var') || isempty(pattern))
		pattern = access_bayer_pattern();
		if isempty(pattern)
			error(['bayer_demosaic: neither parameter pattern nor ' ...
			       'access_bayer_pattern() are set.']);
		end
	end

	if (~exist('interpolate','var') || isempty(interpolate))
		interpolate = true;
	end

	if ischar(img)
		I = myimread(img);
	else
		I = double(img);
	end

	[h, w, nd] = size(I);

	if (nd ~= 1)
		error('bayer_demosaic: image data must be MxNx1.');
	end

	% Transform pattern string into 2x2 cell array, one letter per cell.
	% This gives us easy to use start indices through strcmp.
	bfp = mat2cell(reshape(pattern, [2,2]).', [1,1], [1,1]);

	%red
	Red = zeros(h, w);
	[bi,bj]=find(strcmpi(bfp, 'r'));
	ri = bi:2:h;
	cj = bj:2:w;
	Red(ri, cj) = I(ri, cj);

	%green
	Green1 = zeros(h, w);
	Green2 = Green1;
	[bi,bj]=find(strcmpi(bfp, 'g')); % two green filters
	ri = bi(1):2:h;
	cj = bj(1):2:w;
	Green1(ri, cj) = I(ri, cj);

	ri = bi(2):2:h;
	cj = bj(2):2:w;
	Green2(ri, cj) = I(ri, cj);

	%blue
	Blue = zeros(h, w);
	[bi,bj]=find(strcmpi(bfp, 'b'));
	ri = bi:2:h;
	cj = bj:2:w;
	Blue(ri, cj) = I(ri, cj);

	if (interpolate == true)
		Red = bayer_interp(Red);     % interpolate columnwise
		Red = bayer_interp(Red.').'; % interpolate rowwise
		Green1 = bayer_interp(Green1);
		Green1 = bayer_interp(Green1.').';
		Green2 = bayer_interp(Green2);
		Green2 = bayer_interp(Green2.').';
		Green = (Green1+Green2)/2;
		Blue = bayer_interp(Blue);
		Blue = bayer_interp(Blue.').';
	else
		Green = Green1 + Green2;
	end

	R = reshape([Red Green Blue], [h w 3]);

end

% Interpolates out zeros by replacing them with the average of the pixel
% directly above and the pixel directly below. Zeros along the top/bottom
% edge are replaced with the value of the pixel that's directly below/above.
% This function only interpolates columnwise. To interpolate rowwise
% rotate the input 90 degrees.
function Ri = bayer_interp(img_chan)

	h = size(img_chan, 1);
	B = [img_chan(1:2,:); img_chan; img_chan((h-1):h,:)];
	Ri = filter(triang(3), 1, B);
	Ri = Ri(4:(4+h-1),:);

end

