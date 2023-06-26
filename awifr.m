function [rst] = awifr(chValues, params)
    %% inputs
    inputidx = 1;
    binsize = 0.1; % sec
    interval = [];
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case 'binsize'
                inputidx = inputidx + 1;
                binsize = params{inputidx};
            case 'interval'
                inputidx = inputidx + 1;
                interval = params{inputidx};
            otherwise
                error('AWIFR: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    ts = chValues.timestamps;
    histx = 0:binsize:chValues.timespan;
    
    if ~isempty(interval)
        intvs = chValues.getInterval(interval);
        numintv = size(intvs);
        flags = false(size(ts));
        
        for ii=1:numintv(1)
            flags = flags | (ts >= intvs(ii, 1) & ts < intvs(ii, 2));
        end
        ts = ts(flags);
    end
    spkrate = histcounts(ts, histx);
    AWIFR = mean(spkrate(spkrate > 0));
    
    rst.summary = AWIFR;
    rst.save = AWIFR;
    rst.visual = [];
end

