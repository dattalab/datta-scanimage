% autonotes_setScroll - Update the display's scroll position.
%
% SYNTAX
%  autonotes_setScroll(hObject)
%
% NOTES
%
% CHANGES
%  TO112907H - The line capacity is 2 (not 1) less than the number of characters in the panel's height. -- Tim O'Connor 11/29/07
%
% Created 8/29/07 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function autonotes_setScroll(hObject)

[displayActive, textSlider, log] = getLocalBatch(progmanager, hObject, 'displayActive', 'textSlider', 'log');

if ~displayActive
    return;
end

if isempty(log)
    setLocal(progmanager, hObject, 'logDisplay', log);
end

logDisplayH = getLocalGh(progmanager, hObject, 'logDisplay');
pos = get(logDisplayH, 'Position');
lineCapacity = floor(pos(4)) - 2;%TO112907H - The line capacity is 2 (not 1) less than the number of characters in the panel's height.

%Assume a maximum character per line limit of 120, to reduce the linebreak search overhead.
log = log(max(1, end - (120 * lineCapacity)) : end);
lineBreaks = strfind(log, char(10));%Find the linebreaks, so we can count lines, and display the correct number of lines on the GUI.
setLocalGh(progmanager, hObject, 'textSlider', 'SliderStep', [1/length(lineBreaks) lineCapacity/length(lineBreaks)]);
% log
% lineBreaks
% lineBreakCount = length(lineBreaks)
% lineCapacity
if length(lineBreaks) < lineCapacity
    %There are less lines than there is space in the GUI, show it all.
    setLocalBatch(progmanager, hObject, 'logDisplay', log, 'textSlider', 0);
else
    %Only show the lines selected by the slider.
    relativeLine = (1 - textSlider);
% relativeLine
    lastLineIndex = min(ceil(length(lineBreaks) * relativeLine) + 1, length(lineBreaks));
    if lastLineIndex <= lineCapacity
        setLocalBatch(progmanager, hObject, 'logDisplay', log(1 : lineBreaks(lineCapacity)));
    else
% lastLineIndex
        lastLineBreakCharIndex = lineBreaks(lastLineIndex);
% lastLineBreakCharIndex
        oldestLineBreakIndex = lastLineIndex - lineCapacity;
% oldestLineBreakIndex
        oldestCharShownIndex = lineBreaks(max(oldestLineBreakIndex, 1));
% oldestCharShownIndex
        setLocal(progmanager, hObject, 'logDisplay', log(oldestCharShownIndex : lastLineBreakCharIndex));
% totalChars = length(log)
% log(oldestCharShownIndex : lastLineBreakCharIndex)
    end
end
% logDisplay = getLocal(progmanager, hObject, 'logDisplay')
return;