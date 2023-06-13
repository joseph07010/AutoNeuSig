function [rst] = density(corrValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('DENSITY: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    density = density_dir(corrValues.connmap);
    rst.summary = density;
    rst.save = density;
    rst.visual = [];
end

