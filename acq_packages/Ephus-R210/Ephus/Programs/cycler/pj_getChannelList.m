% pj_getChannelList - Probe other programs for the channel list.
%
% SYNTAX
%  channelList = pj_getChannelList(hObject)
%    hObject - The program handle.
%    channelList - 
%
% USAGE
%
% NOTES
%  See TO040710D.
%
% CHANGES
%
% Created 4/7/10 Timothy O'Connor
% Copyright - Northwestern University/Howard Hughes Medical Institute 2010
function channelList = pj_getChannelList(hObject)

[programHandles] = getLocalBatch(progmanager, hObject, 'programHandles');

channelList = {};
for i = 1 : length(programHandles)
    programName = getProgramName(progmanager, programHandles(i));
    if strcmpi(programName, 'ephys')
        try
            amplifiers = get(getLocalGh(progmanager, programHandles(i), 'amplifierList'), 'String');
            if ischar(amplifiers)
                amplifiers = {amplifiers};
            end
            for j = 1 : length(amplifiers)
                channelList{end + 1} = ['ephys:' amplifiers{j} '-VCom'];
            end
        catch
            %Do nothing.
            warning(lasterr);
        end
    elseif strcmpi(programName, 'stimulator')
        try
            channels = get(getLocalGh(progmanager, programHandles(i), 'channelList'), 'String');
            if ischar(channels)
                channels = {channels};
            end
            for j = 1 : length(channels)
                channelList{end + 1} = ['stimulator:' channels{j}];
            end
        catch
            %Do nothing.
            warning(lasterr);
        end
    elseif strcmpi(programName, 'acquirer')
        %Do nothing.
    else
        warning('pulseJacker: Unsupported program - ''%s''', programName);
    end
end

if isempty(channelList)
    channelList = {''};
end

return;