function [rst] = awifr(chValues, params)
    %% inputs
    inputidx = 1;
    binsize = 0.1; % sec
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case 'binsize'
                inputidx = inputidx + 1;
                binsize = params{inputidx};
            otherwise
                error('AWIFR: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    histx = 0:binsize:chValues.timespan;
    spkrate = histcounts(chValues.timestamps, histx);
    AWIFR = mean(spkrate(spkrate > 0));
    
    rst.summary = AWIFR;
    rst.save = AWIFR;
    rst.visual = [];
end

