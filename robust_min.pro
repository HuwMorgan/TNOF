;+
;
; NAME:
; robust_min
;
; PURPOSE:
; Calculates the robust minimum of an input array. I believe it uses linear interpolation between closest ranks method.
; Wrote intiuitively, but really need to visit the literature and write properly 
; e.g. https://en.wikipedia.org/wiki/Percentile#Weighted_percentile
;
; CALLING SEQUENCE:
; min=robust_min(array[,percent,max=max])
;
; INPUTS:
;   array=input array, numerical
;
; OPTIONAL INPUT:
;   percent=the percentile minimum to use, default is 1%
;
; OUTPUTS:
;   function returns robust minimum
;
;
; OPTIONAL KEYWORD
;   max = returns robust maximum of the array at same percentile
;
; PROCEDURE:
;   Sorts array members into ascending order, then interpolates to the value
;   where number of array members is equal to the percentile
;
; USE & PERMISSIONS
;  If you reuse in your own code, please include acknowledgment to Huw Morgan (see below)
;
; ACKNOWLEDGMENTS:
;  This code was developed with the financial support of:
;  STFC Consolidated grant to Aberystwyth University (Morgan)
;
; MODIFICATION HISTORY:
; Created at Aberystwyth University 07/2019 - Huw Morgan hmorgan@aber.ac.uk
;
;
;-
function robust_min,y0,per,max=max,weights=weights;,nbin=nbin

if n_params() lt 2 then per=1

max=!values.f_nan
indok=where(finite(y0),n)
if n eq 0 then return,!values.f_nan
indsort=sort(y0[indok])
indmin=per*float(n-1)/100.

data=y0[indok[indsort]]
if n_elements(weights) eq 0 then begin
  min=interpol(data,findgen(n),indmin)
  if arg_present(max) then begin
    indmax=(100-per)*float(n-1)/100.
    max=interpol(data,findgen(n),indmax)
  endif
endif else begin
  w=weights[indok[indsort]]
  p=total(w,/cum)*100/total(w)
  min=interpol(data,p,per)
  if arg_present(max) then begin
    indmax=(100-per)*float(n-1)/100.
    max=interpol(data,p,per)
  endif
endelse

return,min

end