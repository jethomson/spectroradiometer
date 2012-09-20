%
% This script demonstrates using so.Hu, the spectrometer's uncalibrated system
% function, to remove the system function from a spectrogram.
%
% call spectrometer_setup and system_function_uncalibrated before running this
% script
%

s = filesep;
so = access_spectrometer_object();

sd = [so.dir_light s 'spectrographs' s '60W_Sylvania_8'];
load([sd s so.ftype '_60W_Sylvania_8_e0.mat']);
Tf = 2681.8; % 60W: own calc. 2681.8 K, internet avg. 2707.73 K

Z = image2spectrum(spctgrph);
Z = filtfilt(so.Ftri, 1, Z); % distorted spectrum, [count]
Zc = Z./so.Hu; % uncalibrated, corrected spectrum, [photon/(s*m^2)/nm]
Zc_gray = merge_RGB_spectrums(Zc);

figure
subplot(211)
plot(so.lambda, fliplr(Z))
a = axis;
axis([so.lambda(1) so.lambda(end) a(3) a(4)])
title('distorted spectrum')
subplot(212)
hold on
plot(so.lambda, fliplr(Zc))
plot(so.lambda, Zc_gray, 'k')
a = axis;
axis([so.lambda(1) so.lambda(end) a(3) a(4)])
ylabel('uncalibrated spectral photon irradiance [photon/(s*m^2)/nm]')
xlabel('wavelength [nm]')
title('uncalibrated, corrected spectrum')
