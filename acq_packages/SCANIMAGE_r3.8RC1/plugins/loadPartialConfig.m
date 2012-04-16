function loadPartialConfig(cfgFile)
global state

%%%VI021009C %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(state.configPath) && isdir(state.configPath)
    startPath = state.configPath;
else
    startPath = cd;
end
if ~strcmpi(startPath(end),filesep) %Ensure startPath ends with a slash
    startPath = [startPath filesep];
end

if nargin < 1 || isempty(cfgFile) %VI050510A
    [fname, pname] = uigetfile([startPath '*.cfg'], 'Choose configuration to load');
    
    if isnumeric(fname)
        return;
    end
    
    [~,~,ext] = fileparts(fname);
    if isempty(ext) || ~strcmpi(ext,'.cfg')
        fprintf(2,'WARNING: Invalid file extension provided. Cannot open CFG file.\n');
        return
    end
    
    %%%%%VI050510A%%%%%%%%%%%%%%%%%
else
    assert(ischar(cfgFile)&&isvector(cfgFile),'Argument to loadConfigurationFile() must be string-valued, specifying configuration (CFG) filename/path to load');
    [pname,f,e] = fileparts(cfgFile);
    if isempty(pname)
        pname = startPath;
    end
    fname = [f e];
    if ~strcmpi(e,'.cfg') || ~exist(fullfile(pname,fname),'file')
        error('Invalid or non-existant configuration (CFG) file specified.');
    end
end

if ~isnumeric(fname)
    [flag, fname, pname]=initGUIs(fullfile(pname,fname));
    
    setStatusString('Config Loaded'); %VI021009D
else
    setStatusString(''); %VI021009D
end
