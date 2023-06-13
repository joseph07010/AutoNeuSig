function [rst] = connDistTotal(corrValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('CONNDISTTOTAL: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    map = corrValues.connmap;
    chs = corrValues.chs;
    
    disttotal = zeros(length(chs)^2, 1);
    distidx = 1;
    for ii=1:length(chs)
        x1 = floor(chs(ii) / 10);
        y1 = rem(chs(ii), 10);
        for jj=1:length(chs)
            x2 = floor(chs(jj) / 10);
            y2 = rem(chs(jj), 10);
            
            if map(jj, ii) > 0
                disttotal(distidx) = sqrt((x1 - x2)^2 + (y1 - y2)^2);
                distidx = distidx + 1;
            end
        end
    end
    disttotal(distidx:end) = [];
    
    rst.summary = [mean(disttotal) std(disttotal) length(disttotal)];
    rst.save = disttotal;
    rst.visual = [];
end