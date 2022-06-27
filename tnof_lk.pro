;+
;
;Name: tnof_align_datacube
;
;Purpose: Applies modified Lucas-Kanade algorithm to datacube and calculates x, y velocity components
;
;Input variables:
; DATACUBE: Input datacube of dimensions [x,y,time] and size [nx,ny,nt]
;
;Keywords:
; NONE
;
;Output: 
;vxmain: x velocity component, in units of pixels per time step. Size nx,ny
;
;vymain: y velocity component.
;
; Author and history:
;      Written by Huw Morgan 2022, hmorgan@aber.ac.uk
;
;-

pro tnof_lk,datacube,vxmain,vymain

sizearr,datacube,nx,ny,nt
kerwdth=1.5

print,'Least squares Lucas-Kanade'
vx=fltarr(nx,ny)
vy=fltarr(nx,ny)
vprev=fltarr(nx,ny)
res=fltarr(nx,ny)

niter=6

iiter=0
repeat begin
  
  print,'Iteration: ',iiter
  
  tnof_difference_arrays,datacube,kerwdth,ax,ay,at,vx=iiter gt 0?vxmain:0,vy=iiter gt 0?vymain:0
  
  print,'LK least squares...'
  for i=0,nx-1 do begin
    if i mod 50 eq 0 then print,i,' out of ',nx-1
    for j=0,ny-1 do begin
      atnow=reform(at[i,j,*])
      axnow=reform(ax[i,j,*])
      aynow=reform(ay[i,j,*])
      a=rotate([[axnow],[aynow]],4)
      vnow=least_squares_huw(a,atnow,fit=fit)
      vx[i,j]=vnow[0]
      vy[i,j]=vnow[1]
      res[i,j]=mean(abs(fit-atnow))/mean(abs(atnow))
    endfor
  endfor
  
  nmd=5
  md=lindgen(nmd)+2
  mdx=fltarr(nx,ny,nmd)
  mdy=fltarr(nx,ny,nmd)
  for imd=0,nmd-1 do begin
    ker=gaussian_function([1,1]*md[imd],/norm)
    mdx[*,*,imd]=convol(vx,ker,/edge_trunc)
    mdy[*,*,imd]=convol(vy,ker,/edge_trunc)
  endfor
  indmd=(interpol([0,nmd-1],[0.5,1.1],res)>0)<(nmd-1)
  vx=interpolate(mdx,rebin(findgen(nx),nx,ny),rebin(reform(findgen(ny),1,ny),nx,ny),indmd)
  vy=interpolate(mdy,rebin(findgen(nx),nx,ny),rebin(reform(findgen(ny),1,ny),nx,ny),indmd)
  
  if iiter eq 0 then begin
    vxmain=vx
    vymain=vy
  endif else begin
    vxmain=vxmain+vx
    vymain=vymain+vy
  endelse
  
  v=sqrt(vx^2+vy^2)
  vdf=mean(abs(v-vprev)/mean(vprev))
  vprev=v
  print,iiter,vdf
  
  
  enditer=iiter ge (niter-1) or vdf lt 0.1
  
  iiter++
  
endrep until enditer

end