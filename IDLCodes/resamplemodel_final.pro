; NAME: 
;      RESAMPLEMODEL_FINAL.PRO
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;     For use with FITMODELGRID_FINAL.PRO
;
;     Resample the higher resolution model to match the resolution and
;     wavelength coverage of the lower resolution data.
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     
; INPUT PARAMETERS:
;    datalam - your data's wavelength scale in microns, an array of floats
;    modellam - your model's wavelength scale in microns, an array of floats
;    modelflux - your model's flux values, an array of floats
;
; RETURNS:
;    modelflux_out - your resampled model, for the wavelength values of datalam
;
; CALLING SEQUENCE:
;    model_resolutionmatched = resamplemodel_final(datalam, modellam, modelflux)
;

function resamplemodel_final, datalam, modellam, modelflux
 
  ; Get the model wavelength and flux only where it overlaps with the data
  index = where(modellam ge min(datalam) and modellam le max(datalam))
  modellam_short = modellam[index]
  modelflux_short = modelflux[index]

  modelflux_out = interpol(modelflux_short, modellam_short, datalam, /lsquadratic)

  return, modelflux_out
end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract