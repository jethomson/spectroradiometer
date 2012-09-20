% This script will calculate an image's RGB histogram, display the bin number
% and counts of the three rightmost non-empty bins of each channel, and display
% the bin number of the end of the right-hand side tail. It will also plot the
% log of each histogram and a portion of each histogram zoomed to the rightmost
% non-empty bin. This information will help you determine if your image is
% saturated, which channels are saturated, how close an image is to being
% saturated, and whether an image is saturated or just has hot pixels.
%
% Before using this script you should take a saturated image. To do this, take
% a photograph with a long exposure time of a brightly illuminated sheet of
% paper so that the photo is overexposed. This will help you learn the
% saturation point of each channel of your camera. The saturation point will be
% the peak on the right hand side of the histogram after which all points are
% zero. If the last non-empty bin is the last bin or the last non-empty bin has
% a count that is much greater than those of the bins that directly precede it
% then the channel is saturated. The tail of the histogram and the saturation
% point will be the same or very close together if a channel is actually
% saturated. Note that some hot pixels are to be expected at the saturation
% point, and that the code for finding the right-hand tail is not perfect. So
% before ruling out a particular exposure as saturated you should examine a
% plot of it's histogram, especially the right-hand side tail. The different
% colored channels may have different saturation points. Different light sources
% have different proportions of red, green, and blue light. For example, an
% incandescent has more red than green, and more green than blue, but a
% fluorescent light will have more blue. So make sure you are actually
% saturating a channel, before you make note of it's saturation point.
%
% The black point of your camera is the leftmost non-empty bin. This may be
% zero but probably is not.
%
% Once you've determined what level your channels saturate at you can determine
% the proper exposure for you spectrographs so that your CCD will operate in
% its linear region. Use this script to check that your spectrographs are
% not saturated.
%
% --------------------
%
% ===Example===
%
% channel -- bin: count; bin: count; bin: count
% red   -- 1023: 1014; 1022: 103; 1021: 289
% green -- 1023: 1; 897: 1; 701: 2
% blue  -- 938: 1; 528: 1; 527: 2
% red tail: 1023; green tail: 701; blue tail: 528
%
% Here we can see that the red channel is saturated because the rightmost
% non-empty bin (1023) is same as the red tail. Plus the next non-empty bins
% (1022 and 1021) are contiguous to the first, and the right-most (1023) has a
% count greater than the bins that precede it. You may think that the green
% channel is saturated because bin 1023 is non-empty, but judging by the green
% tail and the other two non-empty bins listed it should be concluded that the
% count in bin 1023 is because of a hot pixel. The blue channel is not saturated
% either, but has a hot pixel at bin 938.
%

close all
clear all
clc

s = filesep;

filenum = 2; %<-- change this to look at different files in file list
ftype = 'PGM';
%ftype = 'JPG';
makeplots = true;

fl = list_dir(['data' s 'A590' s 'tests' s 'saturation' s 'spectral' s ftype], ['*.' ftype], 1);

if strcmpi(ftype, 'JPG')
	final_bin = 255;
	A = double(imread(fl{filenum}));
elseif strcmpi(ftype, 'PGM')
	pattern = 'gbrg';
	final_bin = 1023;
	A = bayer_demosaic(fl{filenum}, pattern, false);
end

[h, w, nd] = size(A);
A = reshape(A, [h*w nd]);
Ar = A(:, 1);
Ag = A(:, 2);
Ab = A(:, 3);

bn = 0:final_bin;
nr = hist(Ar, bn);
ng = hist(Ag, bn);
nb = hist(Ab, bn);
nr(1) = 0;
ng(1) = 0;
nb(1) = 0;


% last three non-empty bins in descending order
tmp = fliplr(bn(nr>0));
nebr = tmp(1:3);
tmp = fliplr(bn(ng>0));
nebg = tmp(1:3);
tmp = fliplr(bn(nb>0));
nebb = tmp(1:3);

% find the number of counts in the last three non-empty bins.
cr = nr(nebr+1); % add 1 because bn starts w/ 0, but Matlab arrays start w/ 1
cg = ng(nebg+1);
cb = nb(nebb+1);

% display the last three non-empty bins and their counts.
pr = [nebr; cr];
pg = [nebg; cg];
pb = [nebb; cb];
fprintf('channel -- bin: count; bin: count; bin: count\n')
fprintf('red   -- %d: %d; %d: %d; %d: %d\n', pr(:));
fprintf('green -- %d: %d; %d: %d; %d: %d\n', pg(:));
fprintf('blue  -- %d: %d; %d: %d; %d: %d\n', pb(:));


% smooth histogram to remove gaps and convert to a binary
% (empty,0 / non-empty,1) histogram.
filt_len = 5;
NR = conv(ones(1,filt_len)/filt_len, nr) > 0;
NG = conv(ones(1,filt_len)/filt_len, ng) > 0;
NB = conv(ones(1,filt_len)/filt_len, nb) > 0;

% find first transition from 1 to 0 in binary histogram. this transition marks
% the right tail of the histogram, where the counts go from greater than 0 to 0.
% if a channel is saturated it's binary histogram will end with a 1, so append
% a 0 to the end of it so that the transition point can be detected.
[ign, tr] = min(diff([NR 0]));
[ign, tg] = min(diff([NG 0]));
[ign, tb] = min(diff([NB 0]));

% filtering created filt_len-1 non-empty bins after the end of the tail so move
% index back by that amount. then subtract 1 to convert index to bin number.
tailr = tr - (filt_len-1) - 1;
tailg = tg - (filt_len-1) - 1;
tailb = tb - (filt_len-1) - 1;


fprintf('red tail: %d; green tail: %d; blue tail: %d\n', tailr, tailg, tailb);

if (makeplots == true)
	figure
	subplot(211)
	bar(bn, log(nr))
	title('Full Red Histogram (Logarithmic)')
	subplot(212)
	hold on
	bar(bn, nr)
	plot(tailr, nr(tailr+1), '*r')
	plot(nebr(1), cr(1), '*r')
	a = axis;
	axis([a(1) a(2) a(3) cr(1)+10])
	title('Zoomed to Show Last Bin (Linear)')

	figure
	subplot(211)
	bar(bn, log(ng))
	title('Full Green Histogram (Logarithmic)')
	subplot(212)
	hold on
	bar(bn, ng)
	plot(tailg, ng(tailg+1), '*g')
	plot(nebg(1), cg(1), '*g')
	a = axis;
	axis([a(1) a(2) a(3) cg(1)+10])
	title('Zoomed to Show Last Bin (Linear)')

	figure
	subplot(211)
	bar(bn, log(nb))
	title('Full Blue Histogram (Logarithmic)')
	subplot(212)
	hold on
	bar(bn, nb)
	plot(tailb, nb(tailb+1), '*b')
	plot(nebb(1), cb(1), '*b')
	a = axis;
	axis([a(1) a(2) a(3) cb(1)+10])
	title('Zoomed to Show Last Bin (Linear)')
end
