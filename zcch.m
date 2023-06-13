function [rst] = zcch(corrValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('ZCCH: Input error');
        end
        inputidx = inputidx + 1;
    end
    %% calcuation
    zcchs = cell(size(corrValues.corr));
    
    for ii=1:corrValues.numchs
        for jj=1:corrValues.numchs
            corr = corrValues.corr{ii, jj};
            jitmean = corrValues.jitcorrmean{ii, jj};
            jitstd = corrValues.jitcorrstd{ii, jj};
            zcch = (corr - jitmean) ./ jitstd;
            zcch(isinf(zcch)) = 0;
            zcch(isnan(zcch)) = 0;
            
            zcchs{ii, jj} = zcch;
        end
    end
    
    corrValues.normalizedCorr = zcchs;
    
    rst.summary = [];
    rst.save = zcchs;
    rst.visual = [];
end

