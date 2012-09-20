%ACCESS_SPECTROMETER_OBJECT - Controls access to the variables that define the
%                             spectrometer workspace.
%
% The spectrometer object, a structure named 'so', holds the variables camera,
% ftype, exposure, sdate, bd, dir_light, lambda, dlambda, L, Ftri, Hu, and Hr.
% Access to the spectrometer object is not restricted in any way. This accessor
% function was used instead of a global variables because it is more likely to
% prevent the spectrometer object from being accidentally overwritten.
%
% Syntax:  so_out = access_spectrometer_object(so_in)
%
% Inputs:
%     so_in - the spectrometer object as an input.
%
% Outputs:
%    so_out - the stored spectrometer object.
%
% Example:
%    %To set the spectrometer object:
%    access_spectrometer_object(so_in);
%
%    %To get the Bayer filter pattern:
%    so_out = access_spectrometer_out();
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

function so_out = access_spectrometer_object(so_in)

	if (nargin > 1)
		usage('access_spectrometer_object(so_in)');
	end

	persistent so;

	if (exist('so_in', 'var') && ~isempty(so_in))
		so = so_in;
	end

	if (nargout == 1)
		so_out = so;
	end

end
