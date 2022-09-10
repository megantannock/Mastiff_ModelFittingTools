; NAME: 
;      CONTIUUMDIV_POLYNOMIAL_FINAL.PRO
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;     For use with FITMODELGRID_FINAL.PRO
;     
;     Fit a polynomial to the continuum and divide it out
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     
; INPUT PARAMETERS:
;    lam - your wavelength scale in microns, an array of floats
;    flux - your flux values, an array of floats
;    order - the order of the polynomial you want to fit, an integer
;
; RETURNS:
;    fluxfit - an array of the polynomial fit to the fluxes, on the
;        same wavelength scale as the input lam. You can divide your
;        flux by fluxfit to roughly remove the continuum
;
; CALLING SEQUENCE:
;    datafit = contiuumdiv_polynomial_final(datalam, dataflux, 4)
;    

function contiuumdiv_polynomial_final, lam, flux, order

  ; Check if the arrays are the same length as the other arrays
  if (n_elements(lam) ne n_elements(flux)) then begin
    print, "contiuumdiv_polynomial_final: Array sizes do not match."
    print, "contiuumdiv_polynomial_final: Returning NaN."
    return, [!VALUES.F_NAN]
  endif

  ; Smooth to remove outliers before fitting polynomial
  sbin = 30 ; the width of the smoothing box. Smooth.pro uses a boxcar median
  fluxsmooth = SMOOTH(flux, sbin, /NAN, /EDGE_TRUNCATE) 

  ; Fit a polynomial to the data flux vector
  fluxfitparam = ROBUST_POLY_FIT(lam, fluxsmooth, order, fluxfit)

  return, fluxfit
end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract