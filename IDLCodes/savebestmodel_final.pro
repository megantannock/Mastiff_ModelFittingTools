; NAME: 
;      SAVEBESTMODEL_FINAL.PRO
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;     For use with FITMODELGRID_FINAL.PRO
;
;     This code repeats all of the steps performed in FITMODELGRID_FINAL.PRO
;     but for the best fitting model, vsini, and RV from running
;     FITMODELGRID_FINAL.PRO. This code produces a figure (png, eps, and pdf)
;     of the best fitting model, and saves the data in to a text file. All of
;     the scaling information and chi square values are also saved.
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     
; INPUT PARAMETERS:
;    configfilepathandname - the path and filename of the configuration
;          file used with FITMODELGRID_FINAL.PRO
;
; OUTPUTS: 
;    OPENS A NEW WINDOW to display the plot, and also closes it.
;    Produces a figure (png, eps, and pdf) of the best fitting model, and 
;    saves the data in to a text file. All of the scaling information and 
;    chi square values are also saved.
;
; CALLING SEQUENCE:
;    savebestmodel_final, '/path/config.txt'
;

pro savebestmodel_final, configfilepathandname

  ;;;;;;;;;;;;;;;
  ; READ IN ALL INFORMATION FROM A CONFIGURATION FILE
  ; for config file: must put the file containing the names of the models (modelnamesfile)
  ;                  to be used in the same directory as the config file
  ; get the keywords from the configuration file
  keywords = readconfigfile(configfilepathandname, /silent)

  ; set the parameters for use in these codes
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

  
  ; Read in the output from fitmodelgrid.pro to determine what our parameters will be, which model to use
  ; find the best fitting model from the minimum chisquare value

  ; read in the data
  ;region, objectname, dateval, path
  inputfilename = objectname + '_' + rundate + '_' + wavelengthregionname + '.dat'
  outfilename = objectname + '_' + rundate + '_' + wavelengthregionname

  print, 'savebestmodel_final.pro: Reading ' + outfilepath + inputfilename
  ;fmt = 'A,I,F,I,D,D,D,D,D' ; format of filename
  ;readcol, outfilepath + inputfilename, FORMAT = fmt, bestmodelname, bestT, bestlogg, bestf, bestchi, bestdof, bestredchi, bestvsini, bestrvshift, /SILENT, COMMENT='#' ; Read in the data
  fmt = 'A,I,F,I,I,D,D,D,D,D,D,D,D' ; format of filename
  readcol, outfilepath + inputfilename, FORMAT = fmt, bestmodelname, bestT, bestlogg, bestf, bestk, bestchi, bestdof, bestredchi, bestvsini, bestrvshift, bestqa, bestqb, bestqc, /SILENT, COMMENT='#' ; Read in the data
  ;# Filename                                  T_eff             log(g)         f_sed          kzz        chisquare       d.o.f.             reduchisquare    vsini(km/s)     rv(km/s)       a        b       c
  bestindex = where(bestchi eq min(bestchi))

  print, 'best model: ' + bestmodelname[bestindex] + ', vsini=' + strtrim(bestvsini[bestindex],1) + ', rv=' + strtrim(bestrvshift[bestindex],1) + ', redchisquare=' + strtrim(bestredchi[bestindex],1)

  ; check if the output directory exists. If not, make it.
  if ~FILE_TEST(outfilepath + 'figures/', /DIRECTORY) then FILE_MKDIR, outfilepath + 'figures/'

  ; Now repeat the steps from fitmodel grid...


  ;;;;;;;;;;;;;;;
  ; Other constants:
  c = 2.99792458d5 ; km/s - speed of light

  ;;;;;;;;;;;;;;;
  ; SET UP AN ARRAY OF VSINI VALUES
  ; instead of the grid, use the value which gives the lowest chi square
  vsinis = bestvsini[bestindex]

  ;;;;;;;;;;;;;;;
  ; SET UP AN ARRAY OF RV SHIFT VALUES in number of array elements
  ; instead of the grid, use the value which gives the lowest chi square
  shifts = bestrvshift[bestindex]


  ;;;;;;;;;;;;;;;
  ; DETERMINE WHICH PARTS OF THE SPECTRUM WE ARE USING
  regions = getregions_final(wavelengthregionname, wavelengthregion, dividecontinuum)

  ;;;;;;;;;;;;;;;
  ; READ IN THE DATA FILE
  slitwidth = 1 ; set the width of the slit in pixels - this will be re-set in the readdata_final function,
  ; depending on what instrument you're using
  datavalues = readdata_final(objectinstrument, objectpath, objectfilename, objecterrorname, slitwidth)
  ; datavalues is an array of arrays: [[flux], [error], [lam]]


  ;;;;;;;;;;;;;;;;;;
  ; Apply a mask for the OH emission telluric lines

  ; PSG MASK ONLY AVAILABLE FOR J, H AND K BANDS
  ; Check if we're applying the mask:
  masktellurics = uint(masktellurics) ; if 0, don't mask, if anything else, do mask
  bcv = float(bcv)

  IF (masktellurics eq 0) THEN BEGIN
    print, 'savebestmodel_final.pro: No mask for tellurics, leave data as is.'
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

    mask =  maketelluricmask_final(intransmittance, inpsglam, inohstrength, inohlam, datavalues[*,1], datavalues[*,0], bcv, masktellurics/100., slitwidth, objectname)
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
  print, 'savebestmodel_final.pro: Normalizing data...'
  normalizationregions = getregions_final(wavelengthregionname, normalizationregion, dividecontinuum)
  normindex = where(datalam_match gt normalizationregion[0] and datalam_match lt normalizationregion[1])
  normvalue = mean(datavalues_chop[normindex,1], /NAN)

  dataflux_match = datavalues_chop[*,1] / normvalue
  error_match = errorvalues_chop[*,1] / normvalue


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; divide out continuum if requested...
  if dividecontinuum eq 0 then begin ; check if continuum division key word is set in the config file
    ; do nothing
    print, 'savebestmodel_final.pro: Do not do continuum fit and divide for DATA'
  endif else begin
    print, 'savebestmodel_final.pro: Fit continuum and divide for DATA'
    ; data :
    datafit = contiuumdiv_polynomial_final(datalam_match, dataflux_match, dividecontinuum) ; obtain a fit to the continuum
    dataflux_match = dataflux_match / datafit ; divide by that fit
    error_match = error_match / datafit ; divide by that fit
  endelse




  ;;;;;;;;;
  ; ADD EXTRA UNCERTAINTY IN QUADRATURE
  print, 'savebestmodel_final.pro: adding in extra CONSTANT uncertainty of ' + string(erroradjust) + ' (in quadrature: new error = sqrt(error^2 + constant^2))'
  error_match = sqrt( (error_match*error_match) + (float(erroradjust)*float(erroradjust)) )


  ;;;;;;;;;;;;;;;
  ; Use the best model we found:
  modelnames = [bestmodelname[bestindex]]
  ; Now we have a list of the model file names. We need to loop through each one.
  print, 'savebestmodel_final.pro: using model: ' + bestmodelname[bestindex]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Begin the fitting

  ;;;;;;;;;
  ; GET THIS MODEL'S PARAMETERS from it's filename
  modelparams = getmodelparameters_final(modeltype, modelnames) ; modelparams = [temperature, g, fsed]

  ;;;;;;;;;
  ; READ IN THE MODEL
  modelvalues = readmodels_final(modeltype, modelpath, modelnames)
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
    print, 'savebestmodel_final.pro: Do not do continuum fit and divide for MODEL'
  endif else begin
    ; model :
    print, 'savebestmodel_final.pro: Fitting continuum and dividing for MODEL'
    modelfit = contiuumdiv_polynomial_final(modellam_match, modelflux_match) ; obtain a fit to the continuum
    modelflux_match = modelflux_match / modelfit ; divide by that fit
  endelse


  ;;;;;;;;;
  ; BROADEN THE MODEL TO THE VSINI
  ; Broaden with rotation kernel of Gray (1992)
  modelflux_broadened = broadenforvsini_final(modellam_match, modelflux_match, vsinis[0], nkernels, limbdarkeningcoefficient)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;; end of broadening part of code


  ;;;;;;;;;
  ; APPLY THE RV SHIFT TO THE MODEL
  modellam_shifted = modellam_match * (1. + (shifts[0] / c) ) ; c = speed of light
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


  ;;;;;;;;;;
  ; SAVE SPECTRUM WITH MODEL AS A PLOT
  ; Save a plot to check the fit and to see what is driving the chisquare
  chisquarespec = ((dataflux_final - modelflux_final)*(dataflux_final - modelflux_final)) / (error_final*error_final)
  
  p1 = plot(datalam_match, dataflux_final, color='red', xrange=[lowerlam-0.002,upperlam+0.002], yrange=[0,max(dataflux_final)+0.1], $
    xtitle='Wavelength (um)', ytitle = 'Normalized Flux', layout=[1,3,1], DIM=[1000,700], name='Data', $
    title=objectname + ', ' + wavelengthregionname + ', ' + modeltype + ' ' + modelnames + ', vsini=' + trim(vsinis[0]) + ' km/s, rv=' + trim(shifts[0]) + ' km/s, $\chi^2_R$ = ' + STRING(reducedchisquarevalue, FORMAT='(F8.3)'))
    p2 = plot(datalam_match, modelflux_final, /OVERPLOT, color='blue', name='Model')
  p3 = plot(datalam_match, error_final, /OVERPLOT, color='gray', name='Error')
  leg = LEGEND(TARGET=[p1,p2,p3], POSITION=[0.85,0.71], /NORMAL, /AUTO_TEXT_COLOR, VERTICAL_SPACING=0.015)
  p4 = plot(datalam_match, ( dataflux_final-modelflux_final ), xtitle='Wavelength (um)', ytitle='Residuals', xrange=[lowerlam-0.002,upperlam+0.002], $
    yrange=[-1.0 * ((max(dataflux_final)+0.1)/2.0),((max(dataflux_final)+0.1)/2.0) ], /current, layout=[1,3,2])
  line = plot([0,10],[0,0], color='grey', /overplot)
  p5 = plot(datalam_match, chisquarespec, xtitle='Wavelength (um)', ytitle='Chi square contribution', xrange=[lowerlam-0.002,upperlam+0.002],$
    /current, layout=[1,3,3])
  p5.save, outfilepath + 'figures/' + outfilename+'_bestfit_figure.png'
  p5.save, outfilepath + 'figures/' + outfilename+'_bestfit_figure.pdf'
  p5.save, outfilepath + 'figures/' + outfilename+'_bestfit_figure.eps'
  p5.close

  ;;;;;;;
  ; SAVE SPECTRUM WITH MODEL AS A TEXT FILE
  openw,lun, outfilepath + 'figures/' + outfilename + '_bestfit_figuredata.dat', /get_lun, WIDTH=250, /APPEND
  printf, lun, '# SPECTRUM - DATA AND BEST FITTING MODEL.'
  printf, lun, '# FOR PLOTTING'
  printf, lun, '#'
  printf, lun, '# Config file was: ' + configfilepathandname
  printf, lun, '# Input keywords were: ' + configfilepathandname
  FOR i = 0, n_elements(keywords)-1 DO printf, lun, '#     ' + keywords[i]
  printf, lun, '#'
  IF (masktellurics eq 1) THEN printf, lun, '# TELLURIC LINE MASK APPLIED, <35% TRANSMISSION (from PSG) AND OH EMISSION LINES (from IGRINS documentation)'
  IF (masktellurics eq 0) THEN printf, lun, '# NO TELLURIC LINE MASK APPLIED'
  printf, lun, '# MODEL IS: ' + modelnames
  printf, lun, '# VSINI IS: ' + strtrim(vsinis[0],1)
  printf, lun, '# RV IS: ' + strtrim(shifts[0],1)
  
  CASE scaletype OF
    'None': begin
      printf, lun, '# Scaled model and data independently'
    end
    'Scale': begin
      printf, lun, '# DATA divided by factor -- factor: ' + strtrim(constants[0],1)
    end
    'ScaleAndOffset': begin
      printf, lun, '# (DATA+offset) divided by factor -- offset: ' + strtrim(constants[1],1)
      printf, lun, '# (DATA+offset) divided by factor -- factor: ' + strtrim(constants[0],1)
    end
    'Linear': begin
      printf, lun, '# DATA divided by linear (bx + c) -- slope: ' + strtrim(constants[0],1)
      printf, lun, '# DATA divided by linear (bx + c) -- intercept: ' + strtrim(constants[1],1)
    end
    'LinearAndOffset': begin
      printf, lun, '# (DATA+offset) divided by linear (bx + c) -- offset: ' + strtrim(constants[2],1)
      printf, lun, '# (DATA+offset) divided by linear (bx + c) -- slope: ' + strtrim(constants[0],1)
      printf, lun, '# (DATA+offset) divided by linear (bx + c) -- intercept: ' + strtrim(constants[1],1)
    end
    'Quadratic': begin
      printf, lun, '# DATA divided by quadratic (ax^2 + bx + c) -- a: ' + strtrim(constants[0],1)
      printf, lun, '# DATA divided by quadratic (ax^2 + bx + c) -- b: ' + strtrim(constants[1],1)
      printf, lun, '# DATA divided by quadratic (ax^2 + bx + c) -- c: ' + strtrim(constants[2],1)
    end
    'QuadraticAndOffset': begin
      printf, lun, '# (DATA+offset) divided by quadratic (ax^2 + bx + c) -- offset: ' + strtrim(constants[3],1)
      printf, lun, '# (DATA+offset) divided by quadratic (ax^2 + bx + c) -- a: ' + strtrim(constants[0],1)
      printf, lun, '# (DATA+offset) divided by quadratic (ax^2 + bx + c) -- b: ' + strtrim(constants[1],1)
      printf, lun, '# (DATA+offset) divided by quadratic (ax^2 + bx + c) -- c: ' + strtrim(constants[2],1)
    end
  ENDCASE
  
  printf, lun, '# reduced chi square is: ' + strtrim(reducedchisquarevalue)
  printf, lun, '#'
  printf, lun, '# wavelength (um),    data flux,      uncertainty,     model flux'
  FOR i = 0, n_elements(datalam_match)-1 DO printf, lun, datalam_match[i], dataflux_final[i], error_final[i], modelflux_final[i]
  Free_lun, lun

  print, "savebestmodel_final.pro: Data for figure saved as: " + outfilepath + 'figures/' + outfilename + '_bestfit_figuredata.dat'



end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
