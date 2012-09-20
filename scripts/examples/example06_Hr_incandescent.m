%
% This script demonstrates using so.Hr to radiometrically calibrate a incandescent
% lamp's spectrogram and the output of a TSL230 irradiance meter to check the
% the spectrum's calibration. The 60W Sylvania bulb has a filament that is the
% same shape as the 100W calibration lamp's filament; the 60W GE bulb has a
% differently shaped filament.
%
% call spectrometer_setup and system_function_calibrated before running this script.
%

s = filesep;
so = access_spectrometer_object();

%lamp_type = '40Wclear'
lamp_type = '60Wclear_syl'
%lamp_type = '60Wclear_ge'
%lamp_type = '100Wclear'

% the range of wavelengths where the spectrogram isn't mostly noise
if strcmpi(so.ftype, 'JPG')
	l0 = 400; % [nm]
	lf = 650; % [nm]
elseif strcmpi(so.ftype, 'PGM')
	l0 = 400; % [nm]
	lf = 690; % [nm]
end

switch lamp_type
case '40Wclear'
	sd = [so.dir_light s 'spectrographs' s '40W_GE_8'];
	load([sd s so.ftype '_40W_GE_8_e0.mat']);
	Tf = 2632.9; % 40W: own calc. 2632.9 K, internet avg. 2473.2 K

case '60Wclear_syl'
	sd = [so.dir_light s 'spectrographs' s '60W_Sylvania_8'];
	load([sd s so.ftype '_60W_Sylvania_8_e0.mat']);
	%Tf = str2double(metadata.filament_temp);
	Tf = 2681.8; % 60W: own calc. 2681.8 K, internet avg. 2707.73 K

case '60Wclear_ge'
	sd = [so.dir_light s 'spectrographs' s '60W_GE_8'];
	load([sd s so.ftype '_60W_GE_8_e0.mat']);
	Tf = 2681.8; % 60W: own calc. 2681.8 K, internet avg. 2707.73 K

case '100Wclear'
	load([so.dir_light s 'reference' s 'radiometric' s so.ftype '_radiometric_ref.mat']);
	spctgrph = radiometric_ref;
	Tf =  2772.7; % 100W: own calc. 2772.7K, internet avg. 2786.8 K

otherwise
	error('example06_Hr_incandescent: unknown lamp type.');
end

sensor_type = metadata.sensor_type;
fO = str2double(metadata.TSL230_fO); % [kHz]
sensitivity = str2double(metadata.TSL230_sensitivity);
distance = str2double(metadata.distance); % [m]

Z = image2spectrum(spctgrph);
Z = filtfilt(so.Ftri, 1, Z);
Ee = Z./so.Hr; % spectral irradiance, [W/m^2/nm]
Ee_gray = merge_RGB_spectrums(Ee); % spectral irradiance, [W/m^2/nm]

[ign, n0] = min(abs(so.lambda-l0));
[ign, nf] = min(abs(so.lambda-lf));
E1 = trapz(Ee_gray(n0:nf)).*(so.dlambda); % irradiance, [W/m^2]

% [W/(m^2)] * [(10^6 uW)/W] * [(m^2)/(10^4 cm^2)] = 100*[uW/cm^2]
% i.e. 1*[W/(m^2)] = 100*[uW/cm^2]
disp(['irradiance (E1) : ' num2str(E1) ' W/m^2 at distance '...
      num2str(distance) ' m.'])
%disp(['irradiance : ' num2str(100*E1) ' uW/cm^2 at distance '...
%      num2str(distance/100) ' cm.'])


%----------------------------
% check the irradiance result
%----------------------------

% Ee_gray isn't a good model spectrum to pass to TSL230_fO_to_irradiance()
% because the spectrum viewed by the irradiance sensor continues above
% and below the maximum and minimum wavelengths captured by the camera.
% Therefore it's not possible to directly calibrate the spectrogram that
% was captured by the camera. This section of code directly calibrates a
% mathematical model of the spectrogram and compares it to the indirectly
% calibrated spectrogram obtained above.

dl = 0.1;
lambda_Re = 250:dl:1250;

% tungsten emissivity corrected black body spectrum, spectral radiance
L = generate_Wbb_spectrum(lambda_Re, Tf, 'power'); % [W/(sr*m^2)/nm]

% convert radiance L to a model of the spectral irradiance.
Af = 1; % unknown emitting area, [m^2]
Ee_model = Af*L/(distance^2); % irradiance model, [W/m^2/nm]
Ee2 = TSL230_fO_to_irradiance(lambda_Re, Ee_model, fO, sensitivity, sensor_type, 'power');

[ign, n0] = min(abs(lambda_Re-l0));
[ign, nf] = min(abs(lambda_Re-lf));
E2 = trapz(Ee2(n0:nf)).*dl;

figure,	hold on
plot(so.lambda, fliplr(Ee))
%plot(so.lambda, Ee_gray, 'k')
plot(lambda_Re, Ee2, 'k')
axis([so.lambda(1) so.lambda(end) 0 1.1*max(Ee_gray)])
ylabel('spectral irradiance [W/m^2/nm]')
xlabel('wavelength [nm]')
title('incandescent spectrum calibration comparison')
%legend('indirectly calibrated (blue channel)', ...
%       '(green)', ...
%       '(red)', 'directly calibrated')

pct_err = 100*(E1-E2)/E2;
disp(['total irradiant flux percent error : ' num2str(pct_err) '%'])

