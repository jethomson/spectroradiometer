% This script will help you find the RGB color displayed on your monitor that
% appears gray in the photograph recorded by your camera. If you are working
% with raw images, then this color will look gray to your camera without any
% white balance mulitpliers applied. If you have a JPEG only camera, then the
% color that will appear gray depends on the white balance setting used. Some
% cameras can set a custom white balance on a target that saturates the CCD
% resulting in white balance multipliers that are all 1 or at least all equal,
% which is equivalent to no white balance at all. This trick can be used to
% find the RGB color that looks gray to your JPEG only camera without white
% balance.
%
% The RGB color that appears gray to your camera can be determined by solving a
% set of simultaneous equations that relate a stimulus color (the color
% displayed by the monitor) to the response color (the color recorded by the
% camera). The parameters of the simultaneous equations, denoted M, are a set
% of nine multipliers, three for each channel. The independent variable is the
% stimulus, denoted S. The dependent variable is the reponse, denoted R.
% M*S = R (eqn. 1)
% if Srgb = [255   0   0; ...
%              0 255   0; ...
%              0   0 255]
% then M*Srgb = Rrgb, and M = Rrgb*inv(Srgb)
% therefore if Rgray is defined as [64; 64; 64]
% then Sgray = inv(M)*Rgray, Sgray is the display's RGB color that looks gray
% to the camera. Sgray most likely will not appear gray to the human eye.
%
% Before running this script, take a photograph of the monitor displaying solid
% red (255, 0, 0), solid green (0, 255, 0), and solid blue (0, 0, 255). Use the
% same camera settings for each picture. You should defocus or use a diffuser to
% prevent recording the pixel pattern. If you are using this script to find the
% best color to take flats, you should use a diffuser, because you need to use
% the same focus for taking flats as you use for taking lights.
%
% The RGB color determined by this script will need to be fine-tuned to get it
% to look gray to your camera. It may not be possible to get it to be exactly
% gray, for example even when using an RGB color with no green (255, 0, 255)
% the resulting photo still has a green cast.
%
% Once you've found the color your camera sees as gray, it can be used to take
% flats that don't have a color cast or at least don't have a very strong color
% cast. If you've found your camera's raw gray, then you should be able to use
% this RGB color to set a custom white balance of equal multipliers. However,
% this may not work perfectly.
%
% see % http://jethomson.wordpress.com/spectrometer-articles/rgb-flats/

%-----
ftype = 'PGM';
access_bayer_pattern('gbrg');
fl = list_dir(['data/A590/tests/camera_gray_test/e0/' ftype], '*', 1);

% camera gray
Rgray = [64; 64; 64];

% display output/stimulus
Srgb = [255 0 0; ...
        0 255 0; ...
        0 0 255];
%-----

if strcmpi(ftype, 'JPG')
	Srgb = sRGB2lin(Srgb);
	red_rsp = image_mean(sRGB2lin(fl{6})); % camera's response to red stimulus
	green_rsp = image_mean(sRGB2lin(fl{7}));
	blue_rsp = image_mean(sRGB2lin(fl{8}));
else
	red_rsp = image_mean(fl{2});
	green_rsp = image_mean(fl{3});
	blue_rsp = image_mean(fl{4});
end

% row 1: red components of red, green, and blue responses
% row 2: green components of red, green, and blue responses
% row 3: blue components of red, green, and blue responses
Rrgb = [red_rsp(1) green_rsp(1) blue_rsp(1); ...
        red_rsp(2) green_rsp(2) blue_rsp(2); ...
        red_rsp(3) green_rsp(3) blue_rsp(3)];


% The backslash operator is faster but only works in this case because S is a
% scaled identity matrix, 255*I. Therefore, M*S = S*M. However, if S were not a
% scaled identity matrix, then M*S != S*M and one must use M = R*inv(S) instead.
M = Srgb\Rrgb;

%M*S = R  --> M = R*inv(S)
%M = Rrgb*inv(Srgb)


% Now determine the RGB value displayed by the LCD monitor that will result in
% a gray image being recorded by the camera.
% M*Sgray = Rgray
% Sgray = inv(M)*Rgray
if strcmp(ftype, 'JPG')
	Sgray = M\sRGB2lin(Rgray);
	Sgray = Sgray*(255/max(Sgray));
	display_color = round(lin2sRGB(Sgray))
elseif strcmpi(ftype, 'PGM')
	Sgray = M\Rgray;
	Sgray = Sgray*(255/max(Sgray));
	display_color = round(Sgray)
end
