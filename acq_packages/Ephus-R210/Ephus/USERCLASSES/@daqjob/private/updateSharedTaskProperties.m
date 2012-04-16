% @daqjob/private/updateSharedTaskProperties - Updates properties that are shared amongst all tasks in the @daqjob.
%
%% SYNTAX
%  updateSharedTaskProperties(job)
%  updateSharedTaskProperties(job, taskOrPropertyName) 
%   job - The @daqjob instance whose properties are to be updated
%   taskOrPropertyName - Limit update to a particular task (within job's taskMap) or a particular shared property (or property list). If a task, all its shared properties will be updated.  If a property, that property(s) will be updated for all tasks. 
%
%% NOTES
%   The taskOrPropertyName arguments allows this operation to be more efficient. Arguably, all calls to updateSharedTaskProperties() should update all properties for all tasks -- simplifying the logic, for probably no detectable performance hit.
%
%   Current shared propertes are 'sampleClockDestination', 'triggerDestination', and 'clockExportTerminal'--all of which are specified via 'relative' terminal names
%
%% CHANGES
%  TO033008D - Created the clockDestination field. -- Tim O'Connor 3/30/08
%  TO033008E - Refactored `updateTaskProperties` out of `getOrCreateTask`. -- Tim O'Connor 3/30/08
%  TO050508C - Reworked the clock synchronization to allow for a sampleClock and a timebaseClock (20MHz). -- Tim O'Connor 5/5/08
%  TO050508E - Handle device names with more than two slashes when setting a relative clock source. -- Tim O'Connor 5/5/08
%  TO050508G - Digital input/output tasks can't be directly triggered. Instead, trigger their clock source. -- Tim O'Connor 5/5/08
%  VI072408A - Handle case where digital channel name contains 'port' without 'line' -- Vijay Iyer 7/24/08
%  VI072908A - Renamed to 'updateSharedTaskProperties' -- Vijay Iyer 7/29/08
%  TO073008C - Tim's change allowing specified property(s) to be selectively updated -- Vijay Iyer 8/20/08
%  VI081108A - Use regular expressions to obtain device name from subystem name -- Vijay Iyer 8/11/08
%  VI081108B - Removed input arguments. If a task-specific function is actually needed, then it could be added in the future. -- Vijay Iyer 8/11/08
%  VI082008A - Near complete rewrite. Other @daqjob methods now call this rather than updateTaskProperties. See (removed) updateTaskProperties() in repository for history. -- Vijay Iyer 8/20/08
%  VI102308A - Handle the new triggerDestinations/triggerDestinationIndex properties -- Vijay Iyer 10/23/08
%
%% CREDITS
%  Timothy O'Connor 7/30/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
%% **********************************************************
function updateSharedTaskProperties(this,varargin)
global daqjobGlobalStructure;

%Identifies tasks/properties to update
subsystemNames = {};
tasks = {};
property = '';
specificTask = false;
for i = 1 : size(daqjobGlobalStructure(this.ptr).taskMap, 1)
    tasks{end+1} = daqjobGlobalStructure(this.ptr).taskMap{i, 2};
    subsystemNames{end+1} = daqjobGlobalStructure(this.ptr).taskMap{i, 1};
end
if ~isempty(varargin)    
    if isa(varargin{1},'nimex') && isscalar(varargin{1})
        tasks = {varargin{1}}; %select specific task
        subsystemNames = {getSubsystemNameByTask(this,varargin{1})};
        specificTask = true;
    elseif ischar(varargin{1}) || iscellstr(varargin{1})
        property = varargin{1};
    else
        error('Optional argument must specify a single NIMEX task object or a valid shared property name');
    end
end

%Determine task-independent property values
triggerDestination = '';
sampleClockDestination = '';
clockExportTerminal = ''; 

%%%VI102308A%%%%%%%%%%%%%%%
%if ~isempty(daqjobGlobalStructure(this.ptr).triggerDestination) 
    %triggerDestination = daqjobGlobalStructure(this.ptr).triggerDestination; 
triggerDestination = getTriggerDestination(this);    
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(daqjobGlobalStructure(this.ptr).sampleClockDestination)
    sampleClockDestination = daqjobGlobalStructure(this.ptr).sampleClockDestination;
end

%
for i = 1:length(tasks)   

    %Clock export terminal functionality currently disabled
%     if ~isempty(daqjobGlobalStructure(this.ptr).clockOrigin)
%         clockOriginDevice = extractDeviceName(daqjobGlobalStructure(this.ptr).clockOrigin);
%         subsystemDevice = extractDeviceName(getSubsystemNameByTask(tasks{i}));
%         if strcmpi(clockOriginDevice, subSystemDevice)
%             clockExportTerminal = daqjobGlobalStructure(this.ptr).clockOrigin;
%         end
%     end

    %Set trigger destination property only for analog channels
    setTriggerDestination = true;
    if ~isempty(strfind(lower(subsystemNames{i}), 'line')) && ~isempty(strfind(lower(subsystemNames{i}), 'port')) %VI072408A
        setTriggerDestination = false;
    end
    
    %Set remaining properties en-masse
    if isempty(property)
        if setTriggerDestination
            nimex_setTaskProperty(tasks{i},'triggerSource',triggerDestination);
        end
        nimex_setTaskProperty(tasks{i},'clockSource', sampleClockDestination, 'clockExportTerminal', clockExportTerminal);
    else
        if ischar(property)
            property = {property};
        end
        for j=1:length(property)
            switch property{j}
                case 'triggerDestination'
                    if setTriggerDestination
                        nimex_setTaskProperty(tasks{i}, 'triggerSource', triggerDestination);                  
                    end
                case 'sampleClockDestination'
                    nimex_setTaskProperty(tasks{i}, 'clockSource', sampleClockDestination);
                case 'clockExportTerminal'
                    nimex_setTaskProperty(tasks{i}, 'clockExportTerminal', clockExportTerminal);
            end
        end
    end      
end

%Handle masterSampleClock task, if present. Only some of the shared properties pertain.
if ~specificTask && ~isempty(daqjobGlobalStructure(this.ptr).masterSampleClock)
   nimex_setTaskProperty(daqjobGlobalStructure(this.ptr).masterSampleClock, 'triggerSource', triggerDestination); %should clockExportTerminal (were it actually implemented) pertain?
end   

%%%VI102308A%%%%%%%%%%
if ~specificTask
    fireEvent(daqjobGlobalStructure(this.ptr).callbackManager, 'sharedPropertyUpdate');
end
%%%%%%%%%%%%%%%%%%%%%%

return;

%Extract device name from subsystem or channel/terminal name, where using NI DAQmx naming convention
function deviceName = extractDeviceName(subsystemOrChanName)
deviceName = regexpi(subsystemOrChanName,'/?(\w*)/+.*','tokens','once');
deviceName = [deviceName{1} '/'];
return;


