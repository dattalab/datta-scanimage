% xsg_isDiskStreamingEnabled - Determine if disk streaming mode is enabled.
%
%  SYNTAX
%   streamToDisk = xsg_isDiskStreamingEnabled
%
%  CHANGES
%
%  NOTES
%   See TO021510F.
%
% Created 2/15/10 - Tim O'Connor
% Copyright - Northwestern University/Howard Hughes Medical Institute 2010
function streamToDisk = xsg_isDiskStreamingEnabled

streamToDisk = getLocal(progmanager, xsg_getHandle, 'streamToDisk');

return;