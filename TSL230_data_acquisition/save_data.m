% Normally this script will be called from get_data, but if the data has
% bad samples you should tell get_data not to save, remove the bad
% samples then call this script to save.

s = filesep;

save('-V6', ['TSL230_data_acquisition' s 'saved_data' s fname], ...
             'sensor_type', 'sensitivity', 'fscale', 'distance', ...
             'fO_light', 'fO_dark')
%save('-V6', ['data' s 'TSL230_meter_output' s fname], 'sensor_type', ...
%             'sensitivity', 'fscale', 'distance', 'fO_light', 'fO_dark')
