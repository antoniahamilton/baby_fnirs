function [d]=Homer2SPMdata(d)
%% last version of fload_homer 
% right reording of bad channels, output figure with bad channels marked in,
% all the info are read in from Homer, no need to specify anything!

%%%%%% 

fn = fullfile(d.root,d.babydir,d.raw)

% import the all the raw data from Homer in the hd matrix
hd = importdata(fn)

%% get bad trials
badt = cat(1,hd.userdata.data{:,1});

for i=1:length(badt)
    mark = hd.userdata.data{i,2};
    if(length(mark)>0)
        badt(i,2) = 1;
    else
        badt(i,2) = 0;
    end
end
    
d.badt = badt;  %% store bad trials in the d matrix

et = hd.s;

ett = zeros(length(et),1);
%% add up events
for i=1:size(et,2)
    ett = ett+et(:,i).*i;
end

d.ev = ett;  %% very basic event coding by Homer column
d.condnames = hd.CondNames;  %% read from Homer
  
d.Scrpos = hd.SD.SrcPos; %info about sources
d.Detpos = hd.SD.DetPos; %info about detectors
d.Nch = length(hd.d(1,:))/2; % number of channels detected automatically


%% get sources, detectors, channels in the d.chlab from hd
d.chlab(:,1) = hd.SD.MeasList(1:d.Nch,1);
d.chlab(:,2) = hd.SD.MeasList(1:d.Nch,2);

d.chlab
%check the d.chlab printed out in matlab 

cbad = (zeros(d.Nch,1));

%importing the channels marked in yellow (from Homer)
if ~isempty(hd.procResult.SD)
    tmp = hd.procResult.SD.MeasListAct; 
    tmp = reshape(tmp,d.Nch,2);
    
    cbad1 = all(tmp>0.5,2); 
end

%importing the channels marked in pink (from KP script)
if ~isempty(hd.SD)
    tmp2 = hd.SD.MeasListAct; 
    tmp2 = reshape(tmp2,d.Nch,2);
    
    cbad2 = all(tmp2>0.5,2); 
end

%creating the cbad variable with bad channels (both yellow and pink ones)
cbad = cbad1 & cbad2;
[i,reorder] = sort(d.chlab(:,3));

%importing oxy and deoxy data from Homer 
d.nirs_data.oxyData = squeeze(hd.procResult.dc(:,1,reorder));  
d.nirs_data.dxyData = squeeze(hd.procResult.dc(:,2,reorder)); 

% store all the info about the data in the d matrix
d.nirs_data.oxyData=d.nirs_data.oxyData *1000000; %needs to be changed from 6 to 5 zeros when using output from new Homer
d.nirs_data.dxyData=d.nirs_data.dxyData *1000000; %needs to be changed from 6 to 5 zeros when using output from new Homer

d.nirs_data.hdiff = d.nirs_data.oxyData - d.nirs_data.dxyData;  %% calculate hdiff

d.nirs_data.fs = 10;
d.nirs_data.DPF_correction= 'Charite correction';
d.rate = 10;% KB
d.cbad=logical(cbad);
d.cname = [1:d.Nch];

%% figure of the channels structure with bad channels marked in black
figure(1), clf 
for i=1:length(d.chlab)
    ss = d.Scrpos(d.chlab(i,1),:);
    dd = d.Detpos(d.chlab(i,2),:);
    plot([ss(1),dd(1)], [ss(2),dd(2)], 'b-','Color',[0.2,0.2,0.8])
    hold on
    h=plot( mean([ss(1),dd(1)]) , mean([ss(2),dd(2)]) , 'bo','MarkerSize',15,'MarkerFaceColor',[1,1,1],'Color',[0.2,0.2,0.8]);
    text( mean([ss(1),dd(1)]) , mean([ss(2),dd(2)]) , num2str(d.chlab(i,3)),'HorizontalAlignment','Center');

    if(d.cbad(i)==0)
        h=plot( mean([ss(1),dd(1)]) , mean([ss(2),dd(2)]) , 'bo','MarkerSize',15,'MarkerFaceColor',[0,0,0],'Color',[0,0,0]);
        text( mean([ss(1),dd(1)]) , mean([ss(2),dd(2)]) , num2str(d.chlab(i,3)),'HorizontalAlignment','Center','Color',[1,1,1]);
    end        
end
axis off

