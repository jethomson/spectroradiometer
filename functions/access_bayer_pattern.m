%ACCESS_BAYER_PATTERN - Controls access to the Bayer filter pattern.
%
% This function stores the Bayer filter pattern in a persistent variable. Access
% to the filter pattern is not restricted in any way. This accessor function was
% used instead of a global variable because it is more likely to prevent the
% pattern from being accidentally overwritten.
%
% Syntax:  BFP = access_bayer_pattern(pattern)
%
% Inputs:
%    pattern - the Bayer filter pattern.
%
% Outputs:
%    BFP - the stored Bayer filter pattern.
%
% Example:
%    %To set the Bayer filter pattern:
%    access_bayer_pattern(pattern);
%
%    %To get the Bayer filter pattern:
%    BFP = access_bayer_pattern();
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: BAYER_DEMOSAIC
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function argout = access_bayer_pattern(pattern)

	if (nargin > 1)
		usage('access_bayer_pattern(pattern)');
	end

	persistent BFP;

	if (exist('pattern', 'var') && ~isempty(pattern))
		BFP = pattern; %Bayer Filter Pattern
	end

	if (nargout == 1)
		argout = BFP;
	end

end
