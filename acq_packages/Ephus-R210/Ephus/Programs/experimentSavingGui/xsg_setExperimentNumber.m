% xsg_incrementSetID - Increment the setID.
%
% SYNTAX
%  xsg_setExperimentNumber
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO082907A - Update new epoch field too. -- Tim O'Connor 8/29/07
%  TO082907D - Moved the mapper's "New Cell" functionality into here. -- Tim O'Connor 8/29/07
%  TO112907B - Escape '\' for printing. -- Tim O'Connor 11/29/07
%  TO111908F - Clear 'overwriteConfirmedForDirectory', to prevent accidental overwrites when a user goes back to the directory. -- Tim O'Connor 11/19/08
%  TO031010B - Make sure the headerGUI exists, before trying to perform an operation on it. GS031010_REMOTE_DEBUG_SESSION -- Tim O'Connor 3/10/10
%
% Created 4/7/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function xsg_setExperimentNumber(xNumber)

hObject = xsg_getHandle;

if isnumeric(xNumber)
    xNumber = num2str(xNumber);
end

%BSTO060910B - Verify characters. -- Ben Suter/Tim O'Connor 6/9/10
xNumber(~ismember(xNumber, ['A':'Z', 'a':'z', '0':'9'])) = '0';
% for i = 1 : length(xNumber)
%     if ~ismember(xNumber(i), ['A':'Z', 'a':'z', '0':'9'])
%         xNumber(i) = '0';
%     end
% end

if length(xNumber) > 4
    xNumber = xNumber(1:4);
elseif length(xNumber) == 1
    xNumber = ['000' xNumber];
elseif length(xNumber) == 2
    xNumber = ['00' xNumber];
elseif length(xNumber) == 3
    xNumber = ['0' xNumber];
end

for i = 1 : length(xNumber)
    if isempty(str2double(xNumber(i)))
        xNumber(i) = '0';
    end
end

setLocal(progmanager, hObject, 'experimentNumber', xNumber);

%TO111908F - Clear 'overwriteConfirmedForDirectory', to prevent accidental overwrites when a user goes back to the directory. -- Tim O'Connor 11/19/08
if getLocal(progmanager, xsg_getHandle, 'addExperimentNumberToPath')
    setLocal(progmanager, xsg_getHandle, 'overwriteConfirmedForDirectory', '');
end

setLocalBatch(progmanager, xsg_getHandle, 'setID', 'AAAA', 'acquisitionNumber', '0001');

notesName = xsg_getFilename;
autonotes_setFilename(notesName(1 : end-8));
%TO031010B - Make sure the headerGUI exists, before trying to perform an operation on it.
if isprogram(progmanager, 'headerGUI')
    header_saveMFile;
end
autonotes_addNote(strrep(xsg_getPath, '\', '\\'));%TO112907B
autonotes_addNote('NEW_CELL');
autonotes_addNote(['Experiment #' xNumber]);
xsg_setEpochNumber(0);%TO082907A - Update new epoch field too.
fireEvent(getUserFcnCBM, 'xsg:NewCell');

return;