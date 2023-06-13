function [rst] = mbr(chValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('MBR: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    if ~ chValues.burstDetected
        error('MBR: burst detection should be executed first')
    end
    
    MBR = max(chValues.groups) / (chValues.timespan / 60); % bursts per minute
    
    rst.summary = MBR;
    rst.save = MBR;
    rst.visual = [];
end

