% @nimexEngine/nimex_resetDevice - Reset a NIDAQmx device.
%
% SYNTAX
%  nimex_resetDevice(eng, deviceName)
%   eng - @nimexEngine instance.
%   deviceName - The NIDAQmx device.
%            Example: '/dev1'
%
% NOTES
%  Relies on NIMEXEng_resetDevice.mex32.
%
%  
% Created
%  Timothy O'Connor 5/5/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function nimex_resetDevice(this, deviceName)

NIMEXEng_resetDevice(deviceName);

return;