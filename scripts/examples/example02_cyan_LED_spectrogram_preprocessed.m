%
% This script demonstrates how to use the mat files that resulted from
% processing the spectrographs with batch_preprocess.
%
% call spectrometer_setup before running this script
%

s = filesep;
so = access_spectrometer_object();

sd = [so.dir_light s 'spectrographs' s 'Cyan_LED_3'];
load([sd s so.ftype '_Cyan_LED_3_e0.mat']);
cyan = spctgrph;
Z = image2spectrum(cyan, 'rgb');

figure, hold on

plot(so.lambda, Z(:,1), 'r')
plot(so.lambda, Z(:,2), 'g')
plot(so.lambda, Z(:,3), 'b')

Zgray = merge_RGB_spectrums(Z);
plot(so.lambda, Zgray, 'k')

a = axis;
axis([so.lambda(1) so.lambda(end) a(3) a(4)])
xlabel('wavelength [nm]')
legend('red channel', 'green channel', 'blue channel', 'channels averaged')

[pk, l] = max(Z);
pw = so.lambda(l);
plot(pw, pk, 'k*')
disp('Datasheet peak wavelength: 505nm');
fprintf('Measured peak wavelength: Red=%.2fnm, Green=%.2fnm, Blue=%.2fnm\n', pw);

[pk, l] = max(Zgray);
pw = so.lambda(l);
plot(pw, pk, 'k*')
fprintf('Measured peak wavelength: Gray=%.2fnm\n', pw);
