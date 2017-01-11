function [d] = festimate(d)
%% estimate and plot the data

%%------------------------------------------------------
%% step 3: model estimation
load(d.fname_SPM);

nirs_data = d.nirs_data;   %% edit from AH;

switch SPM_nirs.nirs.step
    case 'estimation'
        disp('The process of estimation has been already done. Please do the step of model specification, again.');
        SPM_nirs = [];
        return;
end

disp('Model parameter estimation starts...');
switch SPM_nirs.nirs.Hb
    case 'HbO'
        Y = nirs_data.oxyData;
    case 'HbR'
        Y = nirs_data.dxyData;
    case 'HbT'
        tf = isfield(nirs_data, 'tHbData');
        if tf == 0
            Y = nirs_data.oxyData + nirs_data.dxyData;
        elseif tf == 1
            Y = nirs_data.tHbData;
        end
end

% estimation of GLM parameters using either percoloring or prewhitening
if isfield(SPM_nirs.xVi, 'V') == 1 % precoloring method 
    SPM_nirs = rmfield(SPM_nirs, 'xVi');
    [SPM_nirs] = precoloring(SPM_nirs, Y);
elseif isfield(SPM_nirs.xVi, 'V') == 0
    'using prewhitening';
    [SPM_nirs] = prewhitening(SPM_nirs, Y, pathn);
end
disp('nearly there ...');
save(fullfile(d.root,d.babydir,[ 'SPM_indiv_' SPM_nirs.nirs.Hb '.mat']), 'SPM_nirs');

try
    [pathn, name, ext] = fileparts(d.fname_SPM);
    pathn = [pathn filesep];
catch
    keyboard
    idx = find(d.fname_SPM == filesep);
    pathn = d.fname_SPM(1:idx(end));
end
% delete precalculated files (e.g. interpolated beta, its
% covariance and t- or F-statistics)
fname_others = cellstr(spm_select('FPList', pathn, ['^interp.*\' SPM_nirs.nirs.Hb '.mat$']));
if strcmp(fname_others{1}, filesep) ~= 1
    delete(fname_others{:});
end
fname_others = cellstr(spm_select('FPList', pathn, '^interp_matrix.*\.mat$'));
if strcmp(fname_others{1}, filesep) ~= 1
    delete(fname_others{:});
end
disp('Estimation of model parameters has been completed.'); 


%[SPM_nirs] = estimation_batch(d.fname_SPM, d.outname);
