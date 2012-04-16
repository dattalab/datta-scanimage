% SCOPEOBJECT - An oscilloscope object.
%
% SYNTAX
%  sc = scopeObject
%
% USAGE
%  This object has a linked figure, which displays oscilloscope traces. The mutliple channels 
%  of data can be incrementally updated and display options vaguely emulating those of 
%  oscilloscopes are available.
%
% STRUCTURE
%   name - An identifying string.
%   figure - The associated display figure.
%   axes - The associated display axes.
%   readOnlyFields - A list of fields that can not be changed through the set method.
%   bindings - The line objects, representing each input channel.
%   horizontalCenterLine - A line designating the center of the vertical axis (which may not correspond with a gridline).
%   verticalCenterLine - A line designating the center of the horizontal axis (which may not correspond with a gridline).
%   groundLine - A line designating the "ground" (the 0 value) on the vertical axis.
%
%   xRange - The dynamic range of the x-axis.
%   xOffset - The offset of the x-axis.
%   numberOfXDivs - The number of divisions along the x-axis.
%   xUnitsPerDiv - The time fraction per division, in seconds.
%   xUnitsString - The label for the x units.
%
%   yRange - The dynamic range of the y-axis.
%   yOffset - The offset of the y-axis. This value now rigidly defines the centerpoint of the y-axis (TO121405E).
%   numberOfYDivs - The number of divisions along the y-axis.
%   yUnitsPerDiv - The voltage (or mapped unit) fraction per division, in seconds.
%   yUnitsString - The label for the y units.
%   autoRange - Automatically set the range, based on the inbound data. Default: 1
%   min - Used for computing bounds when autoRange is enabled (a running min of all data). TO121405 - This is now a 2D array.
%   max - Used for computing bounds when autoRange is enabled (a running max of all data). TO121405 - This is now a 2D array.
%   max - Used for computing bounds when autoRange is enabled (a running average of the mean of the data). TO121405
%   autoRangeTime - Used to make sure the autoRange function doesn't run too often on highly variant data.
%   autoRangeTimeLimit - Minimum number of seconds between autoRanging events. Default: 0.6
%   autoRangeForceFit - Force all data to be on the screen at any given time. Default: 1 %TO121405B
%   autoRangeCenterSignal - Attempts to center the signal on the axes at the expense of the dynamic range of the display. Default: 1 %TO121405F
%   autoRangeUseWaveScaling - This carries over the scaling parameters from the @wave class. It overrides all other scaling parameters. Default: 0 %TO121905A
%   simpleAmplitudes - Choose the amplitude, when autoranging, from the following set: {1, 2, 5} * {10^-3, 10^-2, 10^-1, 1, 10, 10^2, 10^3}
%   flexibleYTicks - Allows auto-ranging to change the Y tick marks/labels for optimal display. This invalidates the numberOfYDivs value on 
%                    the display, but not in calculations. Default: 1
%
%   resizeEnabled - Allow the display settings to automatically changed if the window is resized too much. Default: 1
%   pureDisplay - Only show the scope data, no axis labels or legends. Default: 0
%   declaredPureDisplay - Used for when the resizeFcn automatically changes the setting, so it can be returned to the user-defined value.
%   gridOn - Show major gridlines. Default: 1
%   declaredGridOn - Used for when the resizeFcn automatically changes the
%   setting, so it can be returned to the user-defined value.
%   displayCenterLines - Show lines (crosshairs) designating the vertical and horizontal centers of the display.
%   lineStyle - The style of the line for every channel.
%   marker - The marker type for every channel.
%   markerSize - The size of the marker, in points.
%   showXTickLabels - Determines whether tick labels are shown on the x axis.
%   showYTickLabels - Determines whether tick labels are shown on the y axis.
%   backgroundColor - The background color for the scope.
%   foregroundColor - The foreground color for the scope. It is applied to all labels, gridlines, etc.
%   fontSize - The font size for all text on the scope display.
%   fontWeight - The font weight for all text on the scope display.
%   visible - The visibility of this scope display.
%   displayOptions - This is an internal use only variable, that allows for an optimization in the `set` method.
%   holdOn - Flag to force retention of previous traces on the image. Default: 0
%   heldLines - Old traces retained if holdOn is set.
%
%   bufferFactor - Amount of data, which falls outside the available display space to retain (for side scrolling).
%   setListeners - A list of callbacks to be executed when the 'set' method is called.
%   addChannelListeners - A list of callbacks to be executed when the 'addChannel' method is called.
%
%   amplifier - An amplifier object, from which to pick up display settings (only one amplifier per scope).
%
%   creationTime - Timestamp of instance creation.
%   saveTime - Time of last instance save.
%   loadTime - Time of last instace load.
%
%   forceDraw - Call `drawnow` at the end of the `addData` method. Turn this off to boost performance, but lose refresh rate.
%
%   hautoscale - Toolbar button on the gui, to adjust autoRange.
%   hholdon - Toolbar button on the gui, to adjust holdOn.
%   hverticalscale - Toolbar button on the gui, to input new Y range.
%
% NOTES
%
% CHANGES
%  Tim O'Connor 3/4/05 TO030405d: Implemented save/load functionality.
%  Tim O'Connor 4/20/05 TO042005A: Added the displayOptions optimization.
%  Tim O'Connor 6/1/05 TO060105A: Added the forceDraw option.
%  Tim O'Connor 6/27/05 TO062705E: Added the simpleAmplitudes option.
%  Tim O'Connor 7/8/05 TO070805C: Added scopeObjectResizeFcn.
%  Tim O'Connor 7/11/05 TO071105B: Added flexibleYTicks.
%  Tim O'Connor 12/14/05 TO121405A: Make the scaling based on running averages.
%  Tim O'Connor 12/14/05 TO121405B: Force data to be on the screen when autoscaling with 'autoRangeForceFit'. This will still try to ignore undesirable, noisy transients.
%  Tim O'Connor 12/14/05 TO121405E: Redefined the offset to mean the midpoint of the scope (ie. if it's set to 0, the scope will be centered about 0).
%  Tim O'Connor 12/14/05 TO121405F: Center the axes on the mean of the signal using 'autoRangeCenterSignal' which may not get the most out of the dynamic range. Default: 1
%  Tim O'Connor 12/16/05 TO121605A: Turn off all 'HandleVisibility' properties to keep the display from getting corrupted by people doing stupid things on the command line.
%  Tim O'Connor 12/19/05 TO121905A: Use @wave scaling. This carries over the scaling parameters from the @wave class.
%  Jinyang Liu  07/20/2007 JL072007A: Added the toolbar toogle button Autosale and callback functions freeze & autoscale
%  Jinyang Liu  07/20/2007 JL072007B: Added the toolbar push button Setscale and callback function setscale 
%  Jinyang Liu  07/20/2007 JL072007C: Added the toolbar toggle button HoldonScope and callback functions holdon & holdoff
%  Jinyang Liu  07/21/2007 JL072107A: Change the figure render from painter to OpenGL
%  Jinyang Liu  & Tim O'Connor 8/2/07 JL080207A: Added holdOn as a field, implemented functionality in addData.m. Assorted UI tweaks.
%  Tim O'Connor 8/15/07 TO081507B - The handles must all exist before calling any methods.
%  Jinyang Liu 09/17/2007 JL091707A comment this out because it caused some troubles
%  Vijay Iyer 01/08/2008 VI010808: Add 'name' property to the list of displayOptions, so figure title can be properly updated
%
% Created 1/24/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = scopeObject(varargin)
global scopeObjects;

