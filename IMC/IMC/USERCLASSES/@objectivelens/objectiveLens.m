% objectiveLens/objectiveLens - An objectiveLens representation.
%
% SYNTAX
%  objectiveLens(name) - Loads an existing objective.
%  objectiveLens(name, magnification, transmission, numericalAperture) - Creates a new objective.
%   name - A string, in the single argument form if a lens with the same name is found, it is automatically loaded.
%          Only one lens may be resident at a time, loading a new one changes the lens globally, for all handles.
%   magnification - A number, specifying the lens' magnification.
%   
%
% USAGE
%
% STRUCTURE
%  name - A pseudonym, should be descriptive.
%  magnification - The effective magnification of the objective (eg. 4x, 10x, 60x).
%  transmission - The effective transmission of the objective (a value between 0 and 1).
%  numericalAperture - The effective numerical aperture of the objective (eg. .33, 1.4, etc).
%
% NOTES
%
% CHANGES
%
% Created 8/8/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = objectiveLens(name)
global objectiveLens;

if isempty(varargin)
    this.ptr = NaN;
    this.serialized = [];
    
    photodiodeObjects(this.ptr).name = ['objectiveLens' num2str(this.ptr)];
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