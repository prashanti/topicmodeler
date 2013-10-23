clear functions

% cvx-based linear classifier

samples0=rand(10,3);
samples0=samples0./(sum(samples0,2)*ones(1,size(samples0,2)));
samples1=rand(10,3);
samples1=samples1./(sum(samples1,2)*ones(1,size(samples1,2)));

plot(samples0(:,1),samples0(:,2),'o',samples1(:,1),samples1(:,2),'+');

cvx_begin
  variables x(3);
  variables b0(size(samples0,1));
  variables b1(size(samples1,1));
  
  samples0*x<b0; % would like b0 <=0
  samples1*x>-b1; % would like b1 <=0
  
  %  norm(x)>1
  
  minimize sum(pos(b0))+sum(pos(b1))
cvx_end

samples0*x
samples1*x

b0
b1
