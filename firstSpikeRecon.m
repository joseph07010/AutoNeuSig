function fstspikes = firstSpikeRecon(actMat, prcsn)
    for ii=1:length(actMat)
        if sum(~isnan(actMat(ii, :))) > 0
            break
        end
    end
    ts = actMat(ii, :);
    ts(ii) = 0;
    ts = (ts - min(ts));
    ts = ts';
    
    if isequal(size(actMat), size(prcsn))
        ts2 = nan(length(ts), 1);
        for ii=1:length(ts)
            if sum(~isnan(prcsn(ii, :))) == 0
                continue
            end
            temp = prcsn(ii, :);
            temp = temp(~isnan(temp));
            ts2(ii) = median(temp);
        end

        fstspikes = [ts ts2];
    else
        fstspikes = ts;
    end
end

