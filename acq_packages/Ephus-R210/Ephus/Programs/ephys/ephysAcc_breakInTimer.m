% ephysAcc_breakInTimer - Updates the display of time since cell break in.
%
% SYNTAX
%  ephysAcc_breakInTimer(hObject, ampIndex, data, ai, strct, varargin) - AIMUX form.
%
% USAGE
%
% NOTES
%  See TO120205I.
%
% CHANGES
%
% Created 2/25/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephysAcc_breakInTimer(hObject, varargin)
global ephysScopeAccessory;

breakInTime = getLocal(progmanager, hObject, 'breakInTime');
if isempty(breakInTime)
    return;
end

elapsedTime = etime(clock, breakInTime);

minutes = floor(elapsedTime / 60);
seconds = mod(elapsedTime, 60);

if seconds < 10
    setLocalGh(progmanager, hObject, 'breakIn', 'String', sprintf('%s:0%4.2f', num2str(minutes), seconds));
else
    setLocalGh(progmanager, hObject, 'breakIn', 'String', sprintf('%s:%5.2f', num2str(minutes), seconds));
end

return;