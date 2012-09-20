%
% This script uses a mathematically derived spectrum of an incandescent bulb,
% the spectrum of an actual incandescent bulb captured by the spectrometer, and
% a reading from a TSL230 irradiance sensor to obtain a radiometric calibration
% for the spectrometer.
%
% XX is a mathematical representation of the photon spectral irradiance present
% at the slit of the spectrometer, [photon/(s*m^2)/nm].
% YY is the spectrum of the incandescent bulb captured by the camera, [count].
%        -----
% XX --> | H | --> YY
%        -----
% XX*H = YY  --> H = YY/XX
%
% H is the spectrometer's system function.
% For an in-depth explanation visit:
% http://jethomson.wordpress.com/spectrometer-articles/system-function/
%
% A spectrogram may be calibrated by either indirect or direct calibration. If
% the incandescent lamp input spectrum used to determine the system function is
% radiometrically calibrated, then dividing the system function out of a
% spectrogram should result in distortion being removed and it becoming
% radiometrically calibrated. This is known as indirect calibration because a
% direct irradiance measurement of the light source of interest wasn't used to
% calibrate its spectrogram. Direct calibration uses a measurement taken from an
% irradiance sensor of the light source of interest to calibrate its spectrogram
% and relies on dividing out the system function to remove distortion from the
% spectrogram but not to radiometrically calibrate it. Unfortunately indirect
% and direct calibrations don't always agree with each other because the
% irradiance sensor and camera are physically separated and don't always
% see a light source in the same way. For example, a light source could look
% like a point source to the camera, but like an area source to the irradiance
% sensor. Also, assuming a nonisotropic source, the rays that strike the
% irradiance sensor might not originate from a part of the source with the same
% radiation pattern as the rays that strike the camera. For this reason, it's
% best to always reference every spectrogram to what the irradiance sensor sees.
% Therefore you should take an irradiance measurement of every light source of
% interest and use those measurements to directly calibrated their spectrograms.
%
% NOTES:
% This script won't produce accurate results when used on JPEG image data
% because of the non-linear transformations involved in creating a JPEG.
%
% This code uses a table of tungsten emissivity values to model the incandescent
% bulb's spectrum; however, the spectral emissivity of an incandescent bulb can
% vary quite a bit even among bulbs of the exact same type and manufacturer.
%
% Even when my camera is in manual mode, the camera will automatically make
% small corrections to the chosen f-number based of the scene's brightness.
% You can use CHDK's aperture override setting to prevent this.
%
% The smooth ratio is (smooth width)/(peak width) where peak width is full
% width at half maximum (FWHM). Higher smooth ratios will reduce peak height
% and increase peak width. Therefore, to preserve peak width the smooth ratio
% should be less than 0.2
%

%disp('*** Determining spectrometer''s system function. ***');
s = filesep;
so = access_spectrometer_object();

%**** USER SUPPLIED DATA ****%
%calibration_lamp_type = '60Wclear'
calibration_lamp_type = '100Wclear'

switch calibration_lamp_type
case '60Wclear'
	% These parameters result in a calculated filament temperature of 2681.8 K
	% internet avg. 2707.73 K
	Rx = mean([1.35 0.85]);  % [ohms]
	Ri = mean([17.8 17.35]);  % [ohms]
	Vf = mean([(121.85 - 0.0055) (121.75 - 0)]); % [V]
	If = mean([(0.5 - 0.01) (0.47 - 0)]); % [A]
	Rf = (Vf/If) - Rx;  % [ohms]
	Ti = 24.444; % [C]

	Tf = calculate_filament_temp(Ti, Ri, Rf);

	load([so.dir_light  s 'spectrographs' s '60W_Sylvania_8' s so.ftype ...
	      '_60W_Sylvania_8_e0.mat']);
	radiometric_ref = spctgrph;

case '100Wclear'
	% These parameters result in a calculated filament temperature of 2772.7 K
	% Averaging five filament temperatures found on the web resulting in:
	% mean 2786.8 K, std. dev. 58.554 K
	Rx = mean([1.35 0.85]); % [ohms]
	Ri = mean([10.2 9.65]); % [ohms]
	Vf = mean([(119.35 - 0.0055) (119.35 - 0)]); % [V]
	If = mean([(0.815 - 0.01) (0.79 - 0)]); % [A]
	Rf = (Vf/If) - Rx; % [ohms]
	Ti = 24.444; % [C]

	Tf = calculate_filament_temp(Ti, Ri, Rf);

	load([so.dir_light  s 'reference' s 'radiometric' s so.ftype ...
	      '_radiometric_ref.mat']);

otherwise
	error('system_function_calibrated: unknown calibration lamp type.');
end

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

dl = 0.1;
lambda_Re = 250:dl:1250;

sensor_type = metadata.sensor_type;
fO = str2double(metadata.TSL230_fO); % [kHz]
sensitivity = str2double(metadata.TSL230_sensitivity);
distance = str2double(metadata.distance); % [m]

%disp(['filament temperature : ' num2str(Tf) 'K'])

% spectral photon radiance, [photon/(s*sr*m^2)/nm]
N = generate_Wbb_spectrum(lambda_Re, Tf, 'quantal');
Af = 1; % unknown emitting area, [m^2]

% This model assumes the light source is an isotropic point source, which is
% most likely an incorrect assumption. However, we only care about the shape
% of X_model. TSL230_fO_to_irradiance() should scale it properly. Multiplying
% N by Af and dividing by distance squared simply transforms the spectrum to the
% correct units (i.e. from radiance to irradiance).
X_model = Af*N/(distance^2); % spectral photon irradiance, [photon/(s*m^2)/nm]

% use the output of the irradiance sensor to scale the model
X = TSL230_fO_to_irradiance(lambda_Re, X_model, fO, sensitivity, sensor_type, 'quantal');

X = interp1(lambda_Re, X, so.lambda, 'spline');
XX = repmat(X, 1, 3); % [photon/(s*m^2)/nm]

YY = image2spectrum(radiometric_ref, 'rgb'); % [count]
YY = filtfilt(so.Ftri, 1, YY); % smooth YY

H = YY./XX; % spectrometer system function, [count]/[photon/(s*m^2)/nm]

[ign, n0r] = min(abs(so.lambda-l0r));
[ign, n0g] = min(abs(so.lambda-l0g));
[ign, n0b] = min(abs(so.lambda-l0b));
[ign, nfr] = min(abs(so.lambda-lfr));
[ign, nfg] = min(abs(so.lambda-lfg));
[ign, nfb] = min(abs(so.lambda-lfb));

H(1:n0r,1) = Inf;
H(1:n0g,2) = Inf;
H(1:n0b,3) = Inf;
H(nfr:end,1) = Inf;
H(nfg:end,2) = Inf;
H(nfb:end,3) = Inf;

% energy per photon as a function of wavelength
WWp = repmat(h*c./(so.lambda*10^-9), 1, 3); % [J/photon]

% ([count]/[photon/(s*m^2)/nm])/[J/photon] = [count]/[W/m^2/nm]
so.Hr = H./WWp; % Hr represents the transformation from spectral irradiance to counts.

access_spectrometer_object(so);
clear
%disp([mfilename() ' finished.'])
