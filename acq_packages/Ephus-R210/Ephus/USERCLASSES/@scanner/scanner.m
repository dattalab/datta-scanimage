% scanner/scanner - A generic scanner implementation.
%
% SYNTAX
%  scanner(name)
%  scanner(horizontalRangeMin, horizontalRangeMax, horizontalPowerLimit, verticalRangeMin, verticalRangeMax, verticalPowerLimit)
%  scanner(..., PropertyName, PropertyValue, ...)
%   name - A string, identifying a previously instantiated/loaded object, for which to acquire a pointer.
%   horizontalRangeMin - The minimum position value (in hardware control units [V | MHz]).
%   horizontalRangeMax - The maximum position value (in hardware control units [V | MHz]).
%   horizontalPowerLimit - The maximum power of a given movement (frequency * amplitude).
%   verticalRangeMin - The minimum position value (in hardware control units [V | MHz]).
%   verticalRangeMax - The maximum position value (in hardware control units [V | MHz]).
%   verticalPowerLimit - The maximum power of a given movement (frequency * amplitude).
%   PropertyName - The name of any settable property. Multiple property-value pairs may  be specified.
%   PropertyValue - The coinciding value to the given property name. Multiple property-value pairs may  be specified.
%
% USAGE
%
% STRUCTURE
%  name - A pseudonym, should be descriptive.
%  horizontalBoardID - The board ID of the analog output used for a clock signal.
%  horizontalChannelID - The channel ID of the analog output used for a clock signal.
%  horizontalFieldOffset - The fundamental offset used to center the field of view (in hardware control units [V | MHz]).
%  horizontalFieldAmplitude - The fundamental amplitude defining the extent of the field of view (in hardware control units [V | MHz]).
%  horizontalStepLag - The typical response time to a discrete position change, in seconds.
%  horizontalLineLag - The typical phase shift between an analog signal and the change in position, in seconds.
%  horizontalRangeMin - The minimum position value (in hardware control units [V | MHz]).
%  horizontalRangeMax - The maximum position value (in hardware control units [V | MHz]).
%  horizontalPowerLimit - The maximum power of a given movement (frequency * amplitude).
%  horizontalInvert - 1 if the horizontal axis is inverted.
%  horizontalMicrons - Span of horizontal field of view in microns.
%  verticalFieldOffset - The fundamental offset used to center the field of view (in hardware control units [V | MHz]).
%  verticalFieldAmplitude - The fundamental amplitude defining the extent of the field of view (in hardware control units [V | MHz]).
%  verticalStepLag - The typical response time to a discrete position change, in seconds.
%  verticalLineLag - The typical phase shift between an analog signal and the change in position, in seconds.
%  verticalRangeMin - The minimum position value (in hardware control units [V | MHz]).
%  verticalRangeMax - The maximum position value (in hardware control units [V | MHz]).
%  verticalPowerLimit - The maximum power of a given movement (frequency * amplitude).
%  verticalInvert - 1 if the vertical axis is inverted.
%  verticalMicrons - Span of vertical field of view in microns.
%  dm - A @daqmanager instance.
%  lastSaveTime - Timestamp of the last save event.
%  lastLoadTime - Timestamp of the last save event.
%  readOnlyFields - A list of fields which can not be set from outside the object.
%    Value: readOnlyFields, 
%
% NOTES
%
% CHANGES
%
% Created 3/16/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function this = scanner(varargin)
global scannerObjectsGlobal;

if length(varargin) >= 6
    this.ptr = length(scannerObjectsGlobal) + 1;
    this.serialized = [];

    scannerObjectsGlobal(this.ptr).name = ['scanner' num2str(this.ptr)];

    scannerObjectsGlobal(this.ptr).horizontalBoardID = -1;
    scannerObjectsGlobal(this.ptr).horizontalChannelID = -1;
    scannerObjectsGlobal(this.ptr).horizontalFieldOffset = 0;
    scannerObjectsGlobal(this.ptr).horizontalFieldAmplitude = 0;
    scannerObjectsGlobal(this.ptr).horizontalStepLag = 0;
    scannerObjectsGlobal(this.ptr).horizontalLineLag = 0;
    scannerObjectsGlobal(this.ptr).horizontalRangeMin = varargin{1};
    scannerObjectsGlobal(this.ptr).horizontalRangeMax = varargin{2};
    scannerObjectsGlobal(this.ptr).horizontalPowerLimit = varargin{3};
    scannerObjectsGlobal(this.ptr).horizontalInvert = 0;
    scannerObjectsGlobal(this.ptr).horizontalMicrons = 1;
    
    scannerObjectsGlobal(this.ptr).verticalBoardID = -1;
    scannerObjectsGlobal(this.ptr).verticalChannelID = -1;
    scannerObjectsGlobal(this.ptr).verticalFieldOffset = 0;
    scannerObjectsGlobal(this.ptr).verticalFieldAmplitude = 0;
    scannerObjectsGlobal(this.ptr).verticalStepLag = 0;
    scannerObjectsGlobal(this.ptr).verticalLineLag = 0;
    scannerObjectsGlobal(this.ptr).verticalRangeMin = varargin{4};
    scannerObjectsGlobal(this.ptr).verticalRangeMax = varargin{5};
    scannerObjectsGlobal(this.ptr).verticalPowerLimit = varargin{6};
    scannerObjectsGlobal(this.ptr).verticalInvert = 0;
    scannerObjectsGlobal(this.ptr).verticalMicrons = 1;

    scannerObjectsGlobal(this.ptr).dm = getDaqmanager;
    scannerObjectsGlobal(this.ptr).lastSaveTime = clock;
    scannerObjectsGlobal(this.ptr).lastLoadTime = clock;
    scannerObjectsGlobal(this.ptr).readOnlyFields = {'horizontalRangeMin', 'horizontalRangeMax', 'horizontalPowerLimit', ...
        'verticalRangeMin', 'verticalRangeMax', 'verticalPowerLimit', ...
        'lastSaveTime', 'lastLoadTime', 'readOnlyFields'};
elseif length(varargin) == 1
    if ~strcmpi(class(varargin{1}), 'char')
        error('Argument must be a string.');
    end
    
    this = [];
    for i = 1 : length(scannerObjectsGlobal)
        if strcmp(varargin{1}, scannerObjectsGlobal(i).name)
            this.ptr = i;
            this.serialized = [];
            break;
        end
    end

    if isempty(this)
        error('No scanner found with name ''%s''', varargin{1});
    end
else
    error('Illegal number of arguments: %s', num2str(length(varargin)));
end

this = class(this, 'scanner');

if length(varargin) > 6
    set(this, varargin{7 : end});
end

return;