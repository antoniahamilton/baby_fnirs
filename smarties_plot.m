function sig = smarties_plot(data)
%% plot a nice smarties pattern with the optimal smoothing
%% data = [x,y,values]  (n x 3)
%% open a figure first

bad = any(isnan(data'));
badxy = data(bad,1:2);
data = data(~bad,:);

lims = max(abs(data(:,3)));
lims = [-lims,lims]; %scale set automatic
%lims = [-0.6, 0.6]; %set scale manually

sigin = nanmean(nanmean(abs(diff(data(:,1:2)))));

[sig,fval] = fminsearch('optsmoothval',sigin,[],data);
out = valinterp(data,sig,[100,100]);

sdata = (data(:,3)-min(lims)) ./range(lims);
sdata = floor((sdata)*63)+1;

if(any(sdata<1))
    keyboard
end

gca;
cla;
imagesc(out(:,1),out(:,2),out(:,3:end)',lims);
%contourf(out(:,1),out(:,2),out(:,3:end)',0);
hold on
colorbar
cm = colormap;

cx = cos(linspace(-pi,pi,20))*sigin/5;
cy = sin(linspace(-pi,pi,20))*sigin/5;
%% plot smarties
for i=1:length(data)
    h=patch(cx+data(i,1),cy+data(i,2),cm(sdata(i),:));
    set(h,'LineWidth',0.1);
end
axis equal
set(gca,'YDir','Normal')

%% plot empty circles for bad data
for i=1:size(badxy,1)
    h=patch(cx+badxy(i,1),cy+badxy(i,2),[1 1 1]);
    set(h,'LineWidth',0.1);
end
axis equal
set(gca,'YDir','Normal')

% %% show test values:
% tno = 8;
% h1 = (out(:,1)-data(5,1)).^2;
% h1 = find(h1==min(h1));
% h2 = (out(:,1)-data(5,1)).^2;
% h2 = find(h2==min(h2));
% 
% demo = [data(tno,:),out(h1,h2+2)]

