classdef chValues < handle
    % chValues containing data from a mcd file
    %   Containing data like timestamp, channel numbers, etc from a *.mcd,
    %   *.h5, *.gdf
    %   file and have several methods for characterization of the record.
    
    properties
        filename
        timespan % sec
        meta
        
        trigs
        trigChs
        trigNums
        
        timestamps
        chNums
        groups
        
        active
        burstDetected
        activeChanneled
        
        intervals
        intervalName
        
        savepath
    end
    
    methods
        function obj = chValues(filename)
            % Constructor of chValues, read spike data and meta data from
            % given record file. Library should be loaded first.
            if ~ischar(filename) || exist(filename, 'file') ~= 2
                obj.filename = '';
                obj.timestamps = [];
                obj.chNums = [];
                obj.groups = [];
                obj.active = [];
                obj.savepath = '';
                error('chValues: failed to load file')
            else
                tic;
                obj.filename = filename;
                obj.fileLoad();
                
                % need to be fixed
                obj.active = true(size(obj.getChs()));
                obj.burstDetected = false;
                obj.activeChanneled = false;
                
                obj.intervals = {};
                obj.intervalName = {};
                
                obj.metadata();
                obj.savepath = '';
                disp([obj.filename ': ' num2str(toc)])
            end
        end
        
        function fileLoad(obj)
            import McsHDF5.*
            [~, ~, ext] = fileparts(obj.filename);
            if strcmp(ext, '.mcd') % mcd file load
                % File open
                [ns, hfile] = ns_OpenFile(obj.filename);
                if ns ~= 0
                    error('chValues - fileLoad: failed to open file')
                end

                % Get file information (timespan, # of chs)
                [~, info] = ns_GetFileInfo(hfile);
                obj.timespan = info.TimeSpan;
                entityCount = info.EntityCount;

                entitys = cell(entityCount, 1);
                types = zeros(entityCount, 1);
                chs = zeros(entityCount, 1);
                spknums = zeros(entityCount, 1);

                tempidx = 1;
                for ii=1:entityCount % Organize data
                    [~, entity] = ns_GetEntityInfo(hfile, ii);
                    if ~(entity.EntityType == 1 || entity.EntityType == 3) % Only entities type 1 (trig) and 3 (spk)
                        continue
                    end
                    types(ii) = entity.EntityType;

                    chNum = str2double(entity.EntityLabel(end - 1:end)); % Get channel number and trigger number
                    itemCount = entity.ItemCount;
                    ts = zeros(itemCount, 1);
                    if types(ii) == 3
                        for jj=1:itemCount
                            [~, ts(jj), ~, ~, ~] = ns_GetSegmentData(hfile, ii, jj); % load timestamp from file
                        end
                    elseif types(ii) == 1
                        for jj=1:itemCount
                            [~, ts(jj), ~, ~] = ns_GetEventData(hfile, ii, jj); % load trigger data from file
                        end
                    end

                    entitys{tempidx} = ts; % timestamps
                    chs(tempidx) = chNum; % channel number
                    spknums(tempidx) = itemCount;
                    tempidx = tempidx + 1;
                end
                entitys(tempidx:end) = [];
                chs(tempidx:end) = [];
                spknums(tempidx:end) = [];
                
                % File close 
                ns_CloseFile(hfile);
                
                % Trigger organization
                trigidx = find(types == 1);
                trigts = cell(length(trigidx), 1);
                trigchs = zeros(length(trigidx), 1);
                trignums = zeros(length(trigidx), 1);
                
                for ii=1:length(trigidx)
                    trigts{ii} = entitys{trigidx(ii)};
                    trigchs(ii) = chs(trigidx(ii));
                    trignums(ii) = spknums(trigidx(ii));
                end
                
                entitys(trigidx) = [];
                chs(trigidx) = [];  
                spknums(trigidx) = [];
                
                % Spike data organization
                spks = zeros(sum(spknums), 2);
                tempidx = 1;
                for ii=1:length(entitys)
                    spks(tempidx:tempidx + spknums(ii) - 1, 1) = entitys{ii}; % first column is timestamp
                    spks(tempidx:tempidx + spknums(ii) - 1, 2) = chs(ii); % second column is channel number 

                    tempidx = tempidx + spknums(ii);
                end
                spks = sortrows(spks, 1);
            elseif strcmp(ext, '.h5') % hdf5 file
                % File open
                try
                    data = McsHDF5.McsData(obj.filename);
                catch
                    disp('chValues - fileLoad: failed to open file')
                end
                
                timenorm = 1e6;
                recording = data.Recording{1};
                obj.timespan = double(recording.Duration) / timenorm;
                
                % Spike data organization
                tsstream = recording.TimeStampStream{1};
                entityCount = length(tsstream.TimeStamps);
                
                entitys = cell(entityCount, 1);
                chs = zeros(entityCount, 1);
                spknums = zeros(entityCount, 1);
                
                for ii=1:entityCount
                    entitys{ii} = double(tsstream.TimeStamps{ii}) / timenorm;
                    chs(ii) = str2double(tsstream.Info.Label{ii});
                    spknums(ii) = length(entitys{ii});
                end
                
                spks = zeros(sum(spknums), 2);
                tempidx = 1;
                for ii=1:length(entitys)
                    spks(tempidx:tempidx + spknums(ii) - 1, 1) = entitys{ii}; % first column is timestamp
                    spks(tempidx:tempidx + spknums(ii) - 1, 2) = chs(ii); % second column is channel number 

                    tempidx = tempidx + spknums(ii);
                end
                spks = sortrows(spks, 1);
                
                % Trigger data organization
                eventstream = recording.EventStream;
                entityCount = length(eventstream);
                
                trigts = cell(entityCount, 1);
                trigchs = zeros(entityCount, 1);
                trignums = zeros(entityCount, 1);
                for ii=1:entityCount
                    entity = recording.EventStream{ii};
                    ts = entity.Events{1}(1, :)';
                    trigts{ii} = double(ts) / timenorm;
                    trigchs(ii) = str2double(entity.Label(end - 1:end));
                    trignums(ii) = length(trigts{ii});
                end
            elseif strcmp(ext, '.gdf') % gdf file (simulation)
                raw = importdata(obj.filename);
                dimraw = size(raw);
                obj.timespan = round(max(raw(:, 2)) / 1e3, -2);
                
                spks = zeros(dimraw(1), 2);
                spks(:, 1) = raw(:, 2) / 1e3; % raw data have timestamp in the second column
                spks(:, 2) = raw(:, 1); % channel is in the first column in raw data
            else
                disp('chValues - fileLoad: wrong type of file')
            end
            
            obj.trigs = trigts;
            obj.trigChs = trigchs;
            obj.trigNums = trignums;
            
            obj.timestamps = spks(:, 1);
            obj.chNums = spks(:, 2);
            obj.groups = zeros(length(spks(:, 1)), 1);
        end
        
        function metadata(obj)
            % Load meta data from the name of given file. Culture date
            % should place first, and the recording DIV should place last.
            % Culture density should start with 'd', and MEA should start
            % with 'I'.
            [~, ~, ext] = fileparts(obj.filename);
            if strcmp(ext, '.gdf')
                token = split(obj.filename, '\');
                other = strcat(token{1}, token{2}, ', ');
                obj.meta = struct('Date', '', 'Density', '', ...
                'MEA', '', 'DIV', '', 'Other', other);
            else
                token = split(obj.filename, '\');
                token = token{end};
                token = split(token, {'_', '.'});
                token = token(1:end - 1);

                culturedate = str2double(token{1});
                token = token(2:end);

                tempidx = startsWith(token, 'd');
                if nnz(tempidx) > 0
                    tempidx = find(tempidx, 1, 'first');
                    culturedensity = str2double(token{tempidx}(2:end));
                    token(tempidx) = [];
                else
                    culturedensity = 0;
                end

                tempidx = startsWith(token, 'I');
                MEAnum = token{tempidx};
                token = token(~tempidx);

                tempidx = endsWith(token, 'DIV');
                tempidx = find(tempidx, 1, 'last');
                DIV = str2double(token{tempidx}(1:end - 3));
                token(tempidx) = [];

                other = '';
                for ii=1:length(token)
                    other = strcat(other, token{ii}, ', ');
                end
                other = other(1:end - 1);

                obj.meta = struct('Date', culturedate, 'Density', culturedensity, ...
                    'MEA', MEAnum, 'DIV', DIV, 'Other', other);
            end
        end
        
        function setSavepath(obj, savepath)
            obj.savepath = savepath;
        end
        
        function chs = getChs(obj)
            chs = unique(obj.chNums);
        end
        
        function ts = getTimestampCh(obj, ch)
            ts = obj.timestamps(obj.chNums == ch);
        end
        
        function ts = getTimestampIntv(obj, intv)
            if length(intv) ~= 2
                error('Input interval should have 2 numeric values')
            end
            if intv(1) >= intv(2)
                error('Rising edge of interval should be smaller than falling edge')
            end
            ts = obj.timestamps(obj.timestamps >= intv(1) & obj.timestamps < intv(2));
        end
        
        function ts = getTrigger(obj, ch)
            if nnz(obj.trigChs == ch) == 0
                error('Input trigger channel cannot be found')
            end
            ts = obj.trigs{obj.trigChs == ch};
        end
        
        function ts = getTimestampByLabel(obj, label)
            if startsWith(label, 'Trig')
                ch = str2double(label(5:end));
                ts = obj.getTrigger(ch);
            elseif startsWith(label, 'Ch')
                ch = str2double(label(3:end));
                ts = obj.getTimestampCh(ch);
            else
                error('Label should start with Trig or Ch')
            end
        end
        
        function ts = parseGetTimestampByLabel(obj, label)
            if contains(label, '+')
                tokens = split(label, '+');
                if length(tokens) > 2
                    error('Input should be Trig/Ch##(+/-##)')
                end
                ts = obj.getTimestampByLabel(tokens{1});
                ts = ts + str2double(tokens{2});
            elseif contains(label, '-')
                tokens = split(label, '-');
                if length(tokens) > 2
                    error('Input should be Trig/Ch##(+/-##)')
                end
                ts = obj.getTimestampByLabel(tokens{1});
                ts = ts - str2double(tokens{2});
            else
                ts = obj.getTimestampByLabel(label);
            end
        end
        
        function buildInterval(obj, name, manner, varargin)
            % Name finding
            if sum(strcmp(obj.intervalName, name)) > 0
                error('The same name of interval already exist')
            end
            
            % Input parsing
            rise = obj.parseGetTimestampByLabel(varargin{1});
            
            if strcmp(manner, 'risefalledge')
                fall = obj.parseGetTimestampByLabel(varargin{2});
            elseif strcmp(manner, 'timediff')
                tdiff = varargin{2};
                if ~isnumeric(tdiff)
                    error('For timediff, input should be numeric')
                end
                fall = rise + tdiff;
            else
                error('Manner should be risefalledge or timediff')
            end
            
            % Rising and falling edge should be the same number
            if length(rise) ~= length(fall)
                error('Rising and falling edge should be the same number')
            end
            
            % Falling edge hould be larger than rising edge
            if sum(rise > fall) > 0
                error('Falling edge should be larger than rising edge')
            end
            newInterval = [rise fall];
            
            obj.intervals{end + 1} = newInterval;
            obj.intervalName{end + 1} = name;
        end
        
        function intervals = getInterval(obj, name)
            idx = strcmp(obj.intervalName, name);
            if nnz(idx) < 1
                error('There are no such interval')
            end
            intervals = obj.intervals{idx};
        end
    end
end

