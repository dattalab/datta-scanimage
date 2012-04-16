function this = triangleSignal(varargin)

s = signalobject;
triangle(s, 0, 0, 0, 0);%Make sure this is called, to set the basic properties.

this.ptr = 1;
this.serialized = [];

if length(varargin) == 4
    %Set the specific parameters, if supplied.
    triangle(s, varargin{1}, varargin{2}, varargin{3}, varargin{4});
end

set(s, 'readOnlyFields', {'readOnlyFields', 'instantiationTime', 'saveTime', 'loadTime', 'Type', 'children', 'method', ...
    'equational', 'equation', 'distributional', 'distribution', 'arg1', 'arg2', 'arg3', 'fcn', 'fcnTakesArgs', 'waveform'});

this = class(this, 'trianglesignal', s);

return;