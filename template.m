function [rst] = template(chValues, params)
    %% parsing inputs
    inputidx = 1;
    display = true; % if display is true return visualized result
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case 'display'
                inputidx = inputidx + 1;
                display = params{inputidx};
            otherwise
                error('TEMPLATE: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    % implement here
    
    %% return values
    rst.summary = []; % simple numbers
    rst.save = []; % any raw results
    if display
        fig = figure('visible', 'off');
        % visualization here
        
        nowstr = datestr(now, 'yymmdd-HHMMSS.FFF'); % figure file name formatting
        filename = [nowstr '_template.png']; % edit 'template' to your function name
        filename = fullfile(chValues.savepath, filename);
        saveas(fig, filename);
        close(fig);
        rst.visual = filename; % return file path after saving figure
    else
        rst.visual = []; % return empty
    end
end

