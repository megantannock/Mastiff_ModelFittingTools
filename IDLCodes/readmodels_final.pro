; NAME: 
;      READMODELS_FINAL.PRO
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;     For use with FITMODELGRID_FINAL.PRO
;     
;     Read in a model, depending on the type of model it is.  
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     
; INPUT PARAMETERS:
;    modeltype - the name of the family of models you are fitting. 
;          Options are the same as for the configuration file: MORLEY, 
;          SAUMON, SONORA-BOBCAT, BOBCAT-ALTA or BTSETTL-CIFIST2011. You 
;          can add additonal cases if your data differs from these. Ensure 
;          the flux is in F_lambda units and the wavelength is in microns.
;    modelpath - a string that is the path to the model files
;    modelfilename - a string that is the name of the model to read in
; 
; RETURNS:
;    modelvalues - a 2D vector of wavelength in microns (vacuum 
;          wavelengths) and flux in F_lambda units
;
; CALLING SEQUENCE:
;    modelvalues = readmodels('MORLEY', 'pathtomodels/', 'sp_t1000g1000f5_010')
;    
; NOTES: 
;    References:
;      MORLEY: See Morley et al. 2012: https://ui.adsabs.harvard.edu/abs/2012ApJ...756..172M/abstract
;      SAUMON: See Saumon & Marley 2008: https://ui.adsabs.harvard.edu/abs/2008ApJ...689.1327S/abstract
;      SONORA-BOBCAT: See Marley et al. 2021: https://ui.adsabs.harvard.edu/abs/2021ApJ...920...85M/abstract
;      BOBCAT-ALTA: See Tannock et al. 2022: https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;      BTSETTL-CIFIST2011: See Allard et al. 2012
;    

function readmodels_final, modeltype, modelpath, modelfilename
  c = 2.99792458d5 ; km/s - speed of light

  CASE modeltype OF

    'MORLEY': begin
      ; See Morley et al. 2012: https://ui.adsabs.harvard.edu/abs/2012ApJ...756..172M/abstract
      
      ; example filename: 'sp_t1200g3000f2_010_b'
      ; format is: lam [microns], flux
      ; Wavelengths are in vacuum

      fmt = 'D,D' ; format of modelfilename
      readcol, modelpath + modelfilename, FORMAT = fmt, modellam, modelflux, SKIPLINE=3, /SILENT ; Read in the data

      ; Morley models wavelengths are backwards - they go from large lam to small lam
      ; Reverse!!!
      modellam = reverse(modellam)
      modelflux = reverse(modelflux)

      ; Morley models are in Fnu units (erg/cm^2/s/Hz)
      ; convert to Flambda (erg/cm^2/s/um) by multiplying by c / lambda^2
      modelflux = modelflux * c / (modellam * modellam)
    end

    'SAUMON': begin
      ; See Saumon & Marley 2008: https://ui.adsabs.harvard.edu/abs/2008ApJ...689.1327S/abstract

      ; example filename: 'sp_t1500g300f1'
      ; format is: lam [microns], flux
      ; Wavelengths are in vacuum

      fmt = 'D,D' ; format of modelfilename
      readcol, modelpath + modelfilename, FORMAT = fmt, modellam, modelflux, SKIPLINE=3, /SILENT ; Read in the data

      ; Saumon & Marley models are backwards - they go from large lam to small lam
      ; Reverse!!!
      modellam = reverse(modellam)
      modelflux = reverse(modelflux)

      ; Saumon & Marley models are in Fnu units (erg/cm^2/s/Hz)
      ; convert to Flambda (erg/cm^2/s/um) by multiplying by c / lambda^2
      modelflux = modelflux * c / (modellam * modellam)
    end

    'SONORA-BOBCAT': begin
      ; See Marley et al. 2021: https://ui.adsabs.harvard.edu/abs/2021ApJ...920...85M/abstract
      
      ; example filename: 'sp_t2000g3160nc_m0.0'
      ; format is: lam [microns], flux
      ; Wavelengths are in vacuum

      fmt = 'D,D' ; format of modelfilename
      readcol, modelpath + modelfilename, FORMAT = fmt, modellam, modelflux, SKIPLINE=3, /SILENT ; Read in the data

      ; Sonora models are backwards - they go from large lam to small lam
      ; Reverse!!!
      modellam = reverse(modellam)
      modelflux = reverse(modelflux)

      ; Sonora models are in Fnu units (erg/cm^2/s/Hz)
      ; convert to Flambda (erg/cm^2/s/um) by multiplying by c / lambda^2
      modelflux = modelflux * c / (modellam * modellam)
    end

    'BOBCAT-ALTA': begin
      ; See Tannock et al. 2022: https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
      
      fmt = 'D,D' ; format of modelfilename
      readcol, modelpath + modelfilename, FORMAT = fmt, modellam, modelflux, SKIPLINE=3, /SILENT ; Read in the data

      ; Alt A models are backwards - they go from large lam to small lam
      ; Reverse!!!
      modellam = reverse(modellam)
      modelflux = reverse(modelflux)

      ; Alt A models are in Fnu units (erg/cm^2/s/Hz)
      ; convert to Flambda (erg/cm^2/s/um) by multiplying by c / lambda^2
      modelflux = modelflux * c / (modellam * modellam)
    end

    'BTSETTL-CIFIST2011': begin
      ; See Allard et al. 2012
      
      fmt = 'D,D' ; format of filename
      readcol, modelpath + modelfilename, FORMAT = fmt, lam_in, F_in, /SILENT ; Read in the data
      ; F is model, B is a blackbody of the same temperature
      ; Wavelengths are in vacuum

      ; Data is out of order because models are produced in multiple threads. Need to sort in order of wavelength
      sortindex = Sort(lam_in)   ; Set an index to sort from
      lam = lam_in[sortindex]  ; re-order the wavelengths
      flux = F_in[sortindex]   ; re-order the flux

      DF= -8.0  ; -8.0 for BT-SETTL -- Constant necessary for unit conversion
      flux_cor = 10^(flux + DF) ; flux to convert to Ergs/sec/cm**2/A

      modelflux = flux_cor
      modellam = lam / 10000. ; convert to microns
    end
    
    'CallieCloudy': begin
      ; Callie's models should be the same as the Sonora models...

      fmt = 'D,D' ; format of modelfilename
      readcol, modelpath + modelfilename, FORMAT = fmt, modellam, modelflux, SKIPLINE=3, /SILENT ; Read in the data

      ; !!!  models are backwards! Go from large lam to small lam! Reverse!!!
      modellam = reverse(modellam)
      modelflux = reverse(modelflux)

      ; !!!  models are in Fnu units, I think...  files say W/m2/m
      ; convert to Flambda (erg/cm^2/s/um) by multiplying by c / lambda^2
      modelflux = modelflux * c / (modellam * modellam)

    end
    
    'CallieDisEq': begin
      ;

      fmt = 'D,D' ; format of modelfilename
      readcol, modelpath + modelfilename, FORMAT = fmt, modellam, modelflux, SKIPLINE=2, /SILENT ; Read in the data

      ; !!!  models are backwards! Go from large lam to small lam! Reverse!!!
      modellam = reverse(modellam)
      modelflux = reverse(modelflux)

      ; !!!  models are in Fnu units, I think...  files say W/m2/m
      ; convert to Flambda (erg/cm^2/s/um) by multiplying by c / lambda^2
      modelflux = modelflux * c / (modellam * modellam)

    end

  ENDCASE

  modelvalues = [[modellam], [modelflux]]
  return, modelvalues

end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract