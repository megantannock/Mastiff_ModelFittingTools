; NAME:
;     READCONFIGFILE_FINAL
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;
;     For use with FITMODELGRID_FINAL.PRO
;     
;     Reads in the configuration file for BDMODELFITTING_FINAL.pro and
;     returns an array of strings, containing all of the settings for the
;     model fitting. 
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     
; INPUT PARAMETERS: 
;     configfilepathandname - a string that is the path and filename
;          of the configuartion file
; 
; RETURNS: 
;     parametervalues - an array of strings, read in from the configuration
;          file
;          
; CALLING SEQUENCE:
;     keywords = readconfigfile_final(configfilepathandname)
;
; NOTES:
;   CONFIGURATION FILE FORMAT:
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
;          If you have a different model, add a new case to read the model in. 
;          Make sure the flux is in F_lambda units and the wavelength is in microns.
;          You can add these conversions in readmodels_final.pro, you do not have
;          to convert the units before running this code.
;     modelpath = The path to your models
;     modelnamesfile = The path and name of a text file which contains the name of
;          each model you wish to fit to.
;     wavelengthregionname = A name for the region you want to fit to, for
;          example: "Jband." This is to name the output file. Must be a string
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
;          tellurics. If you're not masking, enter your oufilepath
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
;     vsinistep = 0.5
;     rvshiftstartval = -50
;     rvshiftendval = 10
;     rvstep = 0.5
;     limbdarkeningcoefficient = 0.6
;     erroradjust = 5
;     psgpath = /Volumes/Storage/Grad_School/IGRINS_data/
;     masktellurics = 30
;     scaletype = 'Quadratic'
;     bcv = 1.5
;     nkernels = 1
;

function readconfigfile_final, configfilepathandname, silent=silent

  fmt = 'A,A,A' ; format of configuration file

  readcol, configfilepathandname, FORMAT = fmt, parameter, equal, parametervalues, delim=' ', /SILENT, COMMENT='#' ; Read in the data

  if ~keyword_set(silent) then begin
    print, 'readconfigfile.pro: Parameters read in from configuration file ' + configfilepathandname + ':'
    FOR i = 0, n_elements(parameter)-1 DO print, '  ' + parameter[i] + ' ' + equal[i] + ' ' + parametervalues[i]
  endif

  return, parametervalues
end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract