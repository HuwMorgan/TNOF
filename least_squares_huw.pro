;b is measurement vector, with m elements
;a is n column x m row array
;returns least-square solution
;weights same length as b
function least_squares_huw,a,b,weights=weights,fit=fit

sizearr,a,n,m
if keyword_set(weights) then begin
  aa2=a*rebin(reform(weights,1,m),n,m)
  xx=transpose(aa2)##aa2
  xy=transpose(aa2)##(b*weights)
  c=reform(invert(xx)##xy)
endif else begin
  xx=transpose(a)##a
  xy=transpose(a)##b
  c=reform(invert(xx)##xy)
endelse

if arg_present(fit) then fit=total(a*rebin(c,n,m),1)

return,c

end