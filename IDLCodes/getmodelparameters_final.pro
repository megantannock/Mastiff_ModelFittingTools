; NAME: 
;      GETMODELPARAMETERS_FINAL.PRO
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;     For use with FITMODELGRID_FINAL.PRO
;     
;     Get the parameters of a model from its filename. 
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     
; INPUT PARAMETERS:
;    modeltype - the name of the family of models you are fitting. 
;    Options are the same as for the configuration file: MORLEY, 
;    SAUMON, SONORA-BOBCAT, BOBCAT-ALTA or BTSETTL-CIFIST2011. You
;    can add additonal cases if your data differs from these.
;
; RETURNS:
;    values - a three-component vector of [temperature, logg, fsed].
;          Where temperature is the effective temperature of the model 
;          in Kelvin, logg is the log(g) of the model, where g is in units
;          of cm/s/s. The unit shown in each model family is below. fsed is
;          the sedimentation efficiency, and defaults to fsed = 0 if the 
;          model family does not include fsed.
;          
;          g units: MORLEY: m/s/s
;                   SAUMON: m/s/s
;                   SONORA-BOBCAT: m/s/s
;                   BOBCAT-ALTA: m/s/s
;                   BTSETTL-CIFIST2011: log(g) where g is in units of cm/s/s
;
; CALLING SEQUENCE:
;    modelparams = getmodelparameters('MORLEY', 'sp_t1200g3000f2_010_b')
;    
; NOTES: 
;    This was re-written for IDL V8.3. Might not work with other versions.
;    
;    References: 
;      MORLEY: See Morley et al. 2012: https://ui.adsabs.harvard.edu/abs/2012ApJ...756..172M/abstract
;      SAUMON: See Saumon & Marley 2008: https://ui.adsabs.harvard.edu/abs/2008ApJ...689.1327S/abstract
;      SONORA-BOBCAT: See Marley et al. 2021: https://ui.adsabs.harvard.edu/abs/2021ApJ...920...85M/abstract
;      BOBCAT-ALTA: See Tannock et al. 2022: https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;      BTSETTL-CIFIST2011: See Allard et al. 2012
;    

function getmodelparameters_final, modeltype, modelfilename

  CASE modeltype OF

    'MORLEY': begin
      ; See Morley et al. 2012: https://ui.adsabs.harvard.edu/abs/2012ApJ...756..172M/abstract
      
      ; parameters are temperature, gravity g, f_sed for these models
      ; example filename: 'sp_t1200g3000f2_010_b'

      ; Effective Temperature
      split = STRSPLIT(modelfilename,'t',/EXTRACT)
      split = STRSPLIT(split[1],'g',/EXTRACT)
      temperature = split[0]
      temperature = uint(temperature)

      ; gravity
      ; g value in MORLEY models is in m/s/s
      split = STRSPLIT(split[1],'f',/EXTRACT)
      g = split[0]
      g = uint(g)
      g = alog10(g * 100.) ; in log10(cm/s/s)


      ; f_sed
      split = STRSPLIT(split[1],'_',/EXTRACT)
      fsed = split[0]
      fsed = uint(fsed)
      ; no kzz value. Set to the placeholder value 0
      kzz = 0
    end


    'SAUMON': begin
      ; See Saumon & Marley 2008: https://ui.adsabs.harvard.edu/abs/2008ApJ...689.1327S/abstract

      ; parameters are T, g, f_sed
      ; example file name = 'sp_t1500g300f3'
 
      ; Effective Temperature
      split = STRSPLIT(modelfilename,'t',/EXTRACT)
      split = STRSPLIT(split[1],'g',/EXTRACT)
      temperature = split[0]
      temperature = uint(temperature)

      ; gravity
      ; g value in SAUMON models is in m/s/s
      split = STRSPLIT(split[1],'f',/EXTRACT)
      g = split[0]
      g = uint(g)
      g = alog10(g * 100.) ; in log10(cm/s/s)

      ; f_sed
      split = STRSPLIT(split[1],'_',/EXTRACT)
      fsed = split[0]
      fsed = uint(fsed)
      ; no kzz value. Set to the placeholder value 0
      kzz = 0
    end

    'SONORA-BOBCAT': begin
      ; See Marley et al. 2021: https://ui.adsabs.harvard.edu/abs/2021ApJ...920...85M/abstract
            
      ; parameters are T, g. NO f_sed!
      ; example filename: 'sp_t475g1780nc_m0.0'
      
      ; Effective Temperature
      split = STRSPLIT(modelfilename,'t',/EXTRACT)
      split = STRSPLIT(split[1],'g',/EXTRACT)
      temperature = split[0]
      temperature = uint(temperature)

      ; gravity
      ; g value in SONORA-BOBCAT models is in m/s/s
      split = STRSPLIT(split[1],'n',/EXTRACT)
      g = split[0]
      g = uint(g)
      g = alog10(g * 100.) ; in log10(cm/s/s)

      ; no f_sed value in the Sonora models. Set to the placeholder value of 0
      fsed = 0
      ; no kzz value. Set to the placeholder value 0
      kzz = 0
    end
    
    'BOBCAT-ALTA': begin
      ; BOBCAT-ALTA: See Tannock et al. 2022: https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract

      ; parameters are effective temperature, gravity g. NO fsed!
      ; example filename: 't1100g100nc_m0.0.spec'

      ; Effective Temperature
      split = STRSPLIT(modelfilename,'t',/EXTRACT)
      split = STRSPLIT(split[0],'g',/EXTRACT)
      temperature = split[0]
      temperature = uint(temperature)

      ; gravity g
      split = STRSPLIT(split[1],'n',/EXTRACT)
      g = split[0]
      g = uint(g)
      g = alog10(g * 100.) ; in log10(cm/s/s)

      ; no f_sed value in the Alt-A models. Set to the placeholder value 0
      fsed = 0
      ; no kzz value. Set to the placeholder value 0
      kzz = 0
    end

    'BTSETTL-CIFIST2011': begin
      ; See Allard et al. 2012

      ; parameters are T, g, NO fsed

      ; naming convention: lte-LOGG+[M/H]a+[ALPHA/H]
      ; example filename: 'lte009-5.0-0.0a+0.0.BT-Settl.spec.7'
      ; T = 900
      ; logg = 5.0
      ; [M/H] = 0.0
      ; [ALPHA/H] = 0.0

      ; Effective Temperature
      split = STRSPLIT(modelfilename,'e',/EXTRACT)
      split = STRSPLIT(split[1],'-',/EXTRACT)
      temperature = split[0]
      temperature = float(temperature)
      temperature = temperature * 100
      temperature = uint(temperature)

      ; gravity 
      ; log(g) where g is in units of cm/s/s
      split = STRSPLIT(split[1],'n',/EXTRACT)
      g = split[0]
      g = float(g) ; this is already in log(g [cm/s/s])

      ; no f_sed value in the Allard models. Set to the placeholder value 0
      fsed = 0
      ; no kzz value. Set to the placeholder value 0
      kzz = 0
    end
    
    'CallieCloudy': begin
      ;Callie's file names are similar to Sonora

      ; example filename: 't1400g316f2_m0.0_co1.0.spec'
      ; also have a non-cloudy case: 't1700g100nc_m0.0_co1.0.spec'
      ; parameters are temperature, gravity g

      ;;;;;;;;;;;;;;;;;;;;;;;;
      ; Temperature
      split = STRSPLIT(modelfilename,'t',/EXTRACT)
      split = STRSPLIT(split[0],'g',/EXTRACT)
      temperature = split[0]
      temperature = uint(temperature)

      ; gravity g
      split = STRSPLIT(split[1],'n',/EXTRACT)
      g = split[0]
      g = uint(g)
      g = alog10(g * 100.) ; in log10(cm/s/s)

      ; fsed
      split = STRSPLIT(modelfilename,'f',/EXTRACT)
      if split[0] eq modelfilename then begin
        ; non cloudy case, set fsed to 0
        fsed = 0
      endif else begin
        split = STRSPLIT(split[1],'_',/EXTRACT)
        fsed = split[0]
        fsed = uint(fsed)
      endelse

      ; no kzz value. Set to the placeholder value 0
      kzz = 0

    end ; end CallieCloudy
    
    'CallieDisEq': begin

      ; example filenames:
      ;     't1300g316f3.0kzz.spec'
      ;     't1300g316f3.0kzz1m1.spec'
      ;     't1300g316f3.0kzz1p2.spec'
      ; parameters are t, g, f, kzz

      ;;;;;;;;;;;;;;;;;;;;;;;;
      ; Temperature
      split = STRSPLIT(modelfilename,'t',/EXTRACT)
      split = STRSPLIT(split[0],'g',/EXTRACT)
      temperature = split[0]
      temperature = uint(temperature)

      ; gravity g
      split = STRSPLIT(split[1],'n',/EXTRACT)
      g = split[0]
      g = uint(g)
      g = alog10(g * 100.) ; in log10(cm/s/s)

      ; fsed
      split = STRSPLIT(modelfilename,'f',/EXTRACT)
      if split[0] eq modelfilename then begin
        ; non cloudy case, set fsed to 0
        fsed = 0
      endif else begin
        split = STRSPLIT(split[1],'_',/EXTRACT)
        fsed = split[0]
        fsed = uint(fsed)
      endelse

      ; kzz
      split = STRSPLIT(modelfilename,'kzz',/EXTRACT)
      if (split[1] eq '.spec') then begin
        kzz = 1
      endif else if (split[1] eq '1p2.spec') then begin
        kzz = 2
      endif else if (split[1] eq '1m1.spec') then begin
        kzz = 3
      endif

    end ; end CallieDisEq

  ENDCASE

  values = [temperature, g, fsed, kzz]
  return, values

end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract