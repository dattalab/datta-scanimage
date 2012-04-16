function updateDisplayOptions(this)
global scopeObjects;

set(scopeObjects(this.ptr).figure, 'HandleVisibility', 'On');%TO121605A

set(scopeObjects(this.ptr).figure, 'Name', scopeObjects(this.ptr).name, 'Color', scopeObjects(this.ptr).backgroundColor, ...
    'Visible', scopeObjects(this.ptr).visible, 'Tag', scopeObjects(this.ptr).name);

set(scopeObjects(this.ptr).axes, 'XColor', scopeObjects(this.ptr).foregroundColor, 'YColor', scopeObjects(this.ptr).foregroundColor, ...
    'ZColor', scopeObjects(this.ptr).foregroundColor, 'Color', scopeObjects(this.ptr).backgroundColor, ...
    'FontSize', scopeObjects(this.ptr).fontSize, 'FontWeight', scopeObjects(this.ptr).fontWeight);

%Grid Lines
if scopeObjects(this.ptr).gridOn
    set(scopeObjects(this.ptr).axes,'XGrid','on','YGrid','on');
else
    set(scopeObjects(this.ptr).axes,'XGrid','off','YGrid','off');
end

%Axis labels.
set(get(scopeObjects(this.ptr).axes, 'XLabel'), 'String', sprintf('%s [%s/div]', num2str(scopeObjects(this.ptr).xUnitsPerDiv), scopeObjects(this.ptr).xUnitsString), ...
    'FontSize', scopeObjects(this.ptr).fontSize, 'Color', scopeObjects(this.ptr).foregroundColor, 'FontWeight', scopeObjects(this.ptr).fontWeight);
set(get(scopeObjects(this.ptr).axes, 'YLabel'), 'String', sprintf('%s [%s/div]', num2str(scopeObjects(this.ptr).yUnitsPerDiv), scopeObjects(this.ptr).yUnitsString), ...
    'FontSize', scopeObjects(this.ptr).fontSize, 'Color', scopeObjects(this.ptr).foregroundColor, 'FontWeight', scopeObjects(this.ptr).fontWeight);

%Calculate this read-only value.
scopeObjects(this.ptr).xRange = scopeObjects(this.ptr).xUnitsPerDiv * (1 + scopeObjects(this.ptr).numberOfXDivs);
scopeObjects(this.ptr).yRange = scopeObjects(this.ptr).yUnitsPerDiv * (1 + scopeObjects(this.ptr).numberOfYDivs);


% %Set the axes limits.
 xLim = [scopeObjects(this.ptr).xOffset (scopeObjects(this.ptr).xOffset + abs(scopeObjects(this.ptr).xRange))];
 
 %updateScaling(this); JL081807B comment out updatescaling

% groundOffset =  0.5 * scopeObjects(this.ptr).yUnitsPerDiv;
% 
% set(scopeObjects(this.ptr).axes, 'XLim', xLim);
% 
% if yLim(1) == yLim(2)
%     yLim(2) = yLim(2) + 1;
% end
% set(scopeObjects(this.ptr).axes, 'YLim', yLim);
% 
 %Set the position of "ground".
% if yLim(1) > 0
%     set(scopeObjects(this.ptr).groundLine, 'XData', xLim, 'YData', [yLim(1) yLim(1)]);
%elseif yLim(2) < 0
%         set(scopeObjects(this.ptr).groundLine, 'XData', xLim, 'YData', [yLim(2) yLim(2)]);
% else
    set(scopeObjects(this.ptr).groundLine, 'XData', xLim, 'YData', [0 0]);
     % end
