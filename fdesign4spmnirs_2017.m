function [d] = fdesign4spmnirs_new2(d,~)
%% which design number is this, this will allow to easily build up the PPI analyses
if(isfield(d,'design'))
    ndes = length(d.design)+1;
else
    ndes = 1;
end

nirs_data = d.nirs_data;


for i=1:length(d.regressors)
%% find event onsets
Homerevent=num2str(d.Homerevent(i));
colno = find(strcmp(Homerevent,d.condnames))
r(i).onset =(find(d.ev==colno)./d.rate)+d.offset;
r(i).name = d.regressors{i};
r(i).duration = d.regressordur(i);  
end

d.design(ndes).rr = r;
d.design(ndes).name = 'standard GLM'
d.design(ndes).signal = d.hb;


r;

if 0
    %% bad timepoints as a user specified regressor
    mvt = zeros(size(d.tt));
    for i=1:length(d.art.movstart)
        mind = d.tt>d.art.movstart(i) & d.tt<(d.art.movstart(i)+d.art.movdur(i));
        mvt(mind) = 1;
    end
    user_reg = mvt;
    uname = {'headmvt'};
else
    user_reg = [];
    uname = {[]};
end


%% set up other params     %% see specification_batch for details
%hb = 'hbo';   %% look at HbO only  %%% edit this in case you are looking at hbt or hbr
HPF = 'DCT';   %% detrend method
LPF = 'hrf';   %% low pass filtering
method_cor = 0;

flag_window = 1;   %% show the design matrix


%% set up regressors
for i=1:length(r)
    names{i} = r(i).name;
    onsets{i} = r(i).onset;
    durations{i} = r(i).duration;
end

%%%%%%%%%%%% specify design directly

SPM.nscan = size(nirs_data.oxyData,1);
SPM.xY.RT = 1/nirs_data.fs;

%% set up basis function
SPM.xBF.T = 10;
SPM.xBF.T0 = 1;
SPM.xBF.dt = SPM.xY.RT/SPM.xBF.T;
SPM.xBF.UNITS = 'secs';
if d.derivatives==0
   SPM.xBF.name = 'hrf';  %% Put this line in to do HRF alone
else
    SPM.xBF.name = 'hrf (with time and dispersion derivatives)';  %% COULD CHANGE TO HRF ALONE
end

SPM.xBF = nirs_spm_get_bf(SPM.xBF);
switch d.hb
    case 'hbo'
        bf = SPM.xBF.bf;
    case 'hbr'
        bf = SPM.xBF.bf * (-1);
    case 'hbt'
        bf = SPM.xBF.bf;
    case 'hbd'
        bf = SPM.xBF.bf; % not sure whether this is correct? 
end
V = 1;
SPM.xBF.Volterra = V; % model interactions (Volterra) : no

%% set up session
for kk = 1:size(names, 2)
    SPM.Sess.U(kk).name = names(kk);
    SPM.Sess.U(kk).ons = onsets{kk};
    SPM.Sess.U(kk).dur = durations{kk};
end

Xx    = [];
Xb    = [];
Xname = {};
Bname = {};

s=1;  %% only 1 session
k   = SPM.nscan(s);
U = nirs_spm_get_ons_batch(SPM, 1, 1);

%% convolve with basis function
[X,Xn,Fc] = spm_Volterra(U,bf,V);

try
    X = X([0:(k - 1)]*SPM.xBF.T + SPM.xBF.T0 + 32,:);
end

for i = 1:length(Fc)   %% orthogonalise basis function
    X(:,Fc(i).i) = spm_orth(X(:,Fc(i).i));
end


%% set up user regressors
C     = user_reg';
Cname = uname;

X      = [X spm_detrend(C)];
Xn     = {Xn{:}   Cname{:}};

B      = ones(k,1);
Bn{1}  = sprintf('constant');

SPM.Sess(s).U      = U;
SPM.Sess(s).C.C    = C;
SPM.Sess(s).C.name = Cname;
SPM.Sess(s).row    = size(Xx,1) + [1:k];
SPM.Sess(s).col    = size(Xx,2) + [1:size(X,2)];
SPM.Sess(s).Fc     = Fc;

% Append names
%---------------------------------------------------------------
for i = 1:length(Xn)
    Xname{end + 1} = [sprintf('Sn(%i) ',s) Xn{i}];
end
for i = 1:length(Bn)
    Bname{end + 1} = [sprintf('Sn(%i) ',s) Bn{i}];
end

% append into Xx and Xb
%===============================================================
Xx    = blkdiag(Xx,X);
Xb    = blkdiag(Xb,B);

