
    %-------------------------------
    % read the .csv file (JUST 1 SUB ONE SESS FOR NOW)
    %-------------------------------
    
    events = readtable('fiveconditioncode/NAMWORDS1_PL00103_SESS01_FIVECONDITIONCODE.csv');
    [n,m] = size(events);
    
    conditions = events(:,3);
    onsetTimes = events(:,2);
    targetTimes = table;
   

    
    for i=1:n
        fivecondition = events(i,3);
        a = table2array(fivecondition);
        
        if strcmp(a,'ListenWord') 
            fprintf('comparison worked \n')
            targetTimes(i,1) = onsetTimes(i,1);
        end
    end
    
         