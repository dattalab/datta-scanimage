% @nimex/nimex_updateCounterOutput - Write new timing parameters to a counter output channel.
% 
% SYNTAX
%  nimex_updateCounterOutput(nimextask, channelName, initialDelay, lowTime, highTime)
%  nimex_updateCounterOutput(nimextask, channelName, initialDelay, frequency, dutyCycle)
%  nimex_updateCounterOutput(nimextask, channelName, initialDelay, lowTime, highTime, timeout)
%  nimex_updateCounterOutput(nimextask, channelName, initialDelay, frequency, dutyCycle, timeout)
%   nimextask - An instance of the nimex class.
%   channelName - The channel for which to write data.
%   initialDelay - The initial delay before start of the pulse.
%   lowTime - The time, in seconds, spent in the low state.
%             Only applies to time counter outputs.
%   highTime - The time, in seconds, spent in the high state.
%             Only applies to time counter outputs.
%   frequency - The frequency, in Hz, of the pulses.
%             Only applies to frequency counter outputs.
%   dutyCycle - The dutyCycle, ratio of pulseWidth to pulsePeriod.
%             Only applies to frequency counter outputs.
%   timeout - A timeout, after which to give up, in seconds.
%  
% NOTES
%  Relies on NIMEX_updateCounterOutput.mex32.
%  
% Created
%  Timothy O'Connor 3/31/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function nimex_updateCounterOutput(this, channelName, initialDelay, param1, param2, varargin)

NIMEX_updateCounterOutput(this.NIMEX_TaskDefinition, channelName, double(initialDelay), double(param1), double(param2), varargin{:});

% fprintf(1, 'nimex_updateCounterOutput: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;