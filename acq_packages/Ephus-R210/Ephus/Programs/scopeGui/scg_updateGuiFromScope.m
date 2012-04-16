% scg_updateGuiFromScope - Update the GUI display to match the scopeObject's current settings.
%
% SYNTAX
%   scg_updateGuiFromScope(hObject) - Update all fields.
%   scg_updateGuiFromScope(hObject, fieldNames) - Update only specified fields. - NOT_YET_IMPLEMENTED
%       fieldNames - A list of fields to get updated, all others are ignored.
%
% USAGE
%
% NOTES
%   "Non-fields" (meaning fields that exist within the Gui, but not the scope) will always
%   get updated.
%   If the 'noUpdate' flag is set, this function returns immediately. This is to avoid this function
%   executing on every call to the 'set' method of the scope in the scopeGui.
%
% CHANGES
%   TO021805d: Tim O'Connor 2/18/05 - Created the 'updatingGuiFromScope' semaphore, to prevent multiple threads accessing this function simultaneously.
%   TO021805e: Tim O'Connor 2/18/05 - Blocked overly frequent updates with the 'minUpdateTime' and 'lastUpdateTime' variables.
%   TO062705A: Tim O'Connor 6/27/05 - Watch out for errors during updating, that prevent any future updates from occuring.
%   TO070605F: Tim O'Connor 7/6/05 - Watch out for size mismatches in calls to `strcmp`.
%   TO100405D: Tim O'Connor 10/4/05 - As a temporary fix, when dealing with multiple scope objects, just update from the first one.
%
% Created 2/4/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function scg_updateGuiFromScope(hObject, varargin)

%Quit if updating is disabled, an update is in progress, or not enough time has elapsed since the last update. TO021805d, TO021805e
c = clock;
if getLocal(progmanager, hObject, 'noUpdate') | getLocal(progmanager, hObject, 'updatingGuiFromScope') | ...
        etime(c, getLocal(progmanager, hObject, 'lastUpdateTime')) < getLocal(progmanager, hObject, 'minUpdateTime')
    return;
end

setLocal(progmanager, hObject, 'updatingGuiFromScope', 1);

if length(varargin) == 1
    if strcmpi(class(varargin{1}), 'cell')
        varargin = varargin{1};
    end
end

%If an error were to occur here, without the try/catch, no future updates could occur, until updatingGuiFromScope gets reset. -- TO062705A
try
    sc = getLocal(progmanager, hObject, 'scopeObject');
    sc = sc(1);%<--------------------- LOOK HERE!!!
    set(sc, 'autoRangeTime', c);%Block "concurrent" (temporally close) addData calls from autoRanging.

    if isempty(varargin)
        fieldNames = {'xOffset', 'xUnitsPerDiv', 'xUnitsString', 'yOffset', 'yUnitsPerDiv', 'yUnitsString'};
    else
        fieldNames = varargin;
    end
    
    for i = 1 : length(fieldNames)
        setLocal(progmanager, hObject, fieldNames{i}, get(sc, fieldNames{i}));
    end
    
    channelList = get(sc, 'channels');
    setLocal(progmanager, hObject, 'channelListLast', channelList);
    if ~isempty(channelList)
        channelName = getLocal(progmanager, hObject, 'channelList');
        if prod(size(channelList)) ~= prod(size(getLocalGh(progmanager, hObject, 'channelList', 'String')))
            %TO070605F: Watch out for size mismatches in calls to `strcmp`. -- Tim O'Connor 7/6/05
            setLocalGh(progmanager, hObject, 'channelList', 'String', channelList);
        else
            if ~all(strcmp(channelList, reshape(getLocalGh(progmanager, hObject, 'channelList', 'String'), size(channelList))))
                setLocalGh(progmanager, hObject, 'channelList', 'String', channelList);
            end
        end

        if ismember(channelName, channelList)
            setLocal(progmanager, hObject, 'channelList', channelName);
        else
            channelName = getLocal(progmanager, hObject, 'channelList');
        end
        if ~strcmp(channelName, 'None')
            setLocalGh(progmanager, hObject, 'channelOffset', 'Enable', 'On');
            setLocalGh(progmanager, hObject, 'channelGain', 'Enable', 'On');
            setLocalGh(progmanager, hObject, 'channelVisibility', 'Enable', 'On');
            
            setLocal(progmanager, hObject, 'channelOffset', getChannelProperty(sc, channelName, 'offset'));
            setLocal(progmanager, hObject, 'channelGain', getChannelProperty(sc, channelName, 'gain'));
            setLocal(progmanager, hObject, 'channelVisibility', getChannelProperty(sc, channelName, 'visible'));
        else
            setLocalGh(progmanager, hObject, 'channelOffset', 'Enable', 'Off');
            setLocalGh(progmanager, hObject, 'channelGain', 'Enable', 'Off');
            setLocalGh(progmanager, hObject, 'channelVisibility', 'Enable', 'Off');
            
            setLocal(progmanager, hObject, 'channelOffset', 0);
            setLocal(progmanager, hObject, 'channelGain', 0);
            setLocal(progmanager, hObject, 'channelVisibility', 0);
        end
    else
        setLocalGh(progmanager, hObject, 'channelList', 'String', 'None');
        
        setLocalGh(progmanager, hObject, 'channelOffset', 'Enable', 'Off');
        setLocalGh(progmanager, hObject, 'channelGain', 'Enable', 'Off');
        setLocalGh(progmanager, hObject, 'channelVisibility', 'Enable', 'Off');
        
        setLocal(progmanager, hObject, 'channelOffset', 0);
        setLocal(progmanager, hObject, 'channelGain', 1);
        setLocal(progmanager, hObject, 'channelVisibility', 0);
    end

%     if get(sc, 'autoRange')
%         setLocal(progmanager, hObject, 'autoRange', 1);
%         mn = 0;
%         mx = 0;
%         for i = 1 : length(channelList)
%             yData = getChannelProperty(sc, channelName, 'YData');
%             mn = min(mn, min(yData));
%             mx = max(mx, max(yData));
%         end
%         
%         numberOfYDivs = get(sc, 'numberOfYDivs');
%         yUnitsPerDiv = get(sc, 'yUnitsPerDiv');
%         yOffset = get(sc, 'yOffset');
% 
%         if mx > numberOfYDivs * yUnitsPerDiv + yOffset | mn < yOffset | ...
%                 abs(yOffset - mn) > (2 * yUnitsPerDiv) | ...
%                 abs(mx - numberOfYDivs * yUnitsPerDiv + yOffset) >  2 * yUnitsPerDiv
%             
%             divUnit = 1.1 * (mx - mn) / (numberOfYDivs - 1);
%             if divUnit > 0
%                 set(sc, 'yUnitsPerDiv', divUnit, 'yOffset',  mn - 0.5 * divUnit);
%             end
%             setLocal(progmanager, hObject, 'yUnitsPerDiv', divUnit);
%             setLocal(progmanager, hObject, 'yOffset', mn - 0.5 * divUnit);
%         end
%     else
%         setLocal(progmanager, hObject, 'autoRange', 0);
%     end

    %Bump these up even higher.
    set(sc, 'autoRangeTime', clock);
    setLocal(progmanager, hObject, 'lastUpdateTime', clock);
catch
    warning('Error updating scopeGui from scopeObject ''%s'': %s', get(sc, 'Name'), lasterr);
end

setLocal(progmanager, hObject, 'updatingGuiFromScope', 0);

return;