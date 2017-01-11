   clear all, close all
root = '/Volumes/SAMSUNG/Baby Face/NIRS data/SPM-NIRS-CARINA-NEW/Visit 1/'

%These are the subfolders within the subject folder which have the data to
%be plotted
adir = 'Final analyses/HRF and derivatives'

dataHomer = 1; % if not, please set to be 0 % by jun

%% first list the directory, then the name of the raw data file
babies = {'06','BabyFace06_relabeled.nirs'
           '07', 'BabyFace07_relabeled.nirs'
           '09', 'BabyFace09_relabeled.nirs'
           '10', 'BabyFace10_relabeled.nirs'
           '12', 'BabyFace12_relabeled.nirs'
           '13', 'BabyFace13_relabeled.nirs'
           '14', 'BabyFace14_relabeled.nirs'
           '15', 'BabyFace15_relabeled.nirs'
           '16', 'BabyFace16_relabeled.nirs'
           '19', 'BabyFace19_relabeled.nirs'
           '21', 'BabyFace21_relabeled.nirs'
           '22', 'BabyFace22_relabeled.nirs'
           '23', 'BabyFace23_relabeled.nirs'
           '24', 'BabyFace24_relabeled.nirs'
           '27', 'BabyFace27_relabeled.nirs'
           '32', 'BabyFace32_relabeled.nirs'
           '36', 'BabyFace36_relabeled.nirs'
           '37', 'BabyFace37_relabeled.nirs'
           '39', 'BabyFace39_relabeled.nirs'
           '43', 'BabyFace43_relabeled.nirs'
           '44', 'BabyFace44_relabeled.nirs'
           '45', 'BabyFace45_relabeled.nirs'
           '46', 'BabyFace46_relabeled.nirs'
           '47', 'BabyFace47_relabeled.nirs'
           '48', 'BabyFace48_relabeled.nirs'
           '50', 'BabyFace50_relabeled.nirs'
           '52', 'BabyFace52_relabeled.nirs'
           '55', 'BabyFace55_relabeled.nirs'
           '57', 'BabyFace57_relabeled.nirs'
           '58', 'BabyFace58_relabeled.nirs'
           '59', 'BabyFace59_relabeled.nirs'
           '60', 'BabyFace60_relabeled.nirs'}

 torun = 1:length(babies);
 
 for kk = 1:length(torun)
    
    clear d
    fn = fullfile(root,babies{kk,1},adir,'processed.mat')
    load(fn);
    
    %%% CHECK WHETHER THE BAD CHANNEL EXCLUSION WORKS 
    bind = find(d.cbad ~=1);  %% assume good channels are marked 1

    conhbo(kk,:) = d.hbo_final_contrast;
    conhbr(kk,:) = d.hbr_final_contrast;
    conhbt(kk,:) = d.hbt_final_contrast;
        
    conhbo(kk,bind) = NaN;
    conhbr(kk,bind) = NaN;
    conhbt(kk,bind) = NaN;
    
    bno(kk,:) = str2num(babies{kk,1}(2:end));
    
        
 end

%% make grid
for i=1:length(d.chlab)    
    ss = d.Scrpos(d.chlab(i,1),:);
    dd = d.Detpos(d.chlab(i,2),:);

    xpos(i,:) = mean([ss(1),dd(1)]);
    ypos(i,:) = mean([ss(2),dd(2)]);
end
        
 
ty = {'conhbo','Hb Oxy';
    'conhbr','Hb DeOxy';
    'conhbt','Hb Total'}

for j=1:3
    
    eval(['dd = ',ty{j,1}])
    
    figure(j), clf
    subplot(2,1,1)
   % plot(dd','b.')
    hold on
    boxplot(dd)
    %errorbar(nanmean(dd),nanstd(dd)./sqrt(sum(~isnan(dd))-1),'r-','LineWidth',2)
    plot([0,27],[0,0],'k--')
    set(gca,'XTick',1:26,'XTickLabel', strvcat(num2str(d.chlab(:,3))) ) %change for parietal hat channel numbers
    
    %% do ttests
    %% do ttests
    for i=1:26 %put number of channels here
        [h(i),prob(i)] = ttest(dd(:,i),[],0.05); 
    end
    plot(find(h>0.5),max(dd(:,find(h>0.5)))*1.3,'g*')
    for i=find(h>0.5)
        text(i,max(dd(:,i))*1.6,['p=',num2str(prob(i))])
    end
    title(['Analysis of ',num2str(size(dd,1)),' babies'])
    
    
    %% set up grid for smarties
    left = find(d.chlab(:,3)<13.5); % 23.5 for parietal hat
    right = find(d.chlab(:,3)> 13.5); %23.5 for parietal hat
    md = nanmean(dd);
    
    leftdata = [xpos(left,:),ypos(left,:),md(left)']
    rightdata = [xpos(right,:),ypos(right,:),md(right)']
    
    %% plot the data
    colormap jet
    subplot(2,2,3), cla
    smarties_plot(leftdata);   
    hold on
    text(xpos(left)+1,ypos(left)+1,strvcat(num2str(d.chlab(left,3))))
    for i=1:length(left)
        if(h(left(i)))
            cx = cos(linspace(-pi,pi,20))*2.5;
            cy = sin(linspace(-pi,pi,20))*2.5;
            plot(cx+xpos(left(i)),cy+ypos(left(i)),'w-','LineWidth',3)
        end
    end
    axis equal
    title(['left hemi ',ty{j,2}])
    
    subplot(2,2,4)
    smarties_plot(rightdata)
    hold on
    text(xpos(right)+1,ypos(right)+1,strvcat(num2str(d.chlab(right,3))))
    for i=1:length(right)
        if(h(right(i)))
            cx = cos(linspace(-pi,pi,20))*2.5;
            cy = sin(linspace(-pi,pi,20))*2.5;
            plot(cx+xpos(right(i)),cy+ypos(right(i)),'w-','LineWidth',3)
        end
    end
    axis equal
    title(['right hemi ',ty{j,2}])
        
    dlmwrite([ty{j,1},'.txt'],[bno,dd])
    
end
% 
% for j=1:6
%     figure(j)
%     print('-dtiff','-zbuffer',fullfile(d.root,['summary_plots',num2str(j),'.tif']))
% end
% 

