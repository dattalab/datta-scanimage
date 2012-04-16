% xsg_getStreamingFileHandle - Get a valid handle for logging data for the specified channel.
%
%  SYNTAX
%   fHandle = xsg_getStreamingFileHandle(channelName)
%
%  CHANGES
%
%  NOTES
%   See TO021510E.
%
% Created 2/15/10 - Tim O'Connor
% Copyright - Northwestern University/Howard Hughes Medical Institute 2010
function fHandle = xsg_getStreamingFileHandle(channelName)

hObject = xsg_getHandle;
[fileHandleMap, xsgFileFormatVersion, streamToDisk, autosave] = getLocalBatch(progmanager, hObject, 'fileHandleMap', 'xsgFileFormatVersion', 'streamToDisk', 'autosave');

if ~autosave
    fHandle = [];
    return;
end
idx = find(strcmpi({fileHandleMap{:, 1}}, channelName));

if isempty(idx)
    fileHandleMap{size(fileHandleMap, 1) + 1, 1} = channelName;
    filename = xsg_getFilename;
    headerFilename = [filename '.xsghdr'];
    dataFilename = [filename '_' channelName '.xsglog'];
    fileHandleMap{end, 3} = dataFilename;
    fHandle = fopen(fileHandleMap{end, 3}, 'a');
    fileHandleMap{end, 2} = fHandle;
    setLocal(progmanager, hObject, 'fileHandleMap', fileHandleMap)

    if ~exist(headerFilename, 'file')
        setLocal(progmanager, hObject, 'status', 'Gathering headers...');
        header = getHeaders(progmanager);
        %TO043008E
        xsgFileCreationTimestamp = datestr(now);
        header.xsgFileFormatVersion = xsgFileFormatVersion;
        header.xsgFileCreationTimestamp = xsgFileCreationTimestamp;
        header.xsgOriginalFilename = filename;
        header.xsg.xsg.xsgFileFormatVersion = xsgFileFormatVersion;
        header.xsg.xsg.xsgFileCreationTimestamp = xsgFileCreationTimestamp;
        header.xsg.xsg.xsgOriginalFilename = filename;
        header.xsg.xsg.streamToDisk = streamToDisk;
        header.xsg.xsg.streamedFiles = {fileHandleMap{:, 3}};
        data = ['See' filename '_*.xsglog'];
        saveCompatible(headerFilename, 'header', 'data');%TO071906D %TO043008E
        setLocal(progmanager, hObject, 'status', '');
    end
else
    fHandle = fileHandleMap{idx, 2};
end

return;