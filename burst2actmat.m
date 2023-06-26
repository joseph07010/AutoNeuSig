function [actMats, isactive] = burst2actmat(bursts)
    %% Initialize variables
    chWhole = [12, 13, 14, 16, 17, 21, 22, 23, 24, 25, 26, 27, 28, 31, 32, 33, 34, 35, 36, 37, 38, 41, 42, 43, 44, 45, 46, 47, 48, 51, 52, 53, 54, 55, 56, 57, 58, 61, 62, 63, 64, 65, 66, 67, 68, 71, 72, 73, 74, 75, 76, 77, 78, 82, 83, 84, 85, 86, 87];
    numch = length(chWhole);
    burstnum = length(bursts);
    actMats = cell(burstnum, 1);
    isactive = cell(burstnum, 1);
    
    for ii=1:burstnum
        fstspk = NaN(numch, 1); % find first spikes
        
        spk = bursts(ii).spktime;
        ch = bursts(ii).chnum;
        
        for jj=1:numch
            idxtemp = find(ch == chWhole(jj), 1);
            if ~isempty(idxtemp)
                fstspk(jj) = spk(idxtemp);
            end
        end
        
        tempMat = NaN(numch); % build activation matrix
        for jj=1:numch
            for kk=1:numch
                if jj == kk
                    continue
                elseif (fstspk(jj) == 0) || (fstspk(kk) == 0)
                    continue
                else
                    tempMat(jj, kk) = fstspk(kk) - fstspk(jj);
                end
            end
        end
        
        actMats{ii} = tempMat;
        isactive{ii} = ~isnan(fstspk);
    end
end

