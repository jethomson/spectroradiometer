%TSL230_fO_to_irradiance - Converts the frequency output of the TSL230, TSL230R,
%                          or TSL230RD to irradiance when given the light
%                          source's spectrum.
%
% Syntax:  [Ee, E] = TSL230_fO_to_irradiance(lambda, X, fO, sensitivity, sensor_type, dist_type)
%
% Inputs:
%    lambda - the spectrum's wavelength scale.
%         X - the light sources spectrum. [W/(m^2)/nm] or [photon/(s*m^2)/nm]
%        fO - the output of the TSL230*, TSL230*R or TSL230*RD. (small eff, big OH)
%    sensitivity - the sensitivity setting of the sensor
%    sensor_type - TSL230, TSL230R, or TSL230RD. default: TSL230R
%    dist_type - power or quantal. if dist_type is power, then X must have units
%                of [W/(m^2)/nm] and Ee will have the same units. if dist_type
%                is quantal, then X must have units of [photon/(s*m^2)/nm] and
%                Ee likewise. default: power
%
% Outputs:
%    Ee - the light source's spectral irradiance (power or quantal).
%     E - the light source's irradiance (power or quantal).
%
% Example:
%    load('TSL230R_actinic.mat')
%    fO = mean(fO_light) - mean(fO_dark);
%    mu = 415;
%    FWHM = 30;
%    Xactinic = 75*exp(-2.7726*((so.lambda-mu)/FWHM).^2); % model spectrogram
%    Ee_meter = fO_to_irradiance(so.lambda, Xactinic, fO, sensitivity, 'TSL230R', 'power');
%
%    load('TSL230R_actinic.mat')
%    fO = mean(fO_light) - mean(fO_dark);
%    load('actinic_spectrograph.mat'); % loads spctgrph
%    Xactinic = image2spectrum(spctgrph); % spectrogram created from a picture
%    Ee_meter = fO_to_irradiance(so.lambda, Xactinic, fO, sensitivity, 'TSL230R', 'power');
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: NONE
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

%NOTES:
% To determine a light source's irradiance and spectral irradiance this
% m-file uses the shape of the light source's spectrum, the frequency
% output from a sensor in the TSL230* family, TSL230*R family, TSL230*RD
% family (i.e. TSL230RD, TSL230ARD, or TSL230BRD), and the sensor's
% spectral responsivity.
%
% The following technical explanation describes how the TSL230R works. The
% TSL230RD behaves the same way except Re(640 nm) = 79 [kHz/(W/m^2)],
% instead of 77, when sensitivity is 100x and frequency scaler is 1x
% (i.e. 0.79 [kHz/(uW/cm^2)] as given in the datasheet). The TSL230 also
% behaves in a similar manner but has a different responsivity curve.
%
% Assuming the lamp's spotlight fills an area greater than the photodiode's
% aperture then the radiant spectral power (or power spectral density) entering
% the photodiode is the light's spectral irradiance [W/(m^2)/nm] multiplied
% by the area of the aperture [m^2].
% [m^2]*[W/(m^2)/nm] = [W/nm]
%
% Once a photon has entered the photodiode it has a wavelength dependent
% probability of creating a electron/hole pair that produces a differential
% current. This conversion from spectral radiant power to current is
% represented by the photodiode's spectral responsivity [A/W]. All of the
% differential currents naturally integrate to form the photodiode's total
% photocurrent because they enter the same conductor.
% integral{[A/W]*[W/nm]*[nm]} = [A]
%
% Finally the current-to-frequency converter transforms the current to the
% output frequency and scales it by the programmed frequency scaler.
% [kHz/A]*[A] = [kHz]
%
% The total transformation from spectral irradiance to frequency is represented
% by: [kHz] = [kHz/A]*integral{[A/W]*[m^2]*[W/(m^2)/nm]*[nm]}
%
% The datasheet only gives the normalized spectral responsivity (as a plot) and
% the system's responsivity at 640 nm, Re(640 nm) = 77 [kHz/(W/m^2)]
% (when sensitivity is 100x and frequency scaler is 1x). The mat file
% TSL230R_Re_s1.mat is the spectral responsivity of the TSL230R for a
% sensitivity of 1. It was created by converting the datasheet's graph of the
% normalized spectral responsivity into a point-series and multiplying it by
% the system's responsivity at 640 nm with a frequency scaler of 1 and a
% sensitivity of 1, which is 0.77 [kHz/(W/(m^2))].
%
% If the spectral irradiance incident on the TSL230R's photodiode is represented
% by Ee(lambda) then fO = integral{Re(lambda)*Ee(lambda) dlambda} from 0 to inf.
% However, Ee(lambda) is unknown so we must use X(lambda) which has the same
% shape as Ee(lambda) but is off by an unknown multiplicative constant k
% because it is an uncalibrated spectrum (i.e. Ee(lambda) = k*X(lambda)).
% We can then use our mathematical model of the TSL230R to find the frequency
% output that would result if a light source with a spectrum X(lambda) was
% incident on the sensor: fX = integral{Re(lambda)*X(lambda) dlambda}
%
% Since fO is known, fX can be calculated, and the TSL230R is a linear system,
% then k can be found simply: k = fO/fX
% Therefore we have obtained the desired result Ee = k*X.
% The accuracy of your result depends on the accuracy of the TSL230R as well
% as how well your model X(lambda) matches the shape of Ee(lambda).
%
%
% Extra Info
% The detector area changes when the sensitivity is changed. The frequency
% scale of fO vs. Ee changes when the frequency scaling is changed.
%
% Full scale frequency equals (1.1 MHz)/fscale
%
% lambda must be in nm and between 250 nm and 1200 nm inclusive.
%

