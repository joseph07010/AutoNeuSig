function [rst] = connDistMax(corrValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('CONNDISTMAX: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    map = corrValues.connmap;
    chs = corrValues.chs;
    maxdist = zeros(length(chs), 1);
    
    for ii=1:length(chs)
        dist = zeros(length(chs), 1);
        x1 = floor(chs(ii) / 10);
        y1 = rem(chs(ii), 10);
        for jj=1:length(chs)
            x2 = floor(chs(jj) / 10);
            y2 = rem(chs(jj), 10);
            dist(jj) = sqrt((x1 - x2)^2 + (y1 - y2)^2);
        end
        
        if sum(map(:, ii) > 0) == 0
            maxdist(ii) = 0;
        else
            maxdist(ii) = max(dist(map(:, ii) > 0)) * 200;
        end
    end
    
    rst.summary = [mean(maxdist) std(maxdist) length(maxdist)];
    rst.save = maxdist;
    rst.visual = [];
end