if length(varargin) == 1
    if isnumeric(varargin{1})
        this.ptr = varargin{1};
    else
        error('Invalid argument to constructor.');
    end
end

if isempty(scopeObjects) & length(varargin) ~= 1
    this.ptr = 1;
else
    this.ptr = length(scopeObjects) + 1;
end

scopeObjects(this.ptr).name = sprintf('Scope%s', num2str(this.ptr));
scopeObjects(this.ptr).figure = figure('Color', [1 1 1], 'Name', scopeObjects(this.ptr).name, 'NumberTitle', 'Off', 'DoubleBuffer', 'On', ...
    'IntegerHandle', 'Off', 'Tag', scopeObjects(this.ptr).name, 'Units', 'Pixels', 'HandleVisibility', 'On','render','OpenGL');%TO121605A
    %JL072107A
scopeObjects(this.ptr).axes = axes('Parent', scopeObjects(this.ptr).figure);

set(scopeObjects(this.ptr).axes, 'Position',[0.11 0.11 0.87 0.85]); %JL080607

colorOrder = get(scopeObjects(this.ptr).axes, 'ColorOrder');
colorOrder = [1 1 1; 1 0.25 0.25; colorOrder];
set(scopeObjects(this.ptr).axes, 'ColorOrder', colorOrder);
scopeObjects(this.ptr).readOnlyFields = {'fig', 'axes', 'channels', 'readOnlyFields', 'xRange', 'yRange', 'min', 'max', 'displayOptions', 'mean', 'hautoscale', 'hholdon', 'hverticalscale'};%JL080207A
scopeObjects(this.ptr).bindings = {};
scopeObjects(this.ptr).horizontalCenterLine = line('XData', [], 'YData', [], 'Color', [0 0 0], 'LineStyle', '-.', 'Marker', 'd', ...
    'Visible', 'Off', 'Tag', 'scope_horizontalCenterLine', 'Parent', scopeObjects(this.ptr).axes);
