%
% This example script demonstrates various ways to use the spectrometer
% functions to produce spectrograms without using preprocessed spectrographs.
%

example = 'b';

switch example

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the simplest way to use the spectrometer code. It neglects most of the
% code's features; features which result in better spectrograms being produced.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'a'
	s = filesep;
	Hg_fname = ['data' s 'A590' s 'frames' s 'light_frames' s '2s' s ...
	            '2012_08_30' s 'reference' s 'spectral' s 'PGM' s 'HG_REF.PGM'];
	cyan_fname = ['data' s 'A590' s 'frames' s 'light_frames' s '2s' s ...
	              '2012_08_30' s 'spectrographs' s 'Cyan_LED_3' s ...
	              'e0' s 'PGM' s 'CYAN01.PGM'];
	bfp = 'gbrg';
	access_bayer_pattern(bfp); % set Bayer filter pattern

	lambda = wavelength_calibrate(Hg_fname);

	cyan = bayer_demosaic(cyan_fname, bfp, true);
	Z = image2spectrum(cyan, 'rgb');

	figure
	% plot usually plots blue, then green, then red, so flip the data so the
	% red channel is red, green is green, and blue is blue.
	plot(lambda, fliplr(Z))
	xlabel('wavelength [nm]')
	title('simple spectrogram')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This example demonstrates producing an RGB spectrograms from a single raw
% spectrograph that has been cropped but not dark and flat frame corrected.
% It also shows how to construct a path to spectrograms in a more systematic
% way.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'b'
	s = filesep;

	% create spectrometer dataset record
	so.cam = 'A590';
	so.ftype = 'PGM';
	so.exposure = '2s';
	so.sdate = '2012_08_30';
	so.bfp = 'gbrg';
	access_bayer_pattern(so.bfp);
	so.bd = ['data' s so.cam s 'frames']; % base directory
	access_spectrometer_object(so);

	so.dir_light = [so.bd s 'light_frames' s so.exposure s so.sdate];
	y0 = 1175; % You can determine a good y0 by visually inspecting the
	           % spectrograph. Since the Bayer filter pattern is 2x2,
	           % y0 should be odd because the filter pattern repeats
	           % every odd numbered row.
	h = 500; % height of region of interest

	Hg_fname = [so.dir_light s 'reference' s 'spectral' s 'PGM' s 'HG_REF.PGM'];

	so.lambda = wavelength_calibrate(Hg_fname, [y0, h]);
	cyan_dir = [so.dir_light s 'spectrographs' s 'Cyan_LED_3' s 'e0' s 'PGM'];
	fl = list_dir(cyan_dir, '*.PGM', 1);
	cyan = bayer_demosaic(fl{1}, so.bfp, true);

	% you could also load an image like this
	%D = dir([cyan_dir s '*.PGM']);
	%fl = {D.name};
	%cyan_fname = [cyan_dir s fl{1}];
	%cyan = bayer_demosaic(cyan_fname);

	Z = image2spectrum(cyan, 'rgb', [y0, h]);

	figure
	plot(so.lambda, fliplr(Z))
	a = axis;
	axis([so.lambda(1) so.lambda(end) a(3) a(4)])
	xlabel('wavelength [nm]')
	legend('red channel', 'green channel', 'blue channel')
	title('spectrogram from single image');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This example demonstrates producing RGB spectrograms from an ensemble of raw
% spectrographs by averaging, cropping, and performing (simulated) dark and
% flat frame correction.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'c'
	initialize_spectrometer_workspace
	so.dir_light = [so.bd s 'light_frames' s so.exposure s so.sdate];
	y0 = 1175; % first row of ROI
	h = 500; % height of region of interest

	%load([so.bd s 'dark_frames' s 'light_darks' s so.ftype ...
	%      '_master_dark_' so.exposure '.mat']);
	%load([so.bd s 'flat_frames' s so.ftype '_master_flat.mat']);

	% Simulated dark and flat frames. These values won't change anything.
	dark = 0;
	flat = 1;

	Hg_dir = [so.dir_light s 'reference' s 'spectral' s so.ftype];
	Hg = ensemble_average(Hg_dir);

	Hg = Hg - dark;
	Hg = flat_correct(Hg, flat);
	Hg = crop_image(Hg, [y0, h]);
	Hg = bayer_demosaic(Hg, so.bfp, true);
	lambda = wavelength_calibrate(Hg);

	cyan_dir = [so.dir_light s 'spectrographs' s 'Cyan_LED_3' s 'e0' s 'PGM'];
	cyan = ensemble_average(cyan_dir);
	cyan = cyan - dark;
	cyan = flat_correct(cyan, flat);
	cyan = crop_image(cyan, [y0, h]);
	cyan = bayer_demosaic(cyan, so.bfp, true);
	Z = image2spectrum(cyan, 'rgb');

	figure, hold on
	plot(lambda, fliplr(Z))
	Zgray = merge_RGB_spectrums(Z);
	plot(lambda, Zgray, 'k')

	[pk, l] = max(Z);
	pw = lambda(l);
	plot(pw, pk, 'y*')
	disp('Datasheet peak wavelength: 505nm');
	fprintf(['Measured peak wavelength: Red=%.2fnm, Green=%.2fnm,' ...
	         'Blue=%.2fnm\n'], pw);

	[pk, l] = max(Zgray);
	pw = lambda(l);
	plot(pw, pk, 'y*')
	fprintf('Measured peak wavelength: Gray=%.2fnm\n', pw);

	a = axis;
	axis([lambda(1) lambda(end) a(3) a(4)])
	xlabel('wavelength [nm]')
	legend('red channel', 'green channel', 'blue channel', 'channels averaged')
	title('spectrogram from ensemble');

otherwise

end
