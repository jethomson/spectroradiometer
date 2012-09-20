%READ_16BIT_PGM_TEST - Checks a 16 bit PGM test image to see if Octave is
%                      able to read it. If this function returns false, then
%                      GraphicsMagick most likely has a quantum depth of 8 and
%                      Octave will not read 16 bit images correctly.
%
% Syntax:  read16bitOK = read_16bit_pgm_test()
%
% Inputs:
%    none
%
% Outputs:
%    read16bitOK = boolean, true if Octave is able to read the 16 bit test
%                  image or this function is not being run in Octave, and
%                  false if GraphicsMagick returns an error.
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: BAYER_DEMOSAIC, PNMREAD
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function read16bitOK = read_16bit_pgm_test()

	persistent warned = 0;
	read16bitOK = true;
	warning_string = ['read_16bit_pgm_test() -- Octave image library ' ...
	                  'does not support reading 16 bit PGM images. ' ...
	                  'pnmread() will be used instead. This will ' ...
	                  'result in slower image reads.'];

	% OCTAVE_VERSION is a built in function, exist returns 5 in octave
	if (exist('OCTAVE_VERSION'))
		s = filesep;
		fname = ['data' s 'essential_data_sets' s ...
		         'pgm_test_image_16bit_raw.pgm'];

		try
			% Octave crashes if imfinfo is called before any images
			% are read.
			%ign = imfinfo(fname);
			ign = imread(fname);
		catch
			if (warned == 0)
				warning(warning_string)
				warned = 1;
			end
			read16bitOK = false;
		end_try_catch
	end

end
