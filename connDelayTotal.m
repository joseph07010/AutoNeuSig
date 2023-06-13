function [rst] = connDelayTotal(corrValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('CONNDELAYTOTAL: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    map = corrValues.connmap;
    dly = corrValues.dlymap;
    chs = corrValues.chs;
    
    dlytotal = zeros(length(chs)^2, 1);
    dlyidx = 1;
    for ii=1:length(chs)
        for jj=1:length(chs)
            if map(jj, ii) > 0
                dlytotal(dlyidx) = dly(jj, ii);
                dlyidx = dlyidx + 1;
            end
        end
    end
    dlytotal(dlyidx:end) = [];
    
    rst.summary = [mean(dlytotal) std(dlytotal) length(dlytotal)];
    rst.save = dlytotal;
    rst.visual = [];
end