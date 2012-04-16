% pdc_setPhotodiode - Load a photodiode object into the photodiodeConfiguration Gui.
%
% SYNTAX
%  pdc_setPhotodiode(pdiode) - Creates a new Gui instance and loads the photodiode.
%  pdc_setPhotodiode(hObject, pdiode)
%   hObject - A handle to a photodiodeConfiguration Gui.
%   pdiode - A photodiode object, to get configured.
%
% TODO
%  Watch out for collisions in multiple GUI instance names in the single argument form.
%
% Created 8/3/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function pdc_setPhotodiode(varargin)

if length(varargin) == 1
    hObject = program('photodiodeConfiguration', 'photodiodeConfiguration', 'photodiodeConfiguration');
    openprogram(progmanager, hObject);
    photodiode = varargin{1};
elseif length(varargin) == 2
    hObject = varargin{1};
    photodiode = varargin{2};
else
    error('Too many arguments.');
end

setLocal(progmanager, hObject, 'photodiodeObject', photodiode);
photodiodeConfiguration('update', getLocal(progmanager, hObject, 'hObject'));
if ~isempty(photodiode)
    setLocalGh(progmanager, hObject, 'photodiodeName', 'Enable', 'On');
else
    setLocalGh(progmanager, hObject, 'photodiodeName', 'Enable', 'Off');
end

return;