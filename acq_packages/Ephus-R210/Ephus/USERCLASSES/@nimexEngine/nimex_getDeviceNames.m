% @nimexEngine/nimex_getDeviceNames - Retrieves a list of available devices.
%
% SYNTAX
%  names = nimex_getDeviceNames(eng)
%   eng - @nimexEngine instance.
%   names - A cell array of the names of available NIDAQmx devices.
%
% NOTES
%  Relies on NIMEXEng_getDeviceNames.mex32.
%  
% Created
%  Timothy O'Connor 5/5/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function names = nimex_getDeviceNames(this, source, destination)

names = NIMEXEng_getDeviceNames;
if ~isempty(names)
    names = delimitedList(names, ',');
end

return;