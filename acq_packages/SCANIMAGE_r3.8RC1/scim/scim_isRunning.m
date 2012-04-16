function version = scim_isRunning()
%SCIM_ISRUNNING Determines which, if any, version of ScanImage appears to be currently running
%% SYNTAX
%   version = scim_isRunning()
%       version: 0 if ScanImage is not running, or an integer indicating major version number of ScanImage found running, e.g. 3 for ScanImage 3.x

if ismember('state',who('global'))
    global state
    if ~isempty(state)
        version = 3;
    else 
        version = 0;
    end
    
elseif exist('hSI','var') && isvalid(hSI)
    version = 4;
else
    version = 0;
end

