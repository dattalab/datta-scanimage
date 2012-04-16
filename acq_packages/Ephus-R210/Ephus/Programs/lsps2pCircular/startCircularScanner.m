function startCircularScanner
global state;

scanImageRunning = 0;

if exist('state')
    if ~isempty(state)
        if isfield(state, 'init') & isfield(state, 'acq')
            if state.init.pockelsOn
                scanImageRunning = 1;
            end
        end
    end
end

if scanImageRunning
    openProgram(progmanager, program('Lsps2pCircular', 'lsps2pCircular'))
else
    errordlg('ScanImage must be running to use this program.');
    error('ScanImage must be running to use this program.');
end

return;