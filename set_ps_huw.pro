;+
;
; NAME:
; set_ps_huw
;
; PURPOSE:
; Convenient wrapper for setting the postscript device on IDL
;
; CALLING SEQUENCE:
;   set_ps_huw,filename,xsize,ysize[,noteps=noteps]
;
; INPUTS:
;   filename = path for postscript file to be created
;   
;   xsize = x-size of graphic in inches
;   
;   ysize = y-size of graphic in inches
;
; OUTPUTS:
;   (None)
;
; OPTIONAL KEYWORDS
;   noteps = Default is to create encapsulated postscript. Set this keyword to suppress this default.
;
; OPTIONAL INPUTS
;   (NONE)
;
; OPTIONAL OUTPUTS
;   (None)
;
; PROCEDURE:
;   
;
; EXAMPLE:
;   filename = './directory/eps_output.eps'
;   set_ps_huw,filename,5,5
;   plot,[0,1]
;   setx,/close;(see setx which sets graphics device back to X)
;   spawn,'open '+filename ; view output
;   
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

pro set_ps_huw,filename,xsize,ysize,noteps=noteps

encapsul=keyword_set(noteps)?0:1
set_plot,'ps'
device,xsize=xsize,ysize=ysize,/inch,/times,decomposed=0
device,encapsul=encapsul,filename=filename
device,bits=8,/color,language=2
;polyfill,[1,1,0,0,1],[1,0,0,1,1],/normal,color=255
!p.charsize=1.5
!P.thick=2
!x.thick=2
!y.thick=2
!p.charthick=2
!p.font=1
Device, Set_Font='Times Bold', /TT_Font
Device, /ISOLATIN1

end