%DETERMINE_BAYER_PATTERN - Searches a Bayer raw image of a RED subject that
%                          fills the entire frame to determine the Bayer filter
%                          pattern of img.
%
% Note that dcraw will tell you the bayer filter pattern of a digital negative,
% therefore this function is not required to process spectrographs. It was
% mostly written for fun.
%
% Traverses img diagonally examining 2x2 blocks of colored filters to
% determine the image's Bayer filter pattern by finding the most intense
% (red) and least intense (blue) pixels. The ascii drawing below
% demonstrates a diagonal traversal starting at S (start) with a number of
% repetitions (rep) equal to 5. start need not be the upper leftmost corner
% of the image.
%
%     S  S  S  S  S
%        +  +  +  +
%        1  2  3  4
%S   [*][*][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
%S+1 [*][*][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
%S+2 [ ][ ][*][*][ ][ ][ ][ ][ ][ ][ ][ ][ ]
%S+3 [ ][ ][*][*][ ][ ][ ][ ][ ][ ][ ][ ][ ]
%    [ ][ ][ ][ ][*][*][ ][ ][ ][ ][ ][ ][ ]
%    [ ][ ][ ][ ][*][*][ ][ ][ ][ ][ ][ ][ ]
%    [ ][ ][ ][ ][ ][ ][*][*][ ][ ][ ][ ][ ]
%    [ ][ ][ ][ ][ ][ ][*][*][ ][ ][ ][ ][ ]
%    [ ][ ][ ][ ][ ][ ][ ][ ][*][*][ ][ ][ ]
%    [ ][ ][ ][ ][ ][ ][ ][ ][*][*][ ][ ][ ]
%    [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
%    [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]
%
% Syntax:  pattern = determine_bayer_pattern(img, start, rep)
%
% Inputs:
%    img   - Bayer raw image's filename or an image matrix.
%    start - The row and column of the pixel from which the traversing of
%            the image in 2x2 blocks begins. The row and column are always
%            the same so only one number is needed. start must be odd. If
%            start is 1 the traversal will begin at the upper leftmost
%            pixel. It is recommended you specify start such that blocks
%            away from the borders of image are examined. default: 21.
%    rep   - The number of blocks to examine. The more blocks that are found
%            to be in agreement the higher the probability that you have
%            have the correct Bayer pattern. default: 5.
%
% Outputs:
%    pattern - The Bayer filter pattern of img. If rep is greater than one
%              and all the blocks examined are not in agreement then pattern
%              will be nonsense.
%    pp - A matrix of the Bayer filter patterns found in each block. They
%         should all agree. If they don't try increasing start.
%
% Example:
%    [pattern, pp] = determine_bayer_pattern('path/myfilename.PGM', 21, 5)
%
% Other m-files required: myimread
% Subfunctions: none
% MAT-files required: none
%
% See also: NONE

% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function [pattern, pp] = determine_bayer_pattern(img, start, rep)

	if (nargin < 1 || nargin > 3 || isempty(img))
		usage('determine_bayer_pattern(img, start, rep)');
	end

	if (~exist('start','var') || isempty(start))
		start = 21;
	end

	if (~exist('rep','var') || isempty(rep))
		rep = 5;
	end

	if (rem(start,2) == 0)
		error('determine_bayer_pattern: parameter start must be odd.');
	end

	if ischar(img)
		I = myimread(img);
	else
		I = double(img);
	end

	S = start; % Coordinates of starting pixel. Must be odd.
	N = rep; % Number of blocks to examine.

	pp = repmat(['g' 'g' 'g' 'g'], [N, 1]);
	d = 2*(0:N-1);
	for li = 1:N
		B = reshape(I([S+d(li) S+d(li)+1], [S+d(li) S+d(li)+1]).', [4 1]);
		[ign, mj] = max(B); % red will have max intensity
		[ign, mk] = min(B); % blue will have min intensity
		if (mj ~= mk && length(mj) == 1 && length(mk) == 1)
			pp(li,mj) = 'r';
			pp(li,mk) = 'b';
		end
	end
	pattern = char( mean(uint8(pp), 1) );

	c = isempty(strfind(pattern, 'r')) || isempty(strfind(pattern, 'g'))...
		|| isempty(strfind(pattern, 'b'));
	if(c == 1)
		pattern = -1;
		disp(['determine_bayer_pattern: unable to find a valid' ...
			  'Bayer pattern.']);
	end

end
