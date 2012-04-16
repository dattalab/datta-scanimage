% @daqjob/updateMasterSampleClock - Set a properties for the master sample clock.
% 
% SYNTAX
%  updateMasterSampleClock(dj, frequency)
%  updateMasterSampleClock(dj, frequency, dutyCycle)
%  updateMasterSampleClock(dj, propertyName, propertyValue, ...)
%   dj - @daqjob instance.
%   frequency - The desired frequency of the clock signal.
%   dutyCycle - The desired dutyCycle of the clock signal (ratio of high-time to low-time).
%   propertyName - Any valid NIMEX property name, which will get passed along to the task.
%   properyValue - The value corresponding to the name.
%                  Multiple name/value pairs may be specified.
%  
% NOTES
%   See TO033008B.
%
% CHANGES
%  
% Created
%  Timothy O'Connor 3/30/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function updateMasterSampleClock(this, varargin)
global daqjobGlobalStructure;

if length(daqjobGlobalStructure(this.ptr).masterSampleClock) > 1
    warning('Attempting to update multiple sample clock tasks at once.');
end

if ~ischar(varargin{1})
    frequency = varargin{1};
    dutyCycle = 0.5;
    if length(varargin) == 2
        dutyCycle = varargin{2};
    elseif length(varargin) > 2
        error('Too many input arguments. May only specify a frequency and duty cycle.');
    end
    terminalNames = nimex_getTaskProperty(daqjobGlobalStructure(this.ptr).masterSampleClock, 'channels');
    for i = 1 : length(terminalNames)
        nimex_updateCounterOutput(daqjobGlobalStructure(this.ptr).masterSampleClock, terminalNames{i}, 0, frequency, dutyCycle);
    end
else
    nimex_setTaskProperty(daqjobGlobalStructure(this.ptr).masterSampleClock, varargin{:});
end

return;