% pj_setPrograms - Set the hijackable program list.
%
% SYNTAX
%  pj_setPrograms(hObject, programHandles)
%    hObject - The program handle.
%    programHandles - An array of program handles, which must be able to be hijacked (they must support certain variables
%                     and behaviors, which are yet to be fully documented [as of 8/25/06]).
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 8/25/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function pj_setPrograms(hObject, programHandles)

if isempty(programHandles)
    channelList = {''};
end

hObjs = zeros(size(programHandles));
if iscell(programHandles)
    for i = 1 : length(programHandles)
        hObjs(i) = getLocal(progmanager, programHandles{i}, 'hObject');
    end
    programHandles = hObjs;
end

mappedProgramHandles = [];
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
                mappedProgramHandles(end + 1) = programHandles(i);
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
                mappedProgramHandles(end + 1) = programHandles(i);
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

setLocalGh(progmanager, hObject, 'currentChannel', 'String', channelList);
setLocalBatch(progmanager, hObject, 'programHandles', programHandles, 'currentChannel', channelList{1}, 'mappedProgramHandles', mappedProgramHandles);

return;