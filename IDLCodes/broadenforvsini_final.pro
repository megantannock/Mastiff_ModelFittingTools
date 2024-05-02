; NAME:
;     BROADENFORVSINI_FINAL
;
; AUTHOR:
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE:
;
;     For use with FITMODELGRID_FINAL.PRO
;
;     Broadens the input model flux by the input velocity by convolving
;     the broadening profile of Gray (1992) (generated with lsf_rotate.pro 
;     from the Astronomy User's Library: https://idlastro.gsfc.nasa.gov/ftp/pro/astro/lsf_rotate.pro) 
;     with your model flux.
;     
;     If your model's resolution changes a lot across the wavelengths
;     of interest, you may end up overbroadening or underbroadening
;     the ends of the spectrum by using the same kernel across the whole
;     spectrum. A convolution, by definition, has a fixed kernel. Instead 
;     of generating a linear transform to deal with the changing
;     resolution, we take the simple approach of splitting the spectrum
;     in to N sections and broadening each section with its own kernel,
;     then stitching the resulting spectrum back together. If you do not
;     want to do this, set numkernels=1.
;     
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;
; INPUT PARAMETERS:
;    modellam - your model's wavelength scale in microns, an array of floats
;    modelflux - your model's flux values, an array of floats
;    vsini - the velocity to broaden to, a float
;    numkernels - the number of sections to divide this spectrum in to, a float.
;         Each section gets its own kernel for broadening. Use this if your 
;         model changes resolution a lot from one end to the other. If you don't
;         want to do this, use 1.
;    limbdarkeningcoefficient - Numeric scalar giving the limb-darkening
;          coefficient. Use 0.6 as the default value. This is used in
;          lsf_rotate.pro, see documentation for details:
;          https://idlastro.gsfc.nasa.gov/ftp/pro/astro/lsf_rotate.pro
;
; RETURNS:
;     modelflux_broadened_stitched - your broadened model flux
;
; CALLING SEQUENCE:
;     broadenedmodel = broadenforvsini_final(modellam, modelflux, 21.5, 10)
;

function broadenforvsini_final, modellam_in, modelflux_in, vsini, numkernels, limbdarkeningcoefficient
  c = 2.99792458d5 ; km/s - speed of light
  
  if numkernels eq 1 then begin
    
    centreindex = round(n_elements(modellam_in) / 2.) ; get the index for the element in the middle of the wavelength array
    deltaV = ((modellam_in[centreindex] - modellam_in[centreindex-1])*c) / (modellam_in[centreindex]) ; numeric scalar giving the step increment (in km/s) in the output rotation kernel.
    lsf = lsf_rotate(deltaV, vsini, EPSILON=limbdarkeningcoefficient) ; Generate line Spread Function kernel (LSF)
    ; LSF_ROTATE.PRO is from the Astronomy User's Library: https://idlastro.gsfc.nasa.gov/ftp/pro/astro/lsf_rotate.pro
    modelflux_broadened_stitched = CONVOL(modelflux_in, lsf) ; convolve spectrum with LSF kernel
    
    ; do a rough normalization
    modelflux_broadened_stitched = modelflux_broadened_stitched / median(modelflux_broadened_stitched)
    
  endif else begin
    
    elements = n_elements(modellam_in)
    modelflux_broadened = MAKE_ARRAY(elements,numkernels) * 0 ; make an array to fill in with the broadened spectra for each kernel
    width = uint(float(elements) / float(numkernels))
    indices = uint(ARRGEN(width/2., elements-(width/2.), nstep = numkernels)) ; figure out your indices for the kernel, make sure they are integers

    for nk=0, numkernels-1 do begin
      deltaV = abs(((modellam_in[indices[nk]] - modellam_in[indices[nk]-1])*c) / (modellam_in[indices[nk]])) ; numeric scalar giving the step increment (in km/s) in the output rotation kernel.
      lsf = lsf_rotate(deltaV,vsini, EPSILON=limbdarkeningcoefficient) ; Generate line Spread Function kernel (LSF)
      ; LSF_ROTATE.PRO is from the Astronomy User's Library: https://idlastro.gsfc.nasa.gov/ftp/pro/astro/lsf_rotate.pro
      modelflux_broadened[*,nk] = CONVOL(modelflux_in, lsf, /edge_constant) ; convolve spectrum with LSF kernel

      ; do a rough normalization:
      modelflux_broadened[*,nk] = modelflux_broadened[*,nk] / median(modelflux_broadened[*,nk])
    endfor

    ; Now stitch together our sections:

    ; Make an array to hold the franken-spectrum:
    modelflux_broadened_stitched = modelflux_broadened[*,0] * 0

    for nk=0, numkernels-1 do begin
      startval = (nk*width)
      endval = startval + width - 1
      modelflux_broadened_stitched[startval:endval] = modelflux_broadened[startval:endval,nk]
    endfor
  endelse

  return, modelflux_broadened_stitched

end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
