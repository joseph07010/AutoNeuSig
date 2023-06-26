function [rst] = ifr(chValues, params)
    %% inputs
    inputidx = 1;
    binsize = 0.1; % sec
    display = true;
    interval = [];
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case 'binsize'
                inputidx = inputidx + 1;
                binsize = params{inputidx};
            case 'display'
                inputidx = inputidx + 1;
                display = params{inputidx};
            case 'interval'
                inputidx = inputidx + 1;
                interval = params{inputidx};
            otherwise
                error('IFR: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    chs = chValues.getChs();
    if chValues.activeChanneled
        chs = chs(chValues.active);
    end
    
    if ~isempty(interval)
        intvs = chValues.getInterval(interval);
        numintv = size(intvs);
    end
    
    histx = 0:binsize:chValues.timespan;
    IFR = zeros(length(chs), 1);
    
    
    for ii=1:length(chs)
        ts = chValues.getTimestampCh(chs(ii));
        if ~isempty(interval)
            flags = false(size(ts));
            for jj=1:numintv(1)
                flags = flags | (ts >= intvs(ii, 1) & ts < intvs(ii, 2));
            end
            ts = ts(flags);
        end
        
        spkrate = histcounts(ts, histx);
        if nnz(spkrate > 0) == 0
            IFR(ii) = 0;
        else
            IFR(ii) = mean(spkrate(spkrate > 0));
        end
    end
    
    rst.summary = [mean(IFR) std(IFR) length(IFR)];
    rst.save = IFR;
    
    if display
        IFR8by8 = zeros(8, 8);
        for ii=1:length(chs)
            x = floor(chs(ii) / 10);
            y = rem(chs(ii), 10);
            IFR8by8(y, x) = IFR(ii);
        end
        
        fig = figure('visible', 'off');
        imagesc(IFR8by8);
        colormap jet
        colorbar
        daspect([1 1 1])
        xticklabels([])
        yticklabels([])
        title('IFR (Hz / bin)')

        nowstr = datestr(now, 'yymmdd-HHMMSS.FFF');
        filename = [nowstr '_IFR.png'];
        filename = fullfile(chValues.savepath, filename);
        saveas(fig, filename);
        close(fig);
        rst.visual = filename;
    else
        rst.visual = '';
    end
end

