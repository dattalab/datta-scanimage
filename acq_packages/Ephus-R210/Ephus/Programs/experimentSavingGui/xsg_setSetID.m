% xsg_setSetID - Set the setID.
%
% SYNTAX
%  xsg_setSetID(setID)
%   setID - A 4 character string.
%
% USAGE
%
% NOTES
%  See TO031006D (creation of this function).
%
% CHANGES
%  TO111908F - Clear 'overwriteConfirmedForDirectory', to prevent accidental overwrites when a user goes back to the directory. -- Tim O'Connor 11/19/08
%  BSTO060910B - Verify characters. -- Ben Suter/Tim O'Connor 6/9/10
%
% Created 3/10/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function xsg_setSetID(setID)

if length(setID) > 4
    setID = setID(1:4);
elseif length(setID) == 1
    setID = ['AAA' setID];
elseif length(setID) == 2
    setID = ['AA' setID];
elseif length(setID) == 3
    setID = ['A' setID];
end

%BSTO060910B - Verify characters. -- Ben Suter/Tim O'Connor 6/9/10
setID(~ismember(setID, ['A':'Z', 'a':'z'])) = 'A';
% for i = 1 : length(setID)
%     if ~ismember(setID(i), ['A':'Z', 'a':'z'])
%         setID(i) = 'A';
%     end
% end

for i = 1 : length(setID)
    if ~isletter(setID(i))
        setID(i) = 'A';
    end
end

setLocal(progmanager, xsg_getHandle, 'setID', setID);

%TO111908F - Clear 'overwriteConfirmedForDirectory', to prevent accidental overwrites when a user goes back to the directory. -- Tim O'Connor 11/19/08
if getLocal(progmanager, xsg_getHandle, 'addSetIDToPath')
    setLocal(progmanager, xsg_getHandle, 'overwriteConfirmedForDirectory', '');
end

return;