scopeObjects(this.ptr).verticalCenterLine = line('XData', [], 'YData', [], 'Color', [0 0 0], 'LineStyle', '-.', 'Marker', 'd', ...
    'Visible', 'Off', 'Tag', 'scope_verticalCenterLine', 'Parent', scopeObjects(this.ptr).axes);
scopeObjects(this.ptr).groundLine = line('Color', [0 .5 0], 'LineStyle', '-.', 'Marker', 'None', ...
    'LineWidth', 2, 'Tag', 'scope_groundLine', 'Parent', scopeObjects(this.ptr).axes,'visible','off');
scopeObjects(this.ptr).channels = {};

scopeObjects(this.ptr).xOffset = 0;%TO121405E
scopeObjects(this.ptr).numberOfXDivs = 9;
scopeObjects(this.ptr).xUnitsPerDiv = .1;
scopeObjects(this.ptr).xRange = scopeObjects(this.ptr).xUnitsPerDiv * (1 + scopeObjects(this.ptr).numberOfXDivs);
scopeObjects(this.ptr).xUnitsString = 'Seconds';

scopeObjects(this.ptr).yOffset = -5;
scopeObjects(this.ptr).numberOfYDivs = 11;
scopeObjects(this.ptr).yUnitsPerDiv = 1;
scopeObjects(this.ptr).yRange = scopeObjects(this.ptr).yUnitsPerDiv * (1 + scopeObjects(this.ptr).numberOfYDivs);
scopeObjects(this.ptr).yUnitsString = 'Volts';
scopeObjects(this.ptr).autoRange = logical(1);
scopeObjects(this.ptr).min = zeros(1, 1);%TO121405A
scopeObjects(this.ptr).max = zeros(1, 1);%TO121405A
scopeObjects(this.ptr).autoRangeTime = clock;
scopeObjects(this.ptr).autoRangeTimeLimit = 0.6;%Seconds
scopeObjects(this.ptr).autoRangeForceFit = 1;%TO121405B
scopeObjects(this.ptr).autoRangeCenterSignal = 1;%TO121405F
scopeObjects(this.ptr).autoRangeUseWaveScaling = 0;%TO121905A
scopeObjects(this.ptr).simpleAmplitudes = 1;
scopeObjects(this.ptr).simpleAmplitudeSet = [0.001 0.002 0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 2000 5000];
scopeObjects(this.ptr).flexibleYTicks = 1;

scopeObjects(this.ptr).resizeEnabled = 1;
scopeObjects(this.ptr).pureDisplay = 0;
scopeObjects(this.ptr).gridOn = 0;
scopeObjects(this.ptr).declaredPureDisplay = 0;
scopeObjects(this.ptr).declaredGridOn = 0;
scopeObjects(this.ptr).displayCenterLines = 0;
scopeObjects(this.ptr).lineStyle = '-';
scopeObjects(this.ptr).marker = 'None';
scopeObjects(this.ptr).markerSize = 1;
scopeObjects(this.ptr).showXTickLabels = 1;
scopeObjects(this.ptr).showYTickLabels = 1;
scopeObjects(this.ptr).backgroundColor = [0 0 0];%[.01 .2 .01] - Pale green.
scopeObjects(this.ptr).foregroundColor = [.15 .9 .15];
scopeObjects(this.ptr).fontSize = 10;
scopeObjects(this.ptr).fontWeight = 'normal';
scopeObjects(this.ptr).visible = 'On';

%This allows an optimization, by not updating the display options for every call to the `set` method. TO042005A 
scopeObjects(this.ptr).displayOptions = lower({'xOffset', 'numberOfXDivs', 'xUnitsPerDiv', 'xRange', 'xUnitsString', 'yOffset', ...
        'numberOfYDivs', 'yUnitsPerDiv', 'yRange', 'yUnitsString', 'pureDisplay', 'gridOn', 'displayCenterLines', ...
        'lineStyle', 'marker', 'markerSize', 'showXTickLabels', 'showYTickLabels', 'backgroundColor', ...
        'foregroundColor', 'fontSize', 'fontWeight', 'visible', 'name'}); %vi011208

