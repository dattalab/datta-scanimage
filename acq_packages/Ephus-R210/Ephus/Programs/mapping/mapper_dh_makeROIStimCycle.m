% mapper_dh_makeROIStimCycle - Creates pulses for a cycle that illuminates a set of raster scans.
%
% SYNTAX
%  mapper_dh_makeROIStimCycle(repetitions, linesPerROI, xExtent, x0, yExtent, y0, msPerLine, isi, delay, xParkOffset, yParkOffset)
%  mapper_dh_makeROIStimCycle(repetitions, linesPerROI, xExtent, x0, yExtent, y0, msPerLine, isi, delay, xParkOffset, yParkOffset, pulseDest, cycleName)
%   repetitions - The number of times per ROI over which to scan (if greater than length of xExtent, they will be looped).
%                 May be an array of the same length as xExtent.
%   linesPerROI - The number of scan lines per ROI.
%                 May be an array of the same length as xExtent.
%   xExtent - The width of the ROIs, in microns in the field of view.
%             The length of this array determines the number of ROIs to define.
%   x0 - The horizontal position of the ROIs, in microns in the field of view, corresponding to the top left corner.
%        May be an array of the same length as xExtent.
%   yExtent - The height of the ROIs, in microns in the field of view.
%             May be an array of the same length as xExtent.
%   y0 - The vertical position of the ROIs, in microns in the field of view, corresponding to the top left corner.
%        May be an array of the same length as xExtent.
%   msPerLine - The time, in milliseconds, to sweep one horizontal line in the scan.
%               May be an array of the same length as xExtent.
%   isi - The interstimulus (or in this case, interROI) interval, in milliseconds.
%         This is the time from the start of one ROI scan until its repetition.
%   delay - The onset delay, in milliseconds. This is the time from the initial trigger until ROI scanning commences.
%   xParkOffset - The horizontal location at which to park the beam when not scanning.
%   yParkOffset - The vertical location at which to park the beam when not scanning.
%   pulseDest - The directory (the pulse set, within the pulse directory) in which to place pulses.
%               The user will be prompted if this is not specified.
%               Ex: 'C:\Data\User1\pulses\ROICyclePulses'
%   cycleName - The name of the cycle to be created.
%               The user will be prompted if this is not specified.
%
% NOTES
%  This is intended for use in an in-vivo environment. As such, no shutter will be used because the animal may hear the shutter and become conditioned
%  to respond to the click. To stop illuminating, the mirrors will be parked at an extreme angle that does not enter the objective. Additionally, the 
%  mirrors may make noise that can condition the animal, so "no go" trials may also be implemented as scans that fall outside the objective, thus providing
%  the same auditory stimulus regardless of trial-type.
%  The target system is simplified, and does not possess a Pockels cell (or other analog power modulation feature). No electrophysiology pulse is required.
%
% Created: Timothy O'Connor 12/08/09
% Requirements: Daniel Huber (JFRC)
% Copyright: Northwestern University/Howard Hughes Medical Institute 2009
function mapper_dh_makeROIStimCycle(repetitions, linesPerROI, xExtent, x0, yExtent, y0, msPerLine, isi, delay, xParkOffset, yParkOffset, varargin)

mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
sampleRate = getLocalBatch(progmanager, mapperObj, 'sampleRate');

if length(varargin) < 1
    destDir = getDefaultCacheDirectory(progmanager, 'roiStimulationCycle');
    if strcmpi(destDir, pwd)
        destDir = getDefaultCacheDirectory(progmanager, 'pulseDir');
    end
    destDir = uigetdir(destDir, 'Choose a pulseSet for the destination of new pulses.');
    if length(destDir) == 1
        if destDir == 0
            return;
        end
    end
else
    destDir = varargin{1};
    if exist(destDir, 'dir') ~= 7
        error('pulseDest must be a valid directory: ''%s'' does not exist.', destDir);
    end
end
setDefaultCacheValue(progmanager, 'roiStimulationCycle', destDir);
[pulseDir, pulseSetName] = fileparts(destDir);

if length(x0) == 1
    x0 = x0 * ones(size(xExtent));
elseif length(x0) ~= length(xExtent)
    error('The length of x0 must be scalar or the same as the length of xExtent.');
end
if length(yExtent) == 1
    yExtent = yExtent * ones(size(xExtent));
elseif length(yExtent) ~= length(xExtent)
    error('The length of yExtent must be scalar or the same as the length of xExtent.');
end
if length(y0) == 1
    y0 = y0 * ones(size(xExtent));
elseif length(y0) ~= length(xExtent)
    error('The length of y0 must be scalar or the same as the length of xExtent.');
end
if length(linesPerROI) == 1
    linesPerROI = linesPerROI * ones(size(xExtent));
