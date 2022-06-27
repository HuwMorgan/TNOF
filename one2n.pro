;+
;
; NAME:
; one2n
;
; PURPOSE:
; Convenient wrapper for array_indices. Given one-dimensional indices and size of array, 
; calculates the set of indices for each array dimension
;
; CALLING SEQUENCE:
; one2n,index,array,ind0,ind1,ind2....[,minmax=minmax,dimensions=dimensions]
;
; INPUTS:
;   index = one-dimensional index
;   array = either array from which the index has been subscribed, or a vector giving the size of each dimensions, in which case
;           the /dimensions keyword should be set
;
;
; OUTPUTS:
;   ind0,ind1,ind2....up to possible ind8 = returns one-dimensional indices up to the number of dimensions of array
;
; OPTIONAL KEYWORD
;   minmax = if set, the output indices are each two-element arrays giving the minimum and maximum index at that dimension
;
; PROCEDURE:
;   Read the code, also read IDL help on array_indices
;
; EXAMPLE:
;a=[[0,1,2],[3,-1,5]]
;IDL> help,a
;A               INT       = Array[3, 2]
;IDL> index=where(a lt 0)
;IDL> print,index
;4
;IDL> one2n,index,a,ix,iy
;IDL> print,ix,iy
;           1           1
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

pro one2n,index,array,i0,i1,i2,i3,i4,i5,i6,i7,i8,minmax=minmax,dimensions=dimensions

ia=array_indices(array,index,dimensions=dimensions)
s=keyword_set(dimensions)?[n_elements(array)]:size(array)
for i=0,s[0]-1 do begin
  com='inow=reform(ia[i,*])'
  r=execute(com)
  com1='i'+strcompress(string(i),/remove_all)
  if n_elements(inow) gt 1 then $
  com=com1+'=reform(ia[i,*])' else $
  com=com1+'=ia[i]'
  r=execute(com)
  if keyword_set(minmax) then begin
    com=com1+'=minmax('+com1+')'
    r=execute(com)
  endif
endfor

end