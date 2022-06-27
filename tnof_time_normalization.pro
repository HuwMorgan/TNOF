;+
;
;Name: tnof_time_normalization
;
;Purpose: Applies the bandpass filtering and amplitude normalization of the TNOF process.
;
;Input variables:
; DATACUBE: Input datacube
; TAI: time of each datacube timestep in seconds (e.g. in TAI seconds, or Julian seconds,
;        or seconds from first time step, or any suitable system based on seconds, but not date strings!)
;
;Keywords:
; timewindowuser: user can specify the one-sigma width of the wide smoothing Gaussian kernel, 
;                 in seconds. Default 150s. 
;
; totkerwidth: returns the total wide kernel width, so user can crop margins from datacube to avoid
;       edge effects.
;
;Output: Time-normalized datacube
;
;
; Author and history:
;      Written by Huw Morgan 2022, hmorgan@aber.ac.uk
;
;-


function tnof_time_normalization,datacube,tai,timewindowuser=timewindowuser,totkerwidth=totkerwidth

constant=0.3

print,'Applying time normalization...'
timewindow=keyword_set(timewindowuser)?timewindowuser:12.*12.5;=150 seconds as in paper

sizearr,datacube,nx,ny,nt

if n_elements(tai) eq 0 then tai=dindgen(nt)*12
dt=median(tai-shift(tai,1))
nsmo=2.
ker=gaussian_function(nsmo,/norm)
ker=reform(ker,1,1,n_elements(ker))

dt=median(tai-shift(tai,1))
nwindow=timewindow/dt
kerw=gaussian_function(nwindow,/norm)
totkerwidth=n_elements(kerw)
kerw=reform(kerw,1,1,n_elements(kerw))

print,'Convolving datacubes'
datacube_smooth=convol(datacube,ker,/edge_trunc,/nan)
datacube_mean=convol(datacube_smooth,kerw,/edge_trunc)
datacube_stddev=sqrt(convol((datacube_smooth-datacube_mean)^2,kerw,/edge_trunc))
print,'Calculating time-normalized values'
datacube_out=(datacube_smooth-datacube_mean)/(datacube_stddev+constant)

return,datacube_out

end


