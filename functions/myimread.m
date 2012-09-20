%MYIMREAD - A wrapper function for imread and other image reading functions for
%           image file formats that are unsupported by imread.
%
% Syntax:  I = myimread(fname)
%
% Inputs:
%    fname - an image's filename
%
% Outputs:
%    I - a matrix representing the contents of the image pointed to by fname.
%
% Example:
%
%
% Other m-files required: read_16bit_pgm_test, pnmread
% Subfunctions: none
% MAT-files required: none
%
% See also: READ_16BIT_PGM_TEST, PNMREAD
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function I = myimread(fname)

	if (nargin ~= 1 || isempty(fname))
		usage('myimread(fname)');
	end

	[ign, ign, ext] = fileparts(fname);

	% If Octave does not support your image's file format, you'll
	% need to add a special purpose function to decode the image's
	% data.
	if (~read_16bit_pgm_test() && strcmpi(ext, '.PGM'))
		I = double(pnmread(fname));
	%elseif (~read_16bit_tiff_test() && strcmpi(ext, '.TIFF'))
	%	I = double(tiffread(fname));
	else
		I = double(imread(fname));
	end
end
