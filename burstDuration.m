function [rst] = burstDuration(chValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('BURSTDURATION: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    if ~ chValues.burstDetected
        error('MBR: burst detection should be executed first')
    end
    
    burstnum = max(chValues.groups);
    durations = zeros(burstnum, 1);
    for ii=1:burstnum
        times = chValues.timestamps(chValues.groups == ii);
        durations(ii) = times(end) - times(1);
    end
    
    rst.summary = [mean(durations) std(durations) burstnum];
    rst.save = durations;
    rst.visual = [];
end