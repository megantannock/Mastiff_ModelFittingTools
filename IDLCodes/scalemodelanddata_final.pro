; NAME: 
;      SCALEMODELANDDATA_FINAL.PRO
;
; AUTHOR: 
;      Megan E. Tannock (contact: mtannock@uwo.ca)
;
; PURPOSE: 
;     For use with FITMODELGRID_FINAL.PRO
;     
;     Apply some optimized scaling and offsets to the model/data to obtain 
;     the lowest reduced chi square.
;     
;     Depending on what type of scaling/offset you want, a "Goodness of
;     Fit" metric, G, is given. The partial derivatives of G are set to 
;     zero (to minimize G) and the resulting system of equations is solved
;     for the parameters of G. The G equations are given below.
;     
;     The input arrays for wavelength, data, uncertainty, and model flux
;     will be overwritten with their revised versions! The return is the
;     parameters that went in to the fitting, to be output in the file
;     from FITMODELGRID_FINAL.PRO
;     
;     For details please see:
;          Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;          Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
;     If you make use to this code, please cite the above two publications.
;     
; INPUT PARAMETERS:
;    datalam_match - your wavelength scale in microns, an array of floats
;    dataflux_final - your data flux, an array of floats
;    error_final - your uncertainties, an array of floats
;    modelflux_final - your model flux, an array of floats
;    scaletype - the type of scaling or offset you would like, a string.
;          Options are: None, Scale, ScaleAndOffset, Linear, LinearAndOffset, 
;          Quadratic, QuadraticAndOffset
;          
;          Descriptions:
;              None - Do not apply any optimized scaling or offsets - use the 
;                     simple normalization of the Data and Model (normalized 
;                     separately)
;              Scale - Determine a multiplicative factor for the model which 
;                     minimizes the chisquare
;                     G = sum [ ( data - scale * model ) / ( uncert ) ]^2
;                     derivatives: dG/d scale
;              ScaleAndOffset - Determine a multiplicative factor for the model, 
;                     and flux offset for the data which minimizes the chisquare
;                     G = sum [  (data + vertoffset) - scale*model / ( uncert ) ]^2
;                     derivatives: dG/d vertoffset  ; dG/d scale
;              Linear - Determine a linear fit for the model which minimizes the 
;                     chisquare
;                     G = sum [ data - (slope_m*lambda + intercept_b) * model / ( uncert ) ]^2
;                     derivatives: dG/d slope_m  ; dG/d intercept_b
;                     The model is multiplied by the linear fit to simplify the math here, 
;                     but in the code the data is divided by this fit at the end.
;              LinearAndOffset - Determine a linear fit for the model and flux 
;                     offset for the data which minimizes the chisquare
;                     G = sum [ (data + const_c) - (const_m * lambda + const_b) * model / ( uncert ) ]^2
;                     derivatives: dG/d const_a  ; dG/d const_b  ; dG/d const_m
;                     The model is multiplied by the linear fit to simplify the math here, 
;                     but in the code the data is divided by this fit at the end. 
;              Quadratic -Determine a quadratic fit for the model which minimizes 
;                     the chisquare
;                     G = sum [ data - (const_a * lambda * lambda + const_b * lambda + const_c) * model / ( uncert ) ]^2
;                     derivatives: dG/d const_a  ; dG/d const_b  ; dG/d const_c
;                     The model is multiplied by the quadratic fit to simplify the math here,
;                     but in the code the data is divided by this fit at the end.
;              QuadraticAndOffset - Determine a quadratic fit for the model, and 
;                     flux offset for the data which minimizes the chisquare
;                     G = sum [ (data + const_d) - (const_a * lambda * lambda + const_b * lambda + const_c) * model / ( uncert ) ]^2
;                     derivatives: dG/d const_a  ; dG/d const_b  ; dG/d const_c  ; dG/d const_d
;                     The model is multiplied by the quadratic fit to simplify the math here,
;                     but in the code the data is divided by this fit at the end.
;
; RETURNS:
;    constants- an array of the constants used in the scaling/offsets
;    
;    The input arrays for wavelength, data, uncertainty, and model flux
;    will be overwritten with their revised versions! The return is the
;    parameters that went in to the fitting, to be output in the file
;    from FITMODELGRID_FINAL.PRO
;     
; CALLING SEQUENCE:
;    constants = scalemodelanddata_final(datalam, dataflux, uncerts, modelflux, 'Quadratic') 
;

