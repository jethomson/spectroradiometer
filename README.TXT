Visit http://jethomson.wordpress.com/spectrometer-articles/
for a series of articles about this code.
Visit http://jethomson.wordpress.com/spectrometer-articles/code
to download sample spectrographs to process with this code.

Before executing any of the scripts and functions you'll want to run setup_path.
The octave packages octave-miscellaneous and octave-signal are required to run
this code. 

This set of functions and scripts allows you to transform a spectrograph, a 
photograph of a light source's spectrum, into a spectrogram, a plot of the 
light's spectrum with a wavelength scale. Not all the steps listed here are 
necessary to produce a spectrogram. It is possible to produce a spectrogram 
with a wavelength scale quite simply from one spectrograph of a CFL, one 
spectrograph of the light source of interest, and a bit of processing with the 
functions wavelength_calibrate() and image2spectrum().

The spectrographs were taken by placing a diffraction grating over the camera's 
lens and photographing light after it passes through a narrow slit made from 
razor blades. The photos were shot with a custom white balance to prevent the 
white balance from changing as various spectrums are photographed. The 
spectrographs of the light spectrum of interest and the reference spectrographs 
must be taken in the same session to prevent changes in the environment from 
affecting the data.

The scripts directory contains primary scripts and example scripts. The primary 
scripts either batch process spectrographs or setup the spectrometer 
code's workspace at the beginning of a new session. The example script 
example_02_cyan_LED_spectrogram_preprocessed.m shows the easy way to produce a 
spectrogram; however it hides away much of the inner workings so 
example01_cyan_LED_spectrogram_not_preprocessed.m shows more complicated 
examples of how the functions can be called and in what order.

Before using the spectrometer functions and scripts, cd to the spectroradiometer
directory and run setup_path.m

===Methods===
This section details the steps taken to produce a spectrograph and convert it 
to a spectrogram.

Setup and Calibration Frames
----------------------------
01) Let the camera warm up. So that the camera will be thermally stable when 
taking dark frames.
02) Set a custom, uniform white balance.  (note 1)
03) Put on diffraction grating. Turn on CFL.
04) Using LCD view finder: position camera, rotate grating, and orient box to
    get a bright, horizontal spectrum.
05) Determine the best zoom and focus.
06) Use the lowest f-number (while zoomed) and lowest ISO.
07) Determine a shutter speed that will give a proper exposure for the CFL, 
incandescent, and light source of interest.* Use saturation_test.m to help.
08) Determine the best color of light to use for taking flats. Use 
find_camera_gray_test.m to help.
09) Determine the shutter speed that results in the flats' RGB histograms 
between 1/3 and 2/3 of max.
10) Take light darks using the shutter speed determined in step 7.
11) Take flat darks using the shutter speed determined in step 9.
12) Take flats.
13) Take bias frames. **
14) Use batch_raw_decode.m to decode calibration frames.
15) Run make_master_dark_flat_bias.m

*A light source can be moved closer to or further away from the slit to prevent 
under/overexposure. It is not necessary for all the light sources to be the 
same distance from the slit. However the height of every light source should be 
adjusted so that the center of it's spectrum occurs at half the camera's image 
height.

**Bias frames are only necessary if you want to do dark frame matching.

General
-------
01) Let the camera warm up.
02) Set a custom white balance. (note 1)
03) Put on diffraction grating.
04) Using LCD view finder: position camera, rotate grating, and orient box to
    get a bright, horizontal spectrum.
05) Set the camera to the settings determined in "Setup and Calibration Frames".
06) Take a CFL spectrograph.
07) Take an incandescent bulb spectrograph and call get_fO_data to take an
    irradiance reading. (note 2)
08) Take a spectrograph of the light source of interest and take an irradiance
    reading.
09) Follow blackbody steps to get Ti, Ri, and Rf. (note 2)
10) Copy the spectrographs and metadata into the proper directory structure.
11) Run batch_raw_decode.m
12) Run batch_preprocess.m (note 3)
13) Run spectrometer_setup.m
14) Edit the parameters used to determine the temperature of your incandescent
    calibration lamp. (note 2)
15) Run system_function_calibrated.m (note 2)
16) Use image2spectrum to produce a spectrogram from your spectrograph of
    interest.
17) Use Hr from system_function_calibrated to correct spectrogram of interest. (note 2)
18) Use an irradiance measurement and TSL230_fO_to_irradiance() to calibrate
    the spectrum of interest. (note 2)

[1] A uniform white balance, where all the multipliers are equal 
    (i.e. mr = mg = mb), can be obtained by setting a custom white balance on a 
    target that produces an overexposed image. This won't work for all cameras.
[2] This step is only required if you are interested in the spectrometer's 
    system function and the effect it has on your spectrograph of interest.
[3] If you are using an irradiance sensor affixed to one side of the slit, you
    need to determine what row number the center of the sensor corresponds to
    and use that row number to determine the region of interest you want
    batch_preprocess to crop the spectrographs to (i.e. y0 and h defined in
    batch_preprocess.m). An easy way to do this is to aim a laser pointer
    through the slit such that it is level with the center of the sensor, take
    a spectrograph, then examine it to find the row number.

