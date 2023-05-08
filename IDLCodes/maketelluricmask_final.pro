; NAME: MAKETELLURICMASK_FINAL.PRO
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;     For use with FITMODELGRID_FINAL.PRO
;     
;     A function that makes a telluric mask on the fly, based on the Earth's
;     transmittance spectrum from the Planetary Spectrum Generator (PSG):
;     https://psg.gsfc.nasa.gov/
;     The masked region has to be for H or K band - if you want something 
;     else, need to re-run the PSG and make an Earth's transmittance 
;     spectrum for that wavelength range, and ensure that 
;     FITMODELGRID_FINAL.PRO can read it in before calling this function.
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;
; INPUT PARAMETERS:
;    transmittance - the transmittance from the PSG, an array of floats
;    psglam - the wavelengths in microns from the PSG, an array of floats
;    ohstrength - the strengths of the OH emission lines, an array of floats
;    ohlam - the wavelengths in microns of the OH emission lines, array of 
;            floats in um
;    dataflux - your data's flux, an array of floats
;    datalam - your data's wavelength scale in microns, an array of floats
;    bcv - the barycentric velocity in km/s your data has been corrected for
;    threshold - the depth of the transmittance lines you want to mask, in 
;            percentage. Closer to 0% masks more, closer to 100% masks less
;
; RETURNS:
;    finalmask - an array of 1s and NANs. Multiply your data flux by this
;            aray.
;
; CALLING SEQUENCE:
;    mask = maketelluricmask_final(intransmittance, inpsglam, inohstrength, inohlam, dataflux, datalam, -10.1, 30, 4)
;

function maketelluricmask_final, transmittance, psglam, ohstrength, ohlam, dataflux, datalam, bcv, threshold, slitwidth, objectname
  c = 2.99792458d5 ; km/s - speed of light
  
  ; custom per-target shifting (due to RV)
  if (objectname eq 'Luhman16A') then begin
    extrashift = -3
  endif else if (objectname eq 'Luhman16B') then begin
    extrashift = -3
  endif else begin
    extrashift = 0
  endelse

  ; make a copy of everything to use below - don't want to overwrite it
  transmittancecopy = transmittance
  psglamcopy = psglam
  ohstrengthcopy = ohstrength
  ohlamcopy = ohlam
  datafluxcopy = dataflux
  datalamcopy = datalam

  ; shift the PSG to the bcv
  psglamcopy = psglamcopy * (1. + (bcv/c))

  ; match the PSG wavelength scale to the data
  transmittanceout = resamplemodel_final(datalamcopy, psglamcopy, transmittancecopy)
  outlam = datalamcopy
  
  ; make the mask
  telluricmask = (datalamcopy * 0. ) + 1.0 ; make an array of 1s the same length as your datalam array to fill in
  telluricmaskindex = where(transmittanceout le threshold) ; get the indices of everywhere the transmittance goes below your threshold
  telluricmaskindex = telluricmaskindex + extrashift
  telluricmask[telluricmaskindex] = !VALUES.F_NAN ; make those values NaN
  telluricmask[telluricmaskindex-1] = !VALUES.F_NAN ; mask a couple extra pixels
  telluricmask[telluricmaskindex-2] = !VALUES.F_NAN ; mask a couple extra pixels
  ;telluricmask[telluricmaskindex+1] = !VALUES.F_NAN ; mask a couple extra pixels
  ;telluricmask[telluricmaskindex+2] = !VALUES.F_NAN ; mask a couple extra pixels
  telluricmask[telluricmaskindex-3] = !VALUES.F_NAN ; mask a couple extra pixels
  telluricmask[telluricmaskindex-4] = !VALUES.F_NAN ; mask a couple extra pixels
  telluricmask[telluricmaskindex-5] = !VALUES.F_NAN ; mask a couple extra pixels
  ; extra
  telluricmask[telluricmaskindex+1] = !VALUES.F_NAN ; mask a couple extra pixels
  telluricmask[telluricmaskindex-6] = !VALUES.F_NAN ; mask a couple extra pixels
  telluricmask[telluricmaskindex+2] = !VALUES.F_NAN ; mask a couple extra pixels
  telluricmask[telluricmaskindex-7] = !VALUES.F_NAN ; mask a couple extra pixels

  ; We also need to mask the OH emission lines:

  ; correct to the  barycentric velocity
  ohlamcopy = ohlamcopy * (1. + (bcv/c)) ; bvc is an array, so index in for a particular value...

  ; cut out the present order, and take only the strongest lines
  index = where(ohlamcopy ge outlam[0] and ohlamcopy le outlam[-1] and ohstrengthcopy ge 100) ; 100 is arbitrary...
  ohlamchop = ohlamcopy[index]
  strengthchop = ohstrengthcopy[index]


  ; need to find the wavelengths in our data closest to the OH lines
  ; use the indices, rather than wavelengths:
  indices=[] ; our list of indices to fill in
  for lines=0,n_elements(ohlamchop)-1 do begin
    differences = abs(datalamcopy - ohlamchop[lines])
    index = where(differences eq min(differences))
    indices = [indices, index]
  endfor

  ; make a little for loop to broaden the masked bits
  ohmaska = (datalamcopy * 0.) + 1. ; make a mask we'll fill in for the OH lines mask
  for lines=0,n_elements(indices)-1 do begin
    index = indices[lines]
    index = index + extrashift
    if (index gt slitwidth) and (index lt (n_elements(datalamcopy)-slitwidth) ) then ohmaska[index-slitwidth:index+slitwidth] = !VALUES.F_NAN
  endfor

  finalmask = telluricmask*ohmaska

  return, finalmask
end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract