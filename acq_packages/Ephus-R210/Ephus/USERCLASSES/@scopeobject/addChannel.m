% SCOPEOBJECT/addChannel - Add an allowed channel, for data to be added.
%
% SYNTAX
%  addChannel(SCOPEOBJECT, channelName)
%    SCOPEOBJECT - This object instance.
%    channelName - The name of the channel to be added to the scope display.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO021805f: Track a separate min/max for each channel, for autoRanging. -- Tim O'Connor 2/18/05
%  TO121405A: Make the scaling based on running averages. -- Tim O'Connor 12/14/05
%
% Created 2/3/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function addChannel(this, channelName)
global scopeObjects;

if ~ismember(lower(channelName), lower(scopeObjects(this.ptr).channels))
    scopeObjects(this.ptr).channels{length(scopeObjects(this.ptr).channels) + 1} = channelName;

    index = size(scopeObjects(this.ptr).bindings, 1) + 1;
    colorOrder = get(scopeObjects(this.ptr).axes, 'ColorOrder');
    scopeObjects(this.ptr).bindings{index, 1} = channelName;
    color = colorOrder(rem(index, size(colorOrder, 1)), :);
    userData.offset = 0;
    userData.gain = 1;
    userData.visible = 1;
    channel = line('XData', [], 'YData', [], 'ZData', [], 'Marker', scopeObjects(this.ptr).marker, ...
        'LineStyle', scopeObjects(this.ptr).lineStyle, 'Parent', scopeObjects(this.ptr).axes, ...
        'Tag', sprintf('%s::%s', scopeObjects(this.ptr).name, channelName), 'Color', color,...
        'UserData', userData);

    scopeObjects(this.ptr).bindings{index, 2} = channel;
    scopeObjects(this.ptr).min(index, :) = 0;%TO021805f, TO121405A
    scopeObjects(this.ptr).max(index, :) = 0;%TO021805f, TO121405A
    scopeObjects(this.ptr).mean(index, :) = 0;%TO021805f, TO121405A
else
    warning('Channel already exists: ''%s''.', channelName);
end

for i = 1 : length(scopeObjects(this.ptr).addChannelListeners)
    try
        switch lower(class(scopeObjects(this.ptr).addChannelListeners{i}))
            case 'cell'
                callback = scopeObjects(this.ptr).addChannelListeners{i};
                feval(callback{:});
                
            case 'char'
                eval(scopeObjects(this.ptr).addChannelListeners{i})
                
            case 'function_handle'
                feval(scopeObjects(this.ptr).addChannelListeners{i});
                
            otherwise
                warning('Failed to notify this scopeObject''s addChannelListeners: Invalid callback class: %s', class(scopeObjects(this.ptr).addChannelListeners{i}));
        end
    catch
        warning('Failed to notify this scopeObject''s addChannelListeners: %s', lasterr);
    end
end

%Add context menu
ccmenu=uicontextmenu('parent',scopeObjects(this.ptr).figure);
set(channel,'UIContextMenu',ccmenu);
eh1 = uimenu(ccmenu,'Label','Change color','callback',{@cChannelColor,this, channelName});

    
    function cChannelColor(hObject,evetdata,this, channelName)
        global scopeObjects;
        index = findBindingRowIndex(this, channelName);
        channel = scopeObjects(this.ptr).bindings{index, 2};
        currentColor=get(channel,'color');
        ccolor = uisetcolor(currentColor,'Pick a color');
        set(channel,'color',ccolor);