function [rst] = connmap(corrValues, params)
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
                error('CONNMAP: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% calculation
    map = corrValues.connmap;
    
    rst.summary = [];
    rst.save = [];
    
    if display
        connmap = zeros(64, 64);
        for ii=1:corrValues.numchs
            x1 = floor(corrValues.chs(ii) / 10);
            y1 = rem(corrValues.chs(ii), 10);
            for jj=1:corrValues.numchs
                x2 = floor(corrValues.chs(jj) / 10);
                y2 = rem(corrValues.chs(jj), 10);
                xfinal = 8 * (x1 - 1) + x2;
                yfinal = 8 * (y1 - 1) + y2;

                connmap(yfinal, xfinal) = map(jj, ii);
            end
        end

        fig = figure('visible', 'off');
        imagesc(connmap)
        colormap jet
        colorbar
        daspect([1 1 1])

        for ii=1:7
            line([8 8] * ii + 0.5, [0.5 64.5], 'color', 'white')
            line([0.5 64.5], [8 8] * ii + 0.5, 'color', 'white')
        end
        hold on
        for ii=1:8
            for jj=1:8
                if (ii == 1 && jj == 1) || (ii == 1 && jj == 8) || (ii == 8 && jj == 1) || (ii == 8 && jj == 8)
                    continue
                end
                x = (ii - 1) * 8 + ii;
                y = (jj - 1) * 8 + jj;
                plot(x, y, 'wx')
            end
        end
        xticklabels([])
        yticklabels([])
        title('Connection matrix')

        nowstr = datestr(now, 'yymmdd-HHMMSS.FFF');
        filename = [nowstr '_connmap.png'];
        filename = fullfile(corrValues.savepath, filename);
        saveas(fig, filename);
        close(fig);

        rst.visual = filename;
    else
        rst.visual = '';
    end
end

