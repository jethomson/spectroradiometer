%GENERATE_WBB_SPECTRUM - Generates a mathematical approximation of the spectrum
%                        produced by a tungsten filament incandescent light
%                        bulb.
%
% The filament's temperature can be plugged into Planck's law and corrected for
% tungsten's emissivity to get a mathematical approximation of the light bulb's
% spectrum. Wbb stands for tungsten black body.
%
% The output is spectral photon radiance because a CCD measures intensity by
% counting photons.
%
% Emissivity data is available for temperatures 1600 to 2800 K and wavelengths
% 250 to 3500 nm. Emissivity outside of temperature range is extrapolated,
% which may result in error. If lambda is outside of the wavelength range an
% error is returned.
%
% Even when two bulbs appear identical the emissivity of their filaments
% can differ significantly, so don't rely on this function to return
% an entirely accurate model of your light bulb's spectrum.
%
% Syntax:  [N, lambda] = generate_Wbb_spectrum(lambda, Tf, dist_type)
%
% Inputs:
%    lambda - wavelength scale in nanometers [nm], set lambda = [] if you want
%             to use the default lambda.
%        Tf - the temperature of the filament in Kelvin [K].
% dist_type - the type of spectrum to return. 'power' is [W/(sr*m^2)/nm],
%             'quantal' is [photons/(s*sr*m^2)/nm]
%
% Outputs:
%       N - the tungsten filament's emissivity corrected black body spectrum.
%  lambda - the default lambda if the input argument lambda is empty.
%
% Example:
%    % Tf = 2786.8 K is the result of averaging several sources stating the
%    % filament temperature of a 100 W, 120 V incandescent lamp.
%    N = generate_Wbb_spectrum(lambda, 2786.8, 'power');
%
%    % If you'd like to use the full range of wavelengths covered by the
%    % spectral emissivity data, set lambda to empty.
%    [N, lambda] = generate_Wbb_spectrum([], 2786.8, 'quantal');
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: WAVELENGTH_CALIBRATE
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function [N, lambda] = generate_Wbb_spectrum(lambda, Tf, dist_type)

	if (nargin ~= 3)
		usage('generate_Wbb_spectrum(lambda, Tf, dist_type)');
	end

	if (isempty(Tf) || isempty(dist_type))
		error(['generate_Wbb_spectrum: empty value for argument ' ...
		       'dist_type not allowed.']);
	end

	s = filesep;

	% load lambda_ems [nm], T [K], and spectral_emissivity.
	% the spectral emissivity of tungsten is temperature and wavelength
	% dependent.
	load(['data' s 'essential_data_sets' s 'spectral_emissivity.mat']);
	spectral_emissivity_Tf = interp1(T, spectral_emissivity, Tf, ...
                                         'spline', 'extrap');

	M = blackbody_spectrum(lambda_ems, Tf, dist_type);

	% tungsten is not a perfect black-body radiator so M must be corrected
	% with tungsten's spectral emissivity at temperature Tf.
	Me = spectral_emissivity_Tf.*M;

	if ~isempty(lambda)
		if (lambda(1) < lambda_ems(1) || lambda(end) > lambda_ems(end))
			warning('generate_Wbb_spectrum: lambda is out of range.');
		end
		% interpolate so we can use lambda [nm] instead of lambda_ems
		N = interp1(lambda_ems, Me, lambda, 'spline', 0);
	else
		lambda = lambda_ems.';
		N = Me.';
	end
end
