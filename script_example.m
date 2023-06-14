%% Multiple file examplee
filepath = 'F:\Hyungsub\Alginate_total'; % file path example
filelist = dir(fullfile(filepath, '*\*\*.mcd')); % make file list

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