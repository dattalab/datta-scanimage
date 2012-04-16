%  -
%
% SYNTAX
%
% NOTES
%
% CHANGES
%
% Created
%  Timothy O'Connor 8/14/07
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function task = getTaskByDeviceName(this, deviceName)

subsystemName = deviceName;
for i = length(deviceName): -1 : 1
    if deviceName(i) < '0' || '9' < deviceName(i)
        subsystemName = deviceName(1:i);
        break;
    end
end

task = getTaskBySubsystemName(this, subsystemName);

return;