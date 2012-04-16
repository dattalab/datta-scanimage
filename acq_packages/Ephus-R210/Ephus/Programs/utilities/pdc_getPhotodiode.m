% pdc_getPhotodiode - Retrieve the photodiode object from the photodiodeConfiguration Gui.
%
% SYNTAX
%  pdiode = pdc_getPhotodiode(hObject)
%   hObject - A handle to a photodiodeConfiguration Gui.
%   pdiode - A photodiode object, that has been configured.
%
% Created 8/3/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function photodiode = pdc_getPhotodiode(hObject)

photodiode = getLocal(progmanager, hObject, 'photodiodeObject');

return;