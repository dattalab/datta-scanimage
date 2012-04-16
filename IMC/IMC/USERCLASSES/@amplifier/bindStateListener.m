% AMPLIFIER/bindStateListener - Bind a listener for state changes in this object.
%
%  SYNTAX
%   bindStateListener(this, listenerFcn, listenerFcnID)
%
%  USAGE
%   this - An instance of an amplifier object.
%   listenerFcn - A valid callback (function_handle, cell array with a function_handle as the first argument, evalable string).
%   listenerFcnID - A unique identifier (a number, a string, or an object implementing the `eq` method).
%
%  CHANGES
%   TO021505a: Moved from AXOPATCH_200B to AMPLIFIER. -- Tim O'Connor 2/15/05
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%   TO032406F - Use callbackManager instance to notify state listeners. -- Tim O'Connor 3/24/06
%   TO081696H - Switched case convention. See TO122205A. -- Tim O'Connor 8/16/06
%
% Created 2/15/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function bindStateListener(this, listenerFcn, listenerFcnID)
global amplifierObjects;

if ~strcmpi(class(this), 'amplifier') % & ismember('amplifier', fieldnames(this))
    obj = struct(this);
    this = obj.amplifier;%TO122205A %TO081696H
end

%TO032406F
addCallback(amplifierObjects(this.ptr).callbackManager, 'amplifierStateUpdate', listenerFcn, listenerFcnID);%TO032406F
% switch lower(class(listenerFcn))
%     case 'function_handle'
%         amplifierObjects(this.ptr).stateListeners{length(amplifierObjects(this.ptr).stateListeners) + 1} = listenerFcn;
%         
%     case 'cell'
%         if strcmpi(class(listenerFcn{1}), 'function_handle')
%             amplifierObjects(this.ptr).stateListeners{length(amplifierObjects(this.ptr).stateListeners) + 1} = listenerFcn;
%         else
%             error('Cell array callbacks must have a function_handle as their first element');
%         end
%         
%     case 'char'
%         amplifierObjects(this.ptr).stateListeners{length(amplifierObjects(this.ptr).stateListeners) + 1} = listenerFcn;
%         
%     otherwise
%         error('Invalid @AMPLIFIER state listener class: %s', class(listenerFcn));
% end

return;