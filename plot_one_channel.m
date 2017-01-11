%%% plot one channel

dataset = 'D:\everything\Dropbox\SPM-NIRS\b02\SPM_indiv_HbO'
raw = 'D:\everything\Dropbox\SPM-NIRS\b02\processed.mat'

load(dataset)
load raw

chan = 29;

sc = 10^7;  %% scaling factor

figure(5), clf
%plot(SPM_nirs.xX.X(:,1),'k-')
hold on
%plot(SPM_nirs.xX.X(:,4),'k:')
plot(d.nirs_data.oxyData(:,chan)*sc,'r-')
%plot(d.nirs_data.dxyData(:,chan)*sc,'b-')
title(['Channel: ',num2str(chan)])
