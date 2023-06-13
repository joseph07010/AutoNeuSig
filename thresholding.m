function [rst] = thresholding(corrValues, params)
    %% inputs
    inputidx = 1;
    mode = 'relative';
    threshold = 0.3;
    display = true;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case 'mode'
                mode = params{inputidx + 1};
                inputidx = inputidx + 1;
            case 'threshold'
                threshold = params{inputidx + 1};
                inputidx = inputidx + 1;
            case 'display'
                display = params{inputidx + 1};
                inputidx = inputidx + 1;
            otherwise
                error('THRESHOLDING: Input error');
        end
        inputidx = inputidx + 1;
    end
    %% calcuation
    corrs = corrValues.normalizedCorr;
    taxis = corrValues.taxis;
    pos = find(taxis > 0);
    
    map = zeros(size(corrs));
    dly = zeros(size(corrs));
    
    for ii=1:corrValues.numchs
        for jj=1:corrValues.numchs
            if ii == jj
                continue
            end
            [map(ii, jj), I] = max(corrs{ii, jj}(pos));
            dly(ii, jj) = taxis(pos(I));
        end
    end
        
    if strcmp(mode, 'relative')
        temp = sort(map(:), 'descend');
        threshold = temp(floor(length(temp) * threshold));
        corrValues.connmap = map;
        corrValues.connmap(temp < threshold) = 0;
        corrValues.dlymap = dly;
        corrValues.dlymap(temp < threshold) = 0;
    elseif strcmp(mode, 'absolute')
        corrValues.connmap = map;
        corrValues.connmap(map < threshold) = 0;
        corrValues.dlymap = dly;
        corrValues.dlymap(map < threshold) = 0;
    end
    
    rst.summary = [];
    rst.save = {map, dly};
    
    connmap = zeros(64, 64);
    for ii=1:corrValues.numchs
        x1 = floor(corrValues.chs(ii) / 10);
        y1 = rem(corrValues.chs(ii), 10);
        for jj=1:corrValues.numchs
            if ii == jj
                continue
            end
            x2 = floor(corrValues.chs(jj) / 10);
            y2 = rem(corrValues.chs(jj), 10);
            xfinal = 8 * (x1 - 1) + x2;
            yfinal = 8 * (y1 - 1) + y2;
            
            if map(jj, ii) >= threshold
                connmap(yfinal, xfinal) = 1;
            end
        end
    end
    
    if display
        fig = figure;
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
        title('Adjacency matrix')

        nowstr = datestr(now, 'yymmdd-HHMMSS.FFF');
        filename = [nowstr '_thresholding.png'];
        filename = fullfile(corrValues.savepath, filename);
        saveas(fig, filename);
        close(fig);

        rst.visual = filename;
    else
        rst.visual = '';
    end
end

