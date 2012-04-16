% @daqjob/getTaskBySubsystemName - Look up the task corresponding to a given subsystem.
%
% SYNTAX
%  task = getTaskBySubsystemName(dj, subsystemName)
%   dj - A @daqjob instance.
%   subsystemName - The name of the NI subsystem.
%                   ie. '/dev1/ao' or '/dev2/ai' or '/dev3/port0/line'
%   task - The task that corresponds to the given subsystemName.
%
% NOTES
%  National Instruments hardware is arranged into largely independent subsystems. Each subsystem
%  can be started and stopped regardless of the state of the other subsystems. The NIDAQmx drivers
%  reflect this idea by mapping each task to a single subsystem. This concept is further propogated
%  by @nimex.
%
%  @daqjob caters to this scheme by storing only one task per subsystem.
%
%  Typically, the analog input, analog output, each digital port, and each counter/timer constitute separate subsystems.
%
% CHANGES
%  TO073008C - Removed call to updateTaskProperties, as that should only occur upon task creation or calls that alter the properties. -- Tim O'Connor 7/30/08
%
% Created
%  Timothy O'Connor 7/30/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function task = getTaskBySubsystemName(this, subsystemName)
global daqjobGlobalStructure;

%Lookup the subsystem name to get the task object.
index = indexOf(daqjobGlobalStructure(this.ptr).taskMap, subsystemName);
if isempty(index)
    error('Failed to find subsystem name ''%s''.', subsystemName);
end
task = daqjobGlobalStructure(this.ptr).taskMap{index, 2};

return;