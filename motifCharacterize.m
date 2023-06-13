function [rst] = motifCharacterize(chValues, params)
    %% input parameter
    N = 0; % motif size (usually sqrt(# of bursts))
    thre = 0.01; % sec, similarity threshold
    mergethre = 0.9; % motif merge threshold
    validation = true; % flag for validation
    merge = true; % flag for merge
    assignthre = 3;

    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case 'N'
                inputidx = inputidx + 1;
                N = params{inputidx};
            case 'threshold'
                inputidx = inputidx + 1;
                thre = params{inputidx};
            case 'validation'
                inputidx = inputidx + 1;
                validation = params{inputidx};
            case 'merge'
                inputidx = inputidx + 1;
                merge = params{inputidx};
            case 'assign'
                inputidx = inputidx + 1;
                assignthre = params{inputidx};
            otherwise
                error('MOTIFCHARACTERIZE: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    rst.summary = [];
    rst.save = [];
    rst.visual = [];
    
    %% Activation matrix generation
    if ~ chValues.burstDetected % if burst detection
        burstDetect(chValues, {});
    end
    
    numActCh = nnz(chValues.active);
    burstnum = max(chValues.groups);
    bursts = struct('spktime', cell(burstnum, 1), 'chnum', cell(burstnum, 1));
    
    if burstnum <= 1
        return
    elseif burstnum > 400 % limit the number of burst to 400
        bursts = bursts(1:400);
        burstnum = 400;
    end
    
    for ii=1:burstnum
        idxtemp = (chValues.groups == ii);
        bursts(ii).spktime = chValues.timestamps(idxtemp);
        bursts(ii).chnum = chValues.chNums(idxtemp);
    end
    
    [actMats, isactive] = burst2actmat(bursts); % generation of activation matrix
    
    if N == 0
        N = floor(sqrt(burstnum));
    end
    
    %% Similarity matrix
    simMatOri = similarmat(actMats, thre); % calculate similarity matrix
    
    dist = 1 - simMatOri;
    dist = squareform(dist);
    z = linkage(dist, 'average');
    figure
    [~, ~, perm] = dendrogram(z, 0); % find permutation
    close
    simMat = simMatOri(perm, perm);
    actMats = actMats(perm); % reorder actMats according to hierarchical clustering
    isactive = isactive(perm);
    
    %% Motif finding
    [motifSet, motifActMat, motifPrcsn, motifCh] = motifSearch(actMats, isactive, N, thre);
    
    %% Motif validation
    simuldata = load('.\motif_simulation_total.mat');
    if validation
        % Check validity of each motif
        [valid, strd] = motifValidation(actMats, motifSet, motifActMat, motifPrcsn, motifCh, thre, simuldata, numActCh);
        
        motifSet = motifSet(valid);
        motifCh = motifCh(valid);
        strd = strd(valid);
    end
    
    
    %% Motif merging
    if merge
        % Check merge
        [ismerge, combs] = motifMerge(motifSet, motifActMat, motifPrcsn, motifCh, mergethre, numActCh);
        mergeto = 1:length(motifSet);
        
        for ii=1:length(ismerge)
            if ~ismerge(ii)
                continue
            end
            mergeto(combs(ii, 2)) = mergeto(combs(ii, 1));
        end
        
        motifSetRe = cell(max(mergeto), 1);
        for ii=1:max(mergeto)
            tempidx = find(mergeto == ii);
            for jj=1:length(tempidx)
                motifSetRe{ii} = cat(2, motifSetRe{ii}, motifSet{tempidx(jj)});
            end
        end
    else
        motifSetRe = motifSet;
    end
    
    % Recalculate activation matrix of motifs
    motifActMatRe = cell(length(motifSetRe), 1);
    motifPrcsnRe = cell(length(motifSetRe), 1);
    motifChRe = cell(length(motifSetRe), 1);
    for ii=1:length(motifSetRe)
        idxtemp = motifSetRe{ii};
        mattemp = zeros(size(actMats{1}));
        prcsntemp = zeros(size(actMats{1}));
        chtemp = true(length(isactive{1}), 1);
        
        for jj=1:length(idxtemp)
            mattemp = mattemp + actMats{idxtemp(jj)};
            prcsntemp = prcsntemp + actMats{idxtemp(jj)} .^ 2;
            chtemp = chtemp & isactive{idxtemp(jj)};
        end
        
        motifActMatRe{ii} = mattemp / length(idxtemp);
        motifPrcsnRe{ii} = sqrt(prcsntemp / length(idxtemp) - motifActMatRe{ii} .^ 2);
        motifChRe{ii} = chtemp;
    end
    
    %% Burst allocation
    % Calcultate mean & std similarity of each motif
    meanSimilarity = zeros(length(motifSetRe), 1);
    stdSimilarity = zeros(length(motifSetRe), 1);
    for ii=1:length(motifSetRe)
        idxtemp = motifSetRe{ii};
        meansim = 0;
        stdsim = 0;
        for jj=1:length(idxtemp)
            simtemp = burstsim(motifActMatRe{ii}, actMats{idxtemp(jj)}, thre, 'chSelect', motifChRe{ii});
            meansim = meansim + simtemp;
            stdsim = stdsim + simtemp .^ 2;
        end
        meanSimilarity(ii) = meansim / length(idxtemp);
        stdSimilarity(ii) = sqrt(stdsim / length(idxtemp) - meanSimilarity(ii) .^ 2);
    end
    
    % find proper cluster 
    clusternum = zeros(burstnum, 1);
    for ii=1:burstnum
        simtemp = zeros(length(motifSetRe), 1);
        for jj=1:length(motifSetRe)
            if ismember(ii, motifSetRe{jj})
                clusternum(ii) = jj;
                break
            else
                simtemp(jj) = burstsim(motifActMatRe{jj}, actMats{ii}, thre, 'chSelect', motifChRe{jj});
            end
        end
        
        if clusternum(ii) > 0
            continue
        end
        
        [sim, I] = max(simtemp);
        if sim > meanSimilarity(I) - assignthre * stdSimilarity(I)
            clusternum(ii) = I;
        end
    end
    
    %% Make save data
    motifstruct = struct('motifSet', motifSetRe, 'motifActMat', motifActMatRe, 'motifPrcsn', motifPrcsnRe, 'motifCh', motifChRe);
    motifsave = {simMat, simMatOri, burstnum, clusternum, motifstruct};
    
    %% Finish
    rst.summary = [];
    rst.save = motifsave;
    rst.visual = [];
end

