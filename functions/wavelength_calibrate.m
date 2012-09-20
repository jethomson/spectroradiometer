%WAVELENGTH_CALIBRATE - Takes a horizontal slice of a reference spectrograph,
%                       and through user interaction finds the pixel locations
%                       that correspond to known wavelengths which are then used
%                       to calculate and output a calibrated wavelength scale.
%
% It's not necessary to use every row of a spectrograph to derive the
% spectrogram. Although every column is always used. To specify a horizontal
% slice (region), use the optional arguments y0 and h.
%
% This function uses the mercury peaks found in a compact fluorescent lamp's
% (CFL) spectrum as a wavelength reference. It is possible to use other
% reference peaks (e.g. neon) with this function by slightly modifying it.
%
% Syntax:  lambda = wavelength_calibrate(img, roi)
%
% Inputs:
%    img - an image matrix or an image's filename.
%    roi - region of interest of spectrograph to process.
%
% Outputs:
%    lambda - a calibrated wavelength scale in nanometers.
%
% Example:
%    lambda = wavelength_calibrate('path/filename');
%    h=100; y0=(size(I,1)-h)/2; lambda = wavelength_calibrate(I, [y0, h]);
%
% Other m-files required: image2spectrum
% Subfunctions: none
% MAT-files required: none
% Other files required: CFL_Hg_peaks_labeled.png
%
% See also: IMAGE2SPECTRUM, POLYFIT
%
% Author: Jonathan Thomson
% Work:
% email:
% Website: http://jethomson.wordpress.com
%

function lambda = wavelength_calibrate(img, roi)

	if (nargin < 1 || nargin > 2)
		usage('wavelength_calibrate(img, roi)');
	end

	% Look at CFL_Hg_peaks_labeled.png to see the numbered peaks and their
	% wavelengths. These are mercury (Hg) spectrum peaks. The zeros in
	% REF_PEAK_WAVELENGTHS are for non-mercury peaks. Note that your CFL's
	% spectrogram may show a second weaker peak near 407.783 nm next to peak 1
	% at 404.656 nm. This is a mercury peak, but is not shown in the image
	% CFL_Hg_peaks_labeled.png nor is it used for calibration.

	%NIST Atomic Spectra Database
	%http://physics.nist.gov/PhysRefData/ASD/lines_form.html
	%REF_PEAK_WAVELENGTHS = [404.6565, 435.8335, 0, 0, 546.0750, 0, 579.0670];

	%NIST Handbook of Basic Atomic Spectroscopic Data
	%http://physics.nist.gov/PhysRefData/Handbook/Tables/mercurytable2.htm
	%"This handbook is designed to provide a selection of the most important
	%and frequently used atomic spectroscopic data in an easily accessible
	%format."
	REF_PEAK_WAVELENGTHS = [404.6563, 435.8328, 0, 0, 546.0735, 0, 579.0663];

	% This is a user defined constant, but peak numbers 2, 5, and 7 should
	% work fine if you are using a CFL as the reference.
	PEAKNUM = [2 5 7];

	scrsz = get(0, 'ScreenSize');

	if (~exist('roi','var') || isempty(roi))
		roi = [0, 0];
	end

	Z = image2spectrum(img, 'rgb', roi);

	refpknm = REF_PEAK_WAVELENGTHS(PEAKNUM);

	%if rng is large and peak 7 is too close to peak 6, peak 6 might be
	%incorrectly picked.
	%rng = -10:10;
	rng = -5:5;

	dataisgood = false;
	while (dataisgood == false)
		n = figure('Position', [1 1 0.9*scrsz(3) 0.9*scrsz(4)]);
		hold on
		plot(fliplr(Z))
		m = max(max(Z));
		a = axis;
		axis([a(1) a(2) 0 1.10*m])

		for li = 1:length(PEAKNUM)
			title(['Click on peak ' num2str(PEAKNUM(li)) '.']);
			[x, ignored] = ginput(1); % 2nd output of ginput() is mandatory
			x = round(x);

			% The user cannot be expected to click exactly at the peak
			% location so we should search on either side of gpxl
			% (within a hardcoded range) to find the exact peak location.
			dx = x + rng;

			[peak_rgb, pkloc] = max(Z(dx,:));
			[peak, chan] = max(peak_rgb); % which channel has the highest peak

			% x-coordinate/column number of the peak
			pkx(li) = dx(1) + pkloc(chan) - 1;

			hold on, plot(pkx(li), peak, 'k*')
		end

		title(['The reference peaks'' locations have been recorded. ' ...
		       'Please answer the question in the console.'])
		rsp = input(['Did you pick the correct peaks? ' ...
		             'If not, answer no to try again. [(y)es/(n)o/(q)uit]: '], 's');
		if (~isempty(rsp) && lower(rsp(1)) == 'y')
			dataisgood = true;
		elseif (~isempty(rsp) && lower(rsp(1)) == 'q')
			close(n)
			error('wavelength_calibrate: instructed to quit by user.');
		end

		close(n)
	end

	if (dataisgood == true)
		[p, s] = polyfit(pkx, refpknm, 2);
		lambda = polyval(p, (1:size(Z,1)).');
	end

end
