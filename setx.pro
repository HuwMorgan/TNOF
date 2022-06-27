;+
;
; NAME:
; setx
;
; PURPOSE:
; Convenient wrapper for setting the postscript device on IDL to screen. Also sets background as white, foreground as black, 
; and sets device to decomposed=0 and retain=2. Users on other operating systems may need to change these values. Works
; nicely on MacOS.
;
; CALLING SEQUENCE:
;   setx[,close=close,clean=clean]
;
; INPUTS:
;   (None)
;
; OUTPUTS:
;   (None)
;
; OPTIONAL KEYWORDS
;   close = if on call current device is postscript, closes the postscript file 
;   
;   clean = if set, calls the solarsoft cleanplot procedure which sets graphics options to defaults
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
;   setx,/close,/clean
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

pro dev
  device,decomposed=0,retain=2
end

pro baw
  !p.background=255 & !p.color=0
end

pro setx,close=close,clean=clean

  if keyword_set(close) and strlowcase(!d.name) eq 'ps' then device,/close_file
  if keyword_set(clean) then cleanplot,/silent
  devic=!version.os eq 'Win32'?'win':'x'
  set_plot,devic
  dev
  baw

end