% xsg_saveData - Save the previously acquired data to a given file.
%
% SYNTAX
%  xsg_saveData
%  xsg_saveData(filename)
%   filename - A user specified filename, anywhere on the filesystem. Formatting rules do not apply.
%
% USAGE
%
% NOTES
%  When called with no arguments this increments the acquisition number, and may only be called once per start of the 'acquisition' @startmanager object.
%  See TO123005F (in experimentSavingGui.m).
%  With the port to Nimex, the above statement applies, but now it relies on @daqjob instead of @startmanager.
%
% CHANGES
%  TO010506D - Enabling/disabling of UserFcn callbacks is handled by the callbackManager object directly. -- Tim O'Connor 1/5/06
%  TO012606B - Implemented the expectedDataSourceList variable. -- Tim O'Connor 1/26/06
%  TO012706A - Push the call to flush input data into the xsg. -- Tim O'Connor 1/27/06
%  TO012706B - Push the tracking of application's being completed into the @startmanager.
%  TO040706G - @daqmanager/flushInputChannel has been deprecated. See TO033106D. -- Tim O'Connor 4/7/06
%  TO040706I - Make xsg more convenient. -- Tim O'Connor 4/7/06
%  TO071906D - Make sure `save` makes Matlab v6 compatible files. -- Tim O'Connor 7/19/06
%  TO082907A - Insert a note upon saving data. -- Tim O'Connor 8/29/07
%  TO082907B - Confirm overwrite once for a given directory. -- Tim O'Connor 8/29/07
%  TO101007G - General debugging for the port to nimex.  -- Tim O'Connor 10/10/07
%  TO113007B - Fixed a stupid copy&paste error, where all the conditions were using `ischar`. -- Tim O'Connor 11/30/07
%  TO043008E - Add a file format version and timestamp when writing files. -- Tim O'Connor 4/30/08
%  TO021510F - Implemented disk streaming. -- Tim O'Connor 2/15/10
%  TO031010O - Fixed the previously inverted call to fullfile(file, path), when manually selecting a save location after a conflict. GS031010_REMOTE_DEBUG_SESSION -- Tim O'Connor 3/10/10
%
% Created 12/30/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function xsg_saveData(varargin)
% fprintf(1, '%s - xsg_saveData\n%s', datestr(now), getStackTraceString);
hObject = xsg_getHandle;
fname = '';

if isempty(varargin)
    if ~xsg_getAutosave
        % fprintf(1, '%s - xsg_saveData: AUTOSAVE_OFF\n', datestr(now));
        return;
    end
%     %TO012606B
%     if isempty(expectedDataSourceList)
% % fprintf(1, '%s - xsg_saveData: DATATSOURCES_REMAIN\n', datestr(now));
%         return;
%     endF
    fname = [xsg_getFilename '.xsg'];
else
    %TO101007G - General debugging for the port to nimex. The 'done' event passes the names of the channels, so we have to filter for that here. 
    %            The event listener was registered with hObject as the argument, so that can be the cue. -- Tim O'Connor 10/10/07
    if ~ishandle(varargin{1})
        fname = varargin{1};
    else
        if ~xsg_getAutosave
            % fprintf(1, '%s - xsg_saveData: AUTOSAVE_OFF\n', datestr(now));
            return;
        end
        fname = [xsg_getFilename '.xsg'];
    end
end

overwriteConfirmedForDirectory = getLocal(progmanager, hObject, 'overwriteConfirmedForDirectory');

%Moved this out of the first if block, because now there are two places where we could autogenerate the name, and need to test for overwriting.
%Check the trigger status, if no trigger was issued, don't save anything.
started = getLocal(progmanager, hObject, 'started');%TO012606B, TO012706B
if ~started
    % fprintf(1, '%s - xsg_saveData: NOT_STARTED\n', datestr(now));
    return;
end
setLocal(progmanager, hObject, 'started', 0);%Reset the flag.

if ~isempty(fname)
    if exist(fname, 'file') == 2
        %TO082907B
        overwriteDir = fileparts(fname);
        if ~strcmpi(overwriteConfirmedForDirectory, overwriteDir)
            yesOrNo = questdlg(sprintf('%s\nFile exists. Overwrite?', fname), 'Overwrite file(s)?', 'No');%TO082907B - Pluralized question.
            if strcmpi(yesOrNo, 'No')
                [fname pathname] = uiputfile('*.xsg', 'Save Trace');
                if fname == 0
                    return;
                end
                if ~endsWithIgnoreCase(fname, '.xsg')
                    fname = [fname '.xsg'];
                end
                fname = fullfile(pathname, fname);%TO031010O
            elseif strcmpi(yesOrNo, 'Cancel')
                xsg_incrementAcquisitionNumber;%TO040706I
                return;
            else
                setLocal(progmanager, hObject, 'overwriteConfirmedForDirectory', overwriteDir);%TO082907B
            end
        end
    end
else
    fname = varargin{1};
end

xsg_incrementAcquisitionNumber

%TO040706G - @daqmanager/flushInputChannel has been deprecated. See TO033106D. -- Tim O'Connor 4/7/06
% flushAllInputChannels(getDaqmanager);%TO012706A

[programHandles, programCallbacks, fileHandleMap, streamToDisk, zipFilesOnCompletion] = ...
    getLocalBatch(progmanager, hObject, 'programHandles', 'dataCreatingGuiCallbacks', 'fileHandleMap', 'streamToDisk', 'zipFilesOnCompletion');
if length(programHandles) ~= length(programCallbacks)
    warning('Inconsistent set of program handles and program callbacks. Saved data may get mixed up across programs.');
end

%TO043008E
xsgFileCreationTimestamp = datestr(now);
xsgOriginalFilename = fname;
xsgFileFormatVersion = getLocal(progmanager, hObject, 'xsgFileFormatVersion');

setLocal(progmanager, hObject, 'status', 'Gathering headers...');
% fprintf(1, '%s - xsg_saveData - Status set to ''Gathering headers...''\n', datestr(now));
header = getHeaders(progmanager);
%TO043008E
header.xsgFileFormatVersion = getLocal(progmanager, hObject, 'xsgFileFormatVersion');
header.xsgFileCreationTimestamp = xsgFileCreationTimestamp;
header.xsgOriginalFilename = xsgOriginalFilename;
header.xsg.xsg.xsgFileFormatVersion = xsgFileFormatVersion;
header.xsg.xsg.xsgFileCreationTimestamp = xsgFileCreationTimestamp;
header.xsg.xsg.xsgOriginalFilename = xsgOriginalFilename;
header.xsg.xsg.streamToDisk = streamToDisk;
if streamToDisk
    header.xsg.xsg.streamedFiles = {fileHandleMap{:, 3}};
else
    header.xsg.xsg.streamToDisk = {};
end

setLocal(progmanager, hObject, 'status', 'Marshalling data...');
% fprintf(1, '%s - xsg_saveData - Status set to ''Marshalling data...''\n', datestr(now));
data = [];

%TO040706G - @daqmanager/flushInputChannel has been deprecated. See TO033106D. -- Tim O'Connor 4/7/06
% flushAllInputChannels(getDaqmanager);

for i = 1 : length(programCallbacks)
    %TO113007B - Fixed a stupid copy&paste error, where all the conditions were using `ischar`. -- Tim O'Connor 11/30/07
    if ischar(programCallbacks{i})
        data.(getProgramName(progmanager, programHandles(i))) = eval(programCallbacks{i});%TO123005E
    elseif strcmpi(class(programCallbacks{i}), 'function_handle')
        data.(getProgramName(progmanager, programHandles(i))) = feval(programCallbacks{i});%TO123005E
    elseif iscell(programCallbacks{i})
        data.(getProgramName(progmanager, programHandles(i))) = feval(programCallbacks{i}{:});%TO123005E
    else
        fprintf(2, 'Warning: xsg_saveData - Invalid (or no) data retrieval callback provided for %s\n', getProgramName(progmanager, programHandles(i)));
        data.(getProgramName(progmanager, programHandles(i))) = [];
    end
end

setLocal(progmanager, hObject, 'status', 'Writing data...');
% fprintf(1, '%s - xsg_saveData - Status set to ''Writing data...''\n', datestr(now));
saveCompatible(fname, 'header', 'data');%TO071906D %TO043008E
fprintf(1, '%s - Saved data to ''%s''.\n', datestr(now), fname);

if streamToDisk
    for i = 1 : size(fileHandleMap, 1)
        fclose(fileHandleMap{i, 2});
        autonotes_addNote(strrep(fileHandleMap{i, 3}, '\', '\\'));
        fprintf(1, '%s - Saved data to ''%s''.\n', datestr(now), fileHandleMap{i, 3});
    end
    if zipFilesOnCompletion
        filesToZip = {fname, [fname 'hdr'], fileHandleMap{:, 3}};
        zip([fname '.zip'], filesToZip);
        for i = 1 : length(filesToZip)
            delete(filesToZip{i});
        end
        autonotes_addNote(strrep([fname '.zip'], '\', '\\'));
        fprintf(1, '%s - Moved data to ''%s.zip''.\n', datestr(now), fname);
    end
    setLocal(progmanager, hObject, 'fileHandleMap', {});
elseif zipFilesOnCompletion
    if zipFilesOnCompletion
        zip(fname, fname);
        autonotes_addNote(strrep([fname '.zip'], '\', '\\'));
        delete(fname);
        fprintf(1, '%s - Moved data to ''%s''.\n', datestr(now), [fname '.zip']);
    end
else
    [p filename] = fileparts(fname);
    autonotes_addNote(filename);
end

%Increment the acquisition number, if necessary.
if isempty(varargin)
    %TO040706I - Added some xsg conveniences.
    xsg_incrementAcquisitionNumber;
end

%TO010506D
setLocal(progmanager, hObject, 'status', 'Executing userFcns...');
% fprintf(1, '%s - xsg_saveData - Status set to ''Executing userFcns...''\n', datestr(now));
cbm = getUserFcnCBM;
fireEvent(cbm, 'xsg:Save', header, data);

%TO040706I
% setLocalBatch(progmanager, hObject, 'status', '', 'acquisitionNumber', acqNumber);%TO123005F - Only clear the buffers on start.
setLocalBatch(progmanager, hObject, 'status', '');%TO123005F - Only clear the buffers on start.
% fprintf(1, '%s - xsg_saveData - Status set to ''''\n', datestr(now));
% fprintf(1, '%s - xsg_saveData - Done.\n', datestr(now));
return;