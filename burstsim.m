function sim = burstsim(actMat1, actMat2, thre, varargin)
    %% Parameter parsing
    l1 = length(actMat1);
    l2 = length(actMat2);
    chSelect = [];
    
    if l1 ~= l2
        error('BURSTSIM: no equal activation matrix size ')
    end
    
    inputidx = 1;
    while true
        if inputidx > length(varargin)
            break
        end
        
        switch varargin{inputidx}
            case 'chSelect'
                inputidx = inputidx + 1;
                chSelect = varargin{inputidx};
            otherwise
                error('BURSTSIM: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% finding the number of common active channels
    if isempty(chSelect)
        isActive1 = false(l1, 1);
        isActive2 = false(l2, 1);
        for ii=1:l1 % if every element in a row is NaN, corresponding channel is empty
             isActive1 = isActive1 | ~isnan(actMat1(:, ii));
             isActive2 = isActive2 | ~isnan(actMat2(:, ii));
        end

        numCh = sum(isActive1 | isActive2); % burst1 or burst2
    else
        actMat1 = actMat1(chSelect, chSelect);
        actMat2 = actMat2(chSelect, chSelect);
        
        numCh = sum(chSelect);
    end
    
    %% calculate similarity
    sim = sum(abs(actMat1(:) - actMat2(:)) <= thre) / (numCh * (numCh - 1));
end