% sources are marked in red, while detectors are marked in green
plot(d.Scrpos(:,1),d.Scrpos(:,2),'ro','MarkerFaceColor',[1,0,0],'MarkerSize',8);
hold on
for i=1:length(d.Scrpos)
    text(d.Scrpos(i,1)+1,d.Scrpos(i,2)+1,num2str(i))
end
plot(d.Detpos(:,1),d.Detpos(:,2),'go','MarkerFaceColor',[0,1,0],'MarkerSize',8);
hold on
for i=1:length(d.Detpos)
    text(d.Detpos(i,1)+1,d.Detpos(i,2)+1,num2str(i))
end

%%save the picture of channels structures and bad channels in the subject folder
pname = fullfile(d.root,d.babydir,'bad_ch.tif');
print('-dtiff','-zbuffer',pname)

%saving bad channels in the right order in the d matrix
cbad = cbad(reorder);
d.cbad=logical(cbad);

%% sort out trial timing with trials from Homer in userdata
et = find(d.ev>0.1);
badet = find(d.badt(:,2)==1);

d.oldev=d.ev;

try
    d.ev(et(badet)) = -1;
end
    
    
figure(1), clf
plot(d.ev)
title(['Events for: ',d.raw])
drawnow


%% crop data before onset of first event and after last event - added by CdK;
events=find(d.ev>0);
cropbefore=events(1);
% add 8 seconds of data if the last event is a baseline, add 10 seconds of
% data if the last event is a trial
if d.ev(events(end))==d.baseline
   adddata=d.regressordur(end)*10;
else
    adddata=d.regressordur(1)*10;
end
cropafter=events(end)+ adddata; 

%if the recording was stopped half-way through a video, crop the data at
%the end of the recording
if length(d.nirs_data.oxyData)< cropafter
    cropafter=length(d.nirs_data.oxyData);
end

d.nirs_data.oxyData = d.nirs_data.oxyData(cropbefore:cropafter,:); 
d.nirs_data.dxyData = d.nirs_data.dxyData(cropbefore:cropafter,:);
d.nirs_data.hdiff=d.nirs_data.hdiff(cropbefore:cropafter,:);
d.ev=d.ev(cropbefore:cropafter);
d.oldev=d.oldev(cropbefore:cropafter);

%if there is a gap between events that is longer than 11 seconds (for
%example when the script crashed zero out this data
events2=find(d.ev~=0);
for k=2:length(events2)
    eventdifference(k)=events2(k)-events2(k-1);
    events2(k)
    if eventdifference(k) > (d.regressordur(1)*10) +10
        d.nirs_data.oxyData(events2(k-1):events2(k),:)=0;
        d.nirs_data.dxyData(events2(k-1):events2(k),:)=0;
        d.nirs_data.hdiff(events2(k-1):events2(k),:)=0;
    end
        
end

%% zero out bad trials with different
%% durations depending on whether its an excluded baseline (8 sec) or a bad trial (10 sec) 
t_bad = find(d.ev<0)./d.rate;
if(length(t_bad)>0.5)
    row_bad=t_bad *d.rate;
    originalevent= d.oldev(row_bad); 
    for f=1:length(originalevent)
        if originalevent(f)==d.baseline % if the original event was a baseline, use the baseline duration
        bad_dur =d.regressordur(end);
        startbad(f)=row_bad(f);
        baddur(f) =bad_dur*d.rate;
        endbad(f) =startbad(f)+baddur(f);
        d.nirs_data.oxyData(startbad(f):endbad(f),:)=0;
        d.nirs_data.dxyData(startbad(f):endbad(f),:)=0;
        d.nirs_data.hdiff(startbad(f):endbad(f),:)=0;
        else
            bad_dur =d.regressordur(1);
            startbad(f)=row_bad(f);
            baddur(f)=bad_dur*d.rate;
            endbad(f) =startbad(f)+baddur(f);
            d.nirs_data.oxyData(startbad(f):endbad(f),:)=0;
            d.nirs_data.dxyData(startbad(f):endbad(f),:)=0;
            d.nirs_data.hdiff(startbad(f):endbad(f),:)=0;
        end
        if f>1
        baddifference(f)=startbad(f)-endbad(f-1);
        if baddifference(f) < 10
            d.nirs_data.oxyData(endbad(f-1):startbad(f),:)=0;
            d.nirs_data.dxyData(endbad(f-1):startbad(f),:)=0;
            d.nirs_data.hdiff(endbad(f-1):startbad(f),:)=0;
        end
        end
        
    end
    nirs_data = d.nirs_data;
end


figure(1), clf
plot(d.ev)
title(['Events for: ',d.raw])
drawnow