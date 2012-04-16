function acq_addChannels(hObject, varargin)
% function acq_addChannels(hObject, varargin)
% acq_addChannels - Adds (appends) channels to the acquirer program
%
% SYNTAX
%  acq_addChannels(hObject, channels)
%  acq_addChannels(hObject, channelNames, boardIDs, chanIDs)
%  acq_addChannels(hObject, channelProps1,channelProps2...)
%   
%    hObject - A program or graphics handle associated with the acquirer program
%    channels - A structure array of channel parameters to add to acquirer. Structure has fields 'channelName','boardID', and 'channelID'
%    channelNames -- A string or cell of strings containing channel name(s) to add to acquirer
%    boardIDs -- An array of integer values specifying board IDs of channels to add to acquirer
%    chanIDs -- An array of integer values specifying channel IDs of channels to add to acquirer
%    channelProps# -- One or more cell arrays consisting of 3 elements specifying channelName(string) and boardID/chanID(integer-valued numerics)  of channel(s) to be added
%
%   Example:
%           acq_addChannels(acqObj,{'firstChan' 'secondChan'},[1 1],[0 0])
%           acq_addChannels(acqObj,{'firstChan' 1 0},{'secondChan' 1 1}) adds two channels on board1, channelIDs 0&1
%
%% NOTES
%
%   This is effectively a public acquirer 'method'
%
%% CHANGES
%   VI021810A: Replaced stim_getAllOutputChannelNames with acq_getInputChannelNames. Apparent copy/paste error. -- Vijay Iyer 2/18/10
%
%% CREDITS
% Created 6/2/08 Vijay Iyer
% Janelia Farm Research Campus/Howard Hughes Medical Institute 
%% ************************************************************************

if length(varargin) == 1 && isstruct(varargin{1}) %structure input
    newChannelStruct = varargin{1};
elseif iscellstr(varargin{1}) || ischar(varargin{1})
    if ischar(varargin{1})
        newChannelStruct.channelName = varargin{1};
    elseif iscellstr(varargin{1})
        for i=1:length(varargin{1})
            newChannelStruct(i).channelName = varargin{1}{i};
        end
    end

    if ~isnumeric(varargin{2}) || ~isnumeric(varargin{2})
        error('boardIDs and chanIDs must be numeric arrays');
    elseif length(varargin{2}) ~= length(newChannelStruct) || length(varargin{3}) ~= length(newChannelStruct)
        error('The number of boardIDs and/or chanIDs specified did not match the number of channelNames provided');
    elseif any(round(varargin{2})~= varargin{2}) || any(round(varargin{3})~= varargin{3})
        error('boardIDs and chanIDs must be numeric arrays of integer values');
    else
        for i=1:length(newChannelStruct)
            newChannelStruct(i).boardID = varargin{2}(i);
            newChannelStruct(i).channelID = varargin{3}(i);
        end
    end        
elseif iscell(varargin{1})
    
    %Verify input type
    for i=1:length(varargin)
        if ~iscell(varargin{i}) || length(varargin{i})~=3 || ~ischar(varargin{i}{1}) || ~isnumeric(varargin{i}{2}) || ~isnumeric(varargin{i}{3})...
                || round(varargin{i}{2}) ~= varargin{i}{2} || round(varargin{i}{3}) ~= varargin{i}{3}
            error('If not a single structure, then all arguments must be a 3 element cell array consisting of a channelName, boardID, and chanID');
        end
    end
    
    for i=1:length(varargin)
        newChannelStruct(i).channelName = varargin{i}{1};              
        newChannelStruct(i).boardID = varargin{i}{2};
        newChannelStruct(i).channelID = varargin{i}{3};
    end
            
else
    error('Unrecognized input argument format');
end

channelNames = acq_getInputChannelNames(hObject); %VI021810A
if ~isempty(channelNames)
    for i=1:length(channelNames)
        %[boardID chanID] = getDeviceNameByChannelName(daqjob('acquisition'),channelNames{i});
        devName = getDeviceNameByChannelName(daqjob('acquisition'),channelNames{i});
        [boardID chanOrPortID lineID] = getPhysicalChannelIDs(daqjob('acquisition'),devName);

        channels(i).channelName = channelNames{i};
        channels(i).boardID = boardID;
        channels(i).channelID = chanID;
    end
    channels = [channels newChannelStruct];
else
    channels = newChannelStruct;
end

%Update the stimulator channels
acq_setChannels(hObject,channels); %while a bit wasteful, this is smart enough not to re-create channels
