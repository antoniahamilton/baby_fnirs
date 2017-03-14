function d = fplotbetas_CB(d,desno)

load(d.design(desno).fname_SPM)

%%------------------------------------------------------
%% step 4 - manually visualise the betas
betas = SPM_nirs.nirs.beta;

if d.derivatives==0
    for cond = 1:5
    cbeta(cond,:)=betas(cond,:); 
    end
else
%% combine betas according to Calhoun 2004 method
% 5 conditions: Reminder_Native, Reminder_non-Native, Mimicry_Native, Mimicry_non-Native,
% Baseline
v=1:length(d.regressordur); % e.g. v=[1 2 3 4 5]
bb = repelem(v,3); %% v= [1 1 1 2 2 2 3 3 3 etc. ] there are 3 columns for each condition, and we are combining them into a single column for each
for cond = 1:length(d.regressordur)
    cind = find(bb==cond);
    cbeta(cond,:) = sign(betas(cind(1),:)).*sqrt(sum(betas(cind,:).^2,1));
end

end

%% select contrast of interest
con = d.contrast;
final_contrast = con*cbeta; 
final_contrast(~d.cbad) = NaN;

%keyboard
%% plot betas over grid

%% make grid
for i=1:length(d.chlab)    
    ss = d.Scrpos(d.chlab(i,1),:);
    dd = d.Detpos(d.chlab(i,2),:);

    xpos(i,:) = mean([ss(1),dd(1)]);
    ypos(i,:) = mean([ss(2),dd(2)]);
    
    % sort by left/right/frontal
    if any(d.chlab(i,3)==d.channelsleft)
       left(i)=1;
    else left(i)=0;
    end
    if any(d.chlab(i,3)==d.channelsright)
        right(i)=1;
    else right(i)=0;
    end
    if d.frontal==1
        if any(d.chlab(i,3)==d.channelsfront)
            frontal(i)=1;
        else frontal(i)=0;
        end
    end
end
        
%% sort by left/right/frontal
left = logical(left);
right=logical(right);
if d.frontal==1
frontal=logical(frontal);
end

% added by CdK to make sure the data is plotted over the correct channel locations
leftbetas=d.chlab(left,3);
rightbetas=d.chlab(right,3);
if d.frontal==1
frontalbetas=d.chlab(frontal,3);
end

leftdata = [xpos(left,:),ypos(left,:),final_contrast(leftbetas)'];
rightdata = [xpos(right,:),ypos(right,:),final_contrast(rightbetas)'];
if d.frontal==1
frontaldata= [xpos(frontal,:), ypos(frontal,:),final_contrast(frontalbetas)'];
end


%% plot the data
figure(2), clf
colormap jet
set(gcf,'Position',[100,100,1000,1000]) %[50,50,1000,400]
subplot(2,2,1)
smarties_plot(leftdata);
title(['left hemi ',d.babydir,' - ',d.hb])
hold on

subplot(2,2,2)
smarties_plot(rightdata);
title(['right hemi ',d.babydir,' - ',d.hb])
hold on

if d.frontal==1
subplot(2,2,3)
smarties_plot(frontaldata);
title(['frontal', d.babydir,' - ', d.hb])
hold on
end

% save the figure
print('-dtiff','-zbuffer',fullfile(d.root,d.babydir,[d.hb,'_plots.tif']))

%keyboard
%%------------------------------------------------------
%% save the data
str = ['d.',d.hb,'_final_contrast = final_contrast;'];
eval(str);
str = ['d.',d.hb,'_betas = betas;'];
eval(str);


