; NAME:
;     READDATA_FINAL
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;     For use with FITMODELGRID_FINAL.PRO
;     
;     Read in the data, depending on the type of data it is. Uses a flag to 
;     determine how to read the data in. Also sets the slit width for the 
;     instrument you're using (in pixels) - this is needed for the telluric 
;     correction.
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     
; INPUT PARAMETERS:
;    objectinstrument - The type of data you're reading in. Must be a STRING that
;          matches the available cases. Options are: FIRE, GNIRS, IGRNS. You can
;          add additonal cases if your data differs from these. Ensure the flux is
;          in F_lambda units and the wavelength is in microns.
;    objectpath - The path to your data. Must be a string
;    objectfilename - The filename of your data. Must be a string.
;    objecterrorname - The filename of your error. Must be a string. If the errors 
;          are in the same file as the data, just put the data name twice.
;
; RETURNS:
;      Returns a 2D vector of wavelength, flux, error in the format
;      datavalues = [[lam], [flux], [error]]
;
; CALLING SEQUENCE:
;     datain = readdata_final(objectinstrument, objectpath, objectfilename, objecterrorname)
;

function readdata_final, objectinstrument, objectpath, objectfilename, objecterrorname, slitwidth

  CASE objectinstrument OF

    'FIRE': begin
      flux = xmrdfits(objectpath+objectfilename, 0, hdr, /silent)
      error = xmrdfits(objectpath+objecterrorname, 0, /silent)
      lam = 10.^(float(sxpar(hdr,'crval1'))+findgen(n_elements(flux))*float(sxpar(hdr,'cdelt1')))
      lam = lam / 1.d4 ; convert wavelength to um
      slitwidth = 3 ; pixels
    end

    'GNIRS': begin
      ; for GNIRS targets
      fmt = 'D,D' ; format of filename
      readcol, objectpath + objectfilename, FORMAT = fmt, lam, flux, SKIPLINE=70, /SILENT ; Read in the data
      readcol, objectpath + objecterrorname, FORMAT = fmt, lam, error, SKIPLINE=70, /SILENT ; Read in the error
      lam = lam / 1.d4 ; convert wavelength to um
      slitwidth = 3 ; pixels
    end

    'IGRINS': begin
      ; for IGRINS targets
      ; weighted-average spectra per order
      fmt = 'D,D,D,D' ; format of filename
      readcol, objectpath + objectfilename, FORMAT = fmt, lam, flux, error, snr, COMMENT='#', skipline=0 ; Read in the data
      slitwidth = 4 ; pixels (actually 3.6, but we'll round up)
    end

  ENDCASE

  datavalues = [[lam], [flux], [error]]
  return, datavalues

end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract