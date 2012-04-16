% scopeObject/updateScaling - Encapsulation of the autoscaling functionality.
%
% USAGE
%  updateScaling(INSTANCE)
%   INSTANCE - A @scopeObject instance.
%
% CHANGES
%  TO062705A - The listeners (ie. GUI) need updating now. -- Tim O'Connor 6/27/05
%  TO062705B - Only do this if autoRange is enabled. -- Tim O'Connor 6/27/05
%  TO070805E - Scratch TO062705B, let it do it whenever. -- Tim O'Connor 7/8/05
%  Tim O'Connor 7/11/05 TO071105B: Added flexibleYTicks.
%  TO121405E - Redefined the offset to mean the midpoint of the scope (ie. if it's set to 0, the scope will be centered about 0). -- Tim O'Connor 12/14/05
%  TO121605A - Turn off all 'HandleVisibility' properties to keep the display from getting corrupted by people doing stupid things on the command line. -- Tim O'Connor 12/16/05
%  TO031010J - We want to do our own scaling on the X-axis (to get a fixed width display, when the trace length is known a priori. GS031010_REMOTE_DEBUG_SESSION -- Tim O'Connor 3/10/10
%
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function updateScaling(this)
global scopeObjects;

%TO070805E: Scratch TO062705B, let it do it whenever. -- Tim O'Connor 7/8/05
% %TO062705B - Only do this if autoRange is enabled. -- Tim O'Connor 6/27/05
% if ~scopeObjects(this.ptr).autoRange
%     return;
%  end

%TO031010J - We want to do our own scaling on the X-axis (to get a fixed width display, when the trace length is known a priori. GS031010_REMOTE_DEBUG_SESSION
%Calculate this read-only value.
scopeObjects(this.ptr).xRange = scopeObjects(this.ptr).xUnitsPerDiv * (1 + scopeObjects(this.ptr).numberOfXDivs);
%Set the axes limits.
xLim = [scopeObjects(this.ptr).xOffset (scopeObjects(this.ptr).xOffset + abs(scopeObjects(this.ptr).xRange))];
set(scopeObjects(this.ptr).axes, 'XLim', xLim);

return;

scopeObjects(this.ptr).yRange = scopeObjects(this.ptr).yUnitsPerDiv * (1 + scopeObjects(this.ptr).numberOfYDivs);

groundOffset =  0.5 * scopeObjects(this.ptr).yUnitsPerDiv;

set(scopeObjects(this.ptr).figure, 'HandleVisibility', 'On');%TO121605A - Make sure this is on before trying to manipulate the display, at all.

% fprintf(1, 'Actual offset: %3.3f\nActual center: %3.3f\n', scopeObjects(this.ptr).yOffset, scopeObjects(this.ptr).yOffset - 0.5 * scopeObjects(this.ptr).yRange);
yLim = [scopeObjects(this.ptr).yOffset (scopeObjects(this.ptr).yOffset + abs(scopeObjects(this.ptr).yRange))] - 0.5 * scopeObjects(this.ptr).yRange;

% fprintf(1, 'divUnit: %3.3f\nYLim: %3.3f - %3.3f\n\n', scopeObjects(this.ptr).yUnitsPerDiv, yLim(1), yLim(2));
if yLim(1) == yLim(2)
    yLim(2) = yLim(2) + 1;
end
set(scopeObjects(this.ptr).axes, 'YLim', yLim);%TO072105F
% set(scopeObjects(this.ptr).axes, 'YLimMode', 'Auto');

%Set the position of "ground".
if yLim(1) > 0
    set(scopeObjects(this.ptr).groundLine, 'XData', xLim, 'YData', [yLim(1) yLim(1)]);
elseif yLim(2) < 0
    set(scopeObjects(this.ptr).groundLine, 'XData', xLim, 'YData', [yLim(2) yLim(2)]);
else
    set(scopeObjects(this.ptr).groundLine, 'XData', xLim, 'YData', [0 0]);
end

%Create the tick marks.
xTick = scopeObjects(this.ptr).xOffset : scopeObjects(this.ptr).xUnitsPerDiv : scopeObjects(this.ptr).xOffset + ...
    (1 + scopeObjects(this.ptr).numberOfXDivs) * scopeObjects(this.ptr).xUnitsPerDiv;
set(scopeObjects(this.ptr).axes, 'XTick', xTick);

if abs(scopeObjects(this.ptr).yOffset) > 1
    tickOrigin = round(scopeObjects(this.ptr).yOffset) - scopeObjects(this.ptr).yUnitsPerDiv; 
else
    tickOrigin = scopeObjects(this.ptr).yOffset - scopeObjects(this.ptr).yUnitsPerDiv;
end
yTick = yLim(1) : scopeObjects(this.ptr).yUnitsPerDiv : yLim(2);
% yTick = tickOrigin : scopeObjects(this.ptr).yUnitsPerDiv : scopeObjects(this.ptr).yOffset + ...
%     (1 + scopeObjects(this.ptr).numberOfYDivs) * scopeObjects(this.ptr).yUnitsPerDiv;
if isempty(yTick)
    yTick = yLim(1) : (yLim(2) - yLim(1)) / scopeObjects(this.ptr).numberOfYDivs : yLim(2);
end
%TO071105B Moved YTick assignment down below.

%Create the tick labels, and track their lengths.
mxt = 0;
if scopeObjects(this.ptr).showXTickLabels
    for i = 1 : length(xTick)
        xTickLabels{i} = num2str(roundTo(xTick(i), 3));
        mxt = max(mxt, length(xTickLabels{i}));
    end
else
    xTickLabels = [];
end
myt = 0;
mytA= []; %JL080607A when showYTickLabels equal zero, mytA is undefined

if scopeObjects(this.ptr).showYTickLabels
    for i = 1 : length(yTick)
        yTickLabels{i} = num2str(roundTo(yTick(i), 3));
        mytA(i) = max(length(yTickLabels{i}));
    end
else
    yTickLabels = [];
end
%TO071105B
if ~isempty(mytA) & scopeObjects(this.ptr).flexibleYTicks
    myt = max(mytA);
    yTickIndices = find(mytA == min(mytA));
    if length(yTickIndices) == 1
        mytA(yTickIndices) = Inf;
        yTickIndices = cat(2, yTickIndices, find(mytA == min(mytA)));
    end
    [yTick order] = sort(yTick(yTickIndices));
    yTickLabels = {yTickLabels{yTickIndices}};
    yTickLabels = {yTickLabels{order}};
end
% set(scopeObjects(this.ptr).axes, 'YTick', yTick);%TO072105F
% set(scopeObjects(this.ptr).axes, 'YTickMode', 'Auto');%TO072105F
% set(scopeObjects(this.ptr).axes, 'XTickLabel', xTickLabels, 'YTickLabel', yTickLabels);%TO072105F
% set(scopeObjects(this.ptr).axes, 'YTickLabelMode', 'Auto');%TO072105F
% set(scopeObjects(this.ptr).axes, 'XTickLabel', xTickLabels);%TO072105F
% set(scopeObjects(this.ptr).axes, 'YTickLabelMode', 'Auto', 'XTickLabelMode', 'Auto', 'XTickMode', 'Auto', 'YLimMode', 'Auto', 'YTickMode', 'Auto', 'YTickLabelMode', 'Auto');

%Work out the axes position, so everything fits nice.
% pos = [0 0 1 1];%TO070805D
pos = [.06 .06 .92 .92];
if scopeObjects(this.ptr).showXTickLabels
    pos(2) = .1;
    pos(4) = .88;
end
if  (scopeObjects(this.ptr).showYTickLabels & myt <= 1) | ~scopeObjects(this.ptr).showYTickLabels
    pos(1) = .06;
    pos(3) = .92;
elseif  ((scopeObjects(this.ptr).showYTickLabels & myt <= 2) | ~scopeObjects(this.ptr).showYTickLabels)
    pos(1) = .08;
    if scopeObjects(this.ptr).showXTickLabels & mxt > 3
        pos(3) = .88;
    else
        pos(3) = .9;
    end
elseif ~(scopeObjects(this.ptr).showXTickLabels & mxt > 3)
    pos(1) = .15;
    pos(3) = .835;
elseif scopeObjects(this.ptr).showXTickLabels & scopeObjects(this.ptr).showYTickLabels & (myt + mxt) > 12
    %Kind of a catch all, for large numbers, anything beyond this... you're on your own.
    pos(1) = .145;
    pos(3) = .83;
else
    pos(1) = .13;
    pos(3) = .84;
end
if strcmpi(scopeObjects(this.ptr).fontWeight, 'bold')
    pos([1 2]) = pos([1 2]) + 0.01;
    pos([3 4]) = pos([3 4]) - 0.01;
end
if scopeObjects(this.ptr).fontSize > 10
    pos([1 2]) = pos([1 2]) + 0.01 * (scopeObjects(this.ptr).fontSize - 10) * .5;
    pos([3 4]) = pos([3 4]) - 0.01 * (scopeObjects(this.ptr).fontSize - 10) * .5;
end
%TO070805D: Moved the pureDisplay option down here, since it takes
%precedence over all others.
if scopeObjects(this.ptr).pureDisplay
    pos = [0 0 1 1];
end
set(scopeObjects(this.ptr).axes, 'Position', pos);

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

% set(get(scopeObjects(this.ptr).axes, 'XLabel'), 'String', sprintf('%s [%s/div]', num2str(scopeObjects(this.ptr).xUnitsPerDiv), scopeObjects(this.ptr).xUnitsString));
% set(get(scopeObjects(this.ptr).axes, 'YLabel'), 'String', sprintf('%s [%s/div]', num2str(scopeObjects(this.ptr).yUnitsPerDiv), scopeObjects(this.ptr).yUnitsString));
set(get(scopeObjects(this.ptr).axes, 'XLabel'), 'String', sprintf('[%s]', scopeObjects(this.ptr).xUnitsString));
set(get(scopeObjects(this.ptr).axes, 'YLabel'), 'String', sprintf('[%s]', scopeObjects(this.ptr).yUnitsString));

set(scopeObjects(this.ptr).figure, 'HandleVisibility', 'Off');%TO121605A

set(scopeObjects(this.ptr).axes, 'YTickLabelMode', 'Auto', 'XTickLabelMode', 'Auto', 'XTickMode', 'Auto', 'YLimMode', 'Auto', 'YTickMode', 'Auto', 'YTickLabelMode', 'Auto');

% if scopeObjects(this.ptr).forceDraw
%     drawnow;
% end

%TO062705A - The listeners (ie. GUI) need updating now. - 6/27/05
for i = 1 : length(scopeObjects(this.ptr).setListeners)
    try
        switch lower(class(scopeObjects(this.ptr).setListeners{i}))
            case 'cell'
                callback = scopeObjects(this.ptr).setListeners{i};
                feval(callback{:}, {'yUnitsPerDiv', 'yOffset'});
                
            case 'char'
                eval(scopeObjects(this.ptr).setListeners{i})
                
            case 'function_handle'
                feval(scopeObjects(this.ptr).setListeners{i}, {'yUnitsPerDiv', 'yOffset'});
                
            otherwise
                warning('Failed to notify this scopeObject''s setListener: Invalid callback class: s', class(scopeObjects(this.ptr).setListeners{i}));
        end
    catch
        warning('Failed to notify this scopeObject''s setListener: %s', lasterr);
    end
end

return;