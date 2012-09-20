%PROCESS_METADATA_FILE - Loads the metadata text file associated with an
%                        unprocessed spectrograph and converts it to a struct
%                        named metadata.
%
% A metadata file is additional data about an unprocessed spectrograph. The
% metadata file contains information such as the distance the light source
% was from the spectrometer's slit, the output from the TSL230 (fO), etc.
%
% Syntax:  metadata = process_metadata_file(directory)
%
% Inputs:
%    directory - the spectrograph directory.
%
% Outputs:
%     metdata - the struct containing information in the metadata file.
%
% Example:
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

function metadata = process_metadata_file(directory)

	metadata = [];

	dl = list_dir(directory, '*metadata.txt', 1);

	if isempty(dl)
		% metadata file not found.
		return
	end

	fname = dl{1};
	fid = fopen(fname, 'r');
	if (fid == -1)
		error(['process_metadata: cannot open ' fname '.'])
	else
		md_line = fgetl(fid);
		while (check_line(md_line, fname) == true)
			[field, count] = sscanf(md_line, '%s', 1);
			ni = length(field)+1;
			field = field(1:end-1); % strip off colon
			[value, count] = sscanf(md_line(ni:end), '%s%c', inf);
			metadata.(field) = value;

			md_line = fgetl(fid);
		end
	end
end

function line_is_valid = check_line(md_line, fname)

	line_is_valid = true;

	if (md_line == -1) % EOF
		line_is_valid = false;
		return
	end

	if isempty(md_line) || ~ischar(md_line)
		error(['process_metadata: ' fname ' has bad formatting.'])
	end

	[field, count] = sscanf(md_line, '%s', 1);
	if ~strcmpi(field(end), ':')
		error(['process_metadata: ' fname ' has bad formatting.'])
	end

end
