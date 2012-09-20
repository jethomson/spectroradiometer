% Builds a useful path for the spectrometer code.

% This command will change the working directory to the directory in which
% this file resides. It only works if this m-file is in the path.
wd = fileparts(mfilename('fullpath'));
cd(wd);

s = filesep;
gpf = genpath([wd s 'functions']);
gps = genpath([wd s 'scripts']);
gpda = genpath([wd s 'TSL230_data_acquisition']);

addpath(wd, gpf, gps, gpda, '-end')

clear all;
