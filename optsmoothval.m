function [cost] = optsmoothval(sig,data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% get the optimal sig for smoothing values
%% sig is the initial guess
%% data is (a,b,x), ie: locations and vectors
%% returns cost

cost = 0;

for i=1:length(data)
   
   id=1:length(data);
   id=(id~=i);
   
   pt = data(i,1:2);
   des = data(i,3);
   
   aa = data(id,1);
   bb = data(id,2);
   xx = data(id,3);
   
   mu = 0;
   d=sqrt( (aa-pt(1)).^2 + (bb-pt(2)).^2 );
   n=normpdf(d,mu,sig);
   
   x=nansum(n.*xx)/nansum(n);
   
  %error = (des-x).^2;
   error = abs(des-x);
   
   cost = cost+error;
end

