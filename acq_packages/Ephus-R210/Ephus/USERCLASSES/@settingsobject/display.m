% SETTINGSOBJECT/display
%
% SYNTAX
%  display(INSTANCE)
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO032406B: - Display the pointer and dereferenced pointer values. -- Tim O'Connor 3/24/06
%
% Created 7/15/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function display(this)
global settingsObjects;

pointer = indexOf(this);

fprintf(1, 'Program Settings - \n Program: %s\n Gui: %s\n Version: %s\n Pointer: %s (%s)\n', settingsObjects(pointer).programName, ...
    settingsObjects(pointer).guiName, num2str(settingsObjects(pointer).programVersion), num2str(this.ptr), num2str(pointer));%TO032406B
if ~isempty(settingsObjects(pointer).lastSaveTime)
    fprintf(1, ' lastSaveTime: %s\n', datestr(settingsObjects(pointer).lastSaveTime));
else
    fprintf(1, ' lastSaveTime: not-saved\n');
end
if ~isempty(settingsObjects(pointer).lastLoadTime)
    fprintf(1, ' lastLoadTime: %s\n', datestr(settingsObjects(pointer).lastLoadTime));
else
    fprintf(1, ' lastSaveTime: not-loaded\n');
end

if ~isempty(settingsObjects(pointer).settings)
    variableNames = fieldnames(settingsObjects(pointer).settings);
    if ~isempty(variableNames)
        fprintf(1, '-------------------\n Variables:\n');
        for i = 1 : length(variableNames)
            
            c = lower(class(settingsObjects(pointer).settings.(variableNames{i})));
            if strcmp(c, 'char')
                fprintf(1, '   %s: ''%s''\n', variableNames{i}, settingsObjects(pointer).settings.(variableNames{i}));
            elseif isnumeric(settingsObjects(pointer).settings.(variableNames{i}))
                fprintf(1, '   %s: %s\n', variableNames{i}, mat2str(settingsObjects(pointer).settings.(variableNames{i})));
            else
                fprintf(1, '   %s: [%s] of %s\n', variableNames{i}, num2str(size(settingsObjects(pointer).settings.(variableNames{i}))), ...
                    class(settingsObjects(pointer).settings.(variableNames{i})));
            end
        end
    end
end

return;