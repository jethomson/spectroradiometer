% Simple script to plot the RGB histogram of a flat to examine the color balance
% and the effects of normalizing each channel. Use saturation_test to make sure
% your flats aren't saturated. Good flats will peak between 1/3 and 2/3 of the
% range defined by the saturation point minus the black point.

s = filesep;

ftype = 'PGM';
if strcmpi(ftype, 'JPG')
	bn = 0:255;
elseif strcmpi(ftype, 'PGM')
	BFP = 'gbrg';
	bn = 0:1023;
end

% hot pixels must be removed by dark frame subtraction for normalization
% (dividing by the max of each channel) to work correctly
dl = list_dir(['data/A590/tests/flat_cast/dark'], ftype, 3);
dark = ensemble_average(dl{1});
dl = list_dir('data/A590/tests/flat_cast/magenta', ftype, 3);
F = ensemble_average(dl{1}) - dark;

if strcmpi(ftype, 'PGM')
	F = bayer_demosaic(F, BFP);
end

% shift each channel's average gray level so that they are all the same,
% by using the green channel's gray level, mn(2), as a reference.
mn = reshape(image_mean(F), [1 1 3]);
mn_shift = repmat(mn(2)-mn, [size(F,1), size(F,2), 1]);
Fgray = F + mn_shift;

mx = max(Fgray(:));
Fnormal = Fgray./mx;

format short g
mF = image_mean(F)
mFnormal = image_mean(Fnormal)
format


%%%
Fr = F(:,:,1);
Fg = F(:,:,2);
Fb = F(:,:,3);
clear F;

a = [300 700 0 215000];
%a = [0 bn(end) 0 215000];
figure
subplot(311)
[n1r, xx1] = hist(Fr(:), bn);
bar(xx1, n1r)
axis(a)
grid on
title('Red')

subplot(312)
[n1g, xx] = hist(Fg(:), bn);
bar(xx, n1g)
axis(a)
grid on
title('Green')

subplot(313)
[n1b, xx] = hist(Fb(:), bn);
bar(xx, n1b)
axis(a)
grid on
title('Blue')

clear Fr Fg Fb;

%%%
Fgr = Fgray(:,:,1);
Fgg = Fgray(:,:,2);
Fgb = Fgray(:,:,3);
clear Fgray;

a = [300 700 0 215000];
%a = [0 bn(end) 0 215000];
figure
subplot(311)
[n2r, xx] = hist(Fgr(:), bn);
bar(xx, n2r)
axis(a)
grid on
title('Red')

subplot(312)
[n2g, xx] = hist(Fgg(:), bn);
bar(xx, n2g)
axis(a)
grid on
title('Green')

subplot(313)
[n2b, xx] = hist(Fgb(:), bn);
bar(xx, n2b)
axis(a)
grid on
title('Blue')

clear Fgr Fgg Fgb;

%%%
if (false)
	% The histograms for Fnormal should be the same shape as Fgray; however since
	% the bin width is so small quantization error results in the histograms
	% having spikes and dips (comb effect). Averaging several flats together will
	% reduce this effect.
	Fnr = Fnormal(:,:,1);
	Fng = Fnormal(:,:,2);
	Fnb = Fnormal(:,:,3);

	a = [0 1 0 125000 0 1];
	figure
	subplot(311)
	[n2r, xx] = hist(Fnr(:), bn/bn(end));
	bar(xx, n2r)
	axis(a)
	grid on
	title('Red')

	subplot(312)
	[n2g, xx] = hist(Fng(:), bn/bn(end));
	bar(xx, n2g)
	axis(a)
	grid on
	title('Green')

	subplot(313)
	[n2b, xx] = hist(Fnb(:), bn/bn(end));
	bar(xx, n2b)
	axis(a)
	grid on
	title('Blue')
end