% finished
%-----------------------------------------------------------------------
SPM.xX.X      = [Xx Xb];
SPM.xX.iH     = [];
SPM.xX.iC     = [1:size(Xx,2)];
SPM.xX.iB     = [1:size(Xb,2)] + size(Xx,2);
SPM.xX.iG     = [];
SPM.xX.name   = {Xname{:} Bname{:}};
% end

nscan = SPM.nscan;
nsess = length(nscan);

%%% updated for wavelet-MDL detrending 2009-03-19
str = 'Detrending?';

if isempty(strfind(HPF, 'wavelet')) == 0 % wavelet-MDL
    SPM.xX.K.HParam.type = 'Wavelet-MDL';
elseif isempty(strfind(HPF, 'DCT')) == 0 % DCT
    index_cutoff = find(HPF == ',');
    if isempty(index_cutoff) == 1
        cutoff = 128;
    else
        cutoff = str2num(HPF(index_cutoff+1:end));
    end
    SPM.xX.K.HParam.type = 'DCT';
    SPM.xX.K.HParam.M = cutoff;
end

if isempty(strfind(LPF, 'hrf')) == 0 % hrf smoothing
    SPM.xX.K.LParam.type = 'hrf';
elseif isempty(strfind(LPF, 'gaussian')) == 0 % Gaussian smoothing
    index_FWHM = find(LPF == ',');
    if isempty(index_FWHM) == 1
        FWHM = 4;
    else
        FWHM = str2num(LPF(index_FWHM+1:end));
    end
    SPM.xX.K.LParam.FWHM = FWHM;
    SPM.xX.K.LParam.type = 'Gaussian';
else
    SPM.xX.K.LParam.type = 'none';
end

K = struct( 'HParam', SPM.xX.K.HParam,...
    'row', SPM.Sess.row,...
    'RT', SPM.xY.RT,...
    'LParam', SPM.xX.K.LParam);
SPM.xX.K = spm_filter_HPF_LPF_WMDL(K);

% related spm m-file : spm_fmri_spm_ui.m
if method_cor == 0
    cVi = 'none';
elseif method_cor == 1
    cVi = 'AR(1)';
end

if ~ischar(cVi)	% AR coeficient[s] specified
    SPM.xVi.Vi = spm_Ce(nscan,cVi(1:3));
    cVi        = ['AR( ' sprintf('%0.1f ',cVi) ')'];
    
else
    switch lower(cVi)
        case 'none'		%  xVi.V is i.i.d
            %---------------------------------------------------------------
            SPM.xVi.V  = speye(sum(nscan));
            cVi        = 'i.i.d';
        otherwise		% otherwise assume AR(0.2) in xVi.Vi
            %---------------------------------------------------------------
            SPM.xVi.Vi = spm_Ce(nscan,0.2);
            cVi        = 'AR(0.2)';
    end
end
SPM.xVi.form = cVi;
SPM.xsDes = struct('Basis_functions', SPM.xBF.name, 'Sampling_period_sec', num2str(SPM.xY.RT), 'Total_number_of_samples', num2str(SPM.nscan));
if flag_window == 1
    spm_DesRep('DesMtx',SPM.xX,[],SPM.xsDes)
end

fname_nirs =  fullfile(d.root,d.babydir,'processed.mat')

SPM.nirs.step = 'specification';
SPM.nirs.fname = fname_nirs;



SPM_nirs = SPM;
switch d.hb
    case 'hbo'
        SPM_nirs.nirs.Hb = 'HbO';
        SPM_nirs.nirs.level = 'individual';
        fname_SPM = fullfile(d.root,d.babydir,'SPM_indiv_HbO.mat');
        
    case 'hbr'
        SPM_nirs.nirs.Hb = 'HbR';
        SPM_nirs.nirs.level = 'individual';
        fname_SPM = fullfile(d.root,d.babydir,'SPM_indiv_HbR.mat');
       
    case 'hbt'
        SPM_nirs.nirs.Hb = 'HbT';
        SPM_nirs.nirs.level = 'individual';
        fname_SPM = fullfile(d.root,d.babydir,'SPM_indiv_HbT.mat');
        
    case 'hbd'
        SPM_nirs.nirs.Hb = 'HbD';
        SPM_nirs.nirs.level = 'individual';
        fname_SPM = fullfile(d.root,d.babydir,'SPM_indiv_HbD.mat');
        % save([dir_save filesep 'SPM_indiv_HbT.mat'], 'SPM_nirs');
        
end

save(fname_SPM,'SPM_nirs');


disp(['File : ',fname_SPM,' written']);
d.fname_SPM = fname_SPM;
d.design(ndes).fname_SPM = fname_SPM;



