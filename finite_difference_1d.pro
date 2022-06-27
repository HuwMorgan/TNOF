;+
;
; NAME:
; finite_difference_1d
;
; PURPOSE:
; Given input independent and dependent variables x and y, calculates dy/dx. Alternatively, if 
; independent variable x is not supplied, or has just one element, assumes that dx=1. Values should be
; in ascending order of independent variable x for correct dydx (this function does not sort the values).
;
; CALLING SEQUENCE:
; dydx=finite_difference_1d([x,]y[,nodiv=nodiv])
;
; INPUTS:
;   x = vector of independent variables of same length as y. Alternatively, can be any scalar value
;       and dx is then assumed to be a constant 1.
;   y = vector of dependent variables, of same length as x if x is provided.
;
; OUTPUTS:
;   vector of same length as y, giving dydx at each point
;
; OPTIONAL KEYWORD
;   nodiv = default is to do weighted difference between neighbouring points, with weighting
;           set by the distance from the central point to backward and forward points. If this keyword is
;           set, then this weighting is not implemented (assumes equal distance). Note if independent variable x
;           is not supplied, or if x is supplied and has constant dx, nodiv keyword has no effect on result.
;
; PROCEDURE:
;   Calculates forward and backward differences at each point. At vector end points, does only forward or
;   backward difference as appropriate.
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


function finite_difference_1d,x0,y0,nodiv=nodiv

if n_params() lt 2 then begin
  y=x0
  x=dindgen(n_elements(y))
endif else begin
  x=x0
  y=y0
endelse
if n_elements(x) eq 1 then x=dindgen(n_elements(y))

dyf=shift(y,-1)-y
dyb=y-shift(y,1)
dxf=shift(x,-1)-x
dxb=x-shift(x,1)
if ~keyword_set(nodiv) then begin
  dyf=dyf/dxf
  dyb=dyb/dxb
endif
wb=dxf/(dxf+dxb)
dy=wb*dyb+(1-wb)*dyf
dy[0]=dyf[0]
ny=n_elements(y)
dy[ny-1]=dyb[ny-1]

return,dy

end