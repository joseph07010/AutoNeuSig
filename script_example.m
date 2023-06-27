%% Multiple file example
filepath = '.\Test_files\MCD'; % file path example
filelist = dir(fullfile(filepath, '*.mcd')); % make file list

as = analysisSession(filelist); % object construction
as.loadAnalysisConfig(''); % load analysis configuration
as.analyze(); % analysis execute

%% Single file example
selectidx = 1; % file selection
filename = fullfile(filelist(selectidx).folder, filelist(selectidx).name);
chv = chValues(filename); % Channel value object construction

activeChs(chv, {'display', false}); % Active channel test 
burstDetect(chv, {'merge', 0.1}); % Burst detection
rst = motifCharacterize(chv, {}); % Motif characterization

%% Multiple file example with time interval
filepath = '.\Test_files\Interval'; % file path for interval example
filelist = dir(fullfile(filepath, '*.mcd')); % make file list

as = analysisSession(filelist);
as.loadAnalysisConfig('analysis_config_interval.xlsx');
as.buildInterval('intv1', 'risefalledge', 'Trig1', 'Trig2'); % interval from Trig1 to Trig 2
as.buildInterval('intv2', 'timediff', 'Trig1 - 30', 30); % interval from 'Trig1 - 30' for 30 sec
as.analyze();

%% Single file example with time interval
selectidx = 1; % file selection
filename = fullfile(filelist(selectidx).folder, filelist(selectidx).name);
chv = chValues(filename); % Channel value object construction

chv.buildInterval('intv1', 'risefalledge', 'Trig1 + 10', 'Trig2');
chv.buildInterval('intv2', 'timediff', 'Trig2', 30);

activeChs(chv, {'display', false});
rst1 = awmfr(chv, {'interval', 'intv1'});
rst2 = awmfr(chv, {'interval', 'intv2'});