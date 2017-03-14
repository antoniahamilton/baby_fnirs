function [out] = valinterp(data,sig,sz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% interpolate between values to get smooth force field
%% input data (a,b,x) where a&b are locations, x is values
%% also input sig, ie smoothing radius and sz [1x2] of desired output, ie aout & bout size
%% returns out (a,b,x) with smooth locations and vectors
%% see also vectorinterp, optsmoothvec and optsmoothval
% Used by fplotbetas script

aa = data(:,1);
bb = data(:,2);
cc = data(:,3);

a=linspace(min(aa),max(aa),sz(1));
b=linspace(min(bb),max(bb),sz(2));
mu = 0;

for i=1:sz(1)
   for j=1:sz(2)
      
      d=hypot(aa-a(i),bb-b(j));
      n=normpdf(d,mu,sig);
      
      if(sum(n)<0.000001)
         n(1) = n(1)+0.000001;
      end
            
      c(i,j)=sum(n.*cc)/sum(n);
   end
end

%imagesc(a,b,c');
%colorbar
%pause(0.1);

out(:,1) = a';
out(:,2) = b';
out(:,3:(3+sz(2)-1)) = c;
