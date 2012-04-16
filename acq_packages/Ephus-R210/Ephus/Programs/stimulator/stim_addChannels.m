% function stim_addChannels(hObject, varargin)
% stim_addChannels - Adds (appends) channels to the stimulator program
%
% SYNTAX
%  stim_addChannels(hObject, channels)
%  stim_addChannels(hObject, channelNames, boardIDs, chanIDs)
%  stim_addChannels(hObject, channelNames, boardIDs, portIDs, lineIDs)
%  stim_addChannels(hObject, channelProps1, channelProps2...)
%    hObject - A program or graphics handle associated with the stimulator program
%    channels - A structure array of channel parameters to add to stimulator. Structure has fields 'channelName','boardID', and 'channelID'
%    channelNames -- A string or cell of strings containing channel name(s) to add to stimulator
%    boardIDs -- An array of integer values specifying board IDs of channels to add to stimulator
%    chanIDs -- An array of integer values specifying channel IDs of channels to add to stimulator
%    portIDs -- An array of integer values specifiying port IDs of digital channels to add to stimulator
%    lineIDs -- An array of integer values specifiying line IDs of digital channels to add to stimulator
%    channelProps# -- One or more cell arrays consisting of 3 or 4 elements specifying channelName(string), boardID, and either chanID (analog) or portID/lineID (digital) of channel(s) to be added 
%
%   Example:
%           stim_addChannels(stimObj,{'firstChan' 'secondChan'},[1 1],[0 0])
%           stim_addChannels(stimObj,{'firstChan' 1 0},{'secondChan' 1 1}) adds two channels on board1, channelIDs 0&1
%           stim_addChannels(stimObj,{'firstChan' 1 0'},{'digChan' 2 1 0},{'secondChan' 1 1}) adds two analog channels on board 1 (channel IDs 0&1) and one digital channel on board 2 (port 1/line 0)
%
% NOTES
%   I believe these calls have to be all done before anything occurs to set the pulseSetNameArray or pulseNameArray to anything but empty (i.e. beofre loading a configuration)  -- Vijay Iyer 6/2/08
%
%   This is effectively a public stimulator 'method'
%
% CHANGES
%   VI061008A -- Handle digital stimulator channel case -- Vijay Iyer 6/10/2008
%
% CREDITS
% Created 6/2/08 Vijay Iyer
% Janelia Farm Research Campus/Howard Hughes Medical Institute
function stim_addChannels(hObject, varargin)

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
    
    %Argument error checking
    if nargin == 4 
        analog = true;
        paramArrays = varargin(2:3);
    elseif nargin == 5
        analog = false;
        paramArrays = varargin(2:4);
    else
        error('There must be either 4 or 5 arguments when inputting channel info as parameter arrays');
    end
    
    for i=1:length(paramArrays)
        if ~isnumeric(paramArrays{i}) || ~isvector(paramArrays{i})
            error('Parameter arrays (boardID,chanID,portID,lineID) must be numeric vectors');
        elseif length(paramArrays{i})~=length(newChannelStruct)
            error('Length of parameter arrays (boardID,chanID,portID,lineID) must match the number of channelNames provided');
        elseif round(paramArrays{i}) ~= paramArrays{i}
            error('Parameter arrays (boardID,chanID,portID,lineID) must contain integer values');
        end                               
    end
    %%%
    
    %Fill the channel struct
    for i=1:length(newChannelStruct)
        newChannelStruct(i).boardID = varargin{2}(i);
        if nargin==4 %analog channels
            newChannelStruct(i).channelID = varargin{3}(i);
            newChannelStruct(i).portID = [];
            newChannelStruct(i).lineID = [];
        elseif nargin == 5
            newChannelStruct(i).channelID = [];
            newChannelStruct(i).portID = varargin{3}(i);
            newChannelStruct(i).lineID = varargin{4}(i);
        end        
    end

elseif iscell(varargin{1})
    
    %Argument error checking
    for i=1:length(varargin)
        argErrorMsg = 'If not a single structure, then all arguments must be a 3 or 4 element cell array consisting of a channelName, boardID, and chanID (analog) or portID/lineID (digital)';
        if ~iscell(varargin{i}) || (length(varargin{i})~=3 && length(varargin{i})~=4) || ~ischar(varargin{i}{1})
            error(argErrorMsg);
        end        
           
        for j=2:length(varargin{i})
            if ~isnumeric(varargin{i}{j}) || round(varargin{i}{j}) ~= varargin{i}{j}
                error(argErrorMsg);
            end                          
        end        

    end
    
    %Fill the channel struct
    for i=1:length(varargin)
        newChannelStruct(i).channelName = varargin{i}{1}; 
        newChannelStruct(i).boardID = varargin{i}{2};
        if length(varargin{i}) == 3
            newChannelStruct(i).channelID = varargin{i}{3};
            newChannelStruct(i).portID = [];
            newChannelStruct(i).lineID = [];
        else
            newChannelStruct(i).channelID = [];
            newChannelStruct(i).portID = varargin{i}{3};
            newChannelStruct(i).lineID = varargin{i}{4};
        end
    end
            
else
    error('Unrecognized input argument format');
end

channelNames = stim_getAllOutputChannelNames(hObject);
if ~isempty(channelNames)
    for i=1:length(channelNames)
        devName = getDeviceNameByChannelName(daqjob('acquisition'),channelNames{i});         
        [boardID chanOrPortID lineID] = getPhysicalChannelIDs(daqjob('acquisition'),devName);

        channels(i).channelName = channelNames{i};
        channels(i).boardID = boardID;
        
        if isnan(lineID)
            channels(i).channelID = chanOrPortID;
            channels(i).portID = [];
            channels(i).lineID = [];
        else
            channels(i).channelID = [];
            channels(i).portID = chanOrPortID;
            channels(i).lineID = lineID;
        end
            
    end
    channels = [channels newChannelStruct];
else
    channels = newChannelStruct;
end

%Update the stimulator channels
stim_setChannels(hObject, channels); %while a bit wasteful, this is smart enough not to re-create channels

