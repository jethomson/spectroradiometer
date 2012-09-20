===== luminosity function =====
luminosity_function_1924e.mat
-----------------------------
1924 photopic luminosity curve
linear energy
250-1250 nm, dlambda (stepsize)= 0.1 nm
interpolated and extrapolated the csv file:
http://www.cvrl.org/database/data/lum/linCIE2008v2e_fine.csv
nterpolated for greater wavelength resolution
This data has been interpolated for greater wavelength resolution and
zero-padded out to 250 and 1250 nm to make it easier to use with the TSL230's
spectral responsivity data which have these wavelengths as the same lower and
upper bound.

===== emissivity and resistivity =====
data taken from eprints.lancs.ac.uk/6736/1/inproc_326.pdf
ABSOLUTE OPTICAL CALIBRATION USING A SIMPLE TUNGSTEN LIGHT BULB: EXPERIMENT
which took it's data from:
CRC Handbook of Chemistry and Physics, 60th Edition, pp. E-381, ed. R.C. Weast,
CRC Press, Boca Raton, 1979

spectral_emissivity.mat
-----------------------
250 - 3500 nm, dlambda = 0.1 nm
1600 - 2800 K
interpolated for greater wavelength resolution

wavelength_integrated_total_emissivity.mat
------------------------------------------
total emissivity versus temperature
200 - 3000 K

rho_vs_T.mat
------------
resistivity (rho [uOhm*cm]) versus temperature (T [K])
200 - 3000 K

===== TSL230's spectral responsivity =====
TSL230_Re_s1.mat
---------
250-1250 nm, dlambda (stepsize)= 0.1 nm
The spectral responsivity for the TSL230's photodiode when set to a sensitivity
of 1. This is the normalized responsivity found in the graph titled 
"PHOTODIODE SPECTRAL RESPONSIVITY" multiplied by the response at 670 nm which is
0.77 [kHz/(W/m^2)] when the sensitivity is 1. The data is extrapolated out to 
250 and 1250 nm so that the entire range where the response is non-zero is
covered. 250 nm is the lowerbound because that is the lowerbound for the
emissivity data. [kHz/(W/m^2)] is used instead of the units found in the
datasheet [kHz/(uW/cm^2)] because W/m^2 is easier to work with.

===== TSL230R's spectral responsivity =====
Re_s1.mat
---------
250-1250 nm, dlambda (stepsize)= 0.1 nm
The spectral responsivity for the TSL230R's photodiode when set to a sensitivity
of 1. This is the normalized responsivity found in the graph titled 
"PHOTODIODE SPECTRAL RESPONSIVITY" multiplied by the response at 640 nm which is
0.77 [kHz/(W/m^2)] when the sensitivity is 1. The data is extrapolated out to 
250 and 1250 nm so that the entire range where the response is non-zero is
covered. 250 nm is the lowerbound because that is the lowerbound for the
emissivity data. [kHz/(W/m^2)] is used instead of the units found in the
datasheet [kHz/(uW/cm^2)] because W/m^2 is easier to work with. The TSL230RD
has Re(640 nm) = 0.79 [kHz/(W/m^2)] instead of 0.77 [kHz/(W/m^2)]; however the
TSL230RD's responsivity has the same shape as the TSL230R's responsivity, so the
TSL230R's mat file is also used for the TSL230RD and Re_s1 is multiplied by
(0.79/0.77).

