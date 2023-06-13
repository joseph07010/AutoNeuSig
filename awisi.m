function [rst] = awisi(chValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('AWISI: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    AWISI = chValues.timestamps(2:end) - chValues.timestamps(1:end - 1);
    
    rst.summary = [mean(AWISI) std(AWISI) length(AWISI)];
    rst.save = AWISI;
    rst.visual = [];
end

