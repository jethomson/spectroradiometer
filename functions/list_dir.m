%LIST_DIR - Lists the contents of a directory with the path to each item in the
%           list prepended to it. Will also list all subdirectories that match
%           if a search word is provided.
%
% Syntax: ld = list_dir(parentdir, searchname, listtype)
%
% Inputs:
%    parentdir  - path to the directory to be searched
%    searchname - search expression containing wildcard characters for finding
%                 files, or the exact name of the subdirectories to be found.
%    listtype   - If listtype is 1 then list all files (but not directories)
%                 under parentdir that match searchname. If listtype is 2 then
%                 list all child directories of parentdir (searchname is
%                 ignored). If listtype is 3 then recurse through all
%                 subdirectories of parentdir finding each directory whose name
%                 exactly matches searchname (wildcards are not allowed).
%
% Outputs:
%    ld - a list of files or directories
%
% Example:
%    % find all JPEGs in mydir
%    fl = list_dir('path/to/mydir', '*.JPG', 1);
%    % list all the child directories of mydir
%    dl = list_dir('path/to/mydir', '', 2);
%    % list all directories any number of levels below mydir named PGM
%    dl = list_dir('path/to/mydir', 'PGM', 3);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: none
%
% Author: Jonathan Thomson
% Work:
% E-mail:
% Website: http://jethomson.wordpress.com
%

function ld = list_dir(parentdir, searchname, listtype)

	if (nargin ~= 3)
		usage('list_dir(parentdir, searchname, listtype)');
	end

	s = filesep;
	ld = {};

	[dirname, pdirpath] = pop_dirname(parentdir);
	if isempty(pdirpath)
		parentdir = dirname;
	else
		parentdir = [pdirpath s dirname];
	end


	if (listtype == 1)

		D = dir([parentdir s searchname]);
		if ~isempty(D)
			filelist = {D([D.isdir]==0).name};

			for li = 1:length(filelist)
				ld{li} = [parentdir s filelist{li}];
			end
		end

	elseif (listtype == 2)

		if ~isempty(searchname)
			disp(['list_dir: warning: searchname is ignored for listtype ' ...
			      num2str(listtype) '.']);
		end

		D = dir(parentdir);
		if ~isempty(D)
			dirlist = {D([D.isdir]==1).name};

			for li = 3:length(dirlist) % start at 3 to skip . and ..
				idx = length(ld)+1;
				ld{idx} = [parentdir s dirlist{li}];
			end
		end

	elseif (listtype == 3)

		parentdir;
		D = dir(parentdir);
		D([D.isdir]==1).name;

		if ~isempty(D)
			dirlist = {D([D.isdir]==1).name};
			for li = 3:length(dirlist); % start at 3 to skip . and ..
				d = dirlist{li};
				npd = [parentdir s d];
				if strcmp(d, searchname)
					idx = length(ld)+1;
					ld{idx} = npd;
				else
					ld = [ld; list_dir(npd, searchname, listtype)];
				end
			end
		end
	end

end
