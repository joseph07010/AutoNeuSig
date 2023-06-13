function [rst] = strength(corrValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('STRENGTH: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    [~, ~, str] = strengths_dir(corrValues.connmap);
    rst.summary = [mean(str) std(str) length(str)];
    rst.save = str;
    rst.visual = [];
end

