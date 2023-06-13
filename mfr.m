function [rst] = mfr(chValues, params)
    %% inputs
    inputidx = 1;
    display = true;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case 'display'
                inputidx = inputidx + 1;
                display = params{inputidx};
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
    
    MFR = zeros(length(chs), 1);
    for ii=1:length(chs)
        MFR(ii) = nnz(chValues.chNums == chs(ii)) / chValues.timespan;
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
