classdef corrValues < handle
    % corrValues containing data from a correlation file
    %   Containing data of correlation, taxis, etc from a *.corr
    %   file and have several methods for characterization of the record.
    
    properties
        filename
        meta
        chs
        
        numchs
        numspk
        corrlength
        
        taxis
        corr
        jitcorrmean
        jitcorrstd
        
        normalizedCorr
        connmap
        dlymap
        
        savepath
    end
    
    methods
        function obj = corrValues(filename)
            if ~ischar(filename) || exist(filename, 'file') ~= 2
                obj.filename = '';
                obj.chs = [];
                obj.numchs = 0;
                obj.corrlength = 0;
                
                obj.corr = [];
                obj.jitcorrmean = [];
                obj.jitcorrstd = [];
                obj.taxis = [];
                error('corrValues: failed to load file')
            else
                tic;
                obj.filename = filename;
                obj.fileLoad();
                
                obj.meta = obj.metadata();
                
                disp([obj.filename ': ' num2str(toc)])
            end
        end
        
        function fileLoad(obj)
            A = importdata(obj.filename, '\t', 4);
            head = A.textdata;
            raw = A.data;
            
            obj.numchs = str2double(head{1}); % the number of channels
            if obj.numchs == 0
                obj.chs = [];
                obj.corrlength = 0;
                obj.corr = [];
                obj.jitcorrmean = [];
                obj.taxis = [];
                return
            end
            
            token = split(head{2}); % channel numbers
            obj.chs = zeros(length(token), 1);
            tempidx = 1;
            for ii=1:length(token)
                if ~isempty(token{ii})
                    obj.chs(tempidx) = str2double(token{ii});
                    tempidx = tempidx + 1;
                end
            end
            obj.chs(tempidx:end) = [];
            [obj.chs, I] = sort(obj.chs);
            
            token = split(head{3}); % the number of spikes
            obj.numspk = zeros(length(token), 1);
            tempidx = 1;
            for ii=1:length(token)
                if ~isempty(token{ii})
                    obj.numspk(tempidx) = str2double(token{ii});
                    tempidx = tempidx + 1;
                end
            end
            obj.numspk(tempidx:end) = [];
            obj.numspk = obj.numspk(I);
            
            obj.corrlength = str2double(head{4}); % the length of correlation
            
            obj.taxis = raw(1, :); % time axis
            raw(1, :) = [];
            
            comb = obj.numchs^2;
            
            corrtemp = raw(1:comb, :); % cross-correlation
            corrtemp = mat2cell(corrtemp, ones(1, comb), obj.corrlength);
            corrtemp = reshape(corrtemp, obj.numchs, []);
            raw(1:comb, :) = [];
            obj.corr = corrtemp(I, I);
            
            corrtemp = raw(1:comb, :); % jittered correlation mean
            corrtemp = mat2cell(corrtemp, ones(1, comb), obj.corrlength);
            corrtemp = reshape(corrtemp, obj.numchs, []);
            raw(1:comb, :) = [];
            obj.jitcorrmean = corrtemp(I, I);
            
            corrtemp = raw(1:comb, :); % jittered correlation std
            corrtemp = mat2cell(corrtemp, ones(1, comb), obj.corrlength);
            corrtemp = reshape(corrtemp, obj.numchs, []);
            obj.jitcorrstd = corrtemp(I, I);
        end
        
        function meta = metadata(obj)
            % Load meta data from the name of given file. Culture date
            % should place first, and the recording DIV should place last.
            % Culture density should start with 'd', and MEA should start
            % with 'I'.
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
            if nnz(tempidx) > 0
                tempidx = find(tempidx, 1, 'first');
                MEAnum = token{tempidx};
                token(tempidx) = [];
            else
            	MEAnum = 'I11111';
            end
            
            tempidx = endsWith(token, 'DIV');
            tempidx = find(tempidx, 1, 'last');
            DIV = str2double(token{tempidx}(1:end - 3));
            token(tempidx) = [];

            other = '';
            for ii=1:length(token)
                other = strcat(other, token{ii}, ', ');
            end
            other = other(1:end - 1);
            
            meta = struct('Date', culturedate, 'Density', culturedensity, ...
                'MEA', MEAnum, 'DIV', DIV, 'Other', other);
        end
        
        function setSavepath(obj, savepath)
            obj.savepath = savepath;
        end
    end
end

