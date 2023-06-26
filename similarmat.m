function simMat = similarmat(actMats, thre, varargin)
    %% Parameter parsing
    inputidx = 1;
    chSelect = [];
    while true
        if inputidx > length(varargin)
            break
        end
        
        switch varargin{inputidx}
            case 'chSelect'
                inputidx = inputidx + 1;
                chSelect = varargin{inputidx};
            otherwise
                error('BURSTS: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% Build similarity matrix
    burstnum = length(actMats);
    simMat = zeros(burstnum, burstnum);
    
    for ii=1:burstnum
        for jj=1:burstnum
            if ii == jj
                simMat(ii, jj) = 1;
            else
                if isempty(chSelect)
                    simMat(ii, jj) = burstsim(actMats{ii}, actMats{jj}, thre);
                else
                    simMat(ii, jj) = burstsim(actMats{ii}, actMats{jj}, thre, 'chSelect', chSelect);
                end
            end
        end
    end
end
