% scanmirror/scanmirror - A scanmirror representation (including hardware configuration and alignment/calibration).
%
% SYNTAX
%  scanmirror
%  scanmirror(name)
%   name - A string, identifying a previously instantiated/loaded object, for which to acquire a pointer.
%
% USAGE
%
% STRUCTURE
%  name - A pseudonym, should be descriptive.
%  xBoardID - The board ID of the X-axis this scanmirror.
%  xChannelID - The channel ID of the X-axis this scanmirror.
%  xOffset - The "nominal" offset of the X-axis (defined 0).
%  xGain - The 
%  yBoardID - The board ID of the Y-axis this scanmirror.
%  yChannelID - The channel ID of the Y-axis this scanmirror.

%  calibrationVoltages - A set of input voltages, from the photodiode, at each sample point in a calibration.
%  calibrationPowers - A set of mW readins, from a power meter, at each sample point in a calibration.
%  calibrationSlope - The calculated slope, based on the `voltages` and `powers`.
%  calibrationOffset - The extrapolated offset, based on the `voltages` and `powers`. Or, a user-defined offset, based on ambient light readings.
%  calibrationUser - The user responsible for the last calibration.
%  calibrationDate - The date of the last calibration.
%  lastSaveTime - Timestamp of the last save event.
%  lastLoadTime - Timestamp of the last save event.
%  readOnlyFields - A list of fields which can not be set from outside the object.
%    Value: readOnlyFields, lastLoadTime, lastSaveTime, calibrationDate, calibrationSlope, calibrationOffset, calibrationPowers, calibrationVoltages
%
% NOTES
%
% CHANGES
%
% Created 8/2/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = photodiode(varargin)
global photodiodeObjects;

if isempty(varargin)
    this.ptr = length(photodiodeObjects) + 1;
    this.serialized = [];
    
    photodiodeObjects(this.ptr).name = ['photodiode' num2str(this.ptr)];
    photodiodeObjects(this.ptr).boardID = -1;
    photodiodeObjects(this.ptr).channelID = -1;
    photodiodeObjects(this.ptr).calibrationVoltages = [];
    photodiodeObjects(this.ptr).calibrationPowers = [];
    photodiodeObjects(this.ptr).calibrationSlope = [];
    photodiodeObjects(this.ptr).calibrationOffset = [];
    photodiodeObjects(this.ptr).calibrationUser = '';
    photodiodeObjects(this.ptr).calibrationDate = [];
    photodiodeObjects(this.ptr).lastSaveTime = [];
    photodiodeObjects(this.ptr).lastLoadTime = [];
    photodiodeObjects(this.ptr).readOnlyFields = {'readOnlyFields', 'lastLoadTime', 'lastSaveTime', 'calibrationDate', 'calibrationSlope', 'calibrationOffset', ...
            'calibrationPowers', 'calibrationVoltages'};
else
    if length(varargin) ~= 1
        error('Too many arguments.');
    elseif ~strcmpi(class(varargin{1}), 'char')
        error('Argument must be a string.');
    end
    
    this = [];
    for i = 1 : length(photodiodeObjects)
        if strcmp(varargin{1}, photodiodeObjects(i).name)
            this.ptr = i;
            this.serialized = [];
            break;
        end
    end
    
    if isempty(this)
        error('No photodiode found with name ''%s''', varargin{1});
    end  
end

this = class(this, 'photodiode');

return;