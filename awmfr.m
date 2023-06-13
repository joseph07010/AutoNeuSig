function [rst] = awmfr(chValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('AWMFR: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    AWMFR = length(chValues.timestamps) / chValues.timespan;
    
    rst.summary = AWMFR;
    rst.save = AWMFR;
    rst.visual = [];
end

