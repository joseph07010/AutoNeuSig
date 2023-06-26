function [rst] = mfr(chValues, params)
    %% inputs
    inputidx = 1;
    display = true;
    interval = [];
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case 'display'
                inputidx = inputidx + 1;
                display = params{inputidx};
            case 'interval'
                inputidx = inputidx + 1;
                interval = params{inputidx};
            otherwise
                error('MFR: Input error');
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
        
        tspan = 0;
        
        for ii=1:numintv(1)
            tspan = tspan + (intvs(ii, 2) - intvs(ii, 1));
        end
    else
        tspan = chValues.timespan;
    end
    
    MFR = zeros(length(chs), 1);
    for ii=1:length(chs)
        ts = chValues.getTimestampCh(chs(ii));
        if ~isempty(interval)
            flags = false(size(ts));
            for jj=1:numintv(1)
                flags = flags | (ts >= intvs(ii, 1) & ts < intvs(ii, 2));
            end
            ts = ts(flags);
        end
        
        MFR(ii) = length(ts) / tspan;
    end
    
    rst.summary = [mean(MFR) std(MFR) length(MFR)];
    rst.save = MFR;
    
    if display
        MFR8by8 = zeros(8, 8);
        for ii=1:length(chs)
            x = floor(chs(ii) / 10);
            y = rem(chs(ii), 10);
            MFR8by8(y, x) = MFR(ii);
        end
        
        fig = figure('visible', 'off');
        imagesc(MFR8by8);
        colormap jet
        colorbar
        daspect([1 1 1])
        xticklabels([])
        yticklabels([])
        title('MFR (Hz)')

        nowstr = datestr(now, 'yymmdd-HHMMSS.FFF');
        filename = [nowstr '_MFR.png'];
        filename = fullfile(chValues.savepath, filename);
        saveas(fig, filename);
        close(fig);
        rst.visual = filename;
    else
        rst.visual = '';
    end
end
