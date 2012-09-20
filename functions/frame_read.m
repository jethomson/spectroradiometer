%FRAME_READ - A wrapper function for bayer_demosaic and myimread.
%
% If the image's file extension matches the file type specified in the constant
% BAYER_RAW_FTYPE, then the image data will be read, demosaiced, and returned.
% Otherwise, the image will be read and returned. This function allows cleaner
% code to be written because it allows one function call to read regular images
% and Bayer raw images.
%
% Syntax:  I = frame_read(fname)
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
% Other m-files required: bayer_demosaic, myimread
% Subfunctions: none
% MAT-files required: none
%
% See also: BAYER_DEMOSAIC, MYIMREAD
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function I = frame_read(fname)

	% Change this to the file format of your Bayer raws.
	% You may need to write a function to read your raw file's format.
	BAYER_RAW_FTYPE = '.PGM';

	if (nargin ~= 1 || isempty(fname))
		usage('frame_read(fname)');
	end

	[ign, ign, ext] = fileparts(fname);

	if strcmpi(ext, BAYER_RAW_FTYPE)
		I = bayer_demosaic(fname);
	else
		I = myimread(fname);
	end
end
