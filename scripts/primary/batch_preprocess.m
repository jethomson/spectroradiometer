% This script turns a set of spectrographs into averaged, corrected, and
% cropped spectrographs and saves them as mat files. This script only
% needs to run once on a new set of images. Once those images have been
% processed you should work with the resulting mat files. This prevents
% lots of extra computation from reprocessing the image files every time
% you wish to produce a spectrogram. However, the source images remain
% unchanged and the functions are capable of processing them if for some
% reason you want to process them individually with your own scripts,
% for an example of this see:
% examples/example01_cyan_LED_spectrogram_not_preprocessed.m
%
% The region of interest (roi) is the region a spectrograph is cropped to.

initialize_spectrometer_workspace

dark = [];
flat = [];

% uncomment these if you don't want to use real darks, flats, and/or perform
% tone linearization.
%dark = 0;
%flat = 1;

so.dir_light = [so.bd s 'light_frames' s so.exposure s so.sdate];

% If you are using an irradiance sensor then the center of your region of
% interest should be level with the center of the irradiance sensor.
% y0 must be odd so that the filter pattern of the cropped image data remains
% the same as filter pattern for the entire image (assuming the Bayer filter
% pattern is 2x2).
y0 = 1175; % center of irradiance sensor located at y0+(h/2).
h = 500; % set height of region of interest, h;

%roi_light = [0, 0]; % set roi to zeroes if you want to use the entire image.
roi_light = [y0, h, 0, 0]; % region of interest

% load master frames
g = waitbar(0, ['Loading ' so.ftype ' master frames and ' ...
                'processing reference frames. ']);
waitbar(0.001, g); % Octave's buggy waitbar doesn't like 0 or 1
Ns = 4; % number of waitbar steps

if isempty(dark)
	load([so.bd s 'dark_frames' s 'light_darks' s so.ftype ...
	      '_master_dark_' so.exposure '.mat']);
end
waitbar(1/Ns, g);

if isempty(flat)
	load([so.bd s 'flat_frames' s so.ftype '_master_flat.mat']);
end
waitbar(2/Ns, g);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process spectral and radiometric reference spectrographs                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% process spectral_ref
imgdir = [so.dir_light s 'reference' s 'spectral' s so.ftype];
spectral_ref = ensemble_average(imgdir);

spectral_ref = spectral_ref - dark;
spectral_ref = flat_correct(spectral_ref, flat);
spectral_ref = crop_image(spectral_ref, roi_light);

if strcmpi(so.ftype, 'PGM')
	spectral_ref = bayer_demosaic(spectral_ref);
end

[ign, pdirpath] = pop_dirname(imgdir);
metadata = process_metadata_file(pdirpath);

matname = [so.ftype '_spectral_ref.mat'];
save('-V6', [pdirpath s matname], 'spectral_ref', 'metadata');
waitbar(3/Ns, g);

% process radiometric_ref
imgdir = [so.dir_light s 'reference' s 'radiometric' s so.ftype];
radiometric_ref = ensemble_average(imgdir);

radiometric_ref = radiometric_ref - dark;
radiometric_ref = flat_correct(radiometric_ref, flat);
radiometric_ref = crop_image(radiometric_ref, roi_light);

if strcmpi(so.ftype, 'PGM')
	radiometric_ref = bayer_demosaic(radiometric_ref);
end

[ign, pdirpath] = pop_dirname(imgdir);
metadata = process_metadata_file(pdirpath);

matname = [so.ftype '_radiometric_ref.mat'];
save('-V6', [pdirpath s matname], 'radiometric_ref', 'metadata');
clear spectral_ref radiometric_ref;
waitbar((4/Ns)-0.001, g);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process spectrographs of interest                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g = waitbar(0, ['Processing ' so.ftype ' spectrographs. ' ...
                'This may take several minutes.']);
waitbar(0.001, g); % Octave's buggy waitbar doesn't like 0 or 1
dl = list_dir([so.dir_light s 'spectrographs'], so.ftype, 3);
Ns = length(dl);

for jj=1:Ns
	waitbar(((jj-1)/Ns)-0.001, g);
	fl = list_dir(dl{jj}, ['*.' so.ftype], 1);
	if isempty(fl)
		continue;
	end
	spctgrph = ensemble_average(dl{jj});
	spctgrph = spctgrph - dark;

	spctgrph = flat_correct(spctgrph, flat);
	spctgrph = crop_image(spctgrph, roi_light);

	if strcmpi(so.ftype, 'PGM')
		spctgrph = bayer_demosaic(spctgrph);
	end

	[ign, pdirpath] = pop_dirname(dl{jj});
	metadata = process_metadata_file(pdirpath);

	[ensemble_number, pdirpath] = pop_dirname(pdirpath);
	spectrographs_descriptor = pop_dirname(pdirpath);
	matname = [so.ftype '_' spectrographs_descriptor '_' ensemble_number ...
	           '.mat'];
	save('-V6', [pdirpath s matname], 'spctgrph', 'metadata');

end
waitbar(1-0.001, g);

disp('')
disp([mfilename() ' finished.'])
clear all
