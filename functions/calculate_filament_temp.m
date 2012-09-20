%CALCULATE_FILAMENT_TEMP - Calculates the temperature of a powered incandescent
%                          bulb's filament when given the bulb's initial (off)
%                          temperature, initial resistance, and final (on)
%                          resistance.
%
% If the light bulb is in thermal equilibrium with its surroundings, then
% the filament's initial temperature can be easily obtained by measuring the
% temperature of the room. The final resistance is calculated by dividing the
% hot filament's voltage by the current passing through it.
%
% Syntax:  Tf = calculate_filament_temp(Ti, Ri, Rf)
%
% Inputs:
%       Ti - initial temperature of the filament in Celsius [C].
%       Ri - initial resistance of the filament when the light bulb is off.
%       Rf - final resistance of the filament when the light bulb is on.
%
% Outputs:
%       Tf - the temperature of the filament in Kelvin [K].
%
% Example:
%    % These are about the values you should expect to input for a 100W bulb
%    % with a 120V supply and the bulb's initial temperature at room temperature
%    % (298 K, 25 °C, 77 °F). The resulting filament temperature Tf is 2800 K.
%    Tf = calculate_filament_temp(25, 9.5425, 144);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: GENERATE_WBB_SPECTRUM
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function Tf = calculate_filament_temp(Ti, Ri, Rf)

	if (nargin ~= 3)
		usage('calculate_filament_temp(Ti, Ri, Rf)');
	end

	s = filesep;

	Ti = Ti + 273.15; % convert from Celsius to Kelvin, [K]
	Ri = mean(Ri);
	Rf = mean(Rf);

	% load T and rho
	% the resistivity (rho) of tungsten is temperature dependent
	load(['data' s 'essential_data_sets' s 'rho_vs_T.mat']);
	rhoi = interp1(T, rho, Ti, 'spline');
	rhof = rhoi*(Rf/Ri);
	Tf = interp1(rho, T, rhof, 'spline'); %[K]

end
