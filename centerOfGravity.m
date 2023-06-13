function [rst] = centerOfGravity(chValues, params)
    %% inputs
    weighted = false;
    
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case 'weighted'
                inputidx = inputidx + 1;
                weighted = params{inputidx};
            otherwise
                error('CENTEROFGRAVITY: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    chs = chValues.getChs();
    if chValues.activeChanneled
        chs = chs(chValues.active);
    end
    
    if weighted
        coeff = zeros(length(chs), 1);
        for ii=1:length(chs)
            coeff(ii) = length(chValues.getTimestampCh(chs(ii)));
        end
    else
        coeff = ones(length(chs), 1);
    end
    
    xlist = zeros(length(chs), 1);
    ylist = zeros(length(chs), 1);
    for ii=1:length(chs)
        xlist(ii) = floor(chs(ii) / 10);
        ylist(ii) = rem(chs(ii), 10);
    end
    xG = dot(coeff, xlist) / sum(coeff) - 4.5;
    yG = dot(coeff, ylist) / sum(coeff) - 4.5;
    
    rst.summary = [xG, yG];
    rst.save = [xG, yG];
    rst.visual = [];
end

