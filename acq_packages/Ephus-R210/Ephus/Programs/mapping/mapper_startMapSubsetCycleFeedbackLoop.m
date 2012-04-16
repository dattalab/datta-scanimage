% mapper_startMapSubsetCycleFeedbackLoop -  Creates pulses for a cycle that stimulates a subset of map pixels, with individual power/timing settings at each pixel, then starts the cycle.
%
% SYNTAX
%  mapper_startMapSubsetCycleFeedbackLoop(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, callbackFcn, feedbackLoopInterval, feedbackLoopIterations)
%  mapper_startMapSubsetCycleFeedbackLoop(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, callbackFcn, feedbackLoopInterval, feedbackLoopIterations, pulseDest)
%  mapper_startMapSubsetCycleFeedbackLoop(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, callbackFcn, feedbackLoopInterval, feedbackLoopIterations, pulseDest, cycleName)
%   pixelNumbers - An array indicating the indices of the pixels to be included in the cycle.
%                  The locations of these pixels are calculated from the currently selected map pattern along with the other mapper parameters.
%   amplitudes - The amplitudes for each pixel.
%                May be a vector, of the same length as pixelNumbers, or a scalar.
%   delay - The delay for the shutter/modulator pulse, in seconds.
%           The shutter is forced to be 2ms earlier.
%           May be a vector, of the same length as pixelNumbers, or a scalar.
%   width - The width for the shutter/modulator pulse, in seconds.
%           The shutter is forced to be 2ms longer.
%           May be a vector, of the same length as pixelNumbers, or a scalar.
%   pulseISI - The pulse isi, in seconds.
%              This is not equivalent to the pixel isi (which comes directly from the Mapper).
%              May be a vector, of the same length as pixelNumbers, or a scalar.
%   numberOfPulses - The number of shutter/modulator pulses per pixel.
%                    May be a vector, of the same length as pixelNumbers, or a scalar.
%   testPulseAmp - The amplitude of the ephys test pulse.
%   testPulseDelay - The delay of the ephys test pulse, in seconds.
%   testPulseWidth - The width of the test pulse, in seconds.
%   callbackFcn - The function to be called when a cycle is finished, which must then configure the next acquisition.
%                 This must be a function_handle (ie. @my_function) or a cell array whose first element is a function_handle.
%                 In the case of a cell array, all subsequent elements will be passed, in order, as arguments.
%                 Regardless of the type of specification used (function_handle or cell array), the ephys trace data and buffer name (respectively) will be passed as a final arguments.
%   feedbackLoopInterval - The time, in seconds, between successive feedback loop iterations.
%                          This interval MUST be long enough for the entire acquisition to take place and for the data analysis and generation of a new cycle to occur.
%                          During the loop, each pixel will go unstimulated for roughly (feedbackLoopInterval + (pulseISI * numberOfPulses) + <processingOverhead>) seconds.
%   feedbackLoopIterations - The number of feedback loop iterations to execute. May be Inf.
%   pulseDest - The directory (the pulse set, within the pulse directory) in which to place pulses.
%               The user will be prompted if this is not specified.
%               Ex: 'C:\Data\User1\pulses\MapSubsetCyclePulses'
%   cycleName - The name of the cycle to be created.
%               The user will be prompted if this is not specified.
%
% NOTES
%  See mapper_stopMapSubsetCycleFeedbackLoop.
%
% EXAMPLE
%  mapper_startMapSubsetCycleFeedbackLoop([1, 5, 9], 50, 0.1, 0.004, 0.008, 3, 200, 0.38, 0.002, {@user_feedback_analyisis01, customArg1, customArg2}, 30, Inf, 'C:\Data\User1\pulses\MapSubsetCyclePulses', 'MapSubsetCycle01');
%
% Created: Timothy O'Connor 3/14/09
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2009
function mapper_startMapSubsetCycleFeedbackLoop(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, callbackFcn, feedbackLoopInterval, feedbackLoopIterations varargin)
global MapSubsetCycleFeedbackLoop;

if length(varargin) < 1
    destDir = getDefaultCacheDirectory(progmanager, 'mapSubsetCycle');
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
setDefaultCacheValue(progmanager, 'mapSubsetCycle', destDir);

fprintf(1, '%s - mapper_startMapSubsetCycleFeedbackLoop: Configuring ''ephys:TraceAcquired'' userFcn (for data processing)...\n', datestr(now));
cbm = getUserFcnCBM;
addCallback(cbm, 'ephys:TraceAcquired', @mapper_MapSubsetCycleFeedbackLoop_userFcn, 'userFcns_mapper_MapSubsetCycleFeedbackLoop_userFcn');

fprintf(1, '%s - mapper_startMapSubsetCycleFeedbackLoop: Configuring global variable space (''MapSubsetCycleFeedbackLoop'') for feedback loop control...\n');
MapSubsetCycleFeedbackLoop.abort = 0;
MapSubsetCycleFeedbackLoop.callback = callbackFcn;

fprintf(1, '%s - mapper_startMapSubsetCycleFeedbackLoop: Creating and configuring Matlab timer object...\n', datestr(now));
MapSubsetCycleFeedbackLoop.timer = timer('BusyMode', 'error', 'ExecutionMode', 'fixedRate', 'Period', feedbackLoopInterval, 'TasksToExecute', feedbackLoopIterations...
    'Name', 'MapSubsetCycleFeedbackLoopTimer', 'TimerFcn', @mapper_MapSubsetCycleFeedbackLoop_timerFcn, 'StartDelay', feedbackLoopInterval);

fprintf(1, '%s - mapper_startMapSubsetCycleFeedbackLoop: Creating and starting first iteration of the feedback loop...\n', datestr(now));
if nargin >=2 
    mapper_startMapSubsetCycle(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, destDir, varargin{2});
else
    mapper_startMapSubsetCycle(pixelNumbers, amplitudes, delay, width, pulseISI, numberOfPulses, testPulseAmp, testPulseDelay, testPulseWidth, destDir);
end

fprintf(1, '%s - mapper_startMapSubsetCycleFeedbackLoop: Starting timer object...\n', datestr(now));
start(MapSubsetCycleFeedbackLoop.timer);

MapSubsetCycleFeedbackLoop.cycleName = getGlobal(progmanager, 'cycleName', 'pulseJacker', 'pulseJacker');

return;

%------------------------------------------------------
function mapper_MapSubsetCycleFeedbackLoop_userFcn(data, bufferName)
global MapSubsetCycleFeedbackLoop;

if MapSubsetCycleFeedbackLoop.abort
    return;
end

fprintf(1, '%s - mapper_startMapSubsetCycleFeedbackLoop: Invoking user-defined data analysis routine...\n', datestr(now));
if iscell(MapSubsetCycleFeedbackLoop.callbackFcn)
    feval(MapSubsetCycleFeedbackLoop.callbackFcn{:}, data, bufferName);
else
    feval(MapSubsetCycleFeedbackLoop.callbackFcn, data, bufferName);
end

return;

%------------------------------------------------------
function mapper_MapSubsetCycleFeedbackLoop_timerFcn
global MapSubsetCycleFeedbackLoop;

lm = loopManager;
fprintf(1, '%s - mapper_startMapSubsetCycleFeedbackLoop: Initiating cycle...\n', datestr(now));
start(lm);

return;