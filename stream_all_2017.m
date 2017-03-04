
%% set up a total processing stream
clear all, close all

% define the path where all the subjects folders are stored (with the .nirs files inside the folders)
root = '/Volumes/Baby Face 1/Baby Face/NIRS data/SPM-NIRS-CARINA-NEW/Visit 1/Final';


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
           '50', 'BabyFace50_relabeled.nirs'
           '52', 'BabyFace52_relabeled.nirs'
           '55', 'BabyFace55_relabeled.nirs'
           '57', 'BabyFace57_relabeled.nirs'
           '58', 'BabyFace58_relabeled.nirs'
           '59', 'BabyFace59_relabeled.nirs'
           '60', 'BabyFace60_relabeled.nirs'};

torun = 1:length(babies); 

%%%%%%%%%%%% load the data into Matlab
for kk = torun
    
    clear d
    d.root = root;
    d.babydir = babies{kk,1};
    d.raw = babies{kk,2};
    
    %% load in input file (e.g. SPM-NIRS input.xlsx) with original Homer events, regressor names, contrast of interest, and channel names (in second tab
    d.fullname='SPM-NIRS inputV1.xlsx';
    d=floadinput(d);
    
    %% load in data from Homer
    d = fload_homer_2017(d); 
    d.procname = [babies{kk,1},filesep,'processed.mat'];
    save(fullfile(d.root, d.procname),'d')
 
    Hbtypes = {'hbo','hbr','hbt', 'hbd'};
    %% do this 4 times
    for jj=1:4  
        
        disp(['Doing design for : ',Hbtypes{jj}]);
        
        d.hb = Hbtypes{jj};
        
        %% fit the design matrix
        d = fdesign4spmnirs_2017(d); 
        save(fullfile(d.root, d.procname),'d')
        
        pname = fullfile(d.root,d.babydir,[Hbtypes{jj},'_design_matrix.tif']);
        %% print the plot
        print('-dtiff','-zbuffer',pname)
        
        %% estimate the standard design matrix
        d = festimate_2017(d,jj); 
        save(fullfile(d.root, d.procname),'d')
               
        %% plot the betas
         desno = length(d.design);
         d = fplotbetas_2017(d,desno);
         save(fullfile(d.root, d.procname),'d');  
    end
    
    disp('-------------------------------------------')
    disp(['Processing complete for : ',babies{kk,1}])
    disp('-------------------------------------------')
   
end




