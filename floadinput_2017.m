function d = floadinput(d)
%Loads load in input file (e.g. SPM-NIRS input.xlsx) with original Homer events, regressor names, contrast of interest, and channel names (in second tab)
% Baseline condition should always be in last column
% 	[filename, pathname] = uigetfile({'*.xls'; '*.xlsx';'*.*'}, 'Pick an excel file');
% 	fullname = fullfile(pathname, filename);
    [num, txt]=xlsread((d.fullname),1);
    d.chlab(:,3)=xlsread((d.fullname),2); 
    d.regressors= txt(1,2:end);
    d.regressordur=num(2,:);
    d.regressordur(isnan(d.regressordur))=[];
    d.Homerevent=num(1,:);
    d.Homerevent(isnan(d.Homerevent))=[];
    d.contrast=num(3,:);
    d.contrast(isnan(d.contrast))=[];
    d.derivatives=num(4,1);
    d.channelsleft=num(5,:);
    d.channelsleft(isnan(d.channelsleft))=[];
    d.channelsright=num(6,:);
    d.channelsright(isnan(d.channelsright))=[];
    d.channelsfront=num(7,:);
    d.channelsfront(isnan(d.channelsfront))=[];
    d.baseline=num(1,end);
    d.frontal=num(8,1);
    d.offset=num(9,1);
end

