% This script processes light, flat, dark, and bias frames into master light,
% flat, dark, and bias frames. The master frames are saved as .mat files. A
% master bias frame is only necessary if you are interested in scaling a dark
% frame to better match the dark current in a light frame. The flat frame is
% demosaiced, desaturated (made gray), normalized, then re-mosaiced. The flat
% frame is demosaiced because it is easier to desaturate it in this form; it is
% re-mosaiced because it is less computationally intense to flat correct a light
% frame when it is still a Bayer raw.
%

initialize_spectrometer_workspace

dir_lightdarks = [so.bd s 'dark_frames' s 'light_darks' s so.exposure s so.ftype];
dir_flatdarks = [so.bd s 'dark_frames' s 'flat_darks' s so.ftype];
dir_flats = [so.bd s 'flat_frames' s so.ftype];
dir_bias = [so.bd s 'bias_frames' s so.ftype];

g = waitbar(0, ['Processing ' so.ftype ' dark, flat, and bias frames. ' ...
                'This may take several minutes.']);
waitbar(0.001, g); % Octave's buggy waitbar doesn't like 0 or 1
wblen = 6;

waitbar(1/wblen, g);
dark = ensemble_average(dir_lightdarks);
waitbar(2/wblen, g);

FD = ensemble_average(dir_flatdarks);
waitbar(3/wblen, g);
F = ensemble_average(dir_flats);
F = F - FD;
waitbar(4/wblen, g); % finished processing darks and flats

if strcmpi(so.ftype, 'PGM')
	F = bayer_demosaic(F); % separate Bayer raw into channels

	% shift each channel's average gray level so that they are all the same,
	% by using the green channel's gray level, mn(2), as a reference.
	mn = reshape(image_mean(F), [1 1 3]);
	mn_shift = repmat(mn(2)-mn, [size(F,1), size(F,2), 1]);
	Fgray = F + mn_shift;

	mx = max(Fgray(:));
	Fnormal = Fgray./mx;
	% re-mosaic so flat frame correction can be performed on Bayer raws,
	% which is less computationally intense.
	F = bayer_mosaic(Fnormal);
else
	% shift each channel's average gray level so that they are all the same,
	% by using the green channel's gray level, mn(2), as a reference.
	mn = reshape(image_mean(F), [1 1 3]);
	mn_shift = repmat(mn(2)-mn, [size(F,1), size(F,2), 1]);
	Fgray = F + mn_shift;

	mx = max(Fgray(:));
	Fnormal = Fgray./mx;
	F = Fnormal;
end
flat = F;
clear F FD Fgray Fnormal;

bias = ensemble_average(dir_bias);
waitbar(5/wblen, g);

%save calibration frames
[ign, pdirpath] = pop_dirname(dir_lightdarks);
[ign, pdirpath] = pop_dirname(pdirpath);
matname = [so.ftype '_master_dark_' so.exposure '.mat'];
save('-V6', [pdirpath s matname], 'dark');

[ign, pdirpath] = pop_dirname(dir_flats);
matname = [so.ftype '_master_flat.mat'];
save('-V6', [pdirpath s matname], 'flat');

[ign, pdirpath] = pop_dirname(dir_bias);
matname = [so.ftype '_master_bias.mat'];
save('-V6', [pdirpath s matname], 'bias');

waitbar((6/wblen)-0.001, g);

disp('')
disp([mfilename() ' finished.'])
clear all
