% pdc_setPhotodiode - Load a ttl object into the ttlGui.
%
% SYNTAX
%  ttl_setTtlObject(pdiode) - Creates a new Gui instance and loads the ttl.
%  ttl_setTtlObject(hObject, ttl)
%   hObject - A handle to a photodiodeConfiguration Gui.
%   ttl - A ttl object, to get configured.
%
% TODO
%  Watch out for collisions in multiple GUI instance names in the single argument form.
%
% Created 8/3/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ttl_setTtlObject(varargin)

if length(varargin) == 1
    hObject = program('ttlGui', 'ttlGui', 'ttlGui');
    openprogram(progmanager, hObject);
    ttl = varargin{1};
elseif length(varargin) == 2
    hObject = varargin{1};
    ttl = varargin{2};
else
    error('Too many arguments.');
end

setLocal(progmanager, hObject, 'ttlObject', ttl);
ttlGui(getLocal(progmanager, hObject, 'hObject'), 'update');

return;