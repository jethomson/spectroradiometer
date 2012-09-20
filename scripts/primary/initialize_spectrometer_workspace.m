% This script creates and initializes the variables that construct the path to
% the spectrographs you wish to process.
%
% This script also sets the Bayer filter pattern. Remember that batch_raw_decode
% outputs the Bayer filter pattern of the images it decodes. Keep in mind that
% cropping a Bayer raw image may change which filter pattern should be used to
% demosaic the image.

% User-defined variables:
%  camera - camera identifier.
%  ftype - type of file to process. JPG and PGM are supported.
%  exposure - the exposure time of the spectrographs. This is used to load the
%             correct set of master calibration frames.
%  sdate - date spectrographs were taken.

clear access_spectrometer_object

so_name = 'b';
switch so_name

case 'a'
	so.camera = 'A75';
	so.ftype = 'JPG';
	so.exposure = '1dot6s';
	so.sdate = '2012_08_12';

case 'b'
	so.camera = 'A590';
%	so.ftype = 'JPG';
	so.ftype = 'PGM';
	so.exposure = '2s';
%	so.sdate = '2012_07_22';
	so.sdate = '2012_08_30';
%	so.sdate = '2012_09_13';

	%so.raven = 'Galifianakis';

	% set Bayer filter pattern.
	% Bayer filter pattern for a DNG from an A590
	so.bfp = 'gbrg';
	access_bayer_pattern('gbrg');

otherwise

end

s = filesep;
so.bd = ['data' s so.camera s 'frames']; % base directory

access_spectrometer_object(so);
