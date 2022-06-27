function minmaxmult,a0,a1,a2,a3,a4,a5,a6,robust=robust

mnmx=[1.d64,-1.d64]

a=dblarr(n_params(),2)
for i=0,n_params()-1 do begin
  com='a[i,*]=minmax_huw(a'+strcompress(string(i),/rem)+',/nan,robust=robust)'
  void=execute(com)
endfor
mnmx=minmax_huw(a,/nan)

return,mnmx

end