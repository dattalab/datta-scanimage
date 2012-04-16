% saveCompatible - Callthrough to Matlab's `save` that sets the version compatibility flag as necessary to open files in v6 mode.
%
% SYNTAX
%  See Matlab's `save` function.
%
% USAGE
%  Use to ensure binary compatibility with Matlab v6.x.
%
% NOTES
%  See TO071906D.
%
% CHANGES
%
% Created 7/19/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function saveCompatible(varargin)

saveStr = 'save(';
for i = 1 : length(varargin)
    if i < length(varargin)
        saveStr = [saveStr '''' varargin{i} ''', '];
    else
        saveStr = [saveStr '''' varargin{i} ''''];
    end
end

verstring = version;
if str2num(verstring(1:3)) >= 7.2
    saveStr = [saveStr ', ''-v6'');'];
else
    saveStr = [saveStr ');'];
end

% fprintf(1, 'saveCompatible: saveStr = ''%s''\n', saveStr);
evalin('caller', saveStr);

return;