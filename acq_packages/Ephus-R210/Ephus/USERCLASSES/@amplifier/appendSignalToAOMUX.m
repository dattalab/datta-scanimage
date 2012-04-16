% AMPLIFIER/appendSignalToAOMUX - Subclasses must implement this method, to get running updates.
%
%  SYNTAX
%   appendSignalToAOMUX(this, aom, pulse)
%   appendSignalToAOMUX(this, aom, pulse, length)
%    this - AMPLIFIER subclass
%    aom - AOMUX to be bound to.
%    scaledChannel - The name of the channel that will get scaled (preprocessed).
%    length - The length of the signal.
%
%  USAGE
%   This method is just a placeholder, and will issue an error if called. All subclasses should override this.
%
%  CHANGES
%
% Created 6/28/06 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function appendSignalToAOMUX(this, aom, scaledChannelName, varargin)

error('AMPLIFIER/appendSignalToAOMUX must get overridden by subclasses.');

return;