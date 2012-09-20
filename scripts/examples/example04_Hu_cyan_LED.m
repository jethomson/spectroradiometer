%
% This script demonstrates using so.Hu and the output of a TSL230 irradiance
% sensor to produce a radiometrically calibrated spectrum. so.Hu differs from
% the actual system function by a scaling factor, therefore, dividing the cyan
% LED's spectrum by so.Hu results in a corrected but uncalibrated spectrum.
% Since the resulting spectrum is only off by a scaling factor it can be
% directly calibrated using readings taken from a TSL230.
%
% After taking the spectrograph while the LED was pointed at the slit, I
% re-aimed the LED directly at the irradiance sensor. This was necessary because
% the LED is very directional. If your light source's radiation pattern is the
% same at the slit and TSL230 then you can take the irradiance measurement the
% same time you snap a spectrograph (i.e. you don't have to re-aim the light
% source).
%
% call spectrometer_setup and system_function_uncalibrated before running this
% script.
%

s = filesep;
so = access_spectrometer_object();

% the range of wavelengths where the spectrogram isn't mostly noise
l0 = 435; % [nm]
lf = 600; % [nm]

smooth_width = 11;
Ftri = triang(smooth_width);
Ftri = Ftri./sum(Ftri);

sd = [so.dir_light s 'spectrographs' s 'Cyan_LED_3'];
load([sd s so.ftype '_Cyan_LED_3_e0.mat' ]);

sensor_type = metadata.sensor_type;
fO = str2double(metadata.TSL230_fO); % [kHz]
sensitivity = str2double(metadata.TSL230_sensitivity);
distance = str2double(metadata.distance); % [m]

[ign, n0] = min(abs(so.lambda-l0));
[ign, nf] = min(abs(so.lambda-lf));

h = 6.62606896*10^-34; % Planck constant, [J*s]
c = 299792458; % speed of light, [m/s]
Wp = h*c./(so.lambda(n0:nf)*10^-9); % [J/photon]

Z = image2spectrum(spctgrph);
Z = filtfilt(Ftri, 1, Z); % distorted spectrum, [count]
Zc = Z./so.Hu; % uncalibrated spectral photon irradiance, [photon/(s*m^2)/nm]
Zc_green = Zc(n0:nf,2); % the green channel only

% E1 isn't calculated in this script. The variable name E1 is skipped in this
% script so E2 is easier to compare to the variable of the same name
% in example05.

% Zc_green is the uncalibrated spectral photon irradiance of the cyan LED, [photon/(s*m^2)/nm]
% N2 is the directly calibrated spectral photon irradiance of the cyan LED, [photon/(s*m^2)/nm]
N2 = TSL230_fO_to_irradiance(so.lambda(n0:nf), Zc_green, fO, sensitivity, sensor_type, 'quantal');

% Ee2 is the directly calibrated spectral irradiance of the cyan LED, [W/m^2/nm]
Ee2 = Wp.*N2; % convert spectral photon irradiance to spectral irradiance.
E2 = trapz(Ee2).*(so.dlambda); % irradiance, [W/m^2]
disp(['irradiance (E2) : ' num2str(E2) ' W/m^2 at distance '...
	  num2str(distance) ' m.'])

figure
plot(so.lambda(n0:nf), Ee2, 'r')
axis([l0 lf 0 1.1*max(Ee2)])
ylabel('spectral irradiance [W/m^2/nm]')
xlabel('wavelength [nm]')
title('directly calibrated, corrected spectrum of a cyan LED')
