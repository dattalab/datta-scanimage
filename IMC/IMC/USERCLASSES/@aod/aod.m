% aod/aod - A scanner implementation, based on an Isomet Acoustical Optical Deflector.
%
% SYNTAX
%  aod
%  aod(name)
%   name - A string, identifying a previously instantiated/loaded object, for which to acquire a pointer.
%
% USAGE
%
% STRUCTURE
%  name - A pseudonym, should be descriptive.
%  horizontalComPort - The identifier of the com port used to communicate to the controller.
%  horizontalSerialObj - The com port used to communicate to the controller.
%  verticalComPort - The identifier of the com port used to communicate to the controller.
%  verticalSerialObj - The com port used to communicate to the controller.
%  lastSaveTime - Timestamp of the last save event.
%  lastLoadTime - Timestamp of the last save event.
%  readOnlyFields - A list of fields which can not be set from outside the object.
%    Value: readOnlyFields, lastLoadTime, lastSaveTime, horizontalSerialPort, verticalSerialPort, horizontalRangeMin, horizontalRangeMax,
%           verticalRangeMin, verticalRangeMax, horizontalPowerLimit, verticalPowerLimit
%
% NOTES
%
% CHANGES
%
% Created 3/16/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function this = aod(varargin)
global isometAodObjects;

if length(varargin) ~= 1
    this.ptr = length(isometAodObjects) + 1;
    this.serialized = [];
    
    isometAodObjects(this.ptr).name = ['aod' num2str(this.ptr)];
    isometAodObjects(this.ptr).horizontalComPort = '';
    isometAodObjects(this.ptr).horizontalSerialObj = [];
    isometAodObjects(this.ptr).verticalComPort = '';
    isometAodObjects(this.ptr).verticalSerialObj = [];

    isometAodObjects(this.ptr).readOnlyFields = {'readOnlyFields'};
else
    if ~strcmpi(class(varargin{1}), 'char')
        error('Argument must be a string.');
    end
    
    this = [];
    for i = 1 : length(isometAodObjects)
        if strcmp(varargin{1}, isometAodObjects(i).name)
            this.ptr = i;
            this.serialized = [];
            break;
        end
    end
    
    if isempty(this)
        error('No aod found with name ''%s''', varargin{1});
    end  
end

scannerObj = scanner(50, 90, Inf, 50, 90, Inf);
matlabVersionInfo = ver('MATLAB');
if str2num(matlabVersionInfo.Version) < 7.1
    this.SCANNER = scannerObj;
end

this = class(this, 'aod', scannerObj);

if length(varargin) > 1
    set(this, varargin{:});
end

return;