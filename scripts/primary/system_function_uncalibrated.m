%
% This script uses a mathematically derived spectrum of an incandescent bulb
% and the spectrum of an actual incandescent bulb captured by the spectrometer
% to obtain the spectrometer's uncalibrated system function.
%
% XX is a mathematical representation of the photon spectral irradiance present
% at the slit of the spectrometer, [photon/(s*m^2)/nm].
% YY is the spectrum of the incandescent bulb captured by the camera, [count].
%        -----
% XX --> | H | --> YY
%        -----
% XX*H = YY  --> H = YY/XX
%
% H is the spectrometer's system function. Unfortunately since the actual
% irradiance at the slit is unknown the best we can do is model the shape of
% it with XXu, where k*XXu = XX and k is an unknown constant.
%        -----
% H = YY/XX --> H = YY/(k*XXu) --> k*H = YY/XXu --> Hu = YY/XXu
% where Hu is the spectrometer's uncalibrated system function.
%
% Hu has the same shape as H, so it can still be used to remove the distortion
% the system causes to your spectrograms of interest; however the resulting
% spectrums will be off by a constant scaling factor. Although a calibrated
% system function would be better, Hu can still be useful to users that only
% need to see the shape of the spectrum without distortion and don't require
% the correct radiometric scaling.
%
% For an in-depth explanation visit:
% http://jethomson.wordpress.com/spectrometer-articles/system-function/
%
%
% NOTES:
% This script won't produce accurate results when used on JPEG image data
% because of the non-linear transformations involved in creating a JPEG.
%
% This code uses a table of tungsten emissivity values to model the incandescent
% bulb's spectrum; however, the spectral emissivity of an incandescent bulb can
% vary quite a bit even between bulbs of the exact same type and manufacturer.
%
% The smooth ratio is (smooth width)/(peak width) where peak width is full
% width at half maximum (FWHM). Higher smooth ratios will reduce peak height
% and increase peak width. Therefore, to preserve peak width the smooth ratio
% should be less than 0.2
%

s = filesep;
so = access_spectrometer_object();

%**** USER SUPPLIED DATA ****%
distance = 0.2032; % [m]

% 100 W GE crystal clear bulb
% These parameters result in a calculated filament temperature of 2772.7 K
% Averaging five filament temperatures found on the web resulting in:
% mean 2786.8 K, std. dev. 58.554 K
Rx = mean([1.35 0.85]); % [ohms]
Ri = mean([10.2 9.65]); % [ohms]
Vf = mean([(119.35 - 0.0055) (119.35 - 0)]); % [V]
If = mean([(0.815 - 0.01) (0.79 - 0)]); % [A]
Rf = (Vf/If) - Rx; % [ohms]
Ti = 24.444; % [C]

smooth_width = 201;

% The bands [so.lambda(1) to l0] and [lf to so.lambda(end)] will be set to
% infinity in the system function, H, so that noise with values near zero
% will not cause the result of deconvolution to blow up. To determine the
% bands, plot H to see the regions where the function blows up, then adjust
% the band intervals to exclude those regions.

if strcmpi(so.camera, 'A75') % JPEG only camera. Don't expect accurate results.
	l0b = 380; % [nm]
	lfb = 500;
	l0g = 480;
	lfg = 610;
	l0r = 580;
	lfr = 670;
elseif strcmpi(so.camera, 'A590')
	if strcmpi(so.ftype, 'JPG') % Don't expect accurate results with JPEGs.
		l0b = 390; % [nm]
		lfb = 510;
		l0g = 490;
		lfg = 600;
		l0r = 565;
		lfr = 650;
	elseif strcmpi(so.ftype, 'PGM')
		l0b = 390; % [nm]
		lfb = 665;
		l0g = 410;
		lfg = 675;
		l0r = 420;
		lfr = 690;
	end
end

%**** END USER SUPPLIED DATA ****%

h = 6.62606896*10^-34; % Planck constant, [J*s]
c = 299792458; % speed of light, [m/s]
Ftri = triang(smooth_width);
so.Ftri = Ftri./sum(Ftri);

Tf = calculate_filament_temp(Ti, Ri, Rf);
%disp(['filament temperature : ' num2str(Tf) 'K'])

% spectral photon radiance, [photon/(s*sr*m^2)/nm]
N = generate_Wbb_spectrum(so.lambda, Tf, 'quantal');
Af = 1; % unknown emitting area, [m^2]

% This model assumes the light source is an isotropic point source, which is
% most likely an incorrect assumption. However, we only care about the shape
% of Xu. N by Af and dividing by distance squared simply transforms the spectrum
% to the correct units.
Xu = Af*N/(distance^2); % spectral photon irradiance, [photon/(s*m^2)/nm]

XXu = repmat(Xu, 1, 3); % [photon/(s*m^2)/nm]

load([so.dir_light  s 'reference' s 'radiometric' s so.ftype ...
      '_radiometric_ref.mat']);
YY = image2spectrum(radiometric_ref, 'rgb'); % [count]
YY = filtfilt(so.Ftri, 1, YY); % smooth YY

Hu = YY./XXu; % spectrometer's uncalibrated system function, [count]/[photon/(s*m^2)/nm]

[ign, n0r] = min(abs(so.lambda-l0r));
[ign, n0g] = min(abs(so.lambda-l0g));
[ign, n0b] = min(abs(so.lambda-l0b));
[ign, nfr] = min(abs(so.lambda-lfr));
[ign, nfg] = min(abs(so.lambda-lfg));
[ign, nfb] = min(abs(so.lambda-lfb));

% setting these regions to infinity will result in the same regions of a spectrum
% being set to zero when it is divided by the Hu.
Hu(1:n0r,1) = Inf;
Hu(1:n0g,2) = Inf;
Hu(1:n0b,3) = Inf;
Hu(nfr:end,1) = Inf;
Hu(nfg:end,2) = Inf;
Hu(nfb:end,3) = Inf;
so.Hu = Hu; % Hu represents the transformation from spectral photon irradiance to counts.

access_spectrometer_object(so);
clear
