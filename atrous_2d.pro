;+
; NAME:
;   ATROUS_2D
; PURPOSE:
;   Perform a 2-D "a trous" wavelet decomposition on an image. 
;   THIS PROGRAM INCLUDING THIS DESCRIPTION IS AN ALMOST EXACT COPY OF THE 2003 PROGRAM WRITTEN BY
;   Erik Rosolowsky <eros@cosmic>, MODIFIED IN 2005 BY Russ Hewett (rhewett@vt.edu), ALL BASED ON
;   Stark & Murtaugh
;             "Astronomical Image and Data Analysis"
;
; CALLING SEQUENCE:
;   ATROUS, image [, decomposition = decomposition, $
;                 filter = filter, n_scales = n_scales, /check]
;
; INPUTS:
;   IMAGE -- A 2-D Image to Filter
;
; KEYWORD PARAMETERS:
;   FILTER -- A 1D (!!) array representing the filter to be used.
;             Defaults to a B_3 spline filter (see Stark & Murtaugh
;             "Astronomical Image and Data Analysis", Spinger-Verlag,
;             2002, Appendix A)
;   N_SCALES -- Set to name of variable to receive the number of
;               scales performed by the decomposition.
;   CHECK -- Check number of scales to be performed and return.
;   MIRROR -- This is a workaround for the lack of edge mirroring in
;        IDL's CONVOL routine.  Depends on pad_image and
;        depad_image to expand and unexpand the images.
; OUTPUTS:
;   DECOMPOSITION -- A 3-D array with scale running along the 3rd axis
;                    (large scales -> small scales). The first plane
;                    of the array is the smoothed image. To recover
;                    the image at any scale, just total the array
;                    along the 3rd dimension up to the scale desired.
;
;
; RESTRICTIONS:
;   Uses FFT convolutions which edge-wrap instead of mirroring the
;   edges as suggested by Stark & Mutaugh.  Wait for it.
;  -Russ: Maybe not anymore.  Mirroring is super slow though due to an
;      order of magnitude increase in the size of the image being convolved.
;
; MODIFICATION HISTORY:
;
;       Mon Oct 6 11:49:50 2003, Erik Rosolowsky <eros@cosmic>
;    Written.
;    09-jun-2005, Russ Hewett (rhewett@vt.edu)
;      -Added Mirror keyword
;
;-


; Start with simple filter
;  filter = [0.25, 0.5, 0.25]


function atrous_2d,  image,  filter = filter, $
             n_scales = n_scales, check = check,cp=cp


if n_elements(filter) eq 0 then filter = 1./[16, 4, 8/3., 4, 16]
sizearr,image,nx,ny

n_scales = floor(alog((nx < ny)/n_elements(filter))/alog(2))
if keyword_set(check) then return, n_scales

nb=2^(2+n_scales)+1;max filter size
decomp = fltarr(nx+nb*2,ny+nb*2,n_scales+1)

ix=lindgen(nx+nb*2)-nb
ind=where(ix lt 0)
ix[ind]=abs(ix[ind])
ind=where(ix ge nx)
ix[ind]=2*(nx-1)-ix[ind]
ix=rebin(ix,nx+nb*2,ny+nb*2)

iy=lindgen(ny+nb*2)-nb
ind=where(iy lt 0)
iy[ind]=abs(iy[ind])
ind=where(iy ge ny)
iy[ind]=2*(ny-1)-iy[ind]
iy=rebin(reform(iy,1,ny+nb*2),nx+nb*2,ny+nb*2)
im=image[ix,iy]

for k = 0, n_scales-1 do begin
  nk=n_elements(filter)
  smooth=convol(im,filter,/center,/nan)
  smooth=convol(smooth,reform(filter,1,nk),/edge_trunc,/nan)
  decomp[*, *, n_scales-k] = im-smooth
  im = smooth
  newfilter = fltarr(2*n_elements(filter)-1) 
  newfilter[2*findgen(n_elements(filter))] = filter
  filter = newfilter
endfor

; Stick last smoothed image into end of array
if not(keyword_set(cp)) then decomp[*, *, 0] = smooth else $
decomp=decomp[*,*,1:*]
decomp=decomp[nb:nb+nx-1,nb:nb+ny-1,*]
cp=smooth

return,decomp

end
