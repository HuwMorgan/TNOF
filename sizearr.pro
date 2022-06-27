;+
;
; NAME:
; sizearr
;
; PURPOSE:
; Convenient wrapper for the IDL size function. 
;
; CALLING SEQUENCE:
;   sizearr,data,n0,n1,n2,...
;
; INPUTS:
;   data = any IDL variable, vector, or array. Up to 8 dimensions
;
; OUTPUTS:
;   n0 = size of data's first dimension
;
; OPTIONAL KEYWORDS
;   size = returns directly the result of calling size(data)
;   
;   ndim = returns the number of dimensions of data
;
; OPTIONAL INPUTS
;   (NONE)
;
; OPTIONAL OUTPUTS
;   n1,n2,...,n7 = the size of data's higher dimensions
;   
; PROCEDURE:
;   Calls size, and then for each dimension of data, creates variable n0,n1 etc
;   
; EXAMPLE:
;   IDL> data=fltarr(15,21,27)
;   IDL> sizearr,data,nx,ny,nt,ndim=ndim
;   IDL> help,nx
;   NX              LONG      =           15
;   IDL> help,ny
;   NY              LONG      =           21
;   IDL> help,nt
;   NT              LONG      =           27
;   IDL> help,ndim
;   NDIM            LONG      =            3
;   
; USE & PERMISSIONS
; Any problems/queries, or suggestions for improvements, please email Huw Morgan, hmorgan@aber.ac.uk
;
; ACKNOWLEDGMENTS:
;  This code was developed with the financial support of:
;  STFC and Coleg Cymraeg Cenedlaethol Studentship to Aberystwyth University (Humphries)
;  STFC Consolidated grant to Aberystwyth University (Morgan)
;
; MODIFICATION HISTORY:
; Created at Aberystwyth University 2021 - Huw Morgan hmorgan@aber.ac.uk
;
;
;-

function int2str_huw2,num,width=width
  return,string(num,format=n_elements(width) eq 0?'(I0)':$
    '(I' + int2str(width) + '.' + int2str(width) +')')
end

function int2str_huw,num,width
  return,string(num,format=n_params() lt 2?'(I0)':$
    '(I' + int2str_huw2(width) + '.' + int2str_huw2(width) +')')
end

pro sizearr,a,n0,n1,n2,n3,n4,n5,n6,n7,size=s,ndim=ndim
s=size(a)
ndim=s[0]
;initially set all dimension sizes to zero
for i=1,n_params()-1 do begin
  void=execute('n'+int2str_huw(i-1,1)+'=0')
endfor
if n_elements(a) eq 0 then return

for i=1,ndim do void=execute('n'+int2str_huw(i-1,1)+'=s['+int2str_huw(i,1)+']')

void=execute('n'+int2str_huw(i-1,1)+'=1');makes sense when you consider it in context
                                          ;e.g. two-dim image has one time step, so n2=1(=nt)
                                          
end