% @pulseMap/setCallback - Inserts a callback in place of a given pulse for the specified channel.
%
% SYNTAX
%  setCallback(pm, channelName, callback)
%   pm - @pulseMap instance.
%   channelName - The name of the channel to bind the callback to.
%   callback - A function_handle or cell array whose first element is a function_handle.
%              The function must take the same arguments as @signalobject/getData and its
%              return value must also conform to @signalobject/getData.
%
% NOTES
%  The intended first-use of this functionality is for the pulseJacker to insinuate itself into
%  data generation.
%
% CHANGES
%  TO072208A - Allow multiple digital lines to appear separate in the GUI, but actually be grouped underneath. TO101907B wasn't implemented here. -- Tim O'Connor 7/22/08
%
% Created
%  Timothy O'Connor 10/17/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function setCallback(this, channelName, callback)
global pulseMapGlobalStructure;

if iscell(callback)
    if ~strcmpi(class(callback{i}), 'function_handle')
        error('Invalid callback type (first cell must be a function_handle): ''%s''', class(callback{i}));
    end
elseif ~strcmpi(class(callback), 'function_handle')
    error('Invalid callback type (must be a function_handle or cell array): ''%s''', class(callback));
end

index = indexOf(this, channelName);
if isempty(index)
    index = size(pulseMapGlobalStructure(this.ptr).map, 1) + 1;
    pulseMapGlobalStructure(this.ptr).map{index, 1} = channelName;
    pulseMapGlobalStructure(this.ptr).shadowMap{index, 1} = channelName;%TO072208A - See TO101907B.
end
pulseMapGlobalStructure(this.ptr).map{index, 2} = callback;
pulseMapGlobalStructure(this.ptr).shadowMap{index, 2} = callback;%TO072208A - See TO101907B.

return;