function [Ee, E] = TSL230_fO_to_irradiance(lambda, X, fO, sensitivity, sensor_type, dist_type)

	s = filesep;

	if (~exist('sensor_type','var') || isempty(sensor_type))
		sensor_type = 'TSL230R';
	end

	if (~exist('dist_type','var') || isempty(dist_type))
		sensor_type = 'power';
	end

	if ~strcmpi(sensor_type, 'TSL230') && ~strcmpi(sensor_type, 'TSL230R') && ~strcmpi(sensor_type, 'TSL230RD')
		error('TSL230_fO_to_irradiance: unsupported sensor type.');
	end

	% load lambda [nm] and
	% system responsivity at 1x sensitivity, Re_s1
	if strcmpi(sensor_type, 'TSL230')
		load(['data' s 'essential_data_sets' s 'TSL230_Re_s1.mat'])
	else
		% Re(640 nm) = sensitivity*0.77 [kHz/(W/m^2)]
		load(['data' s 'essential_data_sets' s 'TSL230R_Re_s1.mat'])
		if strcmpi(sensor_type, 'TSL230RD')
			% Re(640 nm) = sensitivity*0.79 [kHz/(W/m^2)]
			Re_s1 = (0.79/0.77)*Re_s1;
		end
	end

	if strcmpi(dist_type, 'quantal')
		h = 6.62606896*10^-34; % Planck constant, [J*s]
		c = 299792458; % speed of light, [m/s]
		Wp = h*c./(lambda_Re*10^-9); % [J/photon]
		Re_s1 = Wp.*Re_s1;
	end

	Re = sensitivity*Re_s1;

	% interpolate so we can use lambda [nm] instead of lambda_Re
	Rei = interp1(lambda_Re, Re, lambda, 'spline', 0);

	% fX is the frequency that would be output if the model lamp shined
	% light with a spectral irradiance X on the photodiode.
	dl = mean(diff(lambda)); % [nm]
	fX = trapz(Rei.*X).*dl; % [kHz]

	k = fO./fX; % scaling factor, [dimensionless]

	Ee = k.*X; % spectral irradiance of lamp, [W/(m^2)/nm] or [photon/(s*m^2)/nm]
	E = trapz(Ee).*dl; % irradiance of lamp, [W/(m^2)] or [photon/(s*m^2)]

end

