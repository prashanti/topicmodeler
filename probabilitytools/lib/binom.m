function y=binomial(x,p,n)
% p=binomial(x,p,n) returns the values of the binomial distribution
% with parameters p and n, for the elements of the vector/matrix x
if n<=150
  y=gamma(n+1)./gamma(x+1)./gamma(n-x+1).*p.^x.*(1-p).^(n-x);
else
  disp('binom: n too large for exact computation, normal approx used')
  y=(erf((x+.5-p*n)/sqrt(2*n*p*(1-p)))-erf((x-.5-p*n)/sqrt(2*n*p*(1-p))))/2;
end  
