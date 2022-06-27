;+
;
; NAME:
; fft_corr_track_huw
;
; PURPOSE:
; Calculates translation of input image IM1in0 to reference input image IM00, returns the estimated x,y shift
; Estimates translation (x,y)-shift only, no rotation or scaling
; Method described well by
; Fisher & Welsh http://articles.adsabs.harvard.edu/pdf/2008ASPC..383..373F (and references within)
; 
; CALLING SEQUENCE:
; xy=fft_corr_track_huw(im00,im1in0 [,whole_pixel=whole_pixel,subregion=subregion, $
;                         percent=percent])
;
; INPUTS:
;   im00 = 2-dimensional image
;   
;   im1in0 = 2-dimensional image. Can be different size to im00
;
; OUTPUTS:
;  xy = 2-element vector, giving estimated x,y shift in pixels
;
; OPTIONAL KEYWORDS
;
; whole_pixel : calculate whole pixel translations only (default sub-pixel)
;
; subregion : user can define a subregion of the image in order to calculate the shift (does not crop the return image)
;           Subregion=[xleft,ybottom,xright,ytop] in pixels
;           
; percent  : clips image values to a given percentile 
;           e.g. percent=[4,98] limits values to 4th percentile minium and 2nd percentile (100-98) maximum

;
; OPTIONAL INPUTS
;   (NONE)
;
; OPTIONAL OUTPUTS
;   (None)
;
; PROCEDURE:
;   See Fisher & Welsh http://articles.adsabs.harvard.edu/pdf/2008ASPC..383..373F
;
; USE & PERMISSIONS
; If you use this code in your own work, please cite 
; Fisher & Welsh http://articles.adsabs.harvard.edu/pdf/2008ASPC..383..373F (and references within)
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

function fft_corr_track_huw,im00,im1in0,whole_pixel=whole_pixel,subregion=subregion, $
                                percent=percent

im0=im00
im1=im1in0
if keyword_set(subregion) then image_clip,subregion,im0,im1

if keyword_set(percent) then begin
  mn=robust_min(im0,percent[0],max=mx)
  void=robust_min(im0,percent[1],max=mx)
  ind=where(im0 lt mn or im0 gt mx,comp=nind,cnt)
  if cnt gt 0 then im0[ind]=mean(im0[nind],/nan)
  mn=robust_min(im1,percent[0])
  void=robust_min(im1,percent[1],max=mx)
  ind=where(im1 lt mn or im1 gt mx,comp=nind,cnt)
  if cnt gt 0 then im1[ind]=mean(im1[nind],/nan)
endif


sizearr,im0,nx0,ny0
sizearr,im1,nx1,ny1
nx=nx0>nx1
ny=ny0>ny1
im0temp=fltarr(nx,ny)
im0temp[*]=!values.f_nan
im0temp[0,0]=im0
im0=im0temp
im1temp=fltarr(nx,ny)
im1temp[*]=!values.f_nan
im1temp[0,0]=im1
im1=im1temp

indnan=where(~finite(im0),cntnan)
if cntnan gt 0 then im0[indnan]=mean(im0,/nan)
indnan=where(~finite(im1),cntnan)
if cntnan gt 0 then im1[indnan]=mean(im1,/nan)

nx2=nx/2.
ny2=ny/2.


fft0=fft(im0, /center)
fft1=fft(im1, /center)

c=conj(fft0)*fft1
conv=abs(fft(c, /inverse, /center))
mx=MAX(conv, Ind)
one2n,ind,conv,xm,ym

if ~keyword_set(whole_pixel) then begin
  f=dblarr(3,3)
  ix0=xm eq 0?nx-1:xm-1
  ix1=xm eq nx-1?0:xm+1
  iy0=ym eq 0?ny-1:ym-1
  iy1=ym eq ny-1?0:ym+1
  ix=[ix0,xm,ix1]
  iy=[iy0,ym,iy1]
  for i=0,2 do for j=0,2 do f[i,j]=conv[ix[i],iy[j]]  
  dfdx=(f[2,1]-f[0,1])/2.
  dfdy=(f[1,2]-f[1,0])/2.
  d2fdx2=(f[2,1]+f[0,1]-2*f[1,1])/(1.^2)
  d2fdy2=(f[1,2]+f[1,0]-2*f[1,1])/(1.^2)
  d2fdxdy=(f[2,2]+f[0,0]-f[0,2]-f[2,0])/(4*1.*1.)
  xlineareq=(d2fdy2*dfdx-d2fdxdy*dfdy)/(d2fdxdy^2-d2fdx2*d2fdy2)
  ylineareq=(d2fdx2*dfdy-d2fdxdy*dfdx)/(d2fdxdy^2-d2fdx2*d2fdy2)
  xm=xm+xlineareq
  ym=ym+ylineareq
endif

if xm gt nx2 then xm=xm-nx
if ym gt ny2 then ym=ym-ny

return,[xm,ym]

end