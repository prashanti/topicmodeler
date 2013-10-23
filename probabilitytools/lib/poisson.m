function y=poisson(x,lambda)
% p=poisson(x,lambda) returns the values of the poisson distribution
% with parameter lambda, for the elements of the vector/matrix x
kl=find(x<=150);
y(kl)=exp(-lambda)*lambda.^x(kl)./gamma(x(kl)+1);
kh=find(x>150);
if length(kh)>0
  disp('possion: some x are too large, normal approx used')
  y(kh)=(erf((x(kh)+.5-lambda)/sqrt(2*lambda))-erf((x(kh)-.5-lambda)/sqrt(2*lambda)))/2;
end  