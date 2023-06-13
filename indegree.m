function [rst] = indegree(corrValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('INDEGREE: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    [in, ~, ~] = degrees_dir(corrValues.connmap);
    rst.summary = [mean(in) std(in) length(in)];
    rst.save = in;
    rst.visual = [];
end

