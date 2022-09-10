; NAME:
;     GETREGIONS_FINAL
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;     For use with FITMODELGRID_FINAL.PRO
;     
;     Determine the wavelength regions to be fit with models from values 
;     retrieved from input configuration file.
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     
; INPUT PARAMETERS:
;     The strings extracted from the configuration file containing the wavelength 
;     region names and wavelength regions, and the order of the polynomial to
;     be used to remove the continuum from the spectrum (set to 0 for no continuum
;     removal). These can also be arrays of strings, and arrays will be returned.
;     If configuration file says:
;       wavelengthregionsnames = Jband
;       wavelengthregions = 1.1,1.3
;       dividecontinuum = 0
;     Then the inputs of getregions_final are:
;     
;     wavelengthregionname - 'Jfull'
;     wavelengthregion - '1.1,1.3'
;     dividecontinuum - '0'
;             
; RETURNS: 
;      None. This overwrites the given wavelengthregionsnames, wavelengthregions
;      dividecontinuum with arrays of suitable type (string, double, int,
;      respectively)
;      
; CALLING SEQUENCE:
;     regions = getregions_final(wavelengthregionname, wavelengthregion, dividecontinuum)
;      

function getregions_final, wavelengthregionsnames, wavelengthregions, dividecontinuum

  ; Extract the names of the regions:

  ; get the indices of the different regions within the larger string
  index = strsplit(wavelengthregionsnames, ',')

  ; make an array of the names of the regions
  wavelengthregionsnamesarray = strarr(n_elements(index)) ; empty array, fill in
  ; fill in the array we just created
  for i=0,n_elements(index)-1 do begin
    if (i eq n_elements(index)-1) then begin ; exception for the case of the last region in the array
      length = strlen(wavelengthregionsnames) - index[i]
    endif else begin ; everything else
      length = index[i+1] - index[i] - 1
    endelse
    newstring = strmid(wavelengthregionsnames, index[i], length)
    wavelengthregionsnamesarray[i] = newstring
  endfor


  ; Extract the actual wavelength regions as numbers, not strings:
  
  ; get the indices of the different regions within the larger string
  index = strsplit(wavelengthregions, ',')

  ; make an array of the names of the regions
  wavelengthregionsarray = dblarr(n_elements(index)) ; empty array, fill in
  ; fill in the array we just created
  for i=0,n_elements(index)-1 do begin
    if (i eq n_elements(index)-1) then begin ; exception for the case of the last region in the array
      length = strlen(wavelengthregions) - index[i]
    endif else begin ; everything else
      length = index[i+1] - index[i] - 1
    endelse
    newstring = strmid(wavelengthregions, index[i], length)
    wavelengthregionsarray[i] = double(newstring)

  endfor


  ; Get the order of the polynomial for continuum removal
  index = strsplit(dividecontinuum, ',')
  ; make an array of the names of the regions
  dividecontinuumarray = strarr(n_elements(index)) ; empty array, fill in
  ; fill in the array we just created
  for i=0,n_elements(index)-1 do dividecontinuumarray[i] = uint(strmid(dividecontinuum, index[i]))


  ; reset the variables
  wavelengthregionsnames = wavelengthregionsnamesarray
  wavelengthregions = wavelengthregionsarray
  dividecontinuum = dividecontinuumarray

end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract