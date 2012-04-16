% mc_userFcn_ephysSamplesAcquired - Update mirror positions at the end of an acquisition.
%
% SYNTAX
%  mc_userFcn_ephysSamplesAcquired(hObject, bufferName, data, ai, strct, varargin)
%    hObject - The program handle.
%    bufferName - The name of the previously acquired buffer (supplied as part of the samplesAcquired event).
%    data - The name of the previously acquired buffer (supplied as part of the samplesAcquired event).
%    ai - The daq object that  (supplied as part of the samplesAcquired event).
%    strct - The daq event structure (supplied as part of the samplesAcquired event).
%    bufferName - The name of the previously acquired buffer (supplied as part of the samplesAcquired event).
%    programName - The name of the program that spawned the event.
%    channelName - The name of the channel that spawned the event.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 9/13/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mc_userFcn_ephysSamplesAcquired(hObject, bufferName, data, ai, strct, varargin)

[mapperObj, positions] = getLocalBatch(progmanager, hObject, 'mapperObj', 'positions');
[flashNumber, isi, f, mouse, xOffset, xAmplitude, xGain, yOffset, yAmplitude, yGain, xInvert, yInvert, mousePoints] = getLocalBatch(progmanager, hObject, ...
    'flashNumber', 'isi', 'videoFigure', 'mouse', ...
    'temp_xOffset', 'temp_xAmplitude', 'temp_xGain', 'temp_yOffset', 'temp_yAmplitude', 'temp_yGain', 'temp_xInvert', 'temp_yInvert', 'mousePoints');

if ~mouse
    setLocalGh(progmanager, hObject, 'mouse', 'String', 'Mouse', 'ForegroundColor', [0 .6 0]);
    return;
end

if isempty(mousePoints)
    setLocal(progmanager, hObject, 'mouse', 0);
    setLocalGh(progmanager, hObject, 'mouse', 'String', 'Mouse', 'ForegroundColor', [0 .6 0]);
    return;
end

x = mousePoints(:, 1);
y = mousePoints(:, 2);

setLocalGh(progmanager, hObject, 'mouse', 'String', 'Stop', 'ForegroundColor', [1 .2 .2]);

mapper_captureConfigs(hObject);
mapper_setSaveConfig(hObject, 'flash');
%mapper_createSignals(hObject);%TO031006B
flashNumber = getLocal(progmanager, hObject, 'flashNumber');
xsg_setAcquisitionNumber(flashNumber);
setID = xsg_getSetID;
setID(1) = 'F';
xsg_setSetID(setID);

dm = getDaqmanager;

%TO030906C: Fix the beam position display to take into account any inversions.
if ~xInvert
    xSign = +1;
else
    xSign = -1;
end
if ~yInvert
    ySign = +1;
else
    ySign = -1;
end

%TO042106A - Redefine how invert applies to offset. -- Tim O'Connor 4/21/06
xMirrorVoltages = xSign * xOffset + xSign * x * xGain;
yMirrorVoltages = ySign * yOffset + ySign * y * yGain;

% if any(xMirrorVoltages > xAmplitude + xOffset) | any(xMirrorVoltages < xOffset - xAmplitude)
%     xMirrorVoltages(find(xMirrorVoltages > xAmplitude + xOffset)) = xAmplitude + xOffset;
%     xMirrorVoltages(find(xMirrorVoltages < xOffset - xAmplitude)) = xOffset - xAmplitude;
%     warning('Calculated X values that are outside the x-axis galvo''s field of view.');
% end
% 
% if any(yMirrorVoltages > yAmplitude + yOffset) | any(yMirrorVoltages < yOffset - yAmplitude)
%     yMirrorVoltages(find(yMirrorVoltages > yAmplitude + yOffset)) = yAmplitude + yOffset;
%     yMirrorVoltages(find(yMirrorVoltages < yOffset - yAmplitude)) = yOffset - yAmplitude;
%     warning('Calculated Y values that are outside the y-axis galvo''s field of view.');
% end

setLocal(progmanager, hObject, 'mousing', 1);

%TO032906D - Implement a turbo mode for the mouse as well as the map.
%TO031306A - Determine the timing mode, for now hijack the value from the loopGui.
lm = getGlobal(progmanager, 'loopManager', 'loopGui', 'loopGui');

if ~get(lm, 'preciseTimeMode')
    fireEvent(getUserFcnCBM, 'mapper:MouseStart');%TO030706D: Add userFcn events for the mapper. -- Tim O'Connor 3/7/06

    % setLocal(progmanager, hObject, 'flashNumber', flashNumber + length(xMirrorVoltages));
    
    try
        for i = 1 : length(xMirrorVoltages)
            if ~getLocal(progmanager, hObject, 'mouse')
                break;
            end
            
            %         %Swap X and Y, for now, to be consistent with Matlab image conventions.
            putDaqSample(dm, 'xMirror', xMirrorVoltages(i));
            putDaqSample(dm, 'yMirror', yMirrorVoltages(i));
            
            setLocal(progmanager, hObject, 'beamCoordinates', [x(i) y(i)]);%TO030906C
            
            updateDisplay(hObject);
            
            mapper_stimulatePoint(hObject);
            
            %Implement ISI. -- Tim O'Connor 1/26/06
%             if i < length(xMirrorVoltages) + 1
                pause(isi);
%             end
        end
    catch
        warning('Error encountered while taking a map: %s', lasterr);
    end
    
    fireEvent(getUserFcnCBM, 'mapper:MouseStop');%TO030706D: Add userFcn events for the mapper. -- Tim O'Connor 3/7/06
    
    mapper_restoreConfigs(hObject);
   
    setLocalBatch(progmanager, hObject, 'mouse', 0);
    setLocalGh(progmanager, hObject, 'mouse', 'String', 'Mouse', 'ForegroundColor', [0 .6 0]);
else
    %TO033106A: Update the display before the call to the user function. -- Tim O'Connor 3/31/06
    xPosMicrons = xSign * (xMirrorVoltages(end) - xSign * xOffset) / xGain;
    yPosMicrons = ySign * (yMirrorVoltages(end) - ySign * yOffset) / yGain;
    setLocal(progmanager, hObject, 'beamCoordinates', [xPosMicrons yPosMicrons]);
    updateDisplay(hObject);
    
    fireEvent(getUserFcnCBM, 'mapper:MouseStart');%TO030706D: Add userFcn events for the mapper. -- Tim O'Connor 3/7/06
    turboMode(hObject, xMirrorVoltages, yMirrorVoltages);
    start(lm);
end