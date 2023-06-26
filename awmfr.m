function [rst] = awmfr(chValues, params)
    %% inputs
    inputidx = 1;
    interval = [];
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case 'interval'
                inputidx = inputidx + 1;
                interval = params{inputidx};
            otherwise
                error('AWMFR: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    ts = chValues.timestamps;
    
    if ~isempty(interval)
        intvs = chValues.getInterval(interval);
        numintv = size(intvs);
        flags = false(size(ts));
        tspan = 0;
        
        for ii=1:numintv(1)
            flags = flags | (ts >= intvs(ii, 1) & ts < intvs(ii, 2));
            tspan = tspan + (intvs(ii, 2) - intvs(ii, 1));
        end
        ts = ts(flags);
    else
        tspan = chValues.timespan;
    end

    AWMFR = length(ts) / tspan;
    
    rst.summary = AWMFR;
    rst.save = AWMFR;
    rst.visual = [];
end

