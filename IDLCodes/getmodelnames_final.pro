; NAME: 
;      GETMODELNAMES_FINAL.PRO
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;     For use with FITMODELGRID_FINAL.PRO
;     
;     Gets the names of the models from the file containing them. The 
;     "modelnamesfile" is specified in the configuration file and must 
;     include the full path to the file.
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     
; INPUT PARAMETERS:
;    modelnamesfile - the path and name of a text file containing a
;        list of the names of the models you want to fit to. Can
;        be any length.
;
; RETURNS:
;    modelnames - an array of strings which are the file names of the
;        models
;
; CALLING SEQUENCE:
;    modelnames = getmodelnames_final('path/modelnamesfile.txt')
;    

function getmodelnames_final, modelnamesfile

  nlines = FILE_LINES(modelnamesfile)
  modelnames = STRARR(nlines)
  OPENR, unit, modelnamesfile,/GET_LUN
  READF, unit, modelnames
  FREE_LUN, unit

  return, modelnames
end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract