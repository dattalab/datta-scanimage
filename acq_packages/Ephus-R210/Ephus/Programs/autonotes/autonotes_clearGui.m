% autonotes_clearGui - Clear the GUI's text display.
%
% SYNTAX
%  autonotes_clearGui
%
% NOTES
%
% CHANGES
%
% Created 8/29/07 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function autonotes_clearGui

hObject = getGlobal(progmanager, 'hObject', 'autonotes', 'autonotes');
setLocalBatch(progmanager, hObject, 'log', '', 'logDisplay', '', 'textSlider', 1);

return;