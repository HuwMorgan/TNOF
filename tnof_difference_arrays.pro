;+
;
;Name: tnof_difference_arrays
;
;Purpose: Calculates finite difference arrays (derivatives) in x,y, and time, suitable
;       for use in the modified Lucas-Kanade algorithm. This procedure is called by tnof_lk, and
;       is unlikely to be called for any other purpose, so my notes here are sparse. 
;
;Input variables:
; DATACUBE: Input datacube of dimensions [x,y,time] and size [nx,ny,nt]
; 
; KERWDTH: Width of differencing kernel
;
;Keywords:
; vx (and vy) = user-supplied current estimate of the x (and y) velocity components, in pixels per time step
;
;Output:
;ax: dI/dx
;ay: dI/dy
;at: dI/dt
;
; Author and history:
;      Written by Huw Morgan 2022, hmorgan@aber.ac.uk
;
;-
pro tnof_difference_arrays,datacube,kerwdth,ax,ay,at,vx=vx,vy=vy

print,'Calculating difference arrays...'
sizearr,datacube,nx,ny,nt
ker0=gaussian_function(kerwdth,/norm)
ker=finite_difference_1d(ker0)
nk=n_elements(ker)
nk2=floor(nk/2.)

kert=rebin(reform(-ker,1,1,nk),nx,ny,nk)
indt=lindgen(nk)-nk2

if keyword_set(vx) then begin
  nnx=rebin(findgen(nx),nx,ny)
  nny=rebin(reform(findgen(ny),1,ny),nx,ny)
endif

ax=convol(datacube,ker,/edge_trunc)
ay=convol(datacube,reform(ker,1,n_elements(ker),1),/edge_trunc)
at=fltarr(nx,ny,nt)
for it=0,nt-1 do begin
  if it mod 50 eq 0 then print,it,' out of ',nt-1
  itl=(it-nk2)>0
  itr=(it+nk2)<(nt-1)
  im=datacube[*,*,itl:itr]
  ikl=(nk2-it)>0
  ikr=(nt-it+nk2)<(nk-1)
  if keyword_set(vx) then begin
    for it2=ikl,ikr do begin
      if indt[it2] eq 0 then continue
      im[*,*,it2-ikl-1]=interpolate(im[*,*,it2-ikl-1],nnx+vx*indt[it2],nny+vy*indt[it2],cubic=-0.5)
    endfor
  endif
  at[*,*,it]=total(kert[*,*,ikl:ikr]*im,3)
endfor

end