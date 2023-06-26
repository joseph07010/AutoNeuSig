function [valid, strd] = motifValidation(actMats, motifSet, motifActMat, motifPrcsn, motifCh, thre, simuldata, numActCh)
    %% Initialize variables
    nummotif = length(motifActMat);
    valid = true(nummotif, 1);
    strd = zeros(nummotif, 1);
    N = length(motifSet{1});
    
    %% Motif validation
    for ii=1:nummotif
%         % Reconstruct of first spikes
%         ts = motifActMat{ii};
%         for jj=1:length(ts)
%             if sum(~isnan(ts(jj, :))) > 0
%                 break
%             end
%         end
%         ts = ts(jj, :);
%         ts(jj) = 0;
%         ts = (ts - min(ts));
%         
%         % Reconstruct of jittering of first spikes
%         prcsn = motifPrcsn{ii};
%         ts2 = nan(1, length(ts));
%         for jj=1:length(ts)
%             if sum(~isnan(prcsn(jj, :))) == 0
%                 continue
%             end
%             temp = prcsn(jj, :);
%             temp = temp(~isnan(temp));
%             ts2(jj) = median(temp);
%         end
%         chValid = ts2 <= 0.01;
%         ts2 = ts2(~isnan(ts2));
        
        fstspks = firstSpikeRecon(motifActMat{ii}, motifPrcsn{ii});
        validCh = fstspks(:, 2) <= 0.01;
        
        ts = sort(fstspks(motifCh{ii} & validCh, 1));
        ts2 = fstspks(motifCh{ii} & validCh, 2);
        
        % Find mean spike delay & jittering
        % If median of jittering is larger than 10 msec, motif is not valid
        %temp = sort(ts(~isnan(ts)));
        %spkdly = median(temp(2:end) - temp(1:end - 1));
        %if mean(ts2) > 0.01 && median(ts2) > 0.01
        %    valid(ii) = false;
        %    continue
        %elseif mean(ts2) <= 0.01 && median(ts2) <= 0.01
        %    spkjit = max([mean(ts2) median(ts2)]);
        %else
        %    spkjit = max([min([mean(ts2) 0.01]) min([median(ts2) 0.01])]);
        %end
        spkdly = median(ts(2:end) - ts(1:end - 1));
        spkjit = median(ts2);
        if spkjit > 0.01
            valid(ii) = false;
            continue
        end
        
        % Calculate intra-motif similarity with intersecting channels
        [c, r] = meshgrid(1:N, 1:N);
        simtemp = similarmat(actMats(motifSet{ii}), thre, 'chSelect', motifCh{ii} & validCh);
        
        % Find proper standard similarity from simulation data
        [~, threidx] = min(abs(simuldata.simthres - thre));
        [~, dlyidx] = min(abs(simuldata.spkdelay - spkdly));
        intraMean = simuldata.intraMeanTotal{dlyidx};
        strd(ii) = interp1(simuldata.jittering, intraMean(:, threidx), spkjit);
        
        if nnz(motifCh{ii}) < 0.1 * numActCh % If participating channel is too small
            valid(ii) = false;
        elseif mean(simtemp(c < r)) >= 0.9 % If mean similarity is high enough
            valid(ii) = true;
        elseif mean(simtemp(c < r)) <= strd(ii) % If intra-motif similarity distribution is smaller than standard, valid
            valid(ii) = false;
        end
    end
end

