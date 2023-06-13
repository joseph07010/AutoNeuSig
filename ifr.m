function [rst] = ifr(chValues, params)
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
                error('IFR: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    chs = chValues.getChs();
    if chValues.activeChanneled
        chs = chs(chValues.active);
    end
    histx = 0:binsize:chValues.timespan;
    IFR = zeros(length(chs), 1);
    
    for ii=1:length(chs)
        spks = chValues.getTimestampCh(chs(ii));
        spkrate = histcounts(spks, histx);
        IFR(ii) = mean(spkrate(spkrate > 0));
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

