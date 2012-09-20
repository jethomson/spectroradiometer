%BLACKBODY_SPECTRUM - Returns the spectral radiance of a black body at
%                     temperature Tf.
%
%
% Syntax:  [L, lambda] = blackbody_spectrum(lambda, Tf, dist_type)
%
% Inputs:
%    lambda - the wavelengths to evaluate the black body spectrum at. [nm]
%             default: the range of wavelengths that contains 99.89% of the
%                      power in the black body spectrum.
%        Tf - the temperature of the black body spectrum. [K]
%             default: the temperature of a typical 100W 120V
%                      incandescent bulb
% dist_type - the type of spectrum to return. 'power' is [W/(sr*m^2)/nm],
%             'quantal' is [photons/(s*sr*m^2)/nm]
%             default: power
%
%
% Outputs:
%    L      - the spectral radiance of the black body.
%    lambda - the wavelengths at which the spectrum was evaluated. This output
%             is only useful if the default lambda used to calculate the
%             spectrum is desired. [nm]
%
% Example:
%    L = blackbody_spectrum(lambda, 2800, 'quantal')
%    [L, lambda] = blackbody_spectrum()
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

function [L, lambda] = blackbody_spectrum(lambda, Tf, dist_type)

	if (nargin > 3)
		usage('blackbody_spectrum(varargin)');
	end

	if (~exist('dist_type','var') || isempty(dist_type))
		dist_type = 'power';
	end

	if (~strcmpi(dist_type, 'quantal') && ~strcmpi(dist_type, 'power'))
		error('blackbody_spectrum: bad value for argument dist_type');
	end

	if (~exist('Tf','var') || isempty(Tf))
		% filament temperature of a 100 W, 120 V incandescent, [K]
		Tf = 2786.8;
	end

	if (~exist('lambda','var') || isempty(lambda))
		% http://en.wikipedia.org/wiki/Planck%27s_law#Percentiles
		% 99.9% of the radiation is emitted at wavelengths below
		% lambda = 51613000/T
		% 0.01% of the radiation is emitted at wavelengths below
		% lambda = 910000/T

		dl_nm = 0.1;
		lambda = ((910000/Tf):dl_nm:(51613000/Tf)).'; % [nm]
	end

	l_m = lambda*10^-9; % wavelength scale in meters, [m]

	e = exp(1);
	h = 6.62606896*10^-34; % Planck constant, [J*s]
	c = 299792458; % speed of light, [m/s]
	k = 1.38106504*10^-23; % Boltzmann constant, [J/K]

	% a scaling multiplier (1[m]/(10^9[nm]) is used to express unit
	% wavelength in nanometers [nm] instead of meters
	% [m/(10^9 nm)]*[W/(sr*m^2)/m] = [W/(sr*m^2)/nm]:
	% L, spectral radiance [W/(sr*m^2)/nm]
	L = (10^-9)*(2*h*c^2./l_m.^5).*(1./(e.^(h*c./(l_m*k*Tf)) - 1));

	if strcmpi(dist_type, 'quantal')
		Wp = h.*c./l_m;    % [J/photon]
		%L = (10^-4)*L./Wp; % [photons/(s*sr*cm^2)/nm]
		L = L./Wp; % [photons/(s*sr*m^2)/nm]
	end
end
