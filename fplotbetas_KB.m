function d = fplotbetas_KB(d)

load(d.fname_SPM);

%%------------------------------------------------------
%% step 4 - manually visualise the betas
betas = SPM_nirs.nirs.beta;

% combine betas according to Calhoun 2004 method
% 3 numbers in bb per experimental condition
bb = [1 1 1 2 2 2 3 3 3 4 4 4 5 5 5]; %% here there are 3 columns for each condition, and we are combining them into a single column for each
for cond = 1:5
    cind = find(bb==cond);
    cbeta(cond,:) = sign(betas(cind(1),:)).*sqrt(sum(betas(cind,:).^2,1));
end

% %Use for HRF without derivatives added by CdK
% for cond = 1:5
%     cbeta(cond,:)=betas(cond,:); 
% end


%% calculate contrast of FaceDirect > FaceAverted
con = [1 -1 0 0 0];  %% 1 -1 0 0  this would be the contrast of FaceDirect > Face Averted
final_contrast = con*cbeta;
final_contrast(~d.cbad) = NaN;

%% plot betas over grid

%% make grid
for i=1:length(d.chlab)    
    ss = d.Scrpos(d.chlab(i,1),:);
    dd = d.Detpos(d.chlab(i,2),:);

    xpos(i,:) = mean([ss(1),dd(1)]);
    ypos(i,:) = mean([ss(2),dd(2)]);
end
        
%% sort by left/right

left = d.chlab(:,3)<13.5;
right = d.chlab(:,3)> 13.5;

% added by CdK to make sure the data is plotted over the correct channel locations
[i,reorder] = sort(d.chlab(:,3));
leftbetas=left(reorder);
rightbetas=right(reorder);

leftdata = [xpos(left,:),ypos(left,:),final_contrast(leftbetas)'];
rightdata = [xpos(right,:),ypos(right,:),final_contrast(rightbetas)'];

%% plot the data
figure(2), clf
colormap jet
set(gcf,'Position',[50,50,1000,400])
subplot(1,2,1)
smarties_plot(leftdata);
title(['left hemi ',d.babydir,' - ',d.hb])
hold on

subplot(1,2,2)
smarties_plot(rightdata);
title(['right hemi ',d.babydir,' - ',d.hb])
hold on

% save the figure
print('-dtiff','-zbuffer',fullfile(d.root,d.babydir,[d.hb,'_plots.tif']))

%keyboard
%%------------------------------------------------------

%% save the data
str = ['d.',d.hb,'_final_contrast = final_contrast;'];
eval(str);
str = ['d.',d.hb,'_betas = betas;'];
eval(str);


