function setEpoch(newEpochNumber)
    global state
    
    state.epoch = newEpochNumber;
    try
        state.files.baseName = [state.files.baseName(1:strfind(state.files.baseName, '_e')) 'e' num2str(newEpochNumber) '_'];
        updateGUIByGlobal('state.files.baseName')
        updateHeaderString('state.epoch')
        updateHeaderString('state.files.baseName')
    catch
    end
    xsg_setEpochNumber(state.epoch)
end