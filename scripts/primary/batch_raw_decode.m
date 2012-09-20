% This script uses dcraw to convert your camera's raw file format into Portable
% GrayMaps (PGM) or Tagged Image File Format (TIFF) . The variable in_ftype
% specifies the raw file format to be processed as well as the name of the
% directories that contains this type of file.

s = filesep;

% ==== modify these variables =====
%dir_data = 'data\A590\frames\tone_frames_paper';
%dir_data = ['data' s 'A590' s 'frames' s 'bias_frames'];
%dir_data = ['data' s 'A590' s 'frames' s 'dark_frames'];
%dir_data = ['data' s 'A590' s 'frames' s 'dark_frames' s 'light_darks' s '2s'];
%dir_data = ['data' s 'A590' s 'frames' s 'flat_frames'];
dir_data = ['data' s 'A590' s 'frames' s 'light_frames' s '2s' s '2012_08_30'];
%dir_data = ['data' s 'A590' s 'frames' s 'light_frames' s '2s' s '2012_09_13'];

in_ftype = 'DNG';
%in_ftype = 'CRW';

out_ftype = 'PGM';
%out_ftype = 'TIFF';
% ==== end, modify these variables =====

if strcmp(s, '/') % in Linux
	dcraw = ['/usr/bin/dcraw'];
elseif strcmp(s, '\') % in Windows
	dcraw = ['bin' s 'dcraw'];
end

decode_args = '-c -D -4 -t 0 -j';
finfo_args = '-v -i';

if strcmpi(out_ftype, 'TIFF')
	decode_args = [decode_args ' -T'];
end

decode_cmd = [dcraw ' ' decode_args ' '];
finfo_cmd = [dcraw ' ' finfo_args ' '];

flne = {}; %initialize to empty for ~isempty(flne) test.

g = waitbar(0, ['Decoding raw spectrographs. ' ...
                'This may take several minutes.']);
waitbar(0.001, g); % Octave's buggy waitbar doesn't like 0 or 1
dl = list_dir(dir_data, in_ftype, 3);
Ns = length(dl);

for jj=1:Ns
	idir = dl{jj};
	[ign, pd] = pop_dirname(idir);
	odir = [pd s out_ftype];

	if (exist(odir) == 0)
		[status, msg, msgid] = mkdir(odir);
		if (status == 0)
			error(['batch_raw_decode: error creating ' odir ' . ' msg]);
		end
	elseif (exist(odir) ~= 7)
		error(['batch_raw_decode: ' odir ...
		        ' already exists, but is not a directory!']);
	end

	fl = list_dir(idir, ['*.' in_ftype], 1);
	for kk=1:length(fl)
		[ign, fname, ext] = fileparts(fl{kk});
		system([decode_cmd fl{kk} ' > ' odir s fname '.' out_ftype]);
		flne = fl;
	end
	waitbar((jj/Ns)-0.001, g);
end

disp('')

if ~isempty(flne)
	% Use the last file processed to get the information dcraw can output
	% about the file.
	[ign, output] = system([finfo_cmd flne{1}]);
	si = strfind(output, 'Image size:');
	sf = strfind(output, 'Output size:');
	hwstr = output(si:(sf-1));
	%[ign, ign, ign, M, ign, ign] = regexp(hwstr, '[0-9]+');
	[ign, ign, ign, M] = regexp(hwstr, '[0-9]+');
	w = str2num(M{1});
	h = str2num(M{2});

	si = strfind(output, 'Filter pattern:');
	sf = strfind(output, 'Daylight multipliers:');
	bfpstr = output(si:(sf-1));
	[ign, idx] = regexp(bfpstr, ':\s\w');
	bfp = bfpstr(idx:idx+3);
	fprintf(['These images have width: %d, height: %d, ' ...
	         'and Bayer filter pattern: %s.\n'], w, h, bfp);
end

clear all
