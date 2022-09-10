; NAME: 
;      CHISQUARESTATS_FINAL.PRO
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;     For use with FITMODELGRID_FINAL.PRO
;     
;     Calculate the chi square, reduced chisquare between data and model.
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     
; INPUT PARAMETERS:
;    data - your data flux values, an array of floats
;    error - your uncertainties, an array of floats
;    model - your model flux values, an array of floats
;    order - the order of the polynomial you want to fit, an integer
;
; RETURNS:
;    chisquarestatsarray - an array containing the chi square value, 
;          reduced chi square value, degrees of freedom used to calculate 
;          reduced chi square
;
; CALLING SEQUENCE:
;     chisquarestatsarray = chisquarestats_final(dataflux, uncertainty, modelflux)
;    

function chisquarestats_final, data, error, model

  ; Check if the arrays are the same length as the other arrays
  if (n_elements(data) ne n_elements(error)) or (n_elements(data) ne n_elements(model)) then begin
    print, "chisquarestats_final: Array sizes do not match."
    print, "chisquarestats_final: Returning reduced chisquare = NaN."
    return, [!VALUES.F_NAN,!VALUES.F_NAN,!VALUES.F_NAN]
  endif

  ; make new arrays so we don't overwrite them
  newdata = data
  newmodel = model
  newerror = error

  ; compute chi square
  ; chisquare = sum [ (data - model)^2 / uncertainty^2 ]
  chisquareval = ((newdata - newmodel) / newerror )^2.0 ; intermediate step
  chisquareval = total(chisquareval, /nan)

  ; get the degrees of freedom
  ; total(finite(data)) = number of elements in this array that are NOT nan
  dof = total(finite(newdata)) - 1

  ; compute the reduced chi square
  reducedchisquarevalue = chisquareval / dof

  return, [chisquareval, reducedchisquarevalue, dof]

end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract