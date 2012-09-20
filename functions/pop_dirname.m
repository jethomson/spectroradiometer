%POP_DIRNAME - Returns the name of the last directory in dirpath as well as
%              it's parent directory's path.
%
% Syntax:  [dirname, pdirpath] = pop_dirname(dirpath)
%
% Inputs:
%    dirpath  - a path to a directory
%
% Outputs:
%    dirname  - the name of the directory that dir path points to.
%    pdirpath - the path to the parent directory of dirname.
%
%
% Example 1:
%    [dirname, pdirpath] = pop_dirname('path/to/parent/mydirname')
%    -->  dirname = 'mydirname'
%    -->  pdirpath = 'path/to/parent'
%
% Example 2:
% % It's very common for directory paths to be written both with and without
% % a trailing slash. pop_dirname will return the same result whether or not
% % there is a trailing slash. Therefore pop_dirname can be used to make sure
% % a path to a directory is properly formatted.
%    mypath = 'path/to/parent/mydirname'  % correct
%    mypath = 'path/to/parent/mydirname/' % not quite right
%    % OR
%    mypath = 'path/to/parent/mydirname////' % wrong
%    [dirname, pdirpath] = pop_dirname(mypath)
%    s = filesep;
%    goodpath = [pdirpath s dirname]; %no trailing slash
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: none
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function [dirname, pdirpath] = pop_dirname(dirpath)

	if (nargin ~= 1 || isempty(dirpath))
		usage('pop_dirname(dirpath)');
	end

	s = filesep;
	dirname = [];
	% looping gets rid of possibly extraneous file separators at the end of
	% dirpath
	while (isempty(dirname))
		[d, dirname] = fileparts(dirpath);
		dirpath = d;
	end
	pdirpath = dirpath;
end
