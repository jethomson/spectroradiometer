%FLAT_CORRECT - Corrects for variation in pixel sensitivity and vignetting.
%
% A flat frame is a record of the variation in sensitivity from pixel to pixel
% and the drop off of intensity at the image's border caused by the lens.
%
% Syntax:  I = flat_correct(light, flat)
%
% Inputs:
%    light - a spectrograph.
%    flat  - the master flat frame.
%
% Outputs:
%    I - a spectrograph that has been corrected for unevenness across it's
%        entire field.
%
% Example:
%    none
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

function I = flat_correct(light, flat)

	if (nargin ~= 2)
		usage('flat_correct(light, flat)');
	end

	I = light./flat;
	% the flat will have zeros because of dark subtraction
	I(isnan(I)) = 0; % handles 0/0
	I(isinf(I)) = 0; % handles +/- n/0

end
