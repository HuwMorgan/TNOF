;+
;
; NAME:
; image_clip
;
; PURPOSE:
; Convenient program for extracting subregion from 2-dimensional image [nx,ny] (default) or optional truecolor image [3,nx,ny] 
;
; CALLING SEQUENCE:
;   image_clip,clip,p0[,p1,p2,p3,p4,p5, $
;           p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,truecolor=truecolor]
;
; INPUTS:
;   clip = defines subregion to be extracted, 4-element vector [xleft,ybottom,xright,ytop] 
;   
;   p0 = 2-dimensional image [nx,ny] (default) or optional truecolor image [3,nx,ny]
;
; OUTPUTS:
;   None - all supplied images are modified 
;
; OPTIONAL KEYWORDS
;   truecolor = if set, then indicates that input images are true color with the RGB as 1st dimension [3,nx,ny]
;
; OPTIONAL INPUTS
;   
;   p1,p2,...,p15 = other 2-dimensional images or truecolor images. All clipped to defined subregion.
;   
;   NOTE: all supplied images should be 2-dimensional or truecolor, do not give this program a mixture of both types.
;
; OPTIONAL OUTPUTS
;
; PROCEDURE:
;   
;
; EXAMPLE:
;   IDL> data=fltarr(512,512)
;   IDL> region=[50,60,150,260]
;   IDL> data=fltarr(512,512)
;   IDL> data2=fltarr(712,712)
;   IDL> region=[50,60,150,260]
;   IDL> image_clip,region,data,data2
;   IDL> help,data,data2
;   DATA            FLOAT     = Array[101, 201]
;   DATA2           FLOAT     = Array[101, 201]
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


pro image_clip,clip,p0,p1,p2,p3,p4,p5, $
  p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,truecolor=truecolor

str=keyword_set(truecolor)?'[*,clip[0]:clip[2],clip[1]:clip[3]]':'[clip[0]:clip[2],clip[1]:clip[3]]'
for i=0,n_params()-2 do begin
  pname=strcompress('p'+string(i),/remove_all)
  r0=execute('n=n_elements('+pname+')')
  if n gt 0 then r=execute(strcompress(pname+'='+pname+str,/remove_all))
endfor

end    