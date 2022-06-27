function minmax_huw,a,nan=nan,robust=robust

;+
; NAME:
;   minmax_huw
;
; PURPOSE:
;  returns minimum and maximum values of array in a 2-element vector
;
; CALLING SEQUENCE:
;   mnmx=minmax_huw(array[,/nan])
;
;
; INPUTS:
; array = any numerical array
;
; OUTPUTS:
;  mnmx = 2-element array with mnmx[0] minimum and mnmx[1] maximum
;
; OPTIONAL OUTPUTS
; none
;
; PROCEDURE:
;
; KEYWORDS:
; /nan = ignore NANs
; 
;  MODIFICATION HISTORY:
; Created 03/2013 - Huw Morgan hmorgan@aber.ac.uk
;-

if keyword_set(robust) then begin
  mn=robust_min(a,max=mx)
endif else mn=min(a,max=mx,nan=nan)
return,[mn,mx]

end