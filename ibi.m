function [rst] = ibi(chValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('IBI: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    if ~ chValues.burstDetected
        burstDetect(chValues, {});
    end
    
    burstnum = max(chValues.groups);
    starts = zeros(burstnum, 1);
    ends = zeros(burstnum, 1);
    
    for ii=1:burstnum
        times = chValues.timestamps(chValues.groups == ii);
        starts(ii) = times(1);
        ends(ii) = times(end);
    end
    IBI = starts(2:end) - ends(1:end - 1);
    
    rst.summary = [mean(IBI) std(IBI) burstnum];
    rst.save = IBI;
    rst.visual = [];
end

