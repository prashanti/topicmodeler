function k=dice(p)
% k=dice(p) - generates a random number k between 1 and length(p)
%             such that Prob(k=i) = p(i)

cp=cumsum(p);
k=min(find(rand<=cp));
%[dummy,k]=max(p.*rand(size(p)));  %% wrong

return

% Test dice
p=[.1,.2,.7];n=[];for i=10000:-1:1;n(i)=dice(p);end
hist(n,length(p))

cp=cumsum(p);
k=[];r=0:.0001:1;for i=length(r):-1:1;k(i)=min(find(r(i)<=cp));end
plot(r,k)
