% shared_resetBuffer - Reset a given data buffer.
%
% SYNTAX
%  buffers = shared_resetBuffer(buffers, bufferName, channelName, amplifierName, sampleRate)
%   buffers - The buffer structure, as used in the shared_*.m family of functions.
%   bufferName - The name of the buffer (within the structure the fieldname) to be cleared.
%   channelName - The name of the associated channel, use empty ('' or []) if there is no channel name.
%   amplifierName - The name of the associated channel, use empty ('' or []) if there is no amplifier name.
%   sampleRate - The sample rate of the acquisition.
%
% USAGE
%
% NOTES
%  This is a copy & paste job from acquirer_getData.m, with some editting where necessary.
%  Adapted from ephys_getData.m
%
% CHANGES
%  TO032106D - The buffers have not been cleared from here for a long time. -- Tim O'Connor 3/22/06
%  TO050806B - Index traces by fields, not number of buffers (typo). -- Tim O'Connor 5/8/06
%  TO062306A - Only warn of an empty buffer if acquisition is enabled for that channel. -- Tim O'Connor 6/23/06
%  TO062806A - Changed reference to acqOn to look at acqOnArray instead. -- Tim O'Connor 6/28/06
%  TO101707F - A major refactoring, as part of the port to nimex. -- Tim O'Connor 10/17/07
%  TO043008E - Keep timestamps for each data append. Store other informational fields, if possible. -- Tim O'Connor 4/30/08
%  TO041609B - Reworked the optimizations that check for empty buffers and quit early. The previous implementation was buggy. -- Tim O'Connor 4/16/09
%  TO021510F - Implemented disk streaming. -- Tim O'Connor 2/15/10
%  TO021610F - For some reason, this never needed to conditionally check 'channelName' before, but it does now. This seems right as it is now. -- Tim O'Connor 2/16/10
%
% SEE ALSO
%  shared_Start, shared_recordData & shared_getData
%  TO030210A
%
% Created - Tim O'Connor 3/2/10
% Copyright - Northwestern University/Howard Hughes Medical Institute 2010
function buffers = shared_resetBuffer(buffers, bufferName, channelName, amplifierName, sampleRate)
% fprintf(1, '%s - shared_resetBuffer(...)\n%s\n', datestr(now), getStackTraceString);

stackTrace = getStackTraceString;
buffers.(bufferName).data = [];
buffers.(bufferName).dataEventTimestamps = [];%TO043008E
if ~isempty(channelName)
    buffers.(bufferName).channelName = channelName;%TO120205A
    buffers.(bufferName).amplifierName = [];
else
    buffers.(bufferName).channelName = [];
    buffers.(bufferName).amplifierName = amplifierName;%TO120205A
end
buffers.(bufferName).debug.creationStackTrace = stackTrace;
buffers.(bufferName).debug.resetStackTrace = stackTrace;
buffers.(bufferName).debug.samplesAcquiredFcnExecutionCounter = 0;%TO102306A
buffers.(bufferName).sampleRate = sampleRate;
buffers.(bufferName).resetOnNextSamplesAcquired = 0;%There's no need to reset it now, so we clear the flag.

return