elseif length(linesPerROI) ~= length(xExtent)
    error('The length of linesPerROI must be scalar or the same as the length of xExtent.');
end
if length(repetitions) == 1
    repetitions = repetitions * ones(size(xExtent));
elseif length(repetitions) ~= length(xExtent)
    error('The length of repetitions must be scalar or the same as the length of xExtent.');
end
if length(msPerLine) == 1
    msPerLine = msPerLine * ones(size(xExtent));
elseif length(msPerLine) ~= length(xExtent)
    error('The length of msPerLine must be scalar or the same as the length of xExtent.');
end
if length(isi) == 1
    isi = isi * ones(size(xExtent));
elseif length(isi) ~= length(xExtent)
    error('The length of isi must be scalar or the same as the length of xExtent.');
end
if length(delay) ~= 1
    error('The delay must be scalar.');
end

%Create pulses.
fprintf(1, 'Creating pulses in ''%s''...\n', destDir);
for i = 1 : length(xExtent)
    xSig(i) = signalobject('Name', ['xMirrorROIStimCycle' num2str(i)], 'repeatable', 1, 'sampleRate', sampleRate);
    ySig(i) = signalobject('Name', ['yMirrorROIStimCycle' num2str(i)], 'repeatable', 1, 'sampleRate', sampleRate);
    raster(xSig(i), ySig(i), xExtent(i), x0(i), yExtent(i), y0(i), msPerLine(i), linesPerROI(i), delay, isi(i), xParkOffset, yParkOffset, repetitions(i));
end
nullSig = signalobject('Name', 'nullPulse', 'sampleRate', sampleRate);
DC(nullSig, 0);
%Now save the pulses. Delete them when we're done.
for signal = [xSig, ySig, nullSig]
    fprintf(1, '   Writing pulse to disk - ''%s''...\n', get(signal, 'Name'));
    saveCompatible(fullfile(destDir, [get(signal, 'Name') '.signal']), 'signal', '-mat');
    delete(signal);
end

%Update the pulseJacker.
%Get the handle for the pulseJacker program.
pj = getGlobal(progmanager, 'hObject', 'pulseJacker', 'pulseJacker');
%Create a new cycle.
if length(varargin) < 2
    if ~pj_new(pj)
        %The pj_new command was cancelled or failed. Don't go overwriting an existing cycle if someone cancelled.
        return;
    end
else
    if ~pj_new(pj, varargin{2})
        %The pj_new command was cancelled or failed. Don't go overwriting an existing cycle if someone cancelled.
        return;
    end
end
%Make sure the pulse path matches where we just made new pulses.
pj_setPulsePath(pj, pulseDir);
fprintf(1, 'Creating associated cycle ''%s''...\n', getLocal(progmanager, pj, 'cycleName'));
%Get the list of channels that are in the pulseJacker.
channels = getLocalGh(progmanager, pj, 'currentChannel', 'String');

for i = 1 : length(xExtent)
    fprintf(1, '   Creating cycle position %s...\n', num2str(i));
    %Create a new cycle position.
    pj_newPosition(pj);
    for j = 1 : length(channels)
        fprintf(1, '      Configuring pulse for channel ''%s''...\n', channels{j});
        %Select the channel we want to edit.
        pj_currentChannel(pj, channels{j});
        %Depending on which channel we currently have selected, choose the appropriate pulse.
        if endsWithIgnoreCase(channels{j}, ':xMirror')
            %Set the pulseSet for this channel.
            pj_setPulseSetName(pj, pulseSetName);
            pj_setPulseName(pj, ['xMirrorROIStimCycle' num2str(i)]);
        elseif endsWithIgnoreCase(channels{j}, ':yMirror')
            %Set the pulseSet for this channel.
            pj_setPulseSetName(pj, pulseSetName);
            pj_setPulseName(pj, ['yMirrorROIStimCycle' num2str(i)]);
        elseif endsWithIgnoreCase(channels{j}, ':frames')
            pj_setPulseSetName(pj, 'test_pulses');
            pj_setPulseName(pj, '1000pfs_100ms_delay_13');
        elseif endsWithIgnoreCase(channels{j}, ':computer_triggger')
            pj_setPulseSetName(pj, 'test_pulses');
            pj_setPulseName(pj, 'computer_trigger_6');
%         else
%              pj_setPulseSetName(pj, pulseSetName);
%              pj_setPulseName(pj, ['nullPulse']);
        end
    end
end
pj_currentPosition(pj, 1);%Set the new cycle to the first position.
pj_currentChannel(pj, channels{1});%Set the new cycle to the first channel.

fprintf(1, 'New cycle and pulses complete.\n\n');

return;