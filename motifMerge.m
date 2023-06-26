function [ismerge, combs] = motifMerge(motifSet, motifActMat, motifPrcsn, motifCh, mergethre, numActCh)
    %% Initialize variables
    nummotif = length(motifSet);
    numcomb = nummotif * (nummotif - 1) / 2;
    
    if nummotif == 0
        ismerge = [];
        combs = [];
        return
    elseif numcomb == 0
        ismerge = [];
        combs = [];
        return
    end
    
    N = length(motifSet{1});
    
    ismerge = false(numcomb, 1);
    combs = zeros(numcomb, 2);
    combidx = 1;
    for ii=1:nummotif
        for jj=1:nummotif
            if ii >= jj
                continue
            end
            combs(combidx, :) = [ii, jj];
            combidx = combidx + 1;
        end
    end
    
    %dlyoriginal = zeros(nummotif, 1);
    validCh = cell(nummotif, 1);
    for ii=1:nummotif
        fstspks = firstSpikeRecon(motifActMat{ii}, motifPrcsn{ii});
        validCh{ii} = fstspks(:, 2) <= 0.01;
        %ts = sort(fstspks(~isnan(fstspks)));
        %dlyoriginal(ii) = median(ts(2:end) - ts(1:end - 1));
    end
    
    %% Motif merge
    for ii=1:numcomb
        chSelect = motifCh{combs(ii, 1)} & validCh{combs(ii, 1)} & motifCh{combs(ii, 2)} & validCh{combs(ii, 2)};
        if nnz(chSelect) < 0.1 * numActCh
            continue
        end
        sim = burstsim(motifActMat{combs(ii, 1)}, motifActMat{combs(ii, 2)}, mergethre, 'chSelect', chSelect);
        if sim >= 0.9
            ismerge(ii) = true;
        end
%         % Calculate merged activation matrix
%         meanActMat = zeros(size(actMats{1}));
%         stdActMat = zeros(size(actMats{1}));
%         mergeActMats = cell(2 * N, 1);
%         
%         idxtemp = motifSet{combs(ii, 1)};
%         for jj=1:N
%             meanActMat = meanActMat + actMats{idxtemp(jj)};
%             stdActMat = stdActMat + actMats{idxtemp(jj)} .^ 2;
%         end
%         mergeActMats(1:N) = actMats(idxtemp);
%         
%         idxtemp = motifSet{combs(ii, 2)};
%         for jj=1:N
%             meanActMat = meanActMat + actMats{idxtemp(jj)};
%             stdActMat = stdActMat + actMats{idxtemp(jj)} .^ 2;
%         end
%         mergeActMats(N + 1:2 * N) = actMats(idxtemp);
%         
%         meanActMat = meanActMat / (2 * N);
%         stdActMat = sqrt(stdActMat / (2 * N) - meanActMat .^ 2);
%         
%         % Reconstruct merged first spikes
%         ts = meanActMat;
%         for kk=1:length(ts)
%             if sum(~isnan(ts(kk, :))) > 0
%                 break
%             end
%         end
%         ts = ts(kk, :);
%         ts(kk) = 0;
%         ts = (ts - min(ts));
%         
%         prcsn = stdActMat;
%         ts2 = nan(1, length(ts));
%         for kk=1:length(ts)
%             if sum(~isnan(prcsn(kk, :))) == 0
%                 continue
%             end
%             temp = prcsn(kk, :);
%             temp = temp(~isnan(temp));
%             ts2(kk) = median(temp);
%         end
%         ts2 = ts2(~isnan(ts2));
%         
%         % Calculate spike delay & jittering
%         % If median of jittering is larger than 10 msec, two motifs will not merge
%         temp = sort(ts(~isnan(ts)));
%         spkdly = median(temp(2:end) - temp(1:end - 1));
%         if spkdly > 2 * max(dlyoriginal(combs(ii, :)))
%             continue
%         end
%         
%         %if mean(ts2) > 0.01 && median(ts2) > 0.01
%         %    continue
%         %elseif mean(ts2) <= 0.01 && median(ts2) <= 0.01
%         %    spkjit = min([mean(ts2) median(ts2)]);
%         %else
%         %    spkjit = min([min([mean(ts2) 0.01]) min([median(ts2) 0.01])]);
%         %end
%         spkjit = min([mean(ts2) median(ts2)]);
%         
%         if spkjit > 0.01
%             continue
%         end
%         
%         % Calculate inter-motifsimilarity
%         chSelect = motifCh{combs(ii, 1)} & motifCh{combs(ii, 2)};
%         simtemp = similarmat(mergeActMats, thre, 'chSelect', chSelect);
%         simtemp = simtemp(1:N, N + 1:2 * N);
%         
%         if nnz(chSelect) < 0.1 * numActCh % If merged motif has too small participating channels
%             continue
%         end
%         
%         % Find proper standard similarity form simulation data
%         [~, threidx] = min(abs(simuldata.simthres - thre));
%         [~, dlyidx] = min(abs(simuldata.spkdelay - spkdly));
%         interMean = simuldata.interMeanTotal{dlyidx};
%         strd = interp1(simuldata.jittering, interMean(:, threidx), spkjit);
%         
%         if mean(simtemp(:)) >= strd % if inter-motif similarity distribution is larger than standard, merge
%             ismerge(ii) = true;
%         elseif mean(simtemp(:)) >= 0.9 % If inter-motif similarity is large enough, merge
%             ismerge(ii) = true;
%         end
    end
end

