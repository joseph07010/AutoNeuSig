function [rst] = isi(chValues, params)
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
                error('ISI: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    chs = chValues.getChs();
    if chValues.activeChanneled
        chs = chs(chValues.active);
    end
    
    ISI = cell(length(chs), 1);
    meanISI = zeros(length(chs), 1);
    for ii=1:length(chs)
        ts = chValues.getTimestampCh(chs(ii));
        ISI{ii} = ts(2:end) - ts(1:end - 1);
        meanISI(ii) = mean(ISI{ii});
    end
    
    rst.summary = [mean(meanISI) std(meanISI) length(meanISI)];
    rst.save = ISI;
    
    if display
        ISI8by8 = zeros(8, 8);
        for ii=1:length(chs)
            x = floor(chs(ii) / 10);
            y = rem(chs(ii), 10);
            ISI8by8(y, x) = meanISI(ii);
        end
        
        fig = figure('visible', 'off');
        imagesc(ISI8by8);
        colormap jet
        colorbar
        daspect([1 1 1])
        xticklabels([])
        yticklabels([])
        title('ISI (sec)')

        nowstr = datestr(now, 'yymmdd-HHMMSS.FFF');
        filename = [nowstr '_ISI.png'];
        filename = fullfile(chValues.savepath, filename);
        saveas(fig, filename);
        close(fig);
        rst.visual = filename;
    else
        rst.visual = '';
    end
end