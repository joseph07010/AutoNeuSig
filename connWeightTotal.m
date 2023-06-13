function [rst] = connWeightTotal(corrValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('CONNWEIGHTTOTAL: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    map = corrValues.connmap;
    chs = corrValues.chs;
    
    weighttotal = zeros(length(chs)^2, 1);
    weightidx = 1;
    for ii=1:length(chs)
        for jj=1:length(chs)
            if map(jj, ii) > 0
                weighttotal(weightidx) = map(jj, ii);
                weightidx = weightidx + 1;
            end
        end
    end
    weighttotal(weightidx:end) = [];
    
    rst.summary = [mean(weighttotal) std(weighttotal) length(weighttotal)];
    rst.save = weighttotal;
    rst.visual = [];
end