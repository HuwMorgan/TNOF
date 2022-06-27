;+
;
;Name: tnof_align_datacube
;
;Purpose: Image alignment for datacube of dimensions [spatial,spatial,time] = [x,y,t]
; Calculates image-by-image x,y, pixel translations for optimal alignment
; Calculates the cumulative shift over time.
; Fits this shift to a 2nd-order polynomial.
; Uses this fitted shift to align each image using interpolation
;
;Input variables:
; DATACUBE_IN: Input datacube
; T: time of each datacube timestep (e.g. in TAI, or JD, or any suitable number, but not date strings!)
;
;Keywords:
; psdir: if user supplies name of path for this keyword, then code will output a postscript file
;   named 'tnof_align.eps' showing the results of the alignment and fitting.
;
; indt: this keyword returns the time index of the 'master' timestep, corresponding to the 
;   time step at the median time. This time step is special, since this image is treated as a master, and 
;   is not aligned (x and y shifts are all zero for this time step). 
;
;Output: Aligned datacube
;
;Calls: If user has set the psdir keyword, then programs cgcolor and ctload from the 
; IDL Coyote library are called http://www.idlcoyote.com/documents/programs.php
;
; Author and history:
;      Written by Huw Morgan 2022, hmorgan@aber.ac.uk
;
;-

function preprocess,im,nker

  nsig=3
  k=gaussian_function(nker,/norm)
  ktrans=transpose(k)

  av=convol(convol(im,k,/edge_trunc),ktrans,/edge_trunc)
  diff=im-av
  st=sqrt(convol(convol(diff^2,k,/edge_trunc,/nan),ktrans,/edge_trunc,/nan))
  ind=where(abs(diff) gt nsig*st,cnt)
  if cnt gt 0 then im[ind]=av[ind]
  im=im-convol(convol(im,k,/edge_trunc),ktrans,/edge_trunc)
  return,im
  
end

function tnof_align_datacube,datacube_in,t,indt=indt,psdir=psdir

sizearr,datacube_in,nx,ny,nt

print,'Calculating translational alignments'
xy=fltarr(nt-1,2)

nker=5
imprev=preprocess(datacube_in[*,*,0],nker)

for i=0,nt-2 do begin
  if i mod 20 eq 0 then print,i,' out of ',nt-2
  imnow=preprocess(datacube_in[*,*,i+1],nker)
  xynow=fft_corr_track_huw(imprev,imnow)
  xy[i,*]=xynow
  imprev=imnow
endfor

void=min(abs(t-median(t)),indt)
xt=total(xy[*,0],/cum)
yt=total(xy[*,1],/cum)

t2=t-t[indt]
fx=poly_fit(t2[1:*],xt,2)
xf=fx[0]+fx[1]*t2+fx[2]*(t2^2)
xmidt=xf[indt]
xf=xf-xmidt

fy=poly_fit(t2[1:*],yt,2)
yf=fy[0]+fy[1]*t2+fy[2]*(t2^2)
ymidt=yf[indt]
yf=yf-ymidt

if keyword_set(psdir) then begin
  psname=psdir+'/tnof_align.eps'
  set_ps_huw,psname,7,8
  !p.multi=[0,1,2]
  yra=minmaxmult(xt-xmidt,xf)
  ctload,0
  plot,t2,xt-xmidt,/psym,yra=yra,title='X alignment',xtitle='Time (s from median)',ytitle='Pixels'
  oplot,t2,xf,col=cgcolor('red')
  yra=minmaxmult(yt-ymidt,yf)
  plot,t2,yt-ymidt,/psym,yra=yra,title='Y alignment',xtitle='Time (s from median)',ytitle='Pixels'
  oplot,t2,yf,col=cgcolor('red')
  ctload,0
  setx,/cle,/clo
endif


print,'Aligning datacube'
datacube_out=fltarr(nx,ny,nt)
datacube_out[*]=!values.f_nan
x1=findgen(nx)
y1=findgen(ny)
for i=0,nt-1 do begin
  if i mod 20 eq 0 then print,i,' out of ',nt-2
  ix=x1+xf[i]
  iy=y1+yf[i]
  datacube_out[*,*,i]=interpolate(datacube_in[*,*,i],ix,iy,missing=!values.f_nan,/grid,cubic=-1)
endfor

return,datacube_out

end