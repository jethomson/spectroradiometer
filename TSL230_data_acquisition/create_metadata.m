%
s = filesep;
bd = 'TSL230_data_acquisition';
sd = [bd s 'saved_data'];
odir = [bd s 'metadata'];
D = dir([sd s '*.mat']);
nf = length(D);
if (nf == 0)
	error(['create_metadata: contains no mat files (*.mat)']);
else

	if (exist(odir) == 0)
		[status, msg, msgid] = mkdir(odir);
		if (status == 0)
			error(['create_metadata: error creating ' odir ' . ' msg]);
		end
	elseif (exist(odir) ~= 7)
		error(['create_metadata: ' odir ...
		        ' already exists, but is not a directory!']);
	end

	fl = {D.name};
	for li = 1:nf
		load([sd s fl{li}]);
		fO = (mean(fO_light) - mean(fO_dark))/1000; % [kHz]

		[ign, fname, ign, ign] = fileparts(fl{li});

		fid = fopen([odir s fname '_metadata.txt'], 'w');
		fprintf(fid, 'sensor_type: %s\n', sensor_type);
		fprintf(fid, 'distance: %.4f\n', distance);
		fprintf(fid, 'distance_units: meters\n');
		fprintf(fid, 'TSL230_fO: %.4f\n', fO);
		fprintf(fid, 'TSL230_fO_units: kilohertz\n');
		fprintf(fid, 'TSL230_sensitivity: %d\n', sensitivity);
		fclose(fid);
	end
end

clear all
