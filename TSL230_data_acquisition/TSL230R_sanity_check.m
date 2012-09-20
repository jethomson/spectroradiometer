% From the TSL2561 datasheet:
% "The 640 nm irradiance Ee is supplied by an AlInGaP light-emitting diode with
% the following characteristics: peak wavelength λp = 640 nm and spectral
% halfwidth ∆λ1⁄2 = 17 nm." --> mu = 640 nm, FWHM = 2*17 nm
%
% This script assumes the same test LED was used to measure the typical output
% of the TSL230R.
%
% Operating characteristics from the TSL230R datasheet:
% With a sensitivity of 100x, frequency scaling of 1, Vdd = 5V, Ta = 25°C,
% Ee = 130 uW/cm^2, and λp = 640 nm the typical output frequency is 100 kHz.

s = filesep;
load(['data' s 'essential_data_sets' s 'TSL230R_Re_s1.mat']);
dlambda = lambda_Re(2)-lambda_Re(1);

% Re_s1.mat : (irradiance responsivity @ 640 nm of sensor with sensitivity of 1
%              and freq. scaling of 1 = 0.0077 [kHz/(uW/cm^2)] = 0.77 [kHz/(W/m^2)])
%             *(normalized spectral responsivity of sensor)
Re_s100 = 100*Re_s1; % response for a sensitivity of 100

e = exp(1);
Fled = @(mu, FWHM) e.^(-2.7726*((lambda_Re-mu)/FWHM).^2);
Xred = Fled(640, 2*17);
k = trapz(Xred).*(dlambda);
Ee = (130/k)*Xred; % model of AlInGaP test LED, [uW/cm^2/nm]

% Re_s100 has units of [kHz/(W/m^2)] so Ee needs to be converted
% from [uW/cm^2/nm]  to [W/m^2/nm]
% [uW/(cm^2)] * [(10^-6 W)/uW] * [cm^2/(10^-4 m^2)] = (1/100)*[W/m^2]
% i.e. 1*[uW/(cm^2)] = (1/100)*[W/m^2]
f = trapz(Re_s100.*(Ee/100)).*(dlambda); % [kHz], should be very close to 100

% datasheet says typical output frequency for AlInGaP test LED should be 100 kHz
% at a sensitivity of 100x
pct_error = 100*(f - 100)/100
