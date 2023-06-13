function [rst] = degree(corrValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('DEGREE: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    [~, ~, degree] = degrees_dir(corrValues.connmap);
    rst.summary = [mean(degree) std(degree) length(degree)];
    rst.save = degree;
    rst.visual = [];
end

