% xsg_setPath - Set the epoch number.
%
% SYNTAX
%  xsg_setEpochNumber(path)
%  xsg_setEpochNumber(hObject, path)
%   path - a valid filepath

function xsg_setPath(varargin)

if length(varargin) == 1
    hObject = xsg_getHandle;
    path = varargin{1};
else
    hObject = varargin{1};
    path = varargin{2};
end

setLocal(progmanager, hObject, 'directory', path);

return;