scopeObjects(this.ptr).bufferFactor = 0;

scopeObjects(this.ptr).deleted = 0;
scopeObjects(this.ptr).setListeners = {};
scopeObjects(this.ptr).addChannelListeners = {};

scopeObjects(this.ptr).amplifier = [];

%JL080207A
scopeObjects(this.ptr).heldLines = [];
scopeObjects(this.ptr).holdOn = 0;

%TO030405d
scopeObjects(this.ptr).creationTime = clock;
scopeObjects(this.ptr).saveTime = -1;
scopeObjects(this.ptr).loadTime = -1;
this.serialized = [];

%TO060105A
scopeObjects(this.ptr).forceDraw = 1;

%TO121405A
scopeObjects(this.ptr).mean = zeros(1, 1);

this = class(this, 'scopeObject');

%Add context menu
cmenu=uicontextmenu('parent',scopeObjects(this.ptr).figure);
set(scopeObjects(this.ptr).axes,'UIContextMenu',cmenu);
eh1 = uimenu(cmenu,'Label','Change color');
seh1 = uimenu(eh1,'Label','Background','callback',{@cbackColor,this});
seh2 = uimenu(eh1,'Label','Foreground','callback',{@cforeColor,this});

eh2 = uimenu(cmenu,'Label','Display Options');
seh3 = uimenu(eh2,'Label','X Labels','checked','on','callback',{@sXLabel,this});
seh4 = uimenu(eh2,'Label','Y Labels','checked','on','callback',{@sYLabel,this});
seh4 = uimenu(eh2,'Label','Grid Lines','checked','off','callback',{@sGridLines,this});
seh4 = uimenu(eh2,'Label','Ground Line','checked','off','callback',{@sGroundLine,this});

eh3= uimenu(cmenu,'Label','Clear Data','callback',{@clearScreen,this});


 %Add toolbar buttons
tbh=findall(scopeObjects(this.ptr).figure,'type','uitoolbar');

icon1=load('autoscale.mat');
icon2=load('setscale.mat');
icon3=load('holdon.mat');

iAutoscale=struct2cell(icon1);
iSetScale=struct2cell(icon2);
iHoldOn=struct2cell(icon3);

% JL072007A
scopeObjects(this.ptr).hautoscale=uitoggletool(tbh,'CData',iAutoscale{1},...
    'TooltipString','Autoscale',...
    'Separator','on',...
    'HandleVisibility','off',...
    'State','On',...
    'ClickedCallback', {@autoscale,this}); 

% JL072007B
scopeObjects(this.ptr).hverticalscale=uipushtool(tbh,'CData',iSetScale{1}, 'Separator','off',...
    'TooltipString','Input vertial scale',...
    'HandleVisibility','off',...
    'ClickedCallback',{@inputScale,this});

% JL072007C
scopeObjects(this.ptr).hholdon=uitoggletool(tbh,'CData',iHoldOn{1},...
    'TooltipString','Holdon Scope',...
    'Separator','off',...
    'HandleVisibility','off',...
    'OnCallback',{@holdOn,this},...
    'OffCallback',{@holdOn,this});%JL080207A

%TO081507B - The handles must all exist before calling any methods. -- Tim O'Connor 8/15/07
%JL080207A - ButtonDownFcn toggles autoscaling.
set(scopeObjects(this.ptr).figure, 'CloseRequestFcn', {@delete, this}, 'ResizeFcn', {@scopeObjectResizeFcn, this});

%JL091707A comment this out because it caused some troubles
%set(scopeObjects(this.ptr).axes,'ButtonDownFcn', {@autoscale,this}); 
if length(varargin) > 1
    set(this, varargin{:});
end
updateDisplayOptions(this);

return;

      
    function autoscale(hObject, eventdata,this)
      global scopeObjects;
%      if  ~strcmpi(get(scopeObjects(this.ptr).figure,'SelectionType'),'alt')
          set(this,'autoRange',~scopeObjects(this.ptr).autoRange);
          if ~scopeObjects(this.ptr).autoRange
             set(scopeObjects(this.ptr).hautoscale, 'state','off');
             set(scopeObjects(this.ptr).axes,'xLimMode','manual','YLimMode','manual');
          else
              set(scopeObjects(this.ptr).hautoscale,'state','on');
              set(scopeObjects(this.ptr).axes,'xLimMode','auto','YLimMode','auto');
          end
          
