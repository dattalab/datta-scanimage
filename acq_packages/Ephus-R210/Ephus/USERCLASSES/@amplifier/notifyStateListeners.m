% AMPLIFIER/notifyStateListeners - Signal all listeners that the state of this amplifier has changed.
%
%  SYNTAX
%   notifyStateListeners(this)
%
%  USAGE
%
%  CHANGES
%   TO021505a: Moved from AXOPATCH_200B to AMPLIFIER. -- Tim O'Connor 2/15/05
%   TO032406F - Use callbackManager instance to notify state listeners. -- Tim O'Connor 3/24/06
%
% Created 2/11/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function notifyStateListeners(this)
global amplifierObjects;

%TO032406F
fireEvent(amplifierObjects(this.ptr).callbackManager, 'amplifierStateUpdate');
% for i = 1 : length(amplifierObjects(this.ptr).stateListeners)
% %     try
%         switch lower(class(amplifierObjects(this.ptr).stateListeners{i}))
%             case 'function_handle'
%                 feval(amplifierObjects(this.ptr).stateListeners{i});
%                 
%             case 'cell'
%                 feval(amplifierObjects(this.ptr).stateListeners{i}{:});
%                 
%             case 'char'
%                 eval(amplifierObjects(this.ptr).stateListeners{i});
%                 
%             otherwise
%                 warning('Invalid AMPLIFIER state listener class: %s', class(amplifierObjects(this.ptr).stateListeners{i}));
%         end
% %     catch
% %         listenerString = 'UNKOWN_CALLBACK';
% %         switch lower(class(amplifierObjects(this.ptr).stateListeners{i}))
% %             case 'function_handle'
% %                 listenerString = ['@' func2str(amplifierObjects(this.ptr).stateListeners{i})];
% %                 
% %             case 'cell'
% %                 listenerString = ['{@' func2str(amplifierObjects(this.ptr).stateListeners{i}{1}) ', ...}'];
% %                 
% %             case 'char'
% %                 listenerString = amplifierObjects(this.ptr).stateListeners{i};
% %         end
% %         warning('Failed to notify an AMPLIFIER state listener: %s - %s',  listenerString, lasterr);
% %     end
% end

return;