% 
% %Create the tick marks.
% xTick = scopeObjects(this.ptr).xOffset : scopeObjects(this.ptr).xUnitsPerDiv : scopeObjects(this.ptr).xOffset + ...
%     (1 + scopeObjects(this.ptr).numberOfXDivs) * scopeObjects(this.ptr).xUnitsPerDiv;
% set(scopeObjects(this.ptr).axes, 'XTick', xTick);
% 
% yTick = scopeObjects(this.ptr).yOffset - groundOffset : scopeObjects(this.ptr).yUnitsPerDiv : scopeObjects(this.ptr).yOffset - groundOffset + ...
%     (1 + scopeObjects(this.ptr).numberOfYDivs) * scopeObjects(this.ptr).yUnitsPerDiv;
% if isempty(yTick)
%     yTick = yLim(1) : (yLim(2) - yLim(1)) / scopeObjects(this.ptr).numberOfYDivs : yLim(2);
% end
% set(scopeObjects(this.ptr).axes, 'YTick', yTick);
% 
% %Create the tick labels, and track their lengths.
% mxt = 0;
% if scopeObjects(this.ptr).showXTickLabels
%     for i = 1 : length(xTick)
%         xTickLabels{i} = num2str(roundTo(xTick(i), 3));
%         mxt = max(mxt, length(xTickLabels{i}));
%     end
% else
%     xTickLabels = [];
% end
% 
% myt = 0;
% if scopeObjects(this.ptr).showYTickLabels
%     for i = 1 : length(yTick)
%         yTickLabels{i} = num2str(roundTo(yTick(i), 3));
%         myt = max(myt, length(yTickLabels{i}));
%     end
% else
%     yTickLabels = [];
% end
% set(scopeObjects(this.ptr).axes, 'XTickLabel', xTickLabels, 'YTickLabel', yTickLabels);
% 
% %Work out the axes position, so everything fits nice.
% pos = [0 0 1 1];
% if scopeObjects(this.ptr).pureDisplay
%     pos = [0 0 1 1];
% else
%     pos = [.06 .06 .92 .92];
% end
% if scopeObjects(this.ptr).showXTickLabels
%     pos(2) = .1;
%     pos(4) = .88;
% end
% if  (scopeObjects(this.ptr).showYTickLabels & myt <= 1) | ~scopeObjects(this.ptr).showYTickLabels
%     pos(1) = .06;
%     pos(3) = .92;
% elseif  ((scopeObjects(this.ptr).showYTickLabels & myt <= 2) | ~scopeObjects(this.ptr).showYTickLabels)
%     pos(1) = .08;
%     if scopeObjects(this.ptr).showXTickLabels & mxt > 3
%         pos(3) = .88;
%     else
%         pos(3) = .9;
%     end
% elseif ~(scopeObjects(this.ptr).showXTickLabels & mxt > 3)
%     pos(1) = .12;
%     pos(3) = .86;
% elseif scopeObjects(this.ptr).showXTickLabels & scopeObjects(this.ptr).showYTickLabels & (myt + mxt) > 8
%     %Kind of a catch all, for large numbers, anything beyond this... you're on your own.
%     pos(1) = .145;
%     pos(3) = .83;
% else
%     pos(1) = .11;
%     pos(3) = .86;
% end
% if strcmpi(scopeObjects(this.ptr).fontWeight, 'bold')
%     pos([1 2]) = pos([1 2]) + 0.01;
%     pos([3 4]) = pos([3 4]) - 0.01;
% end
% if scopeObjects(this.ptr).fontSize > 10
%     pos([1 2]) = pos([1 2]) + 0.01 * (scopeObjects(this.ptr).fontSize - 10) * .5;
%     pos([3 4]) = pos([3 4]) - 0.01 * (scopeObjects(this.ptr).fontSize - 10) * .5;
% end
% set(scopeObjects(this.ptr).axes, 'Position', pos);

%Update the center lines.
if scopeObjects(this.ptr).displayCenterLines
    set(scopeObjects(this.ptr).horizontalCenterLine, 'XData', [xLim(1) xLim(1)+.5*(xLim(2)-xLim(1)) xLim(2)], ...
        'YData', ones(3, 1) * (scopeObjects(this.ptr).yOffset + 0.5 * abs(diff(yLim))) - groundOffset, 'Color', scopeObjects(this.ptr).foregroundColor, ...
        'Visible', 'On');
    set(scopeObjects(this.ptr).verticalCenterLine, 'XData', ones(3, 1) * (scopeObjects(this.ptr).xOffset + 0.5 * abs(diff(xLim))), ...
        'YData', [yLim(1) yLim(1)+.5*(yLim(2)-yLim(1)) yLim(2)], 'Color', scopeObjects(this.ptr).foregroundColor, ...
        'Visible', 'On');
else
    set(scopeObjects(this.ptr).horizontalCenterLine, 'Visible', 'Off');
    set(scopeObjects(this.ptr).verticalCenterLine, 'Visible', 'Off');
end

for i = 1 : size(scopeObjects(this.ptr).bindings, 1)
    udata = get(scopeObjects(this.ptr).bindings{i, 2}, 'UserData');

    if udata.visible
        visible = 'On';
    else
        visible = 'Off';
    end
    
    set(scopeObjects(this.ptr).bindings{i, 2}, 'Marker', scopeObjects(this.ptr).marker, 'LineStyle', scopeObjects(this.ptr).lineStyle, ...
        'MarkerSize', scopeObjects(this.ptr).markerSize, 'Visible', visible);
end

set(scopeObjects(this.ptr).figure, 'HandleVisibility', 'Off');%TO121605A

if scopeObjects(this.ptr).forceDraw
    drawnow;
end

return;