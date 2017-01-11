function art = fsort_artefact_codes(fname,sheetname);
%% sort out the artefact coding from Excel
%% inputs are excel filename and sheetname
%% output is structure art with start/duration for not-attending 
%%    and start/duration for moving


%fname = 'NIRS_video_coding1.xlsx';
%sheetname = '65';

[num,txt,raw] = xlsread(fname,sheetname);
disp('------')
disp([num2str(size(raw)),' rows x columns of raw data read from ',fname,' sheet: ',sheetname]);

%% check headers
shouldbe = {'NOT ATTENDING'    [       NaN]    [NaN]    'MOVING'         [       NaN] ;
    'Time- start'      'Time - end'    [NaN]    'Time- start'    'Time - end' };
try
    check = NaN*zeros(size(shouldbe));
    for i=1:5
        for j=1:2
            if(~isnan(shouldbe{j,i}))
                check(j,i) = strcmp(raw{j,i},shouldbe{j,i});
            end
        end
    end
catch
    disp('something is wrong')
    raw
    keyboard
    art = 0;
    return;
end
    
    
if(nansum(check(:))~=6)
    check
    disp('Headers are wrong')
    disp('I read : ')
    raw(1:2,:)
    disp('------------')
    disp('but it should be : ')
    shouldbe
    disp('------------')
    disp('stopping now')
    art = 0;
    return;
end

try
    cols = [1,2,4,5];
    for j=cols
        
        for i=3:length(raw)
            tmp = raw{i,j};
            
            if(strncmp(tmp,'end',3))
                tsec(i,j) = NaN;
            elseif (strncmp(tmp,'***',3))
                tsec(i,j) = NaN;                
            else
                
                if(~isnan(tmp))
                    h = str2num(tmp(1));
                    mm = str2num(tmp(3:4));
                    ss = str2num(tmp(6:7));
                    ms = str2num(tmp(9:10));
                    
                    tsec(i,j) = h*60*60 + mm*60 + ss + ms/100;
                else
                    tsec(i,j) = NaN;
                end
            end
        end
    end    
catch
    disp(['I cannot read the item: ',tmp])
    return
   % keyboard
end
    
disp('-- XLSX read successfully :-) ---')


art.nastart = tsec(:,1);
art.nadur = tsec(:,2)-tsec(:,1);
art.movstart = tsec(3:end,4);
art.movdur = tsec(3:end,5)-tsec(3:end,4);
    
    