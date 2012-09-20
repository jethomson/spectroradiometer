% Once you have preprocessed all your spectrographs you can begin turning them
% into spectrograms. When starting a new session, this script should be run
% first. It sets up several variables used by the other scripts to produce
% spectrograms.
%
%     so   : spectrometer object, a record containing information about the
%            set of spectrographs that are to be processed.
%  lambda  : the calibrated wavelength scale used for plotting spectrograms
%      L   : the length of lambda as well as the width of the images being
%            processed.
%

initialize_spectrometer_workspace
so.dir_light = [so.bd s 'light_frames' s so.exposure s so.sdate];

disp(['*** Setting up workspace to produce spectrograms from ' so.ftype ...
      ' spectrographs. ***']);

% load spectral reference spectrograph
load([so.dir_light  s 'reference' s 'spectral' s so.ftype '_spectral_ref.mat']);

% converting from linear to sRGB will cause the peaks stand out making it easier
% to pick them out.
if strcmpi(so.ftype, 'PGM')
	max_level = 2^ceil(log2(max(spectral_ref(:)))) - 1;
	% because lin2sRGB expects the maximum level to be 255, an image with a
	% a greater range of levels has to be scaled.
	spectral_ref = lin2sRGB((255/max_level)*spectral_ref);
end

% Look at CFL_Hg_peaks_labeled.png to see the numbered peaks and their
% wavelengths. The wavelengths are not given for the non-mercury peaks.
% Your camera might not capture peak number 1. You don't have to click
% exactly on the peak and only the x-coordinate of where you click matters.
so.lambda = wavelength_calibrate(spectral_ref);
so.dlambda = mean(diff(so.lambda));
clear spectral_ref;

so.L = length(so.lambda);

access_spectrometer_object(so);
clear
disp([mfilename() ' finished.'])
