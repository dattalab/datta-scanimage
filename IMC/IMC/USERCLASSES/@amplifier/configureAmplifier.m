% AMPLIFIER/configureAmplifier - Initiate a custom configuration routine/gui.
%
% SYNTAX
%  configureAmplifier(AMPLIFIER)
%
% USAGE
%  This particular method will not function, as it is the responsibility of
%  subclasses to implement this method for their particular configurations.
%
%  All subclasses, in the interest of user-friendliness, should implement this method.
%
% NOTES
%
% CHANGES
%
% Created 3/23/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function configureAmplifier(this)

error('NOT_IMPLEMENTED - It is the responsibility of the subclass to implement this method.');

return;