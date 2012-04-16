function updateScanAngleMultiplier(~,~)
%UPDATERSPS_LISTENER Handles changes necessary after an ROI Scan Parameter (RSP) has been changed.

global state

if ~state.hSI.mdlInitialized
    return;
end

updateRSPs();
resetImageProperties();


