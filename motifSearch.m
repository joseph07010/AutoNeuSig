function [motifSet, motifActMat, motifPrcsn, motifCh] = motifSearch(actMats, isactive, N, thre)
    %% Initialize 
    Nb = length(actMats);
    optSetIdx = cell(Nb - N + 1, 1); % making optional burst sets with sliding index
    for ii=1:Nb - N + 1
        optSetIdx{ii} = ii:ii + N - 1;
    end
    
    %%
    motifSet = cell(Nb - N + 1, 1);
    motifActMat = cell(Nb - N + 1, 1);
    motifPrcsn = cell(Nb - N + 1, 1);
    motifCh = cell(Nb - N + 1, 1);
    motifidx = 1;
    
    while ~isempty(optSetIdx) % until optional burst sets become empty
        actMatSet =  cell(length(optSetIdx), 1);
        prcsnSet = cell(length(optSetIdx), 1);
        simSet = zeros(length(optSetIdx), 1);
        chSet = cell(length(optSetIdx), 1);
        
        for ii=1:length(optSetIdx)
            % mean & std of activation matrix
            idxtemp = optSetIdx{ii};
            mattemp = zeros(size(actMats{1}));
            prcsntemp = zeros(size(actMats{1}));
            
            for jj=1:N
                mattemp = mattemp + actMats{idxtemp(jj)};
                prcsntemp = prcsntemp + actMats{idxtemp(jj)} .^ 2;
            end
            actMatSet{ii} = mattemp / N;
            prcsnSet{ii} = sqrt(prcsntemp / N - (mattemp / N) .^ 2);
            
            % mean similarity (S_set) & intersecting channels
            simtemp = 0;
            chtemp = true(length(isactive{1}), 1);
            for jj=1:N
                simtemp = simtemp + burstsim(actMatSet{ii}, actMats{idxtemp(jj)}, thre);
                chtemp = chtemp & isactive{idxtemp(jj)};
            end
            simSet(ii) = simtemp / N;
            chSet{ii} = chtemp;
        end
        
        % find highest S_set and selected as motif set
        [~, I] = max(simSet);
        motifSet{motifidx} = optSetIdx{I};
        motifActMat{motifidx} = actMatSet{I};
        motifPrcsn{motifidx} = prcsnSet{I};
        motifCh{motifidx} = chSet{I};
        motifidx = motifidx + 1;
        
        % remove optional sets did not fullfill two conditions
        rmv = false(length(optSetIdx), 1);
        for ii=1:length(optSetIdx)
            if sum(ismember(optSetIdx{ii}, optSetIdx{I})) > 0 % condition 1: Isolation
                rmv(ii) = true;
            else
                idxtemp = optSetIdx{ii};
                simselect = zeros(N, 1);
                simorigin = zeros(N, 1);
                for jj=1:N
                    simselect(jj) = burstsim(actMatSet{I}, actMats{idxtemp(jj)}, thre);
                    simorigin(jj) = burstsim(actMatSet{ii}, actMats{idxtemp(jj)}, thre);
                end

                if sum(simselect > simorigin) > 0 % condition 2: separation
                    rmv(ii) = true;
                end
            end
        end
        optSetIdx(rmv) = [];
    end
    
    motifSet(motifidx:end) = [];
    motifActMat(motifidx:end) = [];
    motifPrcsn(motifidx:end) = [];
    motifCh(motifidx:end) = [];
end
