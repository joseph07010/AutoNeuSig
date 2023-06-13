function [rst] = ibr(chValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('IBR: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    if ~chValues.burstDetected
        error('IBR: burst detection should be executed first')
    end
    
    IBR = nnz(chValues.groups) / length(chValues.timestamps);
    
    rst.summary = IBR;
    rst.save = IBR;
    rst.visual = [];
end
