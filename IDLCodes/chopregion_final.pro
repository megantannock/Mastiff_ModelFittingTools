; NAME: 
;      CHOPREGION_FINAL.PRO
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;     For use with FITMODELGRID_FINAL.PRO
;     
;     Remove the ends of an array the match the input wavelengths.
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     
; INPUT PARAMETERS:
;    lowerlam - the start value of the wavelength coverage you want
;          (in microns), a float
;    upperlam - the end value of the wavelength coverage you want (in
;          microns), a float
;    lamvals - your wavelength scale in microns, an array of floats
;    fluxvals - your flux values, an array of floats
;
; RETURNS:
;    chopvalues - a 2D array of the final wavelength array and flux 
;          array, formatted as [[lamchop], [fluxchop]]
;
; CALLING SEQUENCE:
;    datavalues_chop = chopregion_final(1.0, 1.2, datalam, dataflux)
;    

function chopregion_final, lowerlam, upperlam, lamvals, fluxvals

  ; Check if the arrays are the same length as the other arrays
  if (n_elements(lamvals) ne n_elements(fluxvals)) then begin
    print, "chopregion_final: Array sizes do not match."
    print, "chopregion_final: Returning NaN."
    return, [!VALUES.F_NAN]
  endif

  lamchop = lamvals[WHERE(lamvals GT lowerlam AND lamvals LT upperlam, /NULL)]
  fluxchop = fluxvals[WHERE(lamvals GT lowerlam AND lamvals LT upperlam, /NULL)]

  chopvalues = [[lamchop], [fluxchop]]
  return, chopvalues

end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract