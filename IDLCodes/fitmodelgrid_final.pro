; NAME:
;      FITMODELGRID_FINAL
;     
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE:
;     Fit a grid of model spectra to observed spectra for brown dwarfs. This code 
;     takes a brute-force approach, fitting every single model on the grid. The
;     code also determines the vsini (projected rotation velocity) and radial 
;     velocity shift by generating a grid and fitting every value. The output
;     file contains a line for every model on the grid of Teff/logg/fsed/vsini/RV
;     with the corresponding chi square values and degrees of freedom so that
;     you can do your desired statistics.
;     
;     For details please see:
;          Tannock M. E., et al., 2021, AJ, 161, 224      
;              https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;          Tannock M. E., et al., 2022, MNRAS, 514, 3160  
;              https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     If you make use to this code, please cite the above two publications.
;          
;     Please report all errors and bugs to mtannock@uwo.ca
;
; INPUT PARAMETERS:
;     CONFIGFILEPATHANDNAME - a string containing the path and filename of the  
;          configuration file, including the full path to it. See below for the 
;          format for the configuration file.
;     
;     Your input data must be previously corrected for the barycentric velocity.
;
; OPTIONAL INPUT PARAMETERS:
;     MAKEFIGURES - a flag to set if you want the code to generate a figure for
;          the best fitting model on the grid (only makes one figure). OPENS
;          A NEW WINDOW FOR THE PLOT (and also closes it).
;    
; OUTPUT:
;    A file with the naming format:
;    outfilepath/objectname_rundate_wavelengthregionname.dat
;    where outfilepath, objectname, rundate, and wavelengthregionname are set in
;    the configuration file (see below for format).
;    
; CALLING SEQUENCE
;     To call without generating figures:
;          FITMODELGRID_FINAL, '/path/configurationfile.txt'
;     To call and generate figures:
;          FITMODELGRID_FINAL, '/path/configurationfile.txt', /makefigures
;
; NOTES:
;     Calls the following custom IDL programs/functions written by Megan Tannock:
;       broadenforvsini_final.pro
;       chisquarestats_final.pro
;       chopregion_final.pro
;       contiuumdiv_polynomial_final.pro
;       getmodelnames_final.pro
;       getmodelparameters_final.pro
;       getregions_final.pro
;       maketelluricmask_final.pro
;       readconfigfile_final.pro
;       readdata_final.pro
;       readmodels_final.pro
;       resamplemodel_final.pro
;       savebestmodel_final.pro
;       scalemodelanddata_final.pro
;       
;     You will also need the IDL Astronomy User's Library: 
;     https://idlastro.gsfc.nasa.gov/
;     
;     To use the telluric masking function, you need to download the two files:
;     psg_alldefault_JHKband_data.txt and ohlines.dat. Put them wherever you 
;     want, and set their location as the psgpath keyword in the configuration
;     file (see below).
;
;
;
; CONFIGURATION FILE FORMAT:
;
;   The format of the configuration file must include the '='
;   because '=' is used to split the string. The configuration file
;   keywords MUST be in the following order:
;   
;     objectname = The name of your observed object (or whatever you want to 
;          identify it by), must be a string with no spaces
;     objectpath = The path to your observed spectrum data
;     objectfilename = The name of your observed spectrum's flux file. Your 
;          input data must be previously corrected for the barycentric velocity.
;     objecterrorname = The name of your observed spectrum's error file (may 
;          be the same file as above). Your input data must be previously 
;          corrected for the barycentric velocity.
;     objectinstrument = The name of the instrument you used, so you can read 
;          the data in correctly. Options are: FIRE, GNIRS, or IGRINS. If your
;          data differs from these formats, add a new case to read the data in. 
;          Make sure the flux is in F_lambda units and the wavelength is in 
;          microns. You can add these conversions in readdata_final.pro, you do
;          not have to convert the units before running this code.
;     modeltype = The name of the model family you want to fit to. Options
;          are: MORLEY, SAUMON, SONORA-BOBCAT, BOBCAT-ALTA or BTSETTL-CIFIST2011. 
;          If you have a different model, add a new case to read the model in. Make 
;          sure the flux is in F_lambda units and the wavelength is in microns.
;          You can add these conversions in readmodels_final.pro, you do not have
;          to convert the units before running this code.
;     modelpath = The path to your models
;     modelnamesfile = The path and name of a text file which contains the name of
;          each model you wish to fit to.
;     wavelengthregionname = A name for the region you want to fit to, for 
;          example: Jband. This is to name the output file. Must be a string 
;          with no spaces.
;     wavelengthregion = The wavelength coverage you want to fit to. Must be in
;          the format 1.23,1.56 with the comma included. Units are microns.
;     normalizationregion = The wavelength coverage you want to normalize to. 
;          Must be in the format 1.25,1.50 with the comma included. Units are 
;          microns.
;     dividecontinuum = You can divide out the continuum if you wish. Set this 
;         to the degree of the polynomial you want to fit. If you don't want to 
;         divide the continuum, use 0
;     outfilepath = The path where you would like the output file written to.
;     rundate = The date, used for the output file's name. Must be a string
;          with no spaces.
;     vsinistartval = The start value for the range of vsini value you want to
;          test. Units are km/s.
;     vsiniendval = The end value for the range of vsini value you want to test.
;          Units are km/s.
;     vsinistep = The step size for the range of vsini value you want to test
;          Units are km/s.
;     rvshiftstartval = The start value for the range of RV value you want to
;          test. Units are km/s.
;     rvshiftendval = The end value for the range of RV value you want to test.
;          Units are km/s.
;     rvstep = The step size for the range of RV value you want to test. Units
;          are km/s.
;     limbdarkeningcoefficient = Numeric scalar giving the limb-darkening 
;          coefficient. Use 0.6 as the default value. This is used in 
;          lsf_rotate.pro, see documentation for details: 
;          https://idlastro.gsfc.nasa.gov/ftp/pro/astro/lsf_rotate.pro
;     erroradjust = You can add an extra constant to be added in quadrature
;          to your observed spectrum's uncertainty. This can be used to account
;          for uncertainty in the models (which do not come with uncertainties).
;          You can use trial an error to find the value which gives a reduced
;          chi square of 1.
;     psgpath = The path to the PSG transmittance spectrum, if you're masking the
;          tellurics. If you're not masking, enter your oufilepath.
;     masktellurics = You can apply a mask to the wavelengths where strong 
;          telluric features are present. Enter the value (in %) of a cut off of 
;          the model transmittance to mask. For example: Mask all lines which
;          have less than 30% transmittance - use value 30. The mask is based
;          on the atmospheric transmittance from the Planetary Spectrum 
;          Generator: https://psg.gsfc.nasa.gov/
;          If you do not want to use a mask, enter 0.
;     scaletype = This code can do some fancy scaling and applying offsets. Options
;          are: None, Scale, ScaleAndOffset, Linear, LinearAndOffset, Quadratic, 
;          QuadraticAndOffset. See SCALEMODELANDDATA_FINAL.PRO for details.
;     bcv = The barycentric velocity correction that was applied to your data in km/s. 
;     nkernels = If your model's resolution changes a lot across the wavelengths
;          of interest, you may end up overbroadening or underbroadening
;          the ends of the spectrum by using the same kernel across the whole
;          spectrum. You can split the spectrum in to N sections and broadening each 
;          section with its own kernel, then stitching the resulting spectrum back 
;          together. If you do not want to do this, set numkernels=1.
;   
;   
;   The following shows an EXAMPLE OF THE CONFIGURATION FILE. 
;     objectname = 2MASS0348
;     objectpath = ../../mnt/data/megan/2M0348_Spectra/
;     objectfilename = J0348-6002_F.fits
;     objecterrorname = J0348-6002_E.fits
;     objectinstrument = FIRE_1
;     modeltype = MORLEY
;     modelpath = ../../mnt/data/megan/MorleyModels_2012/
;     modelnamesfile = ../../mnt/data/megan/MorleyModelFits/2MASS0348/Nov1_2019/MorleyModelNames.txt
;     wavelengthregionname = Jfull
;     wavelengthregion = 1.14,1.35
;     normalizationregion = 1.26,1.28
;     dividecontinuum = 0
;     outfilepath = ../../mnt/data/megan/MorleyModelFits/2MASS0348/Nov1_2019/
;     rundate = Nov1_2019
;     vsinistartval = 70
;     vsiniendval = 115
;     vsinistep = 0.1
;     rvshiftstartval = -30
;     rvshiftendval = 10
;     rvstep = 0.1
;     limbdarkeningcoefficient = 0.6
;     erroradjust = 5
;     psgpath = /Volumes/Storage/Grad_School/IGRINS_data/
;     masktellurics = 30
;     scaletype = Quadratic
;     bcv = 1.5
;     nkernels = 1
;

pro fitmodelgrid_final, configfilepathandname, MAKEFIGURES = makefigures

  print, 'If you make use of this code, please cite the following two publications:'
  print, ' Tannock M. E., et al., 2021, AJ, 161, 224'
  print, ' Tannock M. E., et al., 2022, MNRAS, 514, 3160'

  starttime = systime()
  print, "fitmodelgrid_final.pro: start time = " + string(starttime)

  ;;;;;;;;;;;;;;;
  ; READ IN ALL INFORMATION FROM A CONFIGURATION FILE

  ; get the parameters from the configuration file
  print, 'fitmodelgrid_final.pro: Reading in configuration file.'
  print
  keywords = readconfigfile_final(configfilepathandname)
  print
  print, 'fitmodelgrid_final.pro: Starting fitting...'

  ; set the keywords for use in these codes
  ; could just index the paratmeters variable, but I did this to avoid any confusion or mistakes
  objectname = keywords[0]
  objectpath = keywords[1]
  objectfilename = keywords[2]
  objecterrorname = keywords[3]
  objectinstrument = keywords[4]
  modeltype = keywords[5]
  modelpath = keywords[6]
  modelnamesfile = keywords[7]
  wavelengthregionname = keywords[8]
  wavelengthregion = keywords[9]
  normalizationregion = keywords[10]
  dividecontinuum = keywords[11]
  outfilepath = keywords[12]
  rundate = keywords[13]
  vsinistartval = keywords[14]
  vsiniendval = keywords[15]
  vsinistep = keywords[16]
  rvshiftstartval = keywords[17]
  rvshiftendval = keywords[18]
  rvshiftstep = keywords[19]
  limbdarkeningcoefficient = keywords[20]
  erroradjust = keywords[21]
  masktellurics = keywords[22]
  psgpath = keywords[23]
  scaletype = keywords[24]
  bcv = keywords[25]
  nkernels = keywords[26]

  ;;;;;;;;;;;;;;;

  ; Other constants:
  c = 2.99792458d5 ; km/s - speed of light


  ;;;;;;;;;;;;;;;
  ; SET UP AN ARRAY OF VSINI VALUES
  vsinilength = round(( double(vsiniendval) - double(vsinistartval) ) / double(vsinistep))
  vsinis = ((dindgen(double(vsinilength + 1.)) ) * double(vsinistep) ) + double(vsinistartval)

  print, 'vsinis are: (km/s)'
  print, vsinis

  ;;;;;;;;;;;;;;;
  ; SET UP AN ARRAY OF RV SHIFT VALUES in number of array elements
  rvlength = round(( double(rvshiftendval) - double(rvshiftstartval) ) / double(rvshiftstep))
  shifts = ((dindgen(double(rvlength + 1.)) ) * double(rvshiftstep) ) + double(rvshiftstartval)
  rvs = shifts

  print, 'rv shifts are: (km/s)'
  print, shifts


  ;;;;;;;;;;;;;;;
  ; DETERMINE WHICH PARTS OF THE SPECTRUM WE ARE USING
  regions = getregions_final(wavelengthregionname, wavelengthregion, dividecontinuum)


  ;;;;;;;;;;;;;;;
  ; READ IN THE DATA FILE
  slitwidth = 1 ; Set up this parameter. We will fill it with the correct value in with readdata_final.pro
  datavalues = readdata_final(objectinstrument, objectpath, objectfilename, objecterrorname, slitwidth)
  ; datavalues is an array of arrays: [[flux], [error], [lam]]


  ;;;;;;;;;;;;;;;;;;
  ; Apply a mask for the OH emission telluric lines

  ; PSG MASK ONLY AVAILABLE FOR J, H AND K BANDS
  ; Check if we're applying the mask:
  masktellurics = uint(masktellurics) ; if 0, don't mask, if anything else, do mask
  bcv = float(bcv)

  IF (masktellurics eq 0) THEN BEGIN
    print, 'fitmodelgrid_final.pro: No mask for tellurics, leave data as is.'
  ENDIF ELSE BEGIN
    ; read in the Planetary Spectrum Generator file and OH line list for making a mask:

    ; read in the PSG:
    psgname = 'psg_alldefault_JHKband_data.txt'
    ; # Wave/freq Total H2O CO2 O3 N2O CO CH4 O2 N2 Rayleigh CIA
    fmt = 'D,D' ; format of filename
    readcol, psgpath + psgname, FORMAT = fmt, inpsglam, intransmittance, SKIPLINE=14, /SILENT ; Read in the data - there are many more columns, but we only need the first two

    ; read in the OH line list
    ohfilename = 'ohlines.dat'
    fmt = 'D,D'
    readcol, psgpath + ohfilename, FORMAT = fmt, inohlam, inohstrength, COMMENT='#' ; Read in the data
    inohlam = inohlam / 10000. ; convert Angstroms to um

    mask =  maketelluricmask_final(intransmittance, inpsglam, inohstrength, inohlam, datavalues[*,1], datavalues[*,0], bcv, masktellurics/100., slitwidth)
    ; mask is an array of 1s and NaNs

    ; multiply the flux by the mask
    datavalues[*,1] = datavalues[*,1] * mask ; mask the flux
    datavalues[*,2] = datavalues[*,2] * mask ; mask the uncertainty

  ENDELSE



  ;;;;;;;;;
  ; CHOP OUT THE REGION OF INTEREST IN BOTH THE DATA AND MODEL

  ; get the lower and upper limits on the current region
  lowerlam = wavelengthregion[0]
  upperlam = wavelengthregion[1]

  ; do the chopping
  datavalues_chop = chopregion_final(lowerlam, upperlam, datavalues[*,0], datavalues[*,1])
  errorvalues_chop = chopregion_final(lowerlam, upperlam, datavalues[*,0], datavalues[*,2])

  ; change the names of the lambda arrays, just so they are a little easier to read
  datalam_match = datavalues_chop[*,0]


  ;;;;;;;;;
  ; NORMALIZATION AND DIVIDE OUT CONTINUUM, IF NECESSARY
  print, 'fitmodelgrid_final.pro: Normalizing data...'
  normalizationregions = getregions_final(wavelengthregionname, normalizationregion, dividecontinuum)
  normindex = where(datalam_match gt normalizationregion[0] and datalam_match lt normalizationregion[1])
  normvalue = mean(datavalues_chop[normindex,1], /NAN)

  dataflux_match = datavalues_chop[*,1] / normvalue
  error_match = errorvalues_chop[*,1] / normvalue
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; divide out continuum if requested...
  if dividecontinuum eq 0 then begin ; check if continuum division key word is set in the config file
    ; do nothing
    print, 'fitmodelgrid_final.pro: Do not do continuum fit and divide for DATA'
  endif else begin
    print, 'fitmodelgrid_final.pro: Fit continuum and divide for DATA'
    ; data :
    datafit = contiuumdiv_polynomial_final(datalam_match, dataflux_match, dividecontinuum) ; obtain a fit to the continuum
    dataflux_match = dataflux_match / datafit ; divide by that fit
    error_match = error_match / datafit ; divide by that fit
  endelse



  ;;;;;;;;;
  ; ADD EXTRA UNCERTAINTY IN QUADRATURE
  print, 'fitmodelgrid_final.pro: adding in extra CONSTANT uncertainty of ' + string(erroradjust) + ' (in quadrature: new error = sqrt(error^2 + constant^2))'
  error_match = sqrt( (error_match*error_match) + (float(erroradjust)*float(erroradjust)) )


  ;;;;;;;;
  ; MAKE OUTPUT FILE TO PUT THE REDUCED CHI SQUARE FITTING INFORMATION IN, for each region.
  ; There is a single output file for each region, instead of one file with many regions
  ; We're just setting up the column headers here. Information to be added below.
  openw,lun, outfilepath + objectname + '_' + rundate + '_' +wavelengthregionname + '.dat', /get_lun, WIDTH=250, /APPEND
  printf, lun, '# Config file was: ' + configfilepathandname
  printf, lun, '# Input keywords were: ' + configfilepathandname
  FOR i = 0, n_elements(keywords)-1 DO printf, lun, '#     ' + keywords[i]
  printf, lun, '#'
  
  IF (masktellurics eq 0) THEN begin
    printf, lun, '# NO TELLURIC LINE MASK APPLIED'
  ENDIF ELSE BEGIN
    printf, lun, '# TELLURIC LINE MASK APPLIED, <'+strtrim(masktellurics,1)+'% TRANSMISSION (from PSG) AND OH EMISSION LINES'
  ENDELSE
  
  printf, lun, '#'
  CASE scaletype OF
    'None': begin
      printf, lun, '# Filename                                  T_eff             log(g)         f_sed             chisquare       d.o.f.             reduchisquare    vsini(km/s)     rv(km/s)'
    end
    'Scale': begin
      printf, lun, '# Filename                                  T_eff             log(g)         f_sed             chisquare       d.o.f.             reduchisquare    vsini(km/s)     rv(km/s)       scale'
    end
    'ScaleAndOffset': begin
      printf, lun, '# Filename                                  T_eff             log(g)         f_sed             chisquare       d.o.f.             reduchisquare    vsini(km/s)     rv(km/s)       scale        offset'
    end
    'Linear': begin
      printf, lun, '# Filename                                  T_eff             log(g)         f_sed             chisquare       d.o.f.             reduchisquare    vsini(km/s)     rv(km/s)       slope        intercept'
    end
    'LinearAndOffset': begin
      printf, lun, '# Filename                                  T_eff             log(g)         f_sed             chisquare       d.o.f.             reduchisquare    vsini(km/s)     rv(km/s)       slope        intercept       offset'
    end
    'Quadratic': begin
        printf, lun, '# Filename                                  T_eff             log(g)         f_sed             chisquare       d.o.f.             reduchisquare    vsini(km/s)     rv(km/s)       a        b       c'
    end
    'QuadraticAndOffset': begin
        printf, lun, '# Filename                                  T_eff             log(g)         f_sed             chisquare       d.o.f.             reduchisquare    vsini(km/s)     rv(km/s)       a        b       c       offset'
    end
  ENDCASE
  Free_lun, lun



  ;;;;;;;;;;;;;;;
  ; OBTAIN THE LIST OF MODEL NAMES FROM THE FILE SPECIFIED IN THE CONFIGURATION FILE
  modelnames = getmodelnames_final(modelnamesfile)
  ; Now we have a list of the model file names. We need to loop through each one.
  print, 'fitmodelgrid_final.pro: Reading in models from ' + modelnamesfile

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;; HERE WE BEGIN A SERIES OF NESTED FOR LOOPS...


  ; GO THROUGH THE MODELS ONE AT A TIME. go through all steps for one model, then move on.
  for m=0,n_elements(modelnames)-1 do begin

    ; print some useful information
    print, 'fitmodelgrid_final.pro: Starting model ' + modelnames[m] + ', model number ' + strtrim(m+1,1) + '/' + strtrim(n_elements(modelnames),1), '   ', systime()

    ;;;;;;;;;
    ; GET THIS MODEL'S PARAMETERS from it's filename
    modelparams = getmodelparameters_final(modeltype, modelnames[m]) ; modelparams = [temperature, g, fsed]

    ;;;;;;;;;
    ; READ IN THE MODEL
    modelvalues = readmodels_final(modeltype, modelpath, modelnames[m])
    ; modelvalues is an array of arrays: [[flux], [lam]]


    ;;;;;;;;;
    ; CHOP OUT THE REGION OF INTEREST IN BOTH THE DATA AND MODEL
    ; Keep some excess on the model, so that shifting around for RV works
    modelvalues_chop = chopregion_final(lowerlam-0.02, upperlam+0.02, modelvalues[*,0], modelvalues[*,1])
    
    ; change the names of the arrays, just so they are a little easier to read
    modelflux_match = modelvalues_chop[*,1]
    modellam_match = modelvalues_chop[*,0]


    ;;;;;;;;;
    ; DIVIDE OUT CONTINUUM, IF NECESSARY
    if dividecontinuum eq 0 then begin ; check if continuum division key word is set in the config file
      ; do nothing
      print, 'fitmodelgrid_final.pro: Do not do continuum fit and divide for MODEL'
    endif else begin
      ; model :
      print, 'fitmodelgrid_final.pro: Fitting continuum and dividing for MODEL'
      modelfit = contiuumdiv_polynomial_final(modellam_match, modelflux_match) ; obtain a fit to the continuum
      modelflux_match = modelflux_match / modelfit ; divide by that fit
    endelse



    ;;;;;;;;;
    ; LOOP THROUGH THE VSINI VALUES
    for v=0,n_elements(vsinis)-1 do begin
      
      ;;;;;;;;;
      ; BROADEN THE MODEL TO THE VSINI
      ; Broaden with rotation kernel of Gray (1992)
      modelflux_broadened = broadenforvsini_final(modellam_match, modelflux_match, vsinis[v], nkernels, limbdarkeningcoefficient)
 
      ;;;;;;;;;;;;;;;;;;;;;;;;;;; end of broadening part of code


      ;;;;;;;;;
      ; LOOP THROUGH THE RV SHIFT VALUES (array is called 'shifts')
      for s=0,n_elements(shifts)-1 do begin

        ;;;;;;;;;
        ; APPLY THE RV SHIFT TO THE MODEL
        modellam_shifted = modellam_match * (1. + (shifts[s] / c) ) ; c = speed of light

        ;;;;;;;;;;;;;;;;;;;;;;;;;;; end of shifting part of code


        ;;;;;;;;;
        ; Now for some finishing touches before saving out the results!

        ;;;;;;;;;
        ; MATCH THE RESOLUTION OF THE MODEL TO THE DATA
        modelflux_resmatch = resamplemodel_final(datalam_match, modellam_shifted, modelflux_broadened)
        ; rename the wavelength array so we know we have matched the resolution to the data
        modellam_resmatch = datalam_match
  
        ; Normalize the model to the normalization region defined in the config file
        normindex = where(modellam_resmatch gt normalizationregion[0] and modellam_resmatch lt normalizationregion[1])
        modelflux_resmatch = modelflux_resmatch / mean(modelflux_resmatch[normindex], /NAN)


        ; Now do any fancy scaling or offsets you like:
        dataflux_final = dataflux_match ; we're going to overwrite this, so let's just keep the old one just in case
        error_final = error_match ; we're going to overwrite this, so let's just keep the old one just in case
        modelflux_final = modelflux_resmatch ; we're going to overwrite this, so let's just keep the old one just in case
        constants = scalemodelanddata_final(datalam_match, dataflux_final, error_final, modelflux_final, scaletype) ; returns the constants used for the scaling/offsets


        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ; CALCULATE FINAL REDUCED CHI SQUARE
        chisquarestatsarray = chisquarestats_final(dataflux_final, error_final, modelflux_final)
        chisquarevalue = chisquarestatsarray[0] ; chi square
        reducedchisquarevalue = chisquarestatsarray[1] ; reduced chi square
        dof = chisquarestatsarray[2] ; degrees of freedom

        ;;;;;;;;;
        ; WRITE REDUCED CHI SQUARE AND OTHER PARAMETERS TO OUTPUT FILE
        openw,lun, outfilepath + objectname + '_' + rundate + '_' +wavelengthregionname + '.dat', /get_lun, WIDTH=250, /APPEND
        
        CASE scaletype OF
          'None': begin
            printf, lun, modelnames[m], '   ', trim(modelparams[0]), '    ', trim(modelparams[1]), '    ', trim(modelparams[2]), '    ', $
              chisquarevalue, dof, reducedchisquarevalue, vsinis[v], '  ', shifts[s]
          end
          'Scale': begin
            printf, lun, modelnames[m], '   ', trim(modelparams[0]), '    ', trim(modelparams[1]), '    ', trim(modelparams[2]), '    ', $
              chisquarevalue, dof, reducedchisquarevalue, vsinis[v], '  ', shifts[s], ' ', $
              constants[0]
          end
          'ScaleAndOffset': begin
            printf, lun, modelnames[m], '   ', trim(modelparams[0]), '    ', trim(modelparams[1]), '    ', trim(modelparams[2]), '    ', $
              chisquarevalue, dof, reducedchisquarevalue, vsinis[v], '  ', shifts[s], ' ', $
              constants[0], constants[1]
          end
          'Linear': begin
            printf, lun, modelnames[m], '   ', trim(modelparams[0]), '    ', trim(modelparams[1]), '    ', trim(modelparams[2]), '    ', $
              chisquarevalue, dof, reducedchisquarevalue, vsinis[v], '  ', shifts[s], ' ', $
              constants[0], constants[1]
          end
          'LinearAndOffset': begin
            printf, lun, modelnames[m], '   ', trim(modelparams[0]), '    ', trim(modelparams[1]), '    ', trim(modelparams[2]), '    ', $
              chisquarevalue, dof, reducedchisquarevalue, vsinis[v], '  ', shifts[s], ' ', $
              constants[0], constants[1], constants[2]
          end 
          'Quadratic': begin
            printf, lun, modelnames[m], '   ', trim(modelparams[0]), '    ', trim(modelparams[1]), '    ', trim(modelparams[2]), '    ', $
              chisquarevalue, dof, reducedchisquarevalue, vsinis[v], '  ', shifts[s], ' ', $
              constants[0], constants[1], constants[2]
          end
          'QuadraticAndOffset': begin
            printf, lun, modelnames[m], '   ', trim(modelparams[0]), '    ', trim(modelparams[1]), '    ', trim(modelparams[2]), '    ', $
              chisquarevalue, dof, reducedchisquarevalue, vsinis[v], '  ', shifts[s], ' ', $
              constants[0], constants[1], constants[2], constants[3]
          end         
        ENDCASE
        
        Free_lun, lun
        
      endfor ; end loop through RV shift values

    endfor ; end loop through the vsini values

  endfor ; end loop through model names



  print
  print, 'fitmodelgrid_final.pro: FITTING GRID COMPLETE.'
  print

  print, 'fitmodelgrid_final.pro: FITTING COMPLETE FOR INPUTS IN CONFIGURATION FILE ' + configfilepathandname
  print, 'fitmodelgrid_final.pro: OUTPUTS SAVED IN DIRECTORY: ' + outfilepath
  print, 'fitmodelgrid_final.pro: start time = ' + string(starttime)
  print, 'fitmodelgrid_final.pro: finish time = ' + systime()


  if keyword_set(makefigures) then begin
    print, 'fitmodelgrid_final.pro: MAKEFIGURES keyword set.'
    print, 'fitmodelgrid_final.pro: Save the best fitting model spectrum as a text file with the data to create a nice figure.'
    print, 'fitmodelgrid_final.pro: calling SAVEBESTMODEL_FINAL.PRO.'
    savebestmodel_final, configfilepathandname
    print
    print, 'fitmodelgrid_final.pro: time = ' + systime()    
  endif else begin
    print, 'fitmodelgrid_final.pro: MAKEFIGURES keyword not set.'
    print, 'fitmodelgrid_final.pro: Do not make figures'
  endelse

  print
  print, 'All done.'
  print
  print, 'If you make use of this code, please cite the following two publications:'
  print, ' Tannock M. E., et al., 2021, AJ, 161, 224'
  print, ' Tannock M. E., et al., 2022, MNRAS, 514, 3160'

end
