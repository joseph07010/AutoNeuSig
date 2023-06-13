function [rst] = fanoFactor(chValues, params)
    %% inputs
    inputidx = 1;
    binsize = 0.1; % sec
    display = true;
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
            otherwise
                error('FANOFACTOR: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    chs = chValues.getChs();
    if chValues.activeChanneled
        chs = chs(chValues.active);
    end
    
    FF = zeros(length(chs), 1);
    histx = 0:binsize:chValues.timespan;
    
    for ii=1:length(chs)
        ts = chValues.getTimestampCh(chs(ii));
        spkrate = histcounts(ts, histx);
        FF(ii) = std(spkrate)^2 / mean(spkrate);
    end
    
    rst.summary = [mean(FF) std(FF) length(FF)];
    rst.save = FF;
    
    if display
        FF8by8 = zeros(8, 8);
        for ii=1:length(chs)
            x = floor(chs(ii) / 10);
            y = rem(chs(ii), 10);
            FF8by8(y, x) = FF(ii);
        end
        
        fig = figure('visible', 'off');
        imagesc(FF8by8);
        colormap jet
        colorbar
        daspect([1 1 1])
        xticklabels([])
        yticklabels([])
        title('Fano factor')

        nowstr = datestr(now, 'yymmdd-HHMMSS.FFF');
        filename = [nowstr '_FanoFactor.png'];
        filename = fullfile(chValues.savepath, filename);
        saveas(fig, filename);
        close(fig);
        rst.visual = filename;
    else
        rst.visual = '';
    end
end

