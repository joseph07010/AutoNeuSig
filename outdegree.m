function [rst] = outdegree(corrValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('OUTDEGREE: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    [~, out, ~] = degrees_dir(corrValues.connmap);
    rst.summary = [mean(out) std(out) length(out)];
    rst.save = out;
    rst.visual = [];
end

