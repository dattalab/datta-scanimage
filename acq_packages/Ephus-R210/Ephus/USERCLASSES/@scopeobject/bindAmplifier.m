% bindAmplifier - Set the amplifier field and bind the state change listener.
%
% SYNTAX
%  bindAmplifier(SCOPEOBJECT, amp)
%    SCOPEOBJECT - This object's instance.
%    amp - The @AMPLIFIER instance to be bound.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO022305d - Take the amplifier as an argument. -- Tim O'Connor 2/23/05
%
% Created 2/17/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function bindAmplifier(this, amp)
global scopeObjects;

% scopeObjects(this.ptr).amplifier = amp;%TO022305d
bindStateListener(amp, {@amplifierStateChangeListener, this, amp});%TO022305d

return;