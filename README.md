# TNOF
IDL code for Time Normalized Optical Flow method, suitable for solar atmospheric image time series

Top level program is tnof.pro

;Name: TNOF
;
;Purpose: Time Normalized Optical Flow. 
; Implements TNOF method on datacube, method described in https://arxiv.org/abs/2206.09640 
; If you use this method in published work, please cite:
;   https://arxiv.org/abs/2206.11077 (or paired Astrophysical Journal Letter)
;   https://arxiv.org/abs/2206.09640 (or paired Solar Physics article)
; Method applies the following main steps:
;   - image alignment, so removing any residual translation caused by e.g. solar rotation
;   - rebinning. Recommended for full-resolution AIA/SDO images, IRIS etc.
;   - time-normalization. A processing step based on bandpass filtering and amplitude 
;     normalization in the time domain, see papers.
;   - A TROUS decomposition, to remove the highest spatial frequencies (noise reduction). 
;     This step greatly improves the clarity of results.
;   - Modified Lucas-Kanade optical flow algorithm to calculate the dominant velocity field  
;The image alignment step can be slow, but is important. On a 1000x1000x600 datacube, it took an hour on 
;an iMac 3.7GHz 6-core Intel i5, 32Gb RAM. Note this step is applied to the 
;non-rebinned (full-resolution) data in order to preserve accuracy.
;
;Input variables:
; DATACUBE_IN: user-supplied datacube of dimensions [spatial,spatial,time] = [x,y,t]
; Time steps must be constant (non-varying cadence). As a guide, we recommend several hundred
; time steps. Using AIA/SDO Extreme UltraViolet data, we usually use 2 hours of observations, 
; so around 600 images. Method will find the velocity field that best satisfies the
; observations at each spatial pixel, so no point having data that contains large temporal changes
; such as eruptions or flares.
; 
; HDRS: The metadata headers corresponding to every time step. 
;
;Keywords:
; rebin: user can specify the level of rebinning. Rebin = 4 (default) is recommended for AIA/SDO
;   full-resolution data, meaning that 4x4 spatial input pixels are combined by local average into one 
;   output pixel. NOTE that we use the IDL rebin function, which requires integer multiples of pixels, so
;   the procedure automatically crops images to satisfy this requirement 
;   (e.g. if Nx = 512, and rebin = 2, then output is Nx_out = 256 - a multiple that satisfies an
;    integer divison by 2, or Nx/2, so no cropping. If Nx=513, our procedure will crop one pixel
;    margin from the x dimension, to give Nx_new = 512, and Nx_out=256).  
;
; no_align: do not apply spatial alignment over time (default is to apply). 
; 
;Output: data structure containing the following fields:
; hdr: header for the time step corresponding to the median time of 
; all the image time series. This header is modified to account for any
; cropping and rebinning. Useful for plotting coordinates etc. in subsequent plots
; vx: the x-velocity component
; vy: the y-velocity component
; image: the image for the median time step. Useful for subsequent display.
;
; Author and history:
;      Written by Huw Morgan 2022, hmorgan@aber.ac.uk
;	Questions or comments welcomed.
;       
;-
