function [rst] = numSpkInBurst(chValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('NUMSPKINBURST: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    if ~ chValues.burstDetected
        burstDetect(chValues, {});
    end
    
    burstnum = max(chValues.groups);
    spknums = zeros(burstnum, 1);
    for ii=1:burstnum
        spknums(ii) = nnz(chValues.groups == ii);
    end
    
    rst.summary = [mean(spknums) std(spknums) burstnum];
    rst.save = spknums;
    rst.visual = [];
end

