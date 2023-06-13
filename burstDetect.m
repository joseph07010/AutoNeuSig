function [rst] = burstDetect(chValues, params)
    %% input parameter
    binsize = 0.025; % 25 msec
    threshold = 9;
    merge = false;
    mergegap = 0;
    edgerate = 0.1;
    entrycut = 0.3;
    save = false;
    
    inputidx = 1;
    while true
        if inputidx > length(params)
            break
        end
        
        switch params{inputidx}
            case 'binsize'
                inputidx = inputidx + 1;
                binsize = params{inputidx};
            case 'threshold'
                inputidx = inputidx + 1;
                threshold = params{inputidx};
            case 'merge'
                merge = true;
                inputidx = inputidx + 1;
                mergegap = params{inputidx};
            case 'edge'
                inputidx = inputidx + 1;
                edgerate = params{inputidx};
            case 'entry'
                inputidx = inputidx + 1;
                entrycut = params{inputidx};
            case 'save'
                save = true;
            otherwise
                error('BURSTDETECT: Input error');
        end
        inputidx = inputidx + 1;
    end
    
    %% basic parameter
    histx = 0:binsize:chValues.timespan;
    timestamps = chValues.timestamps;
    chNums = chValues.getChs();
    if chValues.activeChanneled
        chNums = chNums(chValues.active);
    end
    chNums = length(chNums);
    
    %% calculate spike rate and ch rate
    [spkrate, ~, chs] = histcounts(timestamps, histx);
    chrate = zeros(size(spkrate));
    for ii=1:length(chrate)
        tempidx = (chs == ii);
        chrate(ii) = length(unique(chValues.chNums(tempidx)));
    end
    rate = spkrate .* chrate;
    
    %% find burst regime
    if entrycut == 0
        aa = find(rate >= threshold);
    else
        aa = find(rate >= threshold & chrate >= entrycut * chNums);
    end
    rise = zeros(length(aa), 1);
    fall = zeros(length(aa), 1);
    
    tempidx = 1;
    while ~isempty(aa)
        temp = 1;
        while aa(1) - temp > 0 && rate(aa(1) - temp) > 0
            temp = temp + 1;
        end
        rise(tempidx) = aa(1) - temp + 1;

        temp = 1;
        while aa(1) + temp < length(rate) && rate(aa(1) + temp) > 0
            temp = temp + 1;
        end
        fall(tempidx) = aa(1) + temp;

        aa(aa >= rise(tempidx) & aa <= fall(tempidx)) = [];
        tempidx = tempidx + 1;
    end

    if tempidx <= length(rise)
        rise(tempidx:end) = [];
        fall(tempidx:end) = [];
    end
    
    if edgerate > 0
        for ii=1:length(rise)
            peak = max(rate(rise(ii):fall(ii) - 1));
            temp = 1;
            while rate(rise(ii) + temp - 1) <= peak * edgerate
                temp = temp + 1;
            end
            rise(ii) = rise(ii) + temp - 1;
            
            temp = 1;
            while rate(fall(ii) - temp) <= peak * edgerate
                temp = temp + 1;
            end
            fall(ii) = fall(ii) - temp + 1;
        end
    end
    
    rise = histx(rise);
    fall = histx(fall);
    for ii=1:length(rise)
        tempidx = timestamps >= rise(ii) & timestamps <= fall(ii);
        chValues.groups(tempidx) = ii;
    end
    
    %% merge close bursts
    if merge && length(rise) >= 2
        ismerge = false(length(rise) - 1, 1);
        for ii=2:length(rise)
            burstprev = timestamps(chValues.groups == ii - 1);
            burstcurr = timestamps(chValues.groups == ii);
            
            if burstcurr(1) - burstprev(end) <= mergegap
                ismerge(ii) = true;
            end
        end
        
        groupnum = 1;
        groups = chValues.groups;
        for ii=1:length(rise) - 1
            if ismerge(ii)
                idx1 = find(groups == ii, 1);
                idx2 = find(groups == ii + 1, 1);
                chValues.groups(idx1:idx2) = groupnum;
            else
                chValues.groups(groups == ii) = groupnum;
                groupnum = groupnum + 1;
            end
        end
        chValues.groups(groups == ii + 1) = groupnum;
    else
        groupnum = 0;
    end
    
    %% make burst save
    if save
        burstsave = struct('spktime', cell(groupnum, 1), 'chnum', cell(groupnum, 1));
        for ii=1:groupnum
            idxtemp = (chValues.groups == ii);
            burstsave(ii).spktime = timestamps(idxtemp);
            burstsave(ii).chnum = chValues.chNums(idxtemp);
        end
    end
    
    %% finish
    chValues.burstDetected = true;
    
    rst.summary = [];
    
    if save
        rst.save = burstsave;
    else
        rst.save = [];
    end
    rst.visual = [];
end

