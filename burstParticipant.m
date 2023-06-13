function [rst] = burstParticipant(chValues, params)
    %% inputs
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case ''
            otherwise
                error('BURSTPARTICIPANT: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    if ~ chValues.burstDetected
        burstDetect(chValues, {});
    end
    
    burstnum = max(chValues.groups);
    participants = zeros(burstnum, 1);
    for ii=1:burstnum
        chs = chValues.chNums(chValues.groups == ii);
        participants(ii) = length(unique(chs));
    end
    
    rst.summary = [mean(participants) std(participants) burstnum];
    rst.save = participants;
    rst.visual = [];
end