Blackbody
---------
_No Power Applied_
01) Make sure it's unplugged!
02) Measure temperature of room - Ti, temperature in Celsius.
03) Screw in short-circuit bulb base.
04) Measure Rx, closed loop resistance.
05) Screw in light bulb.
06) Measure R1, cold circuit's total resistance.
07) Measure In, meter AC noise current.
08) Measure Vn, meter AC noise voltage.
09) Make sure shunt is inactivated.
_Power Applied_
10) Measure V2, hot circuit's total AC voltage.
11) Attach current meter.
12) Shunt current through current meter.++
13) Measure I2, hot cirucit's total AC current.
_Calculations_
14) Ri = R1 - Rx
15) Rf = ((V2-Vn)/(I2-In)) - Rx
16) Use calculate_filament_temp() to calculated the temperature of the hot
    filament. Tf = calculate_filament_temp(Ti, Ri, Rf)

+Taking these measurements required a modified electrical outlet box that 
allowed an AC circuit to be interrupted, probed, and measured. If you are using 
a 100W bulb on a 120 Vac supply not much error will result if you assume Tf is 
2800K. generate_Wbb_spectrum() will accept Tf instead of Ri and Rf.
++The resistance of a cold filament allows an inrush of current that may exceed 
the limits of the meter that is why a shunt is used to switch current through 
the meter after the filament has warmed up and it's resistance has increased.

===End Methods===

The following directory tree shows the basic directory structure the 
spectrometer functions and scripts expect. Not all files and folders are shown. 
Spectrographs are always saved in a directory named for the type of files it 
holds. JPG holds the JPEGs output by the camera and PGM holds the PGM files 
that result from developing the CHDK raw files stored in DNG. Only JPEG and PGM 
files are processed by this code. The directories eN (where N is a number) each 
store an ensemble of spectrographs, where an ensemble is a collection of 
multiple pictures of the same subject. For example, if one wanted to test two 
blue LEDs, e0 would hold an ensemble of spectrographs of the 1st LED and e1 
would hold an ensemble of spectrographs of the 2nd LED. Reference spectrographs 
will never need more than one ensemble by virtue of them being references. The 
Hg folder holds a spectrograph of compact fluorescent lamp that is used to 
calibrate a wavelength scale. The W folder holds a spectrograph of an 
incadescent bulb that is used to determine the spectral response of the 
spectrometer. The dark, flat, and bias frames folders hold the images used to 
perform dark and flat frame corrections.


data
└── frames
    ├── bias_frames
    │   ├── DNG
    │   ├── JPG
    │   └── PGM
    ├── dark_frames
    │   ├── flat_darks
    │   │   ├── DNG
    │   │   ├── JPG
    │   │   └── PGM
    │   └── light_darks
    │       └── 2s
    │           ├── DNG
    │           ├── JPG
    │           └── PGM
    ├── flat_frames
    │   ├── DNG
    │   ├── JPG
    │   └── PGM
    └── light_frames
        └── 2s
            └── 2012_08_30
                ├── reference
                │   ├── radiometric
                │   │   ├── DNG
                │   │   ├── JPG
                │   │   └── PGM
                │   └── spectral
                │       ├── DNG
                │       ├── JPG
                │       └── PGM
                └── spectrographs
                    ├── 60W_GE_8
                    │   └── e0
                    │       ├── DNG
                    │       ├── JPG
                    │       └── PGM
                    ├── 60W_Sylvania_8
                    │   └── e0
                    │       ├── DNG
                    │       ├── JPG
                    │       └── PGM
                    └── Cyan_LED_3
                        └── e0
                            ├── DNG
                            ├── JPG
                            └── PGM

===How to Use the Code===
Most of the functions are setup in such a way that they will process individual
images that have not been preprocessed. For example if you have an image of a
CFL's spectrum named HG_REF.JPG and a spectrograph of an LED name CYAN01.JPG, then
to plot the spectrum of the LED you can use the following code:

lambda = wavelength_calibrate('HG_REF.JPG');
Z = image2spectrum('CYAN01.JPG');
plot(lambda, Z)

The next step up in complexity is to take several spectrographs of the same 
light source to form an ensemble and to place the images in a special directory
structure. batch_preprocess averages, crops, dark subtracts, and flat corrects
all of the ensembles and saves them as mat files. Once this processing is done
it doesn't need to be performed again. Dark subtraction, flat correction, and
tone linearization are optional and can be turned off individually by
uncommenting a couple of lines in batch_preprocess. Now that you have
preprocessed the ensembles into mat files you can use the functions to process
them much like you did with individual images.

load('path/to/reference/spectral/PGM_spectral_ref.mat')
lambda = wavelength_calibrate(spectral_ref);
load('path/to/spectrographs/Cyan_LED_3/PGM_Cyan_LED_3_e0.mat');
Z = image2spectrum(spctgrph);
plot(lambda, Z)

To make things easier and keep the workspace tidy the scripts
initialize_spectrometer_workspace and spectrometer_setup create a spectrometer
object. The spectrometer object stores the wavelength scale and several other 
variables that make writing scripts to process spectrograms simpler. The script 
system_function_calibrated demonstrates how to use a incandescent bulb to
calibrate the y-axis of a spectrogram in terms of spectral irradiance. It
creates the so.Hr which when multiplied with a spectrogram converts counts to
W/m^2/nm.

Don't expect accurate radiometric calibration when using JPGs. Proper
radiometric calibration requires that the ensembles be dark subtracted
and flat corrected during the preprocessing step.

Metadata
--------
Metadata about a spectrograph should be saved in a text file that contains
information such as distance from luminating surface to slit, irradiance
measurements from the TSL230, the irradiance sensors sensitivity, units
used, etc. batch_preprocess saves this metadata into the mat file it
creates from each ensemble of spectrographs. Then when a spectrograph's mat file
is loaded in a script its metadata can be used to radiometrically calibrate
the resulting spectrogram.

