% AMPLIFIER/bindToAIMUX - Subclasses must implement this method, to get running updates.
%
%  SYNTAX
%   bindToAIMUX(this, aim, scaledChannelName)
%    this - AMPLIFIER subclass
%    aim - AIMUX to be bound to.
%    scaledChannel - The name of the channel that will get scaled (preprocessed).
%
%  USAGE
%   This method is just a placeholder, and will issue an error if called. All subclasses should override this.
%
%  CHANGES
%
% Created 2/28/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function bindToAIMUX(this, aim, scaledChannelName)

error('AMPLIFIER/bindToAIMUX must get overridden by subclasses.');

return;