%      end

    function inputScale(hObject, eventdata,this)
        global scopeObjects;
        scopeObjects(this.ptr).autoRange=0;
        set(scopeObjects(this.ptr).axes,'YLimMode','manual');
        prompt={'Enter Minimum Y value:','Enter Maximum Y Value'};
        set(scopeObjects(this.ptr).hautoscale,'state','off');
        dlg_title='Input Vertical Scale';
        num_lines=1;
        yLim = get(scopeObjects(this.ptr).axes, 'YLim');
        def={num2str(yLim(1)), num2str(yLim(2))};
        yscale=inputdlg(prompt, dlg_title, num_lines, def);
        if isempty(yscale)
            yscale=def;
        end
        if isempty(str2num(yscale{1}))|isempty(str2num(yscale{2}))
            errordlg('Please input a numerical value for min and Max');
            return;
        end

        min=str2num(yscale{1});
        max=str2num(yscale{2});

        if min>=max
            errordlg('Minimum Y value should be smaller than the maximum Y value!');
            return;
        end
        yLim=[min max];
        set(scopeObjects(this.ptr).axes, 'YLim', yLim);

    function holdOn(hObject,eventdata,this)
        global scopeObjects;
        scopeObjects(this.ptr).holdOn = ~scopeObjects(this.ptr).holdOn;
        if ~scopeObjects(this.ptr).holdOn
            if ~isempty(scopeObjects(this.ptr).heldLines)
                delete(scopeObjects(this.ptr).heldLines);
                scopeObjects(this.ptr).heldLines = [];
            end
        end
        
    function cbackColor(hObject,evetdata,this)
        global scopeObjects;
        currentColor=get(this, 'backgroundColor');
        bcolor=uisetcolor(currentColor,'Pick a color');
        set(this,'backgroundColor',bcolor);
        
    function cforeColor(hobject, eventdata, this)
        global scopeObjects;
        currentColor=get(this, 'foregroundColor');
        fcolor=uisetcolor(currentColor,'Pick a color');
        set(this,'foregroundColor',fcolor);
        
    function sXLabel(hobject,eventdata, this)
        global scopeObjects;
        if strcmpi(get(hobject,'checked'),'on')
            set(hobject,'checked','off');
            pos=get(scopeObjects(this.ptr).axes, 'Position');
            pos(2)=0.03;
            pos(4)=0.95;
            set(scopeObjects(this.ptr).axes, 'Position',pos);
            set(this,'showXTickLabels',0);
        else
            set(hobject,'checked','on');
            pos=get(scopeObjects(this.ptr).axes, 'Position');
            pos(2)=0.11;
            pos(4)=0.85;
            set(scopeObjects(this.ptr).axes, 'Position',pos);
            set(this,'showXTickLabels',1);
        end
        
        
    function sYLabel(hobject,eventdata, this)
        global scopeObjects;
        if strcmpi(get(hobject,'checked'),'on')
            set(hobject,'checked','off');
            pos=get(scopeObjects(this.ptr).axes, 'Position');
            pos(1)=0.03;
            pos(3)=0.95;
            set(scopeObjects(this.ptr).axes, 'Position',pos);
            set(this,'showYTickLabels',0);
        else
            set(hobject,'checked','on');
            set(this,'showYTickLabels',1);
            pos=get(scopeObjects(this.ptr).axes, 'Position');
            pos(1)=0.11;
            pos(3)=0.87;
            set(scopeObjects(this.ptr).axes, 'Position',pos);
        end
        
    function sGridLines(hobject,eventdata, this)
        global scopeObjects;
        if strcmpi(get(hobject,'checked'),'on')
            set(hobject,'checked','off');
            set(this,'gridOn',0);
        else
            set(hobject,'checked','on');
            set(this,'gridOn','1');
        end
        
    function sGroundLine(hobject,eventdata, this)
        global scopeObjects;
        if strcmpi(get(hobject,'checked'),'on')
            set(hobject,'checked','off');
            set(scopeObjects(this.ptr).groundLine,'visible','off');
            updateDisplayOptions(this);
        else
            set(hobject,'checked','on');
            set(scopeObjects(this.ptr).groundLine,'visible','on');
            updateDisplayOptions(this);
        end
        
    function clearScreen(hobject,eventdata,this)
        global scopeObjects;
        clearData(this);

