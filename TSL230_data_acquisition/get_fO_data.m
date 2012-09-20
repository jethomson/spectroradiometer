% This script communicates with the program TSL230_FreqCount running on an
% arduino supported atmega uc. It instructs the uc how the TSL230's sensitivity
% and frequency scaling should be set and receives the frequency count output
% from the uc.
%
% The atmega uc is controlled with simple commands over the serial line in the
% format cnnn, where 'c' means command and 'nnn' is a 3 character argument.
% s - stands for sensitivity, valid arguments are 000, 001, 010, and 100.
% f - stands for frequency scaling, valid arguments are 001, 002, 010, and 100.
% t - stands for transmit, valid arguments are 001-999. the transmit command
%       instructs the uc to enable the TSL230 and output nnn measurements taken
%       by the frequency meter.
% l - stands for light, valid arguments are 000 or 111. if the argument is
%       000/111 then the pin specified in the uc code will be brought low/high.
%       this pin can be used to drive an LED or switch a transitor or relay
%       off/on to control power to a lamp.
%
% The full scale frequency from the TSL230 equals (1.1 MHz)/fscale.
% The maximum input frequency that can be read by the FreqCount code running
% on the atmega is about 8 MHz when signal duty cycle is 50%. It's better to
% use divided outputs (i.e. fscale >= 2) because they are 50% duty cycle square
% waves which are easier to capture than the fixed pulse width output when
% fscale is 1.
%
% The variable prefix fO is "ef oh" not "ef zero". It's how the output frequency
% is denoted in the TSL230's datasheet. The output frequency is recorded when
% the lamp is on (fO_light) and off (fO_dark) so that the photodiode's thermal
% current, measured by fO_dark, can be removed.
%
% fO_light and fO_dark are not automatically saved. You should check for
% bad data before saving. If bad samples are present, remove them and run
% the script save_data.
%
% Tested in:
% -- WinXP: MATLAB 7.5.0 (R2700b), Octave 3.2.4
% -- Debian Wheezy: Octave 3.2.4
%
% MATLAB NOTES:
% fgetl doesn't return -1 when it reaches the end of the stream. Therefore, the
% uc sends a special end of transmission 'EOT' signal.
%

%**** USER SUPPLIED DATA ****%

if strcmpi(filesep, '/') % in Linux
	port = '/dev/ttyUSB0';
	% same tty magic phrase used by arduino
	stty_arg = ['10:0:8bd:0:3:1c:7f:15:4:0:0:0:11:13:1a:0:12:f:17:16:0:0:' ...
	            '0:0:0:0:0:0:0:0:0:0:0:0:0:0'];
	system(['/bin/stty --file=' port ' ' stty_arg]);
elseif strcmpi(filesep, '\') % in Windows
	port = 'COM5';
end

% use TSL230 for TSL230, TSL230A, and TSL230B
% use TSL230R for TSL230R, TSL230AR, and TSL230BR
% use TSL230RD for TSL230RD, TSL230ARD, and TSL230BRD
sensor_type = 'TSL230RD';

sensitivity = 1;
fscale = 2;
num_samples = 20; % number of frequency measurements.

%light_pos = 10; % [inches], inverse square region for incandescents
light_pos = 5; % led position
slit_pos = 2;
% distance of light source from detector, [m]
distance = (light_pos-slit_pos)*0.0254;
%lamp_type = 'CFL';
%lamp_type = '100W_GE';
%lamp_type = '60W_Syl';
%lamp_type = '60W_GE';
lamp_type = 'cyan_LED';

% this is used by the script save_data.
fname = ['s' num2str(sensitivity) 'f' num2str(fscale) '_' lamp_type '_' ...
         num2str(light_pos-slit_pos) '.mat'];

%**** END USER SUPPLIED DATA ****%

fO_light = -1;
fO_dark = -1;

if (exist('OCTAVE_VERSION'))
	serial_write = @(spr, sstr) fputs(spr, sstr);
else
	serial_write = @(spr, sstr) fprintf(spr, '%s', sstr);
end

% pause_time is the amount of time to allow the serial buffer to fill with
% samples. one sample takes about 1.2 seconds to generate. 0.1 seconds per
% sample is added to be safe.
pause_time = (1.2 + 0.1)*(num_samples+2); % seconds
%pause_time = 20; %seconds, *DEBUG*DEBUG*DEBUG*DEBUG*


sp = serial_open(port);

serial_write(sp, 'l111'); %turn on lamp (optional).

% by not having a newline the cursor stays at the end of the line.
fprintf('Please turn on lamp. Then press the Enter key to continue.')
% the pause command without an argument did not halt the script, so using
% input instead.
ign = input('', 's');
fprintf('\nThank you. Proceeding.')

scmd = sprintf('s%03d', sensitivity);
serial_write(sp, scmd); %set sensitivity
fcmd = sprintf('f%03d', fscale);
serial_write(sp, fcmd); %set frequency scaling
tcmd = sprintf('t%03d', num_samples+2); %+2 because first two are discarded.
serial_write(sp, tcmd); %tell uc to start transmitting.

pause(pause_time); %wait for data to be generated and transmitted to buffer

k = 1;
f = fgetl(sp); % the first sample is usually bad, so discard it.
f = fgetl(sp); % the second sample is usually bad, so discard it.
f = fgetl(sp);
while (ischar(f) && ~strcmp(f, 'EOT') && k <= num_samples)
	fO_light(k,:) = str2double(f);
	k = k+1;
	f = fgetl(sp);
end

serial_write(sp, 's000'); %tell TSL230 to power down
% once fgetl has returned -1 (reached EOF) the serial port must be
% closed and re-opened to get any new data.
fclose(sp);

fprintf('\nFinished gathering fO data with lamp on.\n\n');

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

%re-open serial port
sp = serial_open(port);

serial_write(sp, 'l000'); %turn off lamp (optional).

fprintf('Please turn off lamp. Then press the Enter key to continue.')
%pause
% the pause command without an argument did not halt the script, so using
% input instead.
ign = input('', 's');
fprintf('\nThank you. Proceeding.')

% sometimes re-opening serial port resets uc so the sensitivity and frequency
% scaling commands must be resent.
scmd = sprintf('s%03d', sensitivity);
serial_write(sp, scmd); %set sensitivity
fcmd = sprintf('f%03d', fscale);
serial_write(sp, fcmd); %set frequency scaling
tcmd = sprintf('t%03d', num_samples+2); %+2 because first two are discarded.
serial_write(sp, tcmd); %tell uc to start transmitting.

pause(pause_time); %wait for data to be generated and transmitted to buffer

k = 1;
f = fgetl(sp); % the first sample is usually bad, so discard it.
f = fgetl(sp); % the second sample is usually bad, so discard it.
f = fgetl(sp);
while (ischar(f) && ~strcmp(f, 'EOT') && k <= num_samples)
	fO_dark(k,:) = str2double(f);
	k = k+1;
	f = fgetl(sp);
end

serial_write(sp, 's000'); %tell TSL230 to power down
fclose(sp);

fprintf('\nFinished gathering fO data with lamp off.\n\n');

%------------------------------------------------------------------------------%
%------------------------------------------------------------------------------%

fO_light
fO_dark

disp('Check for bad data before saving.');
rsp = input('Do you want to save? [(y)es/(n)o]: ', 's');
if (~isempty(rsp) && lower(rsp(1)) == 'y')
	save_data;
end

