% SCOPEOBJECT/addData - Update a channel's displayed data.
%
% SYNTAX
%  addData(SCOPEOBJECT, channelName, data, sampleRate)
%
% USAGE
%  This object has a linked figure, which displays oscilloscope traces. The mutliple channels 
%  of data can be incrementally updated and display options vaguely emulating those of 
%  oscilloscopes are available.
%
% NOTES
%
% CHANGES
%  TO021805f: Track a separate min/max for each channel, for autoRanging. -- Tim O'Connor 2/18/05
%  TO060105A: Added the forceDraw option. -- Tim O'Connor 6/1/05
%  TO060205A: Fixed an off by one error in the total number of samples displayed. -- Tim O'Connor 6/2/05
%  TO062705E: Added the simpleAmplitudes option. -- Tim O'Connor 6/27/05 
%  TO070605G: Make sure a unit is always chosen, even if one can't be found in the "simpleAmplitudeSet". Use 0.001 in the case where none are found. -- Tim O'Connor 7/6/05
%  TO121405A: Make the scaling based on running averages. -- Tim O'Connor 12/14/05
%  TO121405B: Force data to be on the screen. The offset is based on the min, not the mean. -- Tim O'Connor 12/14/05
%  TO121405E - Redefined the offset to mean the midpoint of the scope (ie. if it's set to 0, the scope will be centered about 0). -- Tim O'Connor 12/14/05
%  TO121405F: Move the signal away from the center using 'autoRangeMaximizeDetail' to get the most out of the dynamic range. -- Tim O'Connor 12/14/05
%  TO121605A: Turn off all 'HandleVisibility' properties to keep the display from getting corrupted by people doing stupid things on the command line. -- Tim O'Connor 12/16/05
%  TO121605D: Yet another attempt to make the display behave as it's wanted, despite an utter inability by all involved to express what it is that they want. 
%             This time, the display will be centered on the midpoint of the signal. -- Tim O'Connor 12/16/05
%  TO121905A: Use @wave scaling. This carries over the scaling parameters from the @wave class. -- Tim O'Connor 12/19/05
%  JL080207A: Jinyang Liu  & Tim O'Connor 8/2/07 Added holdOn as a field, implemented functionality in addData.m.
%  JL081807A: Use Matlab built-in autoscale instead of Tim's autoscale algorithm. Tim's algorithm itself used Matlab built in autoscale.
%
% Created 1/24/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function addData(this, channelName, data, sampleRate, varargin)
global scopeObjects;
% fprintf(1, '@scopeObject/addData\n%s', getStackTraceString);
% fprintf(1, '%s - @scopeObject/addData\n', datestr(now));
% global addDataCounter
% if isempty(addDataCounter)
%     addDataCounter = 1;
% else
%     addDataCounter = addDataCounter + 1;
% end
% if addDataCounter > 200
%     fprintf(1, '@scopeObject/addData: Stopping acquisition...\n%s\n', getStackTraceString);
%     stop(daqfind);
% end
if scopeObjects(this.ptr).deleted
    warning('A deleted scope object has recieved inbound data.');
end

if ~ishandle(scopeObjects(this.ptr).figure)
    warning('Figure handle for this @scopeobject (''%s'') is missing/corrupted.', scopeObjects(this.ptr).name);
    return;
end

if length(varargin) == 3
    if ~ischar(varargin{1})
        error('Illegal arguments. First argument must be a string, in this syntax.');
    end
    
    sampleRate = varargin{1};
elseif length(varargin) > 4
    if ~ischar(varargin{1})
        error('Illegal arguments. First argument must be a string, in this syntax.');
    end
    if ~strcmpi(class(varargin{3}), 'analoginput')
        error('Illegal arguments. Third argument must be an analoginput object in this syntax.');
    end
    
    sampleRate = get(varargin{3}, 'SampleRate');
end

if ~ismember(lower(channelName), lower(scopeObjects(this.ptr).channels))
    error('Unknown channel ''%s''.', channelName);
end

if ~strcmpi(scopeObjects(this.ptr).visible, 'On')
    return;
end

index = findBindingRowIndex(this, channelName);
%Moved into the addChannel method. - 2/4/05 Tim O'Connor
% if index == -1
%     index = length(scopeObjects(this.ptr).bindings) + 1;
%     colorOrder = get(scopeObjects(this.ptr).axes, 'ColorOrder');
%     scopeObjects(this.ptr).bindings{index, 1} = channelName;
%     color = colorOrder(rem(index, size(colorOrder, 1)), :);
%     userData.offset = 0;
%     channel = line('XData', [], 'YData', [], 'ZData', [], 'Marker', scopeObjects(this.ptr).marker, ...
%         'LineStyle', scopeObjects(this.ptr).lineStyle, 'Parent', scopeObjects(this.ptr).axes, ...
%         'Tag', sprintf('%s::%s', scopeObjects(this.ptr).name, channelName), 'Color', color, 'UserData', userData);
%     scopeObjects(this.ptr).bindings{index, 2} = channel;
% else
%     channel = scopeObjects(this.ptr).bindings{index, 2};
% end
channel = scopeObjects(this.ptr).bindings{index, 2};

set(scopeObjects(this.ptr).figure, 'HandleVisibility', 'On');%TO121605A - Might need this on to access the plot's YData field.

userData = get(channel, 'UserData');
if isempty(userData)
    userData.offset = 0;
    userData.gain = 1;
    warning('No UserData found for channel ''%s''. Applying defaults.', channelName);
end

if userData.gain == 0
    userData.gain = 1;
    warning('Channel ''%s'' has a gain of 0. It has been forced to be 1.', channelName);
    set(channel, 'UserData', userData);
end

yData = get(channel, 'YData');
displayableSamples = ceil((scopeObjects(this.ptr).numberOfXDivs + 1) * scopeObjects(this.ptr).xUnitsPerDiv * sampleRate * (1 + scopeObjects(this.ptr).bufferFactor));

% fprintf(1, '@scopeObject/addData -\n displayableSamples: %s\n sampleRate: %s\n samples: %s\n---------\n', num2str(displayableSamples), num2str(sampleRate), num2str(length(data)));

if length(data) >= displayableSamples
    yData = userData.gain * data(max(1, length(data) - displayableSamples) : length(data)) + userData.offset;
elseif ~isempty(yData)
    %Does the dimension ever need to be changed (transpose?).
    [m dimY] = max(size(yData));
    [m dimD] = max(size(data));
    if dimD ~= dimY
        data = data';
    end

    offset = max(1, length(yData) - (displayableSamples - length(data))) + 1;%TO060205A
    yData = cat(dimY, yData(offset:end), userData.gain * data + userData.offset);
% fprintf(1, 'Trimming buffer to %s samples.\n', num2str(length(yData(offset:end))));
else
    yData = userData.gain * data + userData.offset;
end
% fprintf(1, '@scopeObject/addData -\n  min: %3.5f\n  max:%3.5f\n\n', min(data), max(data));

% JL081807A Commenting out the following operations to use the Matlab
% build-in autoscale 

%if scopeObjects(this.ptr).autoRange & ~isempty(yData) & ...
%        ((etime(clock, scopeObjects(this.ptr).autoRangeTime) > scopeObjects(this.ptr).autoRangeTimeLimit) | scopeObjects(this.ptr).autoRangeTime <= 0)
    %TO021805f, TO121405A
%     oldMean = mean(scopeObjects(this.ptr).min(index, :));%TO121605D
%    oldMean = scopeObjects(this.ptr).max(end) - scopeObjects(this.ptr).min(end);%TO121605D
%    oldYDivUnit = scopeObjects(this.ptr).yUnitsPerDiv;

%    if scopeObjects(this.ptr).autoRangeForceFit
%        scopeObjects(this.ptr).min(index, :) = min(yData);
%        mn = scopeObjects(this.ptr).min(end);
%        scopeObjects(this.ptr).max(index, :) = max(yData);
%        mx = scopeObjects(this.ptr).max(end);
%    elseif all(scopeObjects(this.ptr).min(index, :) == 0) & all(scopeObjects(this.ptr).max(index, :) == 0)
%        scopeObjects(this.ptr).min(index, :) = min(yData);
%        mn = scopeObjects(this.ptr).min(1);
%        scopeObjects(this.ptr).max(index, :) = max(yData);
%        mx = scopeObjects(this.ptr).max(1);
%    else
        %Min
%        scopeObjects(this.ptr).min(index, 1:end-1) = scopeObjects(this.ptr).min(index, 2:end);
%        scopeObjects(this.ptr).min(index, end) = min(yData);
%        mn = mean(scopeObjects(this.ptr).min(index, :));
%        if size(scopeObjects(this.ptr).min, 2) > 1
            %If the instantaneous change is too high, throw it away.
%            mn2 = mean(scopeObjects(this.ptr).min(index, 1:end-1));
%            if abs((mn - mn2) / mn2) > 2
%                mn = mn2;
%            end
%        end

        %Max
%        scopeObjects(this.ptr).max(index, 1:end-1) = scopeObjects(this.ptr).max(index, 2:end);
%        scopeObjects(this.ptr).max(index, end) = max(yData);
%        mx = mean(scopeObjects(this.ptr).max(index, :));
%        if size(scopeObjects(this.ptr).max, 2) > 1
            %If the instantaneous change is too high, throw it away.
%            mx2 = mean(scopeObjects(this.ptr).max(index, 1:end-1));
%            if abs((mx - mx2) / mx2) > 2
%                mx = mx2;
%            end
%        end
%    end

    %TO121605D
%     avg = mx - mn;
%    if all(scopeObjects(this.ptr).mean(index, :) == 0)
%        scopeObjects(this.ptr).mean(index, :) = mean(yData);
%        avg = scopeObjects(this.ptr).mean(1);
%    else
        %Mean
%        scopeObjects(this.ptr).mean(index, 1:end-1) = scopeObjects(this.ptr).mean(index, 2:end);
%        scopeObjects(this.ptr).mean(index, end) = mean(yData);
%        avg = mean(scopeObjects(this.ptr).mean(index, :));
%        if size(scopeObjects(this.ptr).mean, 2) > 1
            %If the instantaneous change is too high, throw it away.
%            avg2 = mean(scopeObjects(this.ptr).mean(index, 1:end-1));
% fprintf(1, 'avg: %3.3f\navg2: %3.3f\n', avg, avg2);
%            if avg2 ~= 0
%                if abs((avg - avg2) / avg2) > 0.5
                    % fprintf(1, 'Excessive mean change -\n    avg: %3.3f\n    avg2: %3.3f\n', avg, avg2);
%                    avg = avg2;
%                end
%            end
%        end
%    end

% fprintf(1, 'min: %3.3f\nmax: %3.3f\nmean: %3.3f\n\n', mn, mx, avg);
%    topEdge = scopeObjects(this.ptr).numberOfYDivs * scopeObjects(this.ptr).yUnitsPerDiv + scopeObjects(this.ptr).yOffset;
%    if mx > topEdge |  abs(mx - topEdge) > 2 * scopeObjects(this.ptr).yUnitsPerDiv | ...
%            mn < scopeObjects(this.ptr).yOffset | ...
%            abs(mn - scopeObjects(this.ptr).yOffset) > 2 * scopeObjects(this.ptr).yUnitsPerDiv
%        yRange = mx - mn;
%        divUnit = 1.2 * yRange / (scopeObjects(this.ptr).numberOfYDivs - 1);

        %TO062705E
%        if scopeObjects(this.ptr).simpleAmplitudes
            %TO070605G: Make sure a unit is always chosen, even if one can't be found in the "simpleAmplitudeSet". Use divUnit in the case where none are found.
%             scopeObjects(this.ptr).yUnitsPerDiv = min(scopeObjects(this.ptr).simpleAmplitudeSet(find(scopeObjects(this.ptr).simpleAmplitudeSet > divUnit)));
%            if divUnit < 0.1 * min(scopeObjects(this.ptr).simpleAmplitudeSet)
%                scopeObjects(this.ptr).yUnitsPerDiv = divUnit;
%            else
%                allowable = scopeObjects(this.ptr).simpleAmplitudeSet(find(scopeObjects(this.ptr).simpleAmplitudeSet >= divUnit));
%                distances = abs(allowable - divUnit);
%                nearest = min(distances);
%                unitIndex = find(distances == nearest);
%                if ~isempty(nearest)
%                    if scopeObjects(this.ptr).numberOfYDivs * allowable(unitIndex) > yRange
%                        scopeObjects(this.ptr).yUnitsPerDiv = allowable(unitIndex);
%                    else
%                        scopeObjects(this.ptr).yUnitsPerDiv = min(scopeObjects(this.ptr).simpleAmplitudeSet(find(scopeObjects(this.ptr).simpleAmplitudeSet ...
%                            > max(allowable))));
%                        if isempty(scopeObjects(this.ptr).yUnitsPerDiv)
%                            scopeObjects(this.ptr).yUnitsPerDiv = divUnit;
%                        end
%                    end
%                end
%            end

%            if divUnit > 1.1 * scopeObjects(this.ptr).numberOfYDivs * scopeObjects(this.ptr).yUnitsPerDiv
%                scopeObjects(this.ptr).yUnitsPerDiv = divUnit;
%            end
            %             scopeObjects(this.ptr).yUnitsPerDiv = min(scopeObjects(this.ptr).simpleAmplitudeSet(find(min(abs(scopeObjects(this.ptr).simpleAmplitudeSet - divUnit)))));
            %             if isempty(scopeObjects(this.ptr).yUnitsPerDiv)
            %                 scopeObjects(this.ptr).yUnitsPerDiv = divUnit;
            %             end
%        else
%            scopeObjects(this.ptr).yUnitsPerDiv = divUnit;
%        end
% fprintf(1, 'scopeObject/addData -\n Calculated divUnit: %3.3f\n Selected divUnit: %3.3f\n', divUnit, scopeObjects(this.ptr).yUnitsPerDiv);
        %TO121405B, TO121405E
        %TO121405F
%        scopeObjects(this.ptr).yOffset = mn + 0.5 * (mx - mn);
        
%        if scopeObjects(this.ptr).autoRangeCenterSignal
%            scopeObjects(this.ptr).yOffset = avg;% - 0.2 * (1 + scopeObjects(this.ptr).yUnitsPerDiv) * scopeObjects(this.ptr).numberOfYDivs;
%        else
%            scopeObjects(this.ptr).yOffset = mn + 0.5 * scopeObjects(this.ptr).yUnitsPerDiv * scopeObjects(this.ptr).numberOfYDivs;
%        end
        
        %TO121905A - Parameters taken from 'WaveFunctions/internal/rescaleAxis.m'.
%        if scopeObjects(this.ptr).autoRangeUseWaveScaling
%            range = mx - mn;
%            fudgedLims = [mn - 0.15 * range, mx + 0.15 * range];
%            scopeObjects(this.ptr).yOffset = mean(fudgedLims);
%            scopeObjects(this.ptr).yUnitsPerDiv = 1.3 * range / (1 + scopeObjects(this.ptr).numberOfYDivs);
% fprintf(1, 'scopeObject/addData - \n min: %3.3f\n max: %3.3f\n fudgedLims: [%s]\n yOffset: %3.3f\n yUnitsPerDiv: %3.3f\n', mn, mx, num2str(fudgedLims), ...
%     scopeObjects(this.ptr).yOffset, scopeObjects(this.ptr).yUnitsPerDiv);
            %minY-.05*(YRange) maxY+.15*(YRange)
%        end
%         scopeObjects(this.ptr).yOffset = mn - scopeObjects(this.ptr).yUnitsPerDiv;%(mx - mn) - (1 + scopeObjects(this.ptr).numberOfYDivs) * ...
%             scopeObjects(this.ptr).yUnitsPerDiv;
%         if scopeObjects(this.ptr).yOffset - (0.5 + scopeObjects(this.ptr).numberOfYDivs) < ...
%                 0.2 * scopeObjects(this.ptr).yUnitsPerDiv
%             scopeObjects(this.ptr).yOffset = (0.5 + scopeObjects(this.ptr).numberOfYDivs)* scopeObjects(this.ptr).yUnitsPerDiv;
%         end
%        if (abs(oldMean - avg) > 2 * divUnit) | (oldYDivUnit ~= scopeObjects(this.ptr).yUnitsPerDiv) | scopeObjects(this.ptr).autoRangeForceFit | ...
%                scopeObjects(this.ptr).autoRangeUseWaveScaling
%            updateScaling(this);
%        end

%         set(this, 'yUnitsPerDiv', divUnit, 'yOffset',  mn - 0.5 * divUnit);
%        scopeObjects(this.ptr).autoRangeTime = clock;
%    end
%end

%TO062705D - An experimental optimization, to avoid regenerating the xData, if it's at all avoidable.
xData = get(channel, 'XData');
if length(xData) ~= length(yData)
    xData = scopeObjects(this.ptr).xOffset : 1 / sampleRate : scopeObjects(this.ptr).xOffset + length(yData) / sampleRate - 1 / sampleRate;
end

set(scopeObjects(this.ptr).figure, 'HandleVisibility', 'On');%TO121605A - `updateScaling` would have turned this off.

%JL080207A
if ~scopeObjects(this.ptr).holdOn
    set(channel, 'XData', xData, 'YData', yData);
else
    scopeObjects(this.ptr).heldLines(end + 1) = copyobj(channel, get(channel, 'Parent'));
    %set(scopeObjects(this.ptr).heldLines(end), 'LineStyle', ':');%Make dotted.
    set(scopeObjects(this.ptr).heldLines(end), 'Color', max([0.01, 0.01, 0.01], get(scopeObjects(this.ptr).heldLines(end), 'Color') - 0.4));
    set(channel, 'XData', xData, 'YData', yData);
    scopeObjects(this.ptr).bindings{index, 2} = copyobj(channel, get(channel, 'Parent'));
    delete(channel);
end

% figure, plot(yData), title('Scope')
set(scopeObjects(this.ptr).figure, 'HandleVisibility', 'Off');%TO121605A

%TO060105A
if scopeObjects(this.ptr).forceDraw
    drawnow;
end

return;