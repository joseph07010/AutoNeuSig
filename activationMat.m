% Raichman, N., & Ben-Jacob, E. (2008). JNeurosci Met, 170, 96–110. 
function [rst] = activationMat(chValues, params)
    %% inputs
    threshold = 0.030; % sec, spike timing precision in bursts
    
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case 'threshold'
                inputidx = inputidx + 1;
                threshold = params{inputidx};
            otherwise
                error('ACTIVATIONMAT: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    if ~ chValues.burstDetected
        burstDetect(chValues, {});
    end
    
    chs = chValues.getChs();
    if chValues.activeChanneled
        chs = chs(chValues.active);
    end
    numChs = length(chs);
    
    spks = chValues.timestamps;
    chNums = chValues.chNums;
    bursts = chValues.groups;
    burstnum = max(bursts);
    
    actMat = cell(burstnum, 1);
    for ii=1:burstnum
        fstspks = zeros(numChs, 1);
        
        burstspks = spks(bursts == ii);
        burstchs = chNums(bursts == ii);
        for jj=1:length(burstspks)
            if ~ismember(burstchs(jj), chs) % if a spike is not from the active channel
                continue
            end
            tempidx = find(chs == burstchs(jj));
            if isempty(tempidx) || fstspks(tempidx) ~= 0
                continue
            else
                fstspks(tempidx) = burstspks(jj);
            end
        end
        
        tempMat = zeros(numChs, numChs);
        for jj=1:numChs
            for kk=1:numChs
                if jj == kk
                    tempMat(jj, kk) = nan;
                elseif fstspks(jj) == 0 || fstspks(kk) == 0
                    tempMat(jj, kk) = nan;
                else
                    tempMat(jj, kk) = fstspks(kk) - fstspks(jj);
                end
            end
        end
        actMat{ii} = tempMat;
    end
    
    actMatSimil = zeros(burstnum, burstnum);
    for ii=1:burstnum
        for jj=1:burstnum
            if ii == jj
                actMatSimil(ii, jj) = 1;
            else
                actMatSimil(ii, jj) = sum(abs(actMat{ii}(:) - actMat{jj}(:)) <= threshold) / (numChs * (numChs - 1));
                %actMatSimil(ii, jj) = sum(sum(abs(actMat{ii} - actMat{jj}) < threshold)) / (numChs * (numChs - 1));
            end
        end
    end
    
    rst.summary = [];
    rst.save = {actMat, actMatSimil};
    rst.visual = [];
end

