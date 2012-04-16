% SCOPEOBJECT/bindAveragedAimuxChannel - Set up an averaged aimux channel to be displayed on this scope object.
%
% SYNTAX
%  bindAveragedAimuxChannel(this, channelName, aim)
%
% USAGE
%  This is a convenience method, for setting up the callbacks between an aimux object and a scope object.
%
% NOTES
%
% CHANGES
%
% Created 3/14/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function bindAveragedAimuxChannel(this, channelName, aim)
global scopeObjects;

id = [scopeObjects(this.ptr).name '_Average'];

%Check if it's already bound.
if isbound(aim, channelName, id)
    warning('Channel ''%s'' is already bound.', channelName);
    return;
end

bind(aim, channelName, {@addAveragedData, this, channelName}, id);

channelName = [channelName '_Averaged'];
if ~ismember(channelName, scopeObjects(this.ptr).channels)
    addChannel(this, channelName);
end

return;

%-----------------------------------------------------------
function addAveragedData(this, channelName, data, ai, strct, varargin)

index = findBindingRowIndex(this, channelName);

if size(scopeObjects(this.ptr).bindings, 2) < 3
    averageStruct.data = data;
    averageStruct.counter = 1;
    scopeObjects(this.ptr).bindings{index, 3} = averageStruct;
    addData(this, channelName, data, ai, strct, varargin);
    return;
end

channel = scopeObjects(this.ptr).bindings{index, 2};
averageStruct = scopeObjects(this.ptr).bindings{index, 3};

if size(averageStruct.data) ~= size(data)
    warning('Averaging failed: current data set is of a different size than previous data set(s).');
    return;
end

averageStruct.data = averageStruct.data + data;
averageStruct.counter = averageStruct.counter + 1;

addData(this, channelName, averageStruct.data / averageStruct.counter, ai, strct, varargin);

return;