function scalemodelanddata_final, datalam_match, dataflux_final, error_final, modelflux_final, scaletype

  ; Check if the arrays are the same length as the other arrays
  if (n_elements(datalam_match) ne n_elements(dataflux_final)) or (n_elements(error_final) ne n_elements(modelflux_final)) then begin
    print, "scalemodelanddata_final: Array sizes do not match."
    print, "scalemodelanddata_final: Returning NaN."
    return, [!VALUES.F_NAN]
  endif

  CASE scaletype OF

    'None': begin
      ; do nothing
      return, [0]
    end
    
    'Scale': begin
      ; do a scaling to minimize the chi square only
      
      ; G = sum [ ( data - scale * model ) / ( uncert ) ]^2
      ; derivates: dG/d scale
      ; set derivatives to 0 to obtain this system of equations:
      ; compute the sums we need...
      sum_OM_ss = total( dataflux_final*modelflux_final / (error_final*error_final) , /NAN)
      sum_MM_ss = total( modelflux_final*modelflux_final / (error_final*error_final) , /NAN)

      ; compute the scaling factor
      scale = sum_OM_ss / sum_MM_ss

      ; apply the scaling factor
      modelflux_final = modelflux_final * scale
      
      return, [scale]
    end
    
    'ScaleAndOffset': begin
      ; data + constant, model*constant
      
      ; G = sum [  (data + vertoffset) - scale*model / ( uncert ) ]^2
      ; derivates: dG/d vertoffset  ; dG/d scale
      ; set derivatives to 0 to obtain this system of equations:
      sum_OM_ss = total( dataflux_final*modelflux_final / (error_final*error_final) , /NAN)
      sum_1_ss = total( 1.0 / (error_final*error_final) , /NAN)
      sum_O_ss = total( dataflux_final / (error_final*error_final) , /NAN)
      sum_M_ss = total( modelflux_final / (error_final*error_final) , /NAN)
      sum_MM_ss = total( modelflux_final*modelflux_final / (error_final*error_final) , /NAN)

      ; scaling factor
      scale = ( (sum_OM_ss * sum_1_ss) - ( sum_O_ss * sum_M_ss) ) / ( (sum_MM_ss * sum_1_ss) - (sum_M_ss * sum_M_ss) )

      ; vertical offset
      vertoffset = ( ( sum_OM_ss * sum_M_ss ) - ( sum_O_ss * sum_MM_ss ) ) / ( (sum_MM_ss * sum_1_ss ) - (sum_M_ss * sum_M_ss) )

      ; apply these values and compute reduced chi square
      dataflux_final = dataflux_final + vertoffset
      
      ; apply the scaling factor
      modelflux_final = modelflux_final * scale
      
      return, [scale, vertoffset]
    end
    
    'Linear': begin
      ; G = sum [ data - (slope_m*lambda + intercept_b) * model / ( uncert ) ]^2
      ; derivates: dG/d slope_m  ; dG/d intercept_b
      ; set derivatives to 0 to obtain this system of equations:
      sum_OM_ss = total( dataflux_final*modelflux_final / (error_final*error_final) , /NAN)
      sum_MM_ss = total( modelflux_final*modelflux_final / (error_final*error_final) , /NAN)
      sum_OMx_ss = total( dataflux_final*modelflux_final*datalam_match / (error_final*error_final) , /NAN)
      sum_xMM_SS = total( datalam_match*modelflux_final*modelflux_final / (error_final*error_final) , /NAN)
      sum_xxMM_ss =total( datalam_match*datalam_match*modelflux_final*modelflux_final / (error_final*error_final) , /NAN)

      ; You can actually calculate these, but letting IDL do the linear algebra is much easier
      ; slope of line:
      ; slope_m = ( (sum_MM_ss * sum_OMx_ss) - (sum_xMM_ss * sum_OM_ss) ) / ( (sum_xxMM_ss * sum_MM_ss) - ( sum_xMM_ss * sum_xMM_ss ) )
      ; intercept of line:
      ; intercept_b = ( ( sum_xxMM_ss * sum_OM_ss ) - ( sum_xMM_ss * sum_OMx_ss ) ) / ( ( sum_xxMM_ss * sum_MM_ss ) - (sum_xMM_ss * sum_xMM_ss) )

      ; Let IDL do the linear algebra:
      matrix = [ [sum_xxMM_ss, sum_xMM_SS], $
        [sum_xMM_SS, sum_MM_ss] ]

      constmatrix = [sum_OMx_ss, sum_OM_ss]

      invertmatrix = invert(matrix)

      resultmatrix = invertmatrix ## constmatrix

      slope_m = resultmatrix[0]
      intercept_b = resultmatrix[1]

      ; apply these values
      ; divide the data by a line
      dataflux_final = dataflux_final / ( (slope_m * datalam_match) + intercept_b )
      error_final = error_final / ( (slope_m * datalam_match) + intercept_b )
      ; no changes to the final model
      modelflux_final = modelflux_final
      
      return, [slope_m, intercept_b]
    end
    
    'LinearAndOffset': begin
      ; linear with offset
      
      ; G = sum [ (data + const_c) - (const_m * lambda + const_b) * model / ( uncert ) ]^2
      ; derivates: dG/d const_a  ; dG/d const_b  ; dG/d const_m
      ; set derivatives to 0 to obtain this system of equations:
      sumA = total( (datalam_match^2) * (modelflux_final^2) / (error_final^2) , /NAN, /double)
      sumB = total( (datalam_match) * (modelflux_final^2) / (error_final^2) , /NAN, /double)
      sumC = total( (datalam_match) * (modelflux_final) / (error_final^2) , /NAN, /double)
      sumD = total( (modelflux_final^2) / (error_final^2) , /NAN, /double)
      sumE = total( (modelflux_final) / (error_final^2) , /NAN, /double)
      sumF = total( 1.0 / (error_final^2) , /NAN, /double)

      sumG = total( (datalam_match) * (modelflux_final) * (dataflux_final) / (error_final^2) , /NAN, /double)
      sumH = total( (modelflux_final) * (dataflux_final) / (error_final^2) , /NAN, /double)
      sumI = total( (dataflux_final) / (error_final^2) , /NAN, /double)

      matrix = [ [sumA, sumB, ((-1.0)*sumC)], $
        [sumB, sumD, ((-1.0)*sumE)], $
        [sumC, sumE, ((-1.0)*sumF)] ]

      constmatrix = [sumG, sumH, sumI]

      invertmatrix = invert(matrix)

      resultmatrix = invertmatrix ## constmatrix

      const_m = resultmatrix[0]
      const_b = resultmatrix[1]
      const_c = resultmatrix[2]

      ; apply these values
      dataflux_final = ( dataflux_final + const_c) / ( (const_m*datalam_match) + const_b )
      error_final = error_final / ( (const_m*datalam_match) + const_b )
      ; no changes to the final model
      modelflux_final = modelflux_final
      
     return, [const_m, const_b, const_c]
    end
    
    'Quadratic': begin
      ; quadratic with NO offset
      
      ; G = sum [ data - (const_a * lambda * lambda + const_b * lambda + const_c) * model / ( uncert ) ]^2
      ; derivates: dG/d const_a  ; dG/d const_b  ; dG/d const_c
      ; set derivatives to 0 to obtain this system of equations:
      sumA = total( (datalam_match^4) * (modelflux_final^2) / (error_final^2) , /NAN)
      sumB = total( (datalam_match^3) * (modelflux_final^2) / (error_final^2) , /NAN)
      sumC = total( (datalam_match^2) * (modelflux_final^2) / (error_final^2) , /NAN)
      sumD = total( (datalam_match) * (modelflux_final^2) / (error_final^2) , /NAN)
      sumE = total( (modelflux_final^2) / (error_final^2) , /NAN)

      sumF = total(  (dataflux_final) * (datalam_match^2) * (modelflux_final) / (error_final^2) , /NAN)
      sumG = total(  (dataflux_final) * (datalam_match) * (modelflux_final) / (error_final^2) , /NAN)
      sumH = total(  (dataflux_final) * (modelflux_final) / (error_final^2) , /NAN)


      matrix = [ [sumA, sumB, sumC], $
        [sumB, sumC, sumD], $
        [sumC, sumD, sumE] ]

      ; make sure the determinant is not zero - just for testing
      ;  print, 'det(M) = ', determ(matrix)

      constmatrix = [sumF, sumG, sumH]

      invertmatrix = invert(matrix)

      resultmatrix = invertmatrix ## constmatrix
      ;  print, 'a, b, c = ', resultmatrix

      const_a = resultmatrix[0]
      const_b = resultmatrix[1]
      const_c = resultmatrix[2]

      ; apply these values
      dataflux_final = (dataflux_final) / ( (const_a*(datalam_match^2)) + (const_b*datalam_match) + const_c )
      error_final = error_final / ( (const_a*(datalam_match^2)) + (const_b*datalam_match) + const_c )
      ; No changes to the final model
      modelflux_final = modelflux_final
      
      return, [const_a, const_b, const_c]

    end
    
    'QuadraticAndOffset': begin
      ; quadratic with offset
      
      ; G = sum [ (data + const_d) - (const_a * lambda * lambda + const_b * lambda + const_c) * model / ( uncert ) ]^2
      ; derivates: dG/d const_a  ; dG/d const_b  ; dG/d const_c  ; dG/d const_d
      ; set derivatives to 0 to obtain this system of equations:
      sumA = total( (datalam_match^4) * (modelflux_final^2) / (error_final^2) , /NAN)
      sumB = total( (datalam_match^3) * (modelflux_final^2) / (error_final^2) , /NAN)
      sumC = total( (datalam_match^2) * (modelflux_final^2) / (error_final^2) , /NAN)
      sumD = total( (datalam_match^2) * (modelflux_final) / (error_final^2) , /NAN)
      sumE = total( (datalam_match) * (modelflux_final^2) / (error_final^2) , /NAN)
      sumF = total( (datalam_match) * (modelflux_final) / (error_final^2) , /NAN)
      sumG = total( (modelflux_final^2) / (error_final^2) , /NAN)
      sumH = total( (modelflux_final) / (error_final^2) , /NAN)
      sumI = total( 1.0 / (error_final^2) , /NAN)
  
      sumJ = total(  (dataflux_final) * (datalam_match^2) * (modelflux_final) / (error_final^2) , /NAN)
      sumK = total(  (dataflux_final) * (datalam_match) * (modelflux_final) / (error_final^2) , /NAN)
      sumL = total(  (dataflux_final) * (modelflux_final) / (error_final^2) , /NAN)
      sumM = total(  (dataflux_final) / (error_final^2) , /NAN)
  
  
      matrix = [ [sumA, sumB, sumC, ((-1.0)*sumD)], $
        [sumB, sumC, sumE, ((-1.0)*sumF)], $
        [sumC, sumE, sumG, ((-1.0)*sumH)], $
        [sumD, sumF, sumH, ((-1.0)*sumI)] ]

      constmatrix = [sumJ, sumK, sumL, sumM]
  
      invertmatrix = invert(matrix)
  
      resultmatrix = invertmatrix ## constmatrix
    
      const_a = resultmatrix[0]
      const_b = resultmatrix[1]
      const_c = resultmatrix[2]
      const_d = resultmatrix[3]
  
      ; apply these values:
  
      ; Add the constant
      dataflux_final = dataflux_final + const_d
      ; Nothing to be done with the error for this operation
  
      ; now divide by quadratic
      dataflux_final = dataflux_final / ( (const_a*(datalam_match^2)) + (const_b*datalam_match) + const_c )
      ; do the same for the error:
      error_final = error_final / ( (const_a*(datalam_match^2)) + (const_b*datalam_match) + const_c )
  
      ; No changes to the model:
      modelflux_final = modelflux_final
      
      return, [const_a, const_b, const_c, const_d]
    end
    
  ENDCASE

end
;     If you make use to this code, please cite the following two publications:
;       Tannock M. E., et al., 2021, AJ, 161, 224      https://ui.adsabs.harvard.edu/abs/2022MNRAS.514.3160T/abstract
;       Tannock M. E., et al., 2022, MNRAS, 514, 3160  https://ui.adsabs.harvard.edu/abs/2021AJ....161..224T/abstract
