% makeGraphicsObjectMutable - Allow graphics objects to be moved/changed using the mouse.
%
% SYNTAX
%  makeGraphicsObjectMutable(hObject)
%  makeGraphicsObjectMutable(hObject, PropertyName, ProperyValue)
%    hObject - The handle to the graphics object to become mutable.
%
% PROPERTIES
%    callback - A function_handle, cell array (with a function_handle as the first element), or a string
%               to be executed after completion of a mutation event.
%               If callback is empty, it is ignored.
%    lockToAxes - Set to 1 to lock the axes or 0 to leave them free. Locked axes forces all changes in the object to stay within
%               the current axes limits, and will not allow them to automatically stretch. The object can not be moved/stretched
%               outside the current axes boundaries when lockToAxes is true.
%               Default: 0
%    lockX - Prevent motion/stretching in the X direction, setting this property to 1 enables it, while 0 disables it.
%            Default: 0
%    lockY - Prevent motion/stretching in the Y direction, setting this property to 1 enables it, while 0 disables it.
%            Default: 0
%    blockDrag - Do not allow dragging (left click functionality) of the object. Setting this property to 1 enables it, while 0 disables it.
%            Default: 0
%    blockStretch - Do not allow stretching (right click functionality) of the object. Setting this property to 1 enables it, while 0 disables it.
%            Default: 0
%    blockRectangleInversion - Do not allow rectangles to flip over. Setting this property to 1 enables it, while 0 disables it.
%            Default: 0
%
% USAGE
%  Once this function has been called on a graphics object it may then be manipulated using the mouse.
%  - A left click allows the user to drag the object around its current axes.
%  - A right click allows the user to "stretch" the object, which has different meanings, depending on the type of object:
%    'rectangle' - Do a "traditional" resize, by dragging the corner closest to the mouse at the click event.
%    'line' - Drag the closest vertex (datapoint) to the mouse at the click event, the connections to adjacent datapoints are maintained.
%
% NOTES
%   This function will coopt the object's 'ButtonDownFcn', and overwrite any values already there.
%
%   The 'ButtonDownFcn' and 'WindowButtonDownFcn' settings are disabled
%   during mutation to prevent mutation collisions (one must finish before the next can start).
%
%   Only 2D lines and rectangles are currently supported. More objects may be added later.
%
% EXAMPLE
%  % The following will create a figure with a line and rectangle object, with pseudo-callbacks, in order to play around.
%  % Recommending fiddling includes toggling the lockToAxes, lockX, and lockY properties.
%  f = figure;
%  r = rectangle('Position', [8 8 8 8], 'Tag', 'r');
%  l = line('XData', [1 5 9 12], 'YData', [3 6 21 35], 'Marker', 'o', 'Tag', 'l');
%  c = rectangle('Position', [2 20 5 5], 'Tag', 'c', 'Curvature', [1 1]);
%  makeGraphicsObjectMutable(r, 'Callback', 'disp(''RECTANGLE_MOVE_COMPLETE'')', 'lockToAxes', 1);
%  makeGraphicsObjectMutable(l, 'Callback', 'disp(''LINE_MOVE_COMPLETE'')', 'lockToAxes', 0);
%  makeGraphicsObjectMutable(c, 'Callback', 'disp(''CIRCLE_MOVE_COMPLETE'')', 'lockToAxes', 1);
%
% TODO (as of 2/19/05)
%  - Add support for patch objects.
%  - Fix "hopping" on rectangle inversion during stretching (hint: don't change coordinates 1 or 2 when about to invert).
%
% CHANGES
%  Tim O'Connor 3/3/05 - TO030305a: Fixed feval of cell array callback, it was missing the {:} expansion.
%  Tim O'Connor 3/4/05 - TO030405a: Select multiple vertices for closed polygonal lines.
%  Tim O'Connor 3/4/05 - TO030405b: Add a distinct tag to the glyph, 'makeGraphicsObjectMutableGlyph'.
%  Tim O'Connor 3/4/05 - TO030405c: Added the blockDrag, blockStretch, and blockRectangleInversion options.
%  Tim O'Connor 6/6/05 - TO060605A: Carry color information into the glyph, this may help contrast in some cases.
%  Tim O'Connor 8/31/06 - TO083106a: Corrected case in switch statement for property decoding in argument list
%  Tim O'Connor 7/07/07 - TO071807A: Make sure the HandleVisibility is On to allow glyph drawing. Do not rely on gcf/gca even though they should be fine.
%  
% Created - Tim O'Connor 2/19/05
% Copyright - Timothy O'Connor 2005
function makeGraphicsObjectMutable(hObject, varargin)

callback = [];
options.lockToAxes = 0;
options.lockX = 0;
options.lockY = 0;
options.blockDrag = 0;%TO030405c
options.blockStretch = 0;%TO030405c
options.blockRectangleInversion = 0;%TO030405c
if mod(length(varargin), 2) ~= 0
    error('Properties must come in name-value pairs.');
end
for i = 1 : 2 : length(varargin)
    switch lower(varargin{i})
        case 'callback'
            callback = varargin{i + 1};
        case 'locktoaxes'
            options.lockToAxes = varargin{i + 1};
        case 'lockx'
            options.lockX = varargin{i + 1};
        case 'locky'
            options.lockY = varargin{i + 1};
        case 'blockdrag' %TO083106a
            options.blockDrag = varargin{i + 1};%TO030405c
        case 'blockstretch' %TO083106a
            options.blockStretch = varargin{i + 1};%TO030405c
        case 'blockrectangleinversion'
            error('NOT_YET_IMPLEMENTED');
            options.blockRectangleInversion = varargin{i + 1};%TO030405c
        otherwise
            error('Unrecognized property name: %s', varargin{i});
    end
end

if options.lockX & options.lockY
    error('Both X and Y motion have been locked, leaving no legal mutations.');
end

switch lower(class(callback))
    case 'function_handle'
        
    case 'cell'
        if ~isempty(callback)
            if ~strcmpi(class(callback{1}), 'function_handle')
                error('Cell array callbacks must have a function_handle as the first element: %s', class(callback{1}));
            end
        end
        
    case 'double'
        if ~isempty(callback)
            error('Callbacks may not be numbers.');
        end
        
    case 'char'
        
    otherwise
        error('Invalid callback class: %s', class(callback));
end

set(hObject, 'ButtonDownFcn', {@executeGraphicsObjectMutation, callback, options});

return;

%------------------------------------------------
function executeGraphicsObjectMutation(hObject, eventdata, callback, options)

f = getParent(hObject, 'figure');
a = getParent(hObject, 'axes');

%TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
figureHandleVisibility = get(f, 'HandleVisibility');
axesHandleVisibility = get(a, 'HandleVisibility');
set(f, 'HandleVisibility', 'On');
set(a, 'HandleVisibility', 'On');

%Get the current location of the mouse.
currentPosition = get(a, 'currentPoint');
currentPosition = currentPosition(1, 1:2);%Only consider the (X, Y, 0) plane.

%Create the appropriate glyph.
switch lower(get(hObject, 'Type'))
    case 'rectangle'
        pos = get(hObject, 'Position');
        color = get(hObject, 'EdgeColor');%TO060605A
        nObject = rectangle('Position', pos, 'LineStyle', ':', 'EdgeColor', color, 'Curvature', get(hObject, 'Curvature'), 'Tag', 'makeGraphicsObjectMutableGlyph', 'Parent', a);%TO030405b %TO071807A
        %Find the vertex with the smallest Euclidean distance from the mouseclick, that's the one to be moved.
        vertex = findRectangleVertex(hObject);

    case 'line'
        if ~isempty(get(hObject, 'ZData'))
            error('Mutation of 3D lines is not currently supported.');
        end
        xData = get(hObject, 'XData');
        yData = get(hObject, 'YData');
        color = get(hObject, 'Color');%TO060605A
        nObject = line('XData', xData, 'YData', yData, 'LineStyle', ':', 'Color', color, 'Tag', 'makeGraphicsObjectMutableGlyph', 'Parent', a);%TO030405b %TO071807A
        %Find the datapoint with the smallest Euclidean distance from the mouseclick, that's the one to be moved.
        %Select multiple vertices for closed polygonal lines. TO030405a - Tim O'Connor 3/4/05
        distances = sqrt((currentPosition(1) - xData).^2 + (currentPosition(2) - yData).^2);
        mn = min(distances);%TO030405a - The min function only finds the first occurrence of a minima.
        vertex = find(distances == mn);%TO030405a - So, do a search for all matching points.
        
    otherwise
        %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
        set(a, 'HandleVisibility', axesHandleVisibility);
        set(f, 'HandleVisibility', figureHandleVisibility);
        error('Unsupported graphics object type for dragging.');
end

%Choose the appropriate mutation function.
switch lower(get(f, 'SelectionType'))
    case 'normal'
        %Drag
        if options.blockDrag
            %TO030405c - New Option. -- Tim O'Connor 3/4/05
            delete(nObject);
            %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
            set(a, 'HandleVisibility', axesHandleVisibility);
            set(f, 'HandleVisibility', figureHandleVisibility);
            return;
        end
        motionFcn = {@dragUpdate, nObject, currentPosition, options};
        
    otherwise
        %Stretch
        if options.blockStretch
            %TO030405c - New Option. -- Tim O'Connor 3/4/05
            delete(nObject);
            %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
            set(a, 'HandleVisibility', axesHandleVisibility);
            set(f, 'HandleVisibility', figureHandleVisibility);
            return;
        end
        motionFcn = {@stretchUpdate, nObject, currentPosition, options, vertex};
end

axesButtonDownFcn = get(a, 'ButtonDownFcn');
objectButtonDownFcn = get(hObject, 'ButtonDownFcn');
windowButtonDownFcn = get(f, 'WindowButtonDownFcn');
windowButtonMotionFcn = get(f, 'WindowButtonMotionFcn');
windowButtonUpFcn_ = get(f, 'WindowButtonUpFcn');
doubleBuffer = get(f, 'DoubleBuffer');

%All this will get passed into the completion function ('WindowButtonUpFcn') to restore the original properties.
%To complete the mutation the original handle, the glyph handle, and the callback are required.
finishFcn = {@windowButtonUpFcn, hObject, nObject, callback, objectButtonDownFcn, axesButtonDownFcn, windowButtonMotionFcn, windowButtonUpFcn_, windowButtonDownFcn, doubleBuffer};

%Set up to track the motion.
set(a, 'ButtonDownFcn', finishFcn);
set(f, 'WindowButtonMotionFcn', motionFcn, 'DoubleBuffer', 'On', ...
            'WindowButtonUpFcn', finishFcn, 'WindowButtonDownFcn', finishFcn);

%TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
set(a, 'HandleVisibility', axesHandleVisibility);
set(f, 'HandleVisibility', figureHandleVisibility);

return;


%------------------------------------------------
%Update the glyph position.
function dragUpdate(figHandle, eventdata, nObject, lastPosition, options)

%gcf and gca should be well defined in this case, since we're working under a mouse click.
%TO071807A - In Matlab R2007a, gcf and gca screw things up, because Matlab is retarded.
% f = gcf;
% a = gca;
f = figHandle;
%TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
figureHandleVisibility = get(f, 'HandleVisibility');
set(f, 'HandleVisibility', 'On');
a = getParent(nObject, 'axes');
axesHandleVisibility = get(a, 'HandleVisibility');
set(a, 'HandleVisibility', 'On');

currentPosition = get(a, 'CurrentPoint');
if isempty(currentPosition)
    %No initial click --> This function shouldn't have been called.
    resolveErroneousWindowButtonMotionFcn(f, 'dragUpdate');
    %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
    set(a, 'HandleVisibility', axesHandleVisibility);
    set(f, 'HandleVisibility', figureHandleVisibility);
    return;
end
currentPosition = currentPosition(1, 1:2);%Only consider the (X, Y, 0) plane.

delta = currentPosition - lastPosition;
if options.lockX
    delta(1) = 0;
end
if options.lockY
    delta(2) = 0;
end

switch lower(get(nObject, 'Type'))
    case 'rectangle'
        pos = get(nObject, 'Position');
        pos(1:2) = pos(1:2) + delta;
        if options.lockToAxes
            xLim = get(a, 'XLim');
            yLim = get(a, 'YLim');
            if pos(1) + pos(3) > xLim(2)
                pos(1) = xLim(2) - pos(3);
            elseif pos(1) < xLim(1)
                pos(1) = xLim(1);
            end
            if pos(2) + pos(4) > yLim(2)
                pos(2) = yLim(2) - pos(4);
            elseif pos(2) < yLim(1)
                pos(2) = yLim(1);
            end            
        end
        set(nObject, 'Position', pos);
        
    case 'line'
        xData = get(nObject, 'XData') + delta(1);
        yData = get(nObject, 'YData') + delta(2);
        if options.lockToAxes
            xLim = get(a, 'XLim');
            yLim = get(a, 'YLim');
            if any(xData < xLim(1)) | any(xData > xLim(2))
                %This move is blocked by the axes limits.
                xData = get(nObject, 'XData');
            end
            if any(yData < yLim(1)) | any(yData > yLim(2))
                %This move is blocked by the axes limits.
                yData = get(nObject, 'YData');
            end
            xData(find(xData < xLim(1))) = xLim(1);
            xData(find(xData > xLim(2))) = xLim(2);
            yData(find(yData < yLim(1))) = xLim(1);
            yData(find(yData > yLim(2))) = xLim(2);
        end
        set(nObject, 'XData', xData);
        set(nObject, 'YData', yData);

    otherwise
        %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
        set(a, 'HandleVisibility', axesHandleVisibility);
        set(f, 'HandleVisibility', figureHandleVisibility);
        error('Unsupported type for dragging: %s', get(nObject, 'Type'));
end

%Update the 'lastPosition' variable in the callback.
set(f, 'WindowButtonMotionFcn', {@dragUpdate, nObject, currentPosition, options});

drawnow;

%TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
set(a, 'HandleVisibility', axesHandleVisibility);
set(f, 'HandleVisibility', figureHandleVisibility);

return;

%------------------------------------------------
% Update the glyph position.
%
% NOTES
%  This function has a tendency to cause "hops" when the rectangle gets "inverted".
%  It's unclear, at this moment, how to resolve this. -- Tim O'Connor 2/19/05
function stretchUpdate(figHandle, eventdata, nObject, lastPosition, options, vertex)

%gcf and gca should be well defined in this case, since we're working under a mouse click.
%TO071807A - In Matlab R2007a, gcf and gca screw things up, because Matlab is retarded.
% f = gcf;
% a = gca;
f = figHandle;
%TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
figureHandleVisibility = get(f, 'HandleVisibility');
set(f, 'HandleVisibility', 'On');
a = getParent(nObject, 'axes');
axesHandleVisibility = get(a, 'HandleVisibility');
set(a, 'HandleVisibility', 'On');

currentPosition = get(a, 'currentPoint');
if isempty(currentPosition)
    % No initial click --> This function shouldn't have been called.
    resolveErroneousWindowButtonMotionFcn(f, 'stretchUpdate');
    %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
    set(a, 'HandleVisibility', axesHandleVisibility);
    set(f, 'HandleVisibility', figureHandleVisibility);
    return;
end
currentPosition = currentPosition(1, 1:2);%Only consider the (X, Y, 0) plane.

delta = currentPosition - lastPosition;
if options.lockX
    delta(1) = 0;
end
if options.lockY
    delta(2) = 0;
end

type = lower(get(nObject, 'Type'));
if options.blockRectangleInversion & strcmp(type, 'rectangle')
    pos = get(nObject, 'Position');
    switch vertex
        case 1
            if delta(1) == pos(3) | delta(2) == pos(4)
                %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
                set(a, 'HandleVisibility', axesHandleVisibility);
                set(f, 'HandleVisibility', figureHandleVisibility);
                return;
            end
        case 2
            if delta(1) == -pos(3) | delta(2) == pos(4)
                %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
                set(a, 'HandleVisibility', axesHandleVisibility);
                set(f, 'HandleVisibility', figureHandleVisibility);
                return;
            end
        case 3
            if delta(1) == pos(3) | delta(2) == -pos(4)
                %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
                set(a, 'HandleVisibility', axesHandleVisibility);
                set(f, 'HandleVisibility', figureHandleVisibility);
                return;
            end
        case 4
            if delta(1) == -pos(3) | delta(2) == -pos(4)
                %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
                set(a, 'HandleVisibility', axesHandleVisibility);
                set(f, 'HandleVisibility', figureHandleVisibility);
                return;
            end
    end
end

switch type
    case 'rectangle'
        pos = get(nObject, 'Position');
        switch vertex
            case 1
                pos(1) = pos(1) + delta(1);
                pos(2) = pos(2) + delta(2);
                pos(3) = pos(3) - delta(1);
                pos(4) = pos(4) - delta(2);
            case 2
                pos(2) = pos(2) + delta(2);
                pos(3) = pos(3) + delta(1);
                pos(4) = pos(4) - delta(2);
            case 3
                pos(1) = pos(1) + delta(1);
                pos(3) = pos(3) - delta(1);
                pos(4) = pos(4) + delta(2);
            case 4
                pos(3) = pos(3) + delta(1);
                pos(4) = pos(4) + delta(2);
            otherwise
                %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
                set(a, 'HandleVisibility', axesHandleVisibility);
                set(f, 'HandleVisibility', figureHandleVisibility);
                error('Illegal rectangle vertex: %s', num2str(vertex));
        end
        if options.lockToAxes
            xLim = get(a, 'XLim');
            yLim = get(a, 'YLim');
            if pos(1) + pos(3) > xLim(2)
                pos(1) = xLim(2) - pos(3);
            elseif pos(1) < xLim(1)
                pos(1) = xLim(1);
            end
            if pos(2) + pos(4) > yLim(2)
                pos(2) = yLim(2) - pos(4);
            elseif pos(2) < yLim(1)
                pos(2) = yLim(1);
            end            
        end
        
        if pos(3) == 0
            %This is an illegal state, let them keep moving, or take the previous value.
            %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
            set(a, 'HandleVisibility', axesHandleVisibility);
            set(f, 'HandleVisibility', figureHandleVisibility);
            return;
        elseif pos(3) < 0
            pos(1) = pos(1) - pos(3);
            pos(3) = abs(pos(3));
            switch vertex
                case 1
                   vertex = 2;
                case 2
                    vertex = 1;
                case 3
                    vertex = 4;
                case 4
                    vertex = 3;
            end
        end
        if pos(4) == 0
            %This is an illegal state, let them keep moving, or take the previous value.
            %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
            set(a, 'HandleVisibility', axesHandleVisibility);
            set(f, 'HandleVisibility', figureHandleVisibility);
            return;
        elseif pos(4) < 0
            pos(2) = pos(2) - pos(4);
            pos(4) = abs(pos(4));
            switch vertex
                case 1
                   vertex = 3;
                case 2
                    vertex = 4;
                case 3
                    vertex = 1;
                case 4
                    vertex = 2;
            end
            
        end
        set(nObject, 'Position', pos);
        
    case 'line'
        xData = get(nObject, 'XData');
        xData(vertex) = xData(vertex) + delta(1);
        yData = get(nObject, 'YData');
        yData(vertex) = yData(vertex) + delta(2);
        if options.lockToAxes
            xLim = get(a, 'XLim');
            yLim = get(a, 'YLim');
            xData(find(xData < xLim(1))) = xLim(1);
            xData(find(xData > xLim(2))) = xLim(2);
            yData(find(yData < yLim(1))) = xLim(1);
            yData(find(yData > yLim(2))) = xLim(2);
        end
        set(nObject, 'XData', xData, 'YData', yData);

    otherwise
        %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
        set(a, 'HandleVisibility', axesHandleVisibility);
        set(f, 'HandleVisibility', figureHandleVisibility);
        error('Unsupported type for dragging: %s', get(nObject, 'Type'));
end

%Update the 'lastPosition' variable in the callback.
set(f, 'WindowButtonMotionFcn', {@stretchUpdate, nObject, currentPosition, options, vertex});

drawnow;

%TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
set(a, 'HandleVisibility', axesHandleVisibility);
set(f, 'HandleVisibility', figureHandleVisibility);

return;

%------------------------------------------------
% Reset the figure/axes properties to their initial values.
% Adjust the original object to match the glyph.
% Execute any necessary notifications (callbacks).
function windowButtonUpFcn(figHandle, eventdata, hObject, nObject, callback, objectButtonDownFcn, axesButtonDownFcn, windowButtonMotionFcn, windowButtonUpFcn, windowButtonDownFcn, doubleBuffer)

%TO071807A - In Matlab R2007a, gcf and gca screw things up, because Matlab is retarded.
% f = gcf;
% a = gca;
f = figHandle;
%TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
figureHandleVisibility = get(f, 'HandleVisibility');
set(f, 'HandleVisibility', 'On');
a = getParent(nObject, 'axes');
axesHandleVisibility = get(a, 'HandleVisibility');
set(a, 'HandleVisibility', 'On');

%Revert to the original settings.
set(hObject, 'ButtonDownFcn', objectButtonDownFcn);
set(a, 'ButtonDownFcn', axesButtonDownFcn);
set(f, 'WindowButtonMotionFcn', windowButtonMotionFcn, 'DoubleBuffer', doubleBuffer, ...
            'WindowButtonUpFcn', windowButtonUpFcn, 'WindowButtonDownFcn', windowButtonDownFcn);

switch lower(get(nObject, 'Type'))
    case 'rectangle'
        set(hObject, 'Position', get(nObject, 'Position'));
        
    case 'line'
        set(hObject, 'XData', get(nObject, 'XData'));
        set(hObject, 'YData', get(nObject, 'YData'));

    otherwise
        %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
        set(a, 'HandleVisibility', axesHandleVisibility);
        set(f, 'HandleVisibility', figureHandleVisibility);
        error('Unsupported type for dragging: %s', get(nObject, 'Type'));
end

delete(nObject);

if ~isempty(callback)
    switch lower(class(callback))
        case 'function_handle'
            feval(callback);
            
        case 'cell'
            if ~strcmpi(class(callback{1}), 'function_handle')
                error('Cell array callbacks must have a function_handle as the first element: %s', class(callback{1}));
            end
            %TO030305a - Fixed feval of cell array callback, it was missing the {:} expansion. - Tim O'Connor 3/3/05
            feval(callback{:});
            
        case 'char'
            eval(callback);
            
        otherwise
            %TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
            set(a, 'HandleVisibility', axesHandleVisibility);
            set(f, 'HandleVisibility', figureHandleVisibility);
            error('Invalid callback class: %s', class(callback));
    end
end

%TO071807A - Make sure the HandleVisibility is On to allow glyph drawing.
set(a, 'HandleVisibility', axesHandleVisibility);
set(f, 'HandleVisibility', figureHandleVisibility);

return;

%------------------------------------------------
%Watch out for broken operations, if there's no CurrentPoint defined, nothing should be dragging.
%Verify that the proper WindowButtonUpFcn is defined and, if so, execute it.
%If things are still not fixed, at least remove the WindowButtonMotionFcn.
%Issue an appropriate warning.
function resolveErroneousWindowButtonMotionFcn(f, functionName)

resolved = 0;
corrupted = 0;

windowButtonUpFcn = get(f, 'WindowButtonUpFcn');

if strcmpi(class(windowButtonUpFcn), 'cell')
    if ~isempty(windowButtonUpFcn)
        if strcmpi(class(windowButtonUpFcn{1}), 'function_handle')
            if strcmpi(func2str(windowButtonUpFcn{1}), 'windowButtonUpFcn')
                try
                    feval(windowButtonUpFcn);
                    resolved = 1;
                catch
                    warning('The WindowButtonUpFcn for the current figure ''%s'' has encountered an error: %s', num2str(f), lasterr);
                end
            end
        end
    end
end

windowButtonMotionFcn = get(f, 'WindowButtonMotionFcn');
if ~isempty(windowButtonMotionFcn)
    if strcmpi(class(windowButtonUpFcn), 'cell')
        if ~isempty(windowButtonUpFcn)
            if strcmpi(class(windowButtonUpFcn{1}), 'function_handle')
                if strcmpi(func2str(windowButtonUpFcn{1}), functionName)
                    %Hmm, still not cleaned up.
                    set(f, 'WindowButtonMotionFcn', '');
                    resolved = 1;
                    corrupted = 1;
                end
            end
        end
    end
end

if resolved
    if ~corrupted
        warning('The WindowButtonMotionFcn for the current figure ''%s'' has been unexpectedly executed.\nThis problem may have been automatically resolved.');
    else
        warning('The WindowButtonMotionFcn for the current figure ''%s'' has been unexpectedly executed.\nThis problem may have been automatically resolved.\nThe figure''s properties may be corrupted.');
    end
else
    warning('The WindowButtonMotionFcn for the current figure ''%s'' has been unexpectedly executed.');
end

return;

%------------------------------------------------
function vertex = findRectangleVertex(hObject)

%Get the current location of the mouse.
currentPosition = get(gca, 'currentPoint');
currentPosition = currentPosition(1, 1:2);%Only consider the (X, Y, 0) plane.

pos = get(hObject, 'Position');

%Find the vertex with the smallest Euclidean distance from the mouseclick, that's the one to be moved.
x = sqrt((currentPosition(1) - [pos(1) pos(1)+pos(3)]).^2);
y = sqrt((currentPosition(2) - [pos(2) pos(2)+pos(4)]).^2);
verticesDistances = [x(1)+y(1) x(2)+y(1) x(1)+y(2) x(2)+y(2)];
[mn vertex] = min(verticesDistances);

return;