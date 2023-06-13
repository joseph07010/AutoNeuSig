function [rst] = clustercoeff(corrValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('CLUSTERCOEFF: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    c = clustering_coef_wd(corrValues.connmap);
    
    rst.summary = [mean(c) std(c) length(c)];
    rst.save = c;
    rst.visual = [];
end