function varargout = responseTracker(varargin)
% RESPONSETRACKER M-file for responseTracker.fig
%      RESPONSETRACKER, by itself, creates a new RESPONSETRACKER or raises the existing
%      singleton*.
%
%      H = RESPONSETRACKER returns the handle to a new RESPONSETRACKER or the handle to
%      the existing singleton*.
%
%      RESPONSETRACKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESPONSETRACKER.M with the given input arguments.
%
%      RESPONSETRACKER('Property','Value',...) creates a new RESPONSETRACKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before responseTracker_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to responseTracker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help responseTracker

% Last Modified by GUIDE v2.5 13-Mar-2009 20:16:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @responseTracker_OpeningFcn, ...
                   'gui_OutputFcn',  @responseTracker_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before responseTracker is made visible.
function responseTracker_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to responseTracker (see VARARGIN)

% Choose default command line output for responseTracker
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes responseTracker wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% ------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = responseTracker_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ------------------------------------------------------------------
%TO012709B - Add labels. -- Tim O'Connor 1/27/09
function displayAnnotations(hObject)

[annotations, annotationHandles, numberLabelHandles] = getLocalBatch(progmanager, hObject, 'annotations', 'annotationHandles', 'numberLabelHandles');

if ~isempty(annotationHandles) && any(ishandle(annotationHandles))
    delete(annotationHandles(ishandle(annotationHandles)));
    if any(ishandle(numberLabelHandles))
        delete(numberLabelHandles(ishandle(numberLabelHandles)));%To012709B'
    end
    annotationHandles = [];
end

for i = 1 : length(annotations)
    if ~isempty(annotations(i).boundary) %TO012209A
        [h, nlh] = displayAnnotation(hObject, annotations(i), i);
        annotationHandles(i) = h;
        numberLabelHandles(i) = nlh;
%         if get(annotationHandles(i), 'UserData') ~= get(numberLabelHandles(i), 'UserData')
%             fprintf(2, 'displayAnnotations: Error - UserData Mismatch\n  annotationHandles(%s).UserData = %s\n  numberLabelHandles(%s).UserData = %s\n', ...
%                 num2str(i), num2str(get(annotationHandles(i), 'UserData')), num2str(i), num2str(get(numberLabelHandles(i), 'UserData')));
%         end
    else
        annotationHandles(i) = [];
        numberLabelHandles(i) = [];
    end
end

setLocalBatch(progmanager, hObject, 'annotationHandles', annotationHandles, 'numberLabelHandles', numberLabelHandles);

return;

% ------------------------------------------------------------------
function saveAnnotations(hObject, filename)

fprintf(1, '%s - ResponseTracker: Saving annotation data to ''%s''.\n', datestr(now), filename);
[annotations] = getLocalBatch(progmanager, hObject, 'annotations');
version = getVersion(hObject, [], []);

cdata = getCData(hObject);
aspectRatio = size(cdata);
if endsWithIgnoreCase(filename, 'pos') || endsWithIgnoreCase(filename, 'position') || endsWithIgnoreCase(filename, 'positions')
    PosMatrix = bwlabel(createMask(hObject));
    save(filename, 'version', 'PosMatrix', 'aspectRatio', '-MAT');
    warndlg('The preferred format for saving data is *.rtrk.');
else
    save(filename, 'version', 'annotations', 'aspectRatio', '-MAT');
end

setLocal(progmanager, hObject, 'lastAnnotationFile', filename);

return;

% ------------------------------------------------------------------
function loadAnnotations(hObject, filename)

fprintf(1, '%s - ResponseTracker: Loading annotation data from ''%s''.\n', datestr(now), filename);
loadedData = load(filename, '-MAT');
if isfield(loadedData, 'PosMatrix')
    annotations = [];
    [labels, nlabels] = bwlabel(loadedData.PosMatrix, 8);
    for j = 1 : nlabels
        if isempty(annotations)
            annotations = createAnnotationByPixels(hObject, find(labels == j), size(labels));
        else
            annotations(end + 1) = createAnnotationByPixels(hObject, find(labels == j), size(labels));
        end
    end
    setLocalBatch(progmanager, hObject, 'annotations', annotations, 'objectCount', length(annotations));
    displayAnnotations(hObject);
else
    %TO012309C - Added a unique ID. -- Tim O'Connor 1/23/09
    if loadedData.version < 0.25
        if ~isfield(loadedData.annotations, 'guid')
            for i = 1 : length(loadedData.annotations)
                loadedData.annotations(i).guid = getGUID(hObject);
            end
        end
    end
    setLocalBatch(progmanager, hObject, 'annotations', loadedData.annotations, 'objectCount', length(loadedData.annotations));
end

if isfield(loadedData, 'aspectRatio')
    cdata = getCData(hObject);
    setLocal(progmanager, hObject, 'annotationsAspectRatio', loadedData.aspectRatio);

    if ~all(loadedData.aspectRatio == size(cdata))
        rescaleAnnotations(hObject);
    else
        displayAnnotations(hObject);
    end
else
    displayAnnotations(hObject);
end

return;

% ------------------------------------------------------------------
function out = makeGlobalCellArray(hObject, eventdata, handles)

% config 7 (0111) would imply that the variable is part of the lightweight configuration, header, and the configuration.
% config 6 (0110) would imply that the variable is part of the lightweight configuration and header, but NOT the configuration.
% config 5 (0101) would imply that the variable is part of the lightweight configuration and configuration, but NOT the header.
% config 4 (0100) would imply that the variable is part of the lightweight configuration (miniSettings as per TO062306D).
% config 3 (0011) would imply that the variable is part of both the header and configuration.
% config 2 (0010) would imply that the variable is part of the header and but NOT the configuration.
% config 1 (0001) would imply that the variable is part of the configuration but NOT the header.
% config 0 (0000) would imply that the variable is not saved anywhere.
out = {
       'imageFilename', '', 'class', 'char', 'Config', 5, 'Gui', 'imageFilename', ...
       'imageAxes', [], ...
       'imageFigure', [], ...
       'imageFigurePosition', [], 'Config', 5, ...
       'imageHandle', [], ...
       'frameNumber', 1, 'Config', 5, ...
       'blackVal', 0, 'class', 'numeric', 'Config', 5, 'Gui', 'blackVal', ...
       'whiteVal', 2000, 'class', 'numeric', 'Config', 5, 'Gui', 'whiteVal', ...
       'frameNumber', 1, 'Class', 'numeric', 'Gui', 'frameNumber', 'Min', 1, ...
       'frameCount', NaN, 'Class', 'numeric', 'Gui', 'frameCountLabel' ...
       'frameNumberSlider', 0.5, 'Min', 0.0, 'Max', 1.0, 'Class', 'numeric', 'Gui', 'frameNumberSlider', ...
       'annotations', [], ...
       'annotationHandles', [], ...
       'currentAnnotation', -1, 'Class', 'numeric', 'Gui', 'objectNumber', ...
       'lastAnnotationFile', '', ...
       'objectCount', NaN, 'Class', 'numeric', 'Gui', 'objectCountLabel' ...
       'objectNumberSlider', 0.5, 'Min', 0.0, 'Max', 1.0, 'Class', 'numeric', 'Gui', 'objectNumberSlider', ...
       'diskFilterRadius', 12, 'Class', 'numeric', 'Gui', 'diskFilterRadius', ...
       'xcorrThreshold', 0.3, 'Class', 'numeric', 'Gui', 'xcorrThreshold', ...
       'minObjectSize', 10, 'Class', 'numeric', 'Gui', 'minObjectSize', ...
       'deletedAnnotations', [], ...
       'forceAspectRatioSquare', 1, 'Class', 'numeric', 'Gui', 'forceAspectRatioSquare', ...
       'showObjects', 1, 'Class', 'numeric', 'Gui', 'showObjects', ...
       'originalAspectRatio', [], ...
       'annotationsAspectRatio', [], ...
       'averageFrames', 0, 'Class', 'numeric', 'Gui', 'averageFrames', ...
       'averageRange', '', 'Class', 'char', 'Gui', 'averageRange', ...
       'loadedFilename', '', ...
       'borderMask', 20, 'Class', 'numeric', 'Gui', 'borderMask', ...
       'numberLabelHandles', [], ...
       'showNumberLabels', 0, 'Class', 'numeric', 'Config', 5, 'Gui', 'showLabels', ...
       'moveAll', 0, 'Class', 'numeric', 'Config', 5, 'Gui', 'moveAll', ...
      };

return;

% ------------------------------------------------------------------
function genericStartFcn(hObject, eventdata, handles)

set(hObject, 'KeyPressFcn', {@keyPressFcn, hObject});

return;

% ------------------------------------------------------------------
function genericUpdateFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericCloseFcn(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
function genericOpenData(hObject, eventdata, handles)

browsePath = getDefaultCacheDirectory(progmanager, 'reponseTracker_annotationPath');

[filename, pathname] = uigetfile({'*.rtrk;', 'Response Tracker Files (*.rtrk)'; '*.pos; *.position;', 'NeuroResponse Position Files (*.pos, *.position)'; ...
    fullfile(browsePath, '*.*'), 'All files (*.*)'}, ...
    'Choose an annotation file to load.', browsePath);
if isequal(filename, 0) || isequal(pathname, 0)
    return;
end

setDefaultCacheValue(progmanager, 'reponseTracker_annotationPath', pathname);

loadAnnotations(hObject, fullfile(pathname, filename));

return;

% ------------------------------------------------------------------
function genericSaveProgramData(hObject, eventdata, handles)

lastAnnotationFile = getLocal(progmanager, hObject, 'lastAnnotationFile');
if isempty(lastAnnotationFile) || ~exist(lastAnnotationFile, 'file') == 2
    genericSaveProgramDataAs(hObject, eventdata, handles);
else
    saveAnnotations(hObject, lastAnnotationFile);
end

return;

% ------------------------------------------------------------------
function genericSaveProgramDataAs(hObject, eventdata, handles)

browsePath = getDefaultCacheDirectory(progmanager, 'reponseTracker_annotationPath');
[imageFilename] = getLocalBatch(progmanager, hObject, 'imageFilename');
[p, f] = fileparts(imageFilename);

% [filename, pathname] = uigetfile({'*.tif; *.tiff; *.rif', 'TIFF encoded images (*.tif, *.tiff, *.rif)'; '*.xml', 'Prairie image stacks (*.xml)'; fullfile(browsePath, '*.*'), 'All files (*.*)'}, ...
%     'Choose an image to load.', browsePath);
[filename, pathname, filterIndex] = uiputfile({'*.rtrk;', 'Response Tracker Files (*.rtrk)'; '*.pos; *.position;', 'NeuroResponse Position Files (*.pos, *.position)'; ...
    fullfile(browsePath, '*.*'), 'All files (*.*)'}, ...
    'Choose an annotation file to load.', fullfile(browsePath, f));
if isequal(filename, 0) || isequal(pathname, 0)
    return;
end

setDefaultCacheValue(progmanager, 'reponseTracker_annotationPath', pathname);

if filterIndex == 1
    if ~endsWithIgnoreCase(filename, '.rtrk')
        filename = [filename '.rtrk'];
    end
elseif filterIndex == 2
    if ~endsWithIgnoreCase(filename, '.pos') && ~endsWithIgnoreCase(filename, '.position')
        filename = [filename '.pos'];
    end
end

saveAnnotations(hObject, fullfile(pathname, filename));

return;

% ------------------------------------------------------------------
function out = getVersion(hObject, eventdata, handles)

out = 0.25;

return;

% ------------------------------------------------------------------
function resTr_errorDlg(varargin)

errordlg(sprintf(varargin{:}));

return;

% ------------------------------------------------------------------
function updateCLims(hObject)

[imageAxes, blackVal, whiteVal] = getLocalBatch(progmanager, hObject, 'imageAxes', 'blackVal', 'whiteVal');

if whiteVal < 1
    whiteVal = 1;
    setLocal(progmanager, hObject, 'whiteVal', whiteVal);
end
if blackVal > whiteVal
    blackVal = whiteVal - 1;
    setLocal(progmanager, hObject, 'blackVal', blackVal);
elseif blackVal < 0
    blackVal = 0;
    setLocal(progmanager, hObject, 'blackVal', blackVal);
end

if ishandle(imageAxes)
    set(imageAxes, 'CLim', [blackVal, whiteVal]);
end

return;

% ------------------------------------------------------------------
function varargout = squareAspectRatio(cdata)

resized = 0;

if size(cdata, 1) > size(cdata, 2)
    resampleFactor = size(cdata, 1) / size(cdata, 2);
    % fprintf(1, 'Resampling from %sx%s using factor %s.\n', num2str(size(cdata, 1)), num2str(size(cdata, 2)), num2str(resampleFactor));
    if resampleFactor ~= round(resampleFactor)
        errordlg(sprintf('Failed to resample image while forcing aspect ratio to be square.\nThe ratio of dimensions must be an integer (%s / %s = %s)', ...
            num2str(size(cdata, 1)), num2str(size(cdata, 2)), num2str(resampleFactor)));
    end
    resampledCData = zeros(size(cdata, 1), size(cdata, 1));
    for i = 1 : size(cdata, 1)
        resampledCData(i, :) = interp(cdata(i, :), resampleFactor);
    end
    cdata = resampledCData;
    resized = 1;
elseif size(cdata, 1) < size(cdata, 2)
    resampleFactor = size(cdata, 2) / size(cdata, 1);
    % fprintf(1, 'Resampling from %sx%s using factor %s.\n', num2str(size(cdata, 1)), num2str(size(cdata, 2)), num2str(resampleFactor));
    if resampleFactor ~= round(resampleFactor)
        errordlg(sprintf('Failed to resample image while forcing aspect ratio to be square.\nThe ratio of dimensions must be an integer (%s / %s = %s)', ...
            num2str(size(cdata, 2)), num2str(size(cdata, 1)), num2str(resampleFactor)));
    end
    resampledCData = zeros(size(cdata, 2), size(cdata, 2));
    for i = 1 : size(cdata, 2)
        resampledCData(:, i) = interp(cdata(:, i), resampleFactor);
    end
    cdata = resampledCData;
    resized = 1;
end

varargout{1} = cdata;
varargout{2} = resized;
    
return;

% ------------------------------------------------------------------
function mask = createMask(hObject)

[annotations, annotationsAspectRatio] = getLocalBatch(progmanager, hObject, 'annotations', 'annotationsAspectRatio');
if isempty(annotationsAspectRatio)
    cdata = getCData(hObject);
    annotationsAspectRatio = size(cdata);
end

mask = zeros(annotationsAspectRatio);
for i = 1 : length(annotations)
    mask(annotations(i).pixels) = 1;
end

return;

% ------------------------------------------------------------------
%Optionally takes the aspect ratio of the annotations.
function rescaleAnnotations(hObject, varargin)

[annotations, annotationsAspectRatio] = getLocalBatch(progmanager, hObject, 'annotations', 'annotationsAspectRatio');
if isempty(annotations)
    return;
end

aspectRatio = size(getCData(hObject));

if prod(annotationsAspectRatio) > prod(aspectRatio)
    if aspectRatio(1) < aspectRatio(2)
        resampleFactor = aspectRatio(2) /  aspectRatio(1);
    elseif aspectRatio(1) > aspectRatio(2)
        resampleFactor = aspectRatio(1) /  aspectRatio(2);
    end

    %Decimate/subsample.
    % if aspectRatio(1) < aspectRatio(2)
    %     rescaledMask = zeros(aspectRatio(1) / resampleFactor, aspectRatio(2));
    %     for i = 1 : annotationsAspectRatio(1) / resampleFactor
    %         rescaledMask(i, :) = sum(mask((i-1) * resampleFactor + 1 : i * resampleFactor, :), 1);
    %     end
    % elseif aspectRatio(1) > aspectRatio(2)
    %     rescaledMask = zeros(aspectRatio(1), aspectRatio(2) / resampleFactor);
    %     for i = 1 : annotationsAspectRatio(2) / resampleFactor
    %         rescaledMask(i, :) = sum(mask(:, (i-1) * resampleFactor + 1 : i * resampleFactor), 1);
    %     end
    % end
    % mask = rescaledMask;
    % mask(mask < resampleFactor / 2) = 0;
    % mask(mask ~= 0) = 1;
    %TO01809A - As per Takaki's request, drop Karel's technique, and just index out the appropriate lines. -- Timothy O'Connor 1/18/09
    % if aspectRatio(1) < aspectRatio(2)
    %     mask = mask(1:resampleFactor:end, :);
    % elseif aspectRatio(1) > aspectRatio(2)
    %     mask = mask(:, 1:resampleFactor:end);
    % end
    %TO012209A - Takaki wants the object numbers to stay constant during rescaling. Relabelling doesn't allow for that. -- Tim O'Connor 1/22/09
    %            Note that now, objects may become non-contiguous, but will still be seen as a single object. - TO012209A
    for i = 1 : length(annotations)
        [xInd, yInd] = ind2sub(annotationsAspectRatio, annotations(i).pixels);
        if aspectRatio(1) < aspectRatio(2)
            indices = xInd;
        elseif aspectRatio(1) > aspectRatio(2)
            indices = yInd;
        end

        %Take the ones that are in the first row/column or are evenly divisible by the resampleFactor.
        subindices = find((indices == 1) | (indices / resampleFactor == floor(indices / resampleFactor)));
        if aspectRatio(1) < aspectRatio(2)
            dividendIndices = find(xInd > 1);
            xInd(dividendIndices) = xInd(dividendIndices) / resampleFactor + 1;
        elseif aspectRatio(1) > aspectRatio(2)
            dividendIndices = find(yInd > 1);
            yInd(dividendIndices) = yInd(dividendIndices) / resampleFactor + 1;
        end
        if ~isempty(subindices)
            guid = annotations(i).guid;
            annotations(i) = createAnnotationByPixels(hObject, sub2ind(aspectRatio, xInd(subindices), yInd(subindices)), aspectRatio);
            annotations(i).guid = guid;
        else
            annotations(i).boundary = [];
        end
    end
    annotationsAspectRatio = aspectRatio;
elseif prod(annotationsAspectRatio) < prod(aspectRatio)
    if annotationsAspectRatio(1) < annotationsAspectRatio(2)
        resampleFactor = annotationsAspectRatio(2) /  annotationsAspectRatio(1);
    elseif annotationsAspectRatio(1) > annotationsAspectRatio(2)
        resampleFactor = annotationsAspectRatio(1) /  annotationsAspectRatio(2);
    end
    
    %Interpolate/repeat.
    %TO012309B - As in TO012209A, make sure labels remain consistent.
    % annotations = [];%TO012209A
    % mask = createMask(hObject);%TO012209A
    %
    % if annotationsAspectRatio(1) < annotationsAspectRatio(2)
    %     rescaledMask = reshape(mask, numel(mask), 1);
    %     rescaledMask = repmat(rescaledMask, 1, resampleFactor);
    %     rescaledMask = reshape(rescaledMask', aspectRatio);
    % elseif annotationsAspectRatio(1) > annotationsAspectRatio(2)
    %     rescaledMask = repmat(mask', resampleFactor, 1);
    %     rescaledMask = reshape(rescaledMask, aspectRatio);
    %     rescaledMask = rescaledMask';
    % end
    %
    % mask = rescaledMask;
    %
    % %TO012209A
    % %Convert the mask into annotations.
    % [labels, nlabels] = bwlabel(mask, 8);
    % for j = 1 : nlabels
    %     if isempty(annotations)
    %         annotations = createAnnotationByPixels(hObject, find(labels == j), size(labels));
    %     else
    %         annotations(end + 1) = createAnnotationByPixels(hObject, find(labels == j), size(labels));
    %     end
    % end
    % annotationsAspectRatio = size(mask);

    %TO012309B - Ported TO012209A into upscaling, to make sure labels remain consistent. -- Tim O'Connor 1/23/09
    %TO012209A - Takaki wants the object numbers to stay constant during rescaling. Relabelling doesn't allow for that. -- Tim O'Connor 1/22/09
    %            Note that now, objects may become non-contiguous, but will still be seen as a single object. - TO012209A
    for i = 1 : length(annotations)
        [xInd, yInd] = ind2sub(annotationsAspectRatio, annotations(i).pixels);
        if annotationsAspectRatio(1) < annotationsAspectRatio(2)
            indices = xInd;
        elseif annotationsAspectRatio(1) > annotationsAspectRatio(2)
            indices = yInd;
        end

        %Take the ones that are in the first row/column or are evenly divisible by the resampleFactor.
        if annotationsAspectRatio(1) < annotationsAspectRatio(2)
            xInd = repmat(xInd, 1, resampleFactor);
            xInd(xInd > 1) = (xInd - 1) * 4;
            for j = 2 : resampleFactor
                xInd(:, j) = xInd(:, j) + j - 1;
            end
            xInd = reshape(xInd, [numel(xInd), 1]);
            yInd = repmat(yInd, 1, resampleFactor);
            yInd = reshape(yInd, [numel(yInd), 1]);
        elseif annotationsAspectRatio(1) > annotationsAspectRatio(2)
            yInd = repmat(yInd, 1, resampleFactor);
            yInd(yInd > 1) = (yInd - 1) * 4;
            for j = 2 : resampleFactor
                yInd(:, j) = yInd(:, j) + j - 1;
            end
            yInd = reshape(yInd, [numel(yInd), 1]);
            xInd = repmat(xInd, 1, resampleFactor);
            xInd = reshape(xInd, [numel(xInd), 1]);
        end
        guid = annotations(i).guid;
        annotations(i) = createAnnotationByPixels(hObject, sub2ind(aspectRatio, xInd, yInd), aspectRatio);
        annotations(i).guid = guid;
    end
    annotationsAspectRatio = aspectRatio;
else
    return;
end

setLocalBatch(progmanager, hObject, 'annotations', annotations, 'objectCount', length(annotations), 'annotationsAspectRatio', annotationsAspectRatio);
displayAnnotations(hObject);

return;

% % si=size(mask);
% % mask2=zeros(si(1)/resampleFactor, si(2));
% % % f = figure
% % %resampleFactor
% % for i=1:si(1)/resampleFactor
% %     temp=mask(((i-1)*resampleFactor+1):i*resampleFactor, :);
% % %    sum(sum(temp))
% % % if any(temp)
% % %    plot(temp), pause(1)
% % % end
% %     temp=sum(temp);
% %     ind=find(temp > 1);
% %     mask2(i, ind) = 1;
% % %     if any(temp)
% % %         mask2(i, :)=ind;
% % %     end
% % end
% % f = figure, movegui(f), imagesc(mask2)

% 
% if numel(mask) < prod(aspectRatio)
%     %Interpolation is unreliable in this case, because it produces non-binary data.
%     %Using repmat would be faster, but it requires more thinking to get the indexing right.
%     newMask = zeros(aspectRatio);
%     if annotationsAspectRatio(1) < annotationsAspectRatio(2)
%         resampleFactor = annotationsAspectRatio(2) / annotationsAspectRatio(1);
%         idx = 1;
%         for i = 1 : aspectRatio(1)
%             for j = 1 : resampleFactor
% % fprintf(1, '%s -> %s\n', num2str(idx), num2str(i + j - 1));
%                 newMask(i + j - 1, :) = mask(idx, :);
% if any(mask(idx, :) > 0)
% fprintf(1, '1@%s: %s -> %s\n', num2str(i), num2str(idx), num2str(i + j - 1));
% else
% fprintf(1, '0@%s: %s -> %s\n', num2str(i), num2str(idx), num2str(i + j - 1));
% end
%             end
%             idx = idx + 1;
%         end
%     elseif annotationsAspectRatio(1) > annotationsAspectRatio(2)
%         resampleFactor = annotationsAspectRatio(1) / annotationsAspectRatio(2);
%         idx = 1;
%         for i = 1 : resampleFactor : annotationsAspectRatio(1)
%             for j = 1 : resampleFactor
% % fprintf(1, '%s -> %s\n', num2str(i + j - 1), num2str(idx));
%                 newMask(:, i + j - 1) = mask(:, idx);
%             end
%             idx = idx + 1;
%         end
%     end
%     mask = newMask;
% %     %Interpolate.
% %     mask(mask ~= 0) = 65535;%This makes the interpolation produce a cleaner image for binarizing.
% %     mask = squareAspectRatio(mask);
% % f = figure, movegui(f), imagesc(mask), colorbar
% % %     wiener2(mask, 4);%Filter because the interpolation can leave low-value gaps.
% %     mask(mask ~= 0) = 1;%Interpolation changes it from a binary mask, so convert it back.
% else
%     %Decimate/subsample.
% %     if annotationsAspectRatio(1) > annotationsAspectRatio(2)
% %         resampleFactor = size(annotationsAspectRatio(1)) / size(annotationsAspectRatio(2));
% %         newMask = mask(1:resampleFactor:end, :);
% %     elseif annotationsAspectRatio(1) < annotationsAspectRatio(2)
% %         resampleFactor = size(annotationsAspectRatio(2)) / size(annotationsAspectRatio(1));
% %         newMask = mask(1:resampleFactor:end, :);
% %     end
% %     mask = newMask;
% % setLocal(progmanager, hObject, 'minObjectSize', getLocal(progmanager, hObject, 'minObjectSize') * 4);
%     for i = 1 : length(annotations)
%         subs = ind2subs(annotationsAspectRatio, annotations(i).pixels);
%         if aspectRatio(1) > aspectRatio(2)
%         elseif aspectRatio(2) < aspectRatio(1)
%     end
% end

% f = figure, movegui(f), imagesc(mask), colorbar

% ------------------------------------------------------------------
function updateFrame(hObject)

[imageHandle, imageAxes, imageFigure, frameNumber, imageFilename, frameCount, forceAspectRatioSquare, annotations, averageFrames, averageRange, loadedFilename] = getLocalBatch(progmanager, hObject, ...
    'imageHandle', 'imageAxes', 'imageFigure', 'frameNumber', 'imageFilename', 'frameCount', 'forceAspectRatioSquare', 'annotations', 'averageFrames', 'averageRange', 'loadedFilename');

if isempty(ishandle(imageFigure))
    return;
end
if ~ishandle(imageFigure)
    return;
end

if frameNumber < 1 || frameNumber > frameCount || isempty(imageFilename)
    return;
end

resized = 0;
if averageFrames
    if ~strcmpi(loadedFilename, imageFilename)
        %This image hasn't been averaged/loaded.
        if isempty(averageFrames)
            range = 1 : frameCount;
        else
            averageRange = strrep(averageRange, 'end', num2str(frameCount));
            try
                range = eval(averageRange);
            catch
                fprintf(2, 'Error evaluating averageRange ''%s''.\n%s\n', averageRange, getLastErrorStack);
                errordlg(sprintf('Failed to interpret averageRange: ''%s'' - %s', averageRange, lasterr));
                range = 1 : min(10, frameCount);
            end
        end
        cdata = [];
        for i = 1 : length(range)
            if isempty(cdata)
                cdata = double(imread(imageFilename, range(i)));
            else
                cdata = cdata + double(imread(imageFilename, range(i)));
            end
        end
        cdata = uint16(cdata / length(range));
        setLocal(progmanager, hObject, 'frameCount', 1);
    else
        cdata = getCData(hObject);
    end
else
    cdata = imread(imageFilename, frameNumber);
end
    
setLocalBatch(progmanager, hObject, 'originalAspectRatio', size(cdata), 'loadedFilename', imageFilename);

if forceAspectRatioSquare
    [cdata, resized] = squareAspectRatio(cdata);
end

if isempty(imageHandle) || ~ishandle(imageHandle)
    imageHandle = imagesc(cdata, 'Parent', imageAxes);
    setLocal(progmanager, hObject, 'imageHandle', imageHandle);
    updateCLims(hObject);
    displayAnnotations(hObject);
else
    if numel(get(imageHandle, 'CData')) ~= numel(cdata)
        delete(imageHandle);
        imageHandle = imagesc(cdata, 'Parent', imageAxes);
        set(imageAxes, 'XLim', [1, size(cdata, 2)], 'YLim', [1, size(cdata, 1)]);
        setLocal(progmanager, hObject, 'imageHandle', imageHandle);
        updateCLims(hObject);
        if ~isempty(annotations)
            rescaleAnnotations(hObject, getLocal(progmanager, hObject, 'annotationsAspectRatio'));
        else
            displayAnnotations(hObject);
        end
    else
        set(imageHandle, 'CData', cdata);
    end
end

return;

% ------------------------------------------------------------------
function imageCloseRequestFcn(figHandle, eventdata, hObject)

imageFigure = getLocal(progmanager, hObject, 'imageFigure');
if ~ishandle(imageFigure)
    return;
end

setLocalBatch(progmanager, hObject, 'imageFigure', [], 'imageFigurePosition', get(imageFigure, 'Position'));

delete(imageFigure);

return;

% ------------------------------------------------------------------
function loadImage(hObject)

[imageFigure, imageFilename, imageFigurePosition] = getLocalBatch(progmanager, hObject, 'imageFigure', 'imageFilename', 'imageFigurePosition');

if exist(imageFilename, 'file') ~= 2
    resTr_errorDlg('File ''%s'' does not exist.', imageFilename);
    return;
end

if isempty(imageFigure) || ~ishandle(imageFigure)
    imageFigure = figure;
    imageAxes = axes('Parent', imageFigure);
    try
        movegui(imageFigure);
    catch
        fprintf(2, 'Error executing `movegui(imageFigure);` - %s', getLastErrorStack);
    end
    if ~isempty(imageFigurePosition)
        set(imageFigure, 'Position', imageFigurePosition);
    else
        setLocal(progmanager, hObject, 'imageFigurePosition', get(imageFigure, 'Position'));
    end
    set(imageFigure, 'ColorMap', gray, 'CloseRequestFcn', {@imageCloseRequestFcn, hObject}, 'KeyPressFcn', {@keyPressFcn, hObject});
    setLocalBatch(progmanager, hObject, 'imageFigure', imageFigure, 'imageAxes', imageAxes);
end

[pname, fname] = fileparts(imageFilename);
set(imageFigure, 'Name', fname);

info = imfinfo(imageFilename);
setLocalBatch(progmanager, hObject, 'frameCount', length(info), 'loadedFilename', '');

updateFrame(hObject);
updateCLims(hObject);

return;

% ------------------------------------------------------------------
function imageFilename_Callback(hObject, eventdata, handles)

imageFilename = getLocal(progmanager, hObject, 'imageFilename');
if exist(imageFilename, 'file') ~= 2
    setLocalGh(progmanager, hObject, 'imageFilename', 'ForegroundColor', [1, 0, 0]);
else
    setLocalGh(progmanager, hObject, 'imageFilename', 'ForegroundColor', [0, 0, 0]);
%     setDefaultCacheValue(progmanager, 'reponseTracker_browsePath', fileparts(imageFilename));
    loadImage(hObject);
end

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function imageFilename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% ------------------------------------------------------------------
% --- Executes on button press in fileBrowse.
function fileBrowse_Callback(hObject, eventdata, handles)

browsePath = getDefaultCacheDirectory(progmanager, 'reponseTracker_browsePath');

% [filename, pathname] = uigetfile({'*.tif; *.tiff; *.rif', 'TIFF encoded images (*.tif, *.tiff, *.rif)'; '*.xml', 'Prairie image stacks (*.xml)'; fullfile(browsePath, '*.*'), 'All files (*.*)'}, ...
%     'Choose an image to load.', browsePath);
[filename, pathname] = uigetfile({'*.tif; *.tiff; *.rif', 'TIFF encoded images (*.tif, *.tiff, *.rif)'; fullfile(browsePath, '*.*'), 'All files (*.*)'}, ...
    'Choose an image to load.', browsePath);
if isequal(filename, 0) || isequal(pathname, 0)
    return;
end

setLocalGh(progmanager, hObject, 'imageFilename', 'ForegroundColor', [0, 0, 0]);
setLocal(progmanager, hObject, 'imageFilename', fullfile(pathname, filename));

setDefaultCacheValue(progmanager, 'reponseTracker_browsePath', pathname);

loadImage(hObject);

return;

% ------------------------------------------------------------------
function frameNumber_Callback(hObject, eventdata, handles)

updateFrame(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function frameNumber_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function frameNumberSlider_Callback(hObject, eventdata, handles)

[frameNumber, frameNumberSlider, frameCount] = getLocalBatch(progmanager, hObject, 'frameNumber', 'frameNumberSlider', 'frameCount');
setLocal(progmanager, hObject, 'frameNumberSlider', 0.5);

if frameNumberSlider < 0.5
    if frameNumber > 1
        setLocal(progmanager, hObject, 'frameNumber', frameNumber - 1);
        updateFrame(hObject);
    end
elseif frameNumberSlider > 0.5
    if frameNumber < frameCount
        setLocal(progmanager, hObject, 'frameNumber', frameNumber + 1);
        updateFrame(hObject);
    end
end

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function frameNumberSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
return;

% ------------------------------------------------------------------
function blackVal_Callback(hObject, eventdata, handles)

updateCLims(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function blackVal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% ------------------------------------------------------------------
function whiteVal_Callback(hObject, eventdata, handles)

updateCLims(hObject);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function whiteVal_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% ------------------------------------------------------------------
% --- Executes on button press in test.
function test_Callback(hObject, eventdata, handles)
get(getLocal(progmanager, hObject, 'imageAxes'), 'Children')
% setLocal(progmanager, hObject, 'annotations', []);
% hintDetect(hObject);
% % [imageHandle, imageFigure, imageAxes, blackVal, whiteVal] = getLocalBatch(progmanager, hObject, 'imageHandle', 'imageFigure', 'imageAxes', 'blackVal', 'whiteVal');
% % 
% % cdata = get(imageHandle, 'CData');
% % % % 
% % % % whiteVal = max(max(cdata));
% % % % cdata(cdata <= blackVal) = 0;
% % % % cdata(cdata > blackVal) = cdata(cdata > blackVal) - blackVal;
% % % % cdata = cdata / (whiteVal - blackVal);
% % % % cdata = wiener2(cdata, [10, 10]);
% % % 
% % % % % % BW = im2bw(cdata);
% % % % % BW_filled = imfill(cdata, 'holes');
% % % % % boundaries = bwboundaries(BW_filled);
% % % % % hold on
% % % % % for k = numel(boundaries)
% % % % %    b = boundaries{k};
% % % % %    plot(b(:,2),b(:,1),'g','LineWidth',3, 'Parent', imageAxes);
% % % % % end
% % % 
% % % % SE = strel('rectangle', [40, 30]);
% % % SE = strel('disk', 50);
% % % BW2 = imerode(cdata, SE);
% % % BW3 = imdilate(BW2, SE);
% % % cdata = cdata - BW3;
% % % BW = im2bw(cdata, graythresh(cdata));
% % % % BW = imadjust(BW);
% % % f = figure, movegui(f), imagesc(BW);
% % set(imageAxes, 'units', 'pixels');
% % [y, x] = getpts(imageAxes);
% % x, y
% % f = figure, movegui(f), set(f, 'ColorMap', gray);
% % xr = 50;%pixels
% % yr = 10;%pixels
% % % x1 = max(1, x-xr)
% % % x2 = min(size(cdata, 1), x+xr)
% % % y1 = max(1, y-yr)
% % % y2 = min(size(cdata, 2), y+yr)
% % cdata = cdata(round(max(1, x-xr)) : round(min(size(cdata, 1), x+xr)), round(max(1, y-yr)) : round(min(size(cdata, 2), y+yr)));
% % % imagesc(real(ifft2(double(cdata))));
% % cdata = double(cdata);
% % fdata = zeros(size(cdata));
% % fdata(1:end-1, :) = fdata(1:end-1, :) + cdata(1:end-1, :) - cdata(2:end, :);%down
% % fdata(2:end, :) = fdata(2:end, :) + cdata(2:end, :) - cdata(1:end-1, :);%up
% % fdata(:, 1:end-1) = fdata(:, 1:end-1) + cdata(:, 1:end-1) - cdata(:, 2:end);%left
% % fdata(:, 2:end) = fdata(:, 2:end) + cdata(:, 2:end) - cdata(:, 1:end-1);%right
% % % cdata = im2bw(cdata, graythresh(cdata));
% % fdata = fdata / 4;
% % imagesc(edge(cdata, 'Canny'));
% % f = figure, movegui(f), set(f, 'ColorMap', gray);
% % imagesc(cdata);
% annotationHandles = getLocalBatch(progmanager, hObject, 'annotationHandles');
% if ~isempty(annotationHandles) && any(ishandle(annotationHandles))
%     delete(annotationHandles(ishandle(annotationHandles)));
%     annotationHandles = [];
% end
% 
% coords = autodetectObjects(hObject);
% annotationHandles = zeros(size(coords));
% for i = 1 : length(coords)
%     annotations(i) = createAnnotationByPixels(hObject, coords{i});
%     annotationHandles(i) = displayAnnotation(hObject, annotations(i), i);
% end
% 
% setLocalBatch(progmanager, hObject, 'annotations', annotations, 'annotationHandles', annotationHandles);

return;

% ------------------------------------------------------------------
function cdata = getCData(hObject)

imageHandle = getLocal(progmanager, hObject, 'imageHandle');
if isempty(imageHandle) || ~ishandle(imageHandle)
    cdata = [];
else
    cdata = get(imageHandle, 'CData');
end

return;

% ------------------------------------------------------------------
function hintDetect(hObject)

[imageAxes, annotations, minObjectSize] = getLocalBatch(progmanager, hObject, 'imageAxes', 'annotations', 'minObjectSize');
[y, x] = getPointsFromAxes(imageAxes);%TO031910D

% xr = 5;%pixels
% yr = 10;%pixels

% x1 = max(1, x-xr)
% x2 = min(size(cdata, 1), x+xr)
% y1 = max(1, y-yr)
% y2 = min(size(cdata, 2), y+yr)
cdata = getCData(hObject);

searchRadiusFactor = 1.3;%Empirically determined, maybe it could be configurable, but that's not critical.
if size(cdata, 1) > size(cdata, 2)
    xr = round(searchRadiusFactor * minObjectSize);
    yr = round(searchRadiusFactor * minObjectSize * round(size(cdata, 2) / size(cdata, 1)));
elseif size(cdata, 2) > size(cdata, 1)
    xr = round(searchRadiusFactor * minObjectSize * round(size(cdata, 1) / size(cdata, 2)));
    yr = round(searchRadiusFactor * minObjectSize);
else
    xr = round(searchRadiusFactor * minObjectSize);
    yr = round(searchRadiusFactor * minObjectSize);
end

for i = 1 : length(x)
    %Mask out the part of the image indicated by the hint.
    rows = round(max(1, x(i)-xr)) : round(min(size(cdata, 1), x(i)+xr));
    columns = round(max(1, y(i)-yr)) : round(min(size(cdata, 2), y(i)+yr));
    cdataMask = zeros(size(cdata));
    cdataMask(rows, columns) = 1;
    maskedCdata = double(cdata) .* cdataMask;
    % f = figure, movegui(f), imagesc(cdata)
    [labels, nlabels] = autoDetect(hObject, maskedCdata);

    for j = 1 : nlabels
        if isempty(annotations)
            annotations = createAnnotationByPixels(hObject, find(labels == j), size(labels));
        else
            annotations(end + 1) = createAnnotationByPixels(hObject, find(labels == j), size(labels));
        end
    end
end

setLocalBatch(progmanager, hObject, 'annotations', annotations, 'objectCount', length(annotations), 'annotationsAspectRatio', size(getCData(hObject)));

displayAnnotations(hObject);

setAnnotation(hObject, length(annotations));

return;

% ------------------------------------------------------------------
%TO012809B - Implement deterministic (pixel-resolution) dragging.
function annotationMove_Callback(hObject, lineHandle, delta, type, varargin)

[annotations, currentAnnotation, numberLabelHandles, annotationHandles, moveAll] = getLocalBatch(progmanager, hObject, 'annotations', 'currentAnnotation', 'numberLabelHandles', 'annotationHandles', 'moveAll');

%TO031309D - Allow all objects to be moved together, en masse.
if ~isempty(varargin)
    currentAnnotation = varargin{1};
end
if moveAll && isempty(varargin)
    %Don't do this for stretches, only drags.
    if strcmpi(type, 'drag')
        for i = 1 : length(annotations)
            annotationMove_Callback(hObject, annotationHandles(i), delta, type, i);
        end
        return;
    end
end

if strcmpi(type, 'stretch')
    annotations(currentAnnotation) = createAnnotationByBoundary(hObject, cat(1, get(lineHandle, 'YData'), get(lineHandle, 'XData')));
elseif strcmpi(type, 'drag')
    if length(delta) > 2
        if size(delta, 1) > size(delta, 2)
            delta = delta(1, :);
        else
            delta = delta(:, 1);
        end
    end
    delta = round(delta);%Do not allow subpixel movements.
    %Directly modify the boundary and pixels, do not re-detect either of them.
    annotations(currentAnnotation).boundary(:, 1) = annotations(currentAnnotation).boundary(:, 1) + delta(2);
    annotations(currentAnnotation).boundary(:, 2) = annotations(currentAnnotation).boundary(:, 2) + delta(1);
    aspectRatio = size(getCData(hObject));
    [x, y] = ind2sub(aspectRatio, annotations(currentAnnotation).pixels);
    x = x + delta(2);
    y = y + delta(1);
% mask = zeros(aspectRatio); mask(annotations(currentAnnotation).pixels) = 1;
% figure('ColorMap', gray); imagesc(mask); title('Before');
    annotations(currentAnnotation).pixels = sub2ind(aspectRatio, x, y);
% mask = zeros(aspectRatio); mask(annotations(currentAnnotation).pixels) = 1;
% figure('ColorMap', gray); imagesc(mask); title('After');
    set(annotationHandles(currentAnnotation), 'XData', annotations(currentAnnotation).boundary(:, 2), 'YData', annotations(currentAnnotation).boundary(:, 1));
end
set(numberLabelHandles(currentAnnotation), 'Position', [mean(annotations(currentAnnotation).boundary(:, 2)), mean(annotations(currentAnnotation).boundary(:, 1))]);%TO012709B

setLocalBatch(progmanager, hObject, 'annotations', annotations);

return;

% ------------------------------------------------------------------
function contextMenuDelete_Callback(currentObject, eventdata, hObject)

deleteObject_Callback(hObject, [], []);

return;

% ------------------------------------------------------------------
function [h, label] = displayAnnotation(hObject, annotation, annotationIndex)

%TO012209A
if isempty(annotation.pixels) || isempty(annotation.boundary)
    h = [];
    return;
end

[imageAxes, imageFigure, showObjects, showNumberLabels] = getLocalBatch(progmanager, hObject, 'imageAxes', 'imageFigure', 'showObjects', 'showNumberLabels');

h = line('XData', annotation.boundary(:, 2), 'YData', annotation.boundary(:, 1), 'Parent', imageAxes, 'Color', [.2, 1, .2], 'UserData', annotation.guid);
cmenu = uicontextmenu('Parent', imageFigure);
set(h, 'UIContextMenu', cmenu);
uimenu(cmenu, 'Label', 'delete', 'Callback', {@contextMenuDelete_Callback, hObject});

makegraphicsobjectmutable(h, 'Callback', {@annotationMove_Callback, hObject, h}, 'lockToAxes', 1, 'multiPointStretch', 1, 'forceClosedPolygon', 1, 'passDelta', 1, 'passType', 1);

set(h, 'ButtonDownFcn', {@selectAnnotation, hObject, get(h, 'ButtonDownFcn')});%Insert a select function, and let it call the mouse controls.
% h = plot(annotation.boundary(:, 2), annotation.boundary(:, 1), 'Parent', imageAxes);

if ~showObjects
    set(h, 'Visible', 'Off');
end

%TO012709B - Add labels. -- Tim O'Connor 1/27/09
label = text('Position', [mean(annotation.boundary(:, 2)), mean(annotation.boundary(:, 1))], 'Parent', imageAxes, 'Color', [0, .7, 1], ...
    'FontName', 'FixedWidth', 'FontWeight', 'Bold', 'HorizontalAlignment', 'Center', 'HitTest', 'Off', 'String', num2str(annotationIndex), 'UserData', annotation.guid);

if ~showNumberLabels
    set(label, 'Visible', 'Off');
end

return;

% ------------------------------------------------------------------
%TO012309C
function guid = getGUID(hObject)
global responseTrackerGUID;

if isempty(responseTrackerGUID)
    responseTrackerGUID = 1;
else
    responseTrackerGUID = responseTrackerGUID + 1;
end

guid(1) = responseTrackerGUID + (cputime + now * 10^-2) * 10^-5;

return;

% ------------------------------------------------------------------
%Creates a new annotation object, contained within the specified boundary.
function annotation = createAnnotationByBoundary(hObject, boundary)

%TO012009A - Make sure the boundary is oriented correctly.
if size(boundary, 2) > size(boundary, 1)
    boundary = boundary';
end

%Find the ROI defined by the boundary.
cdata = getCData(hObject);

mask = poly2mask(boundary(:, 2), boundary(:, 1), size(cdata, 1), size(cdata, 2));
annotation.pixels = find(mask == 1);
% f = figure('ColorMap', gray); movegui(f), imagesc(mask), hold on, plot(boundary(:, 2), boundary(:, 1)), hold off

%This has to be created second, or else we get a 'Subscripted assignment between dissimilar structures'. It must match the order of creation in createAnnotationByPixels.
annotation.boundary = boundary;

annotation.guid = getGUID(hObject);%TO012309C

return;

% ------------------------------------------------------------------
%Creates a new annotation object, consisting of the specified coordinates.
function annotation = createAnnotationByPixels(hObject, coordinates, varargin)

annotation.pixels = coordinates;

if isempty(varargin)
    aspectRatio = size(getCData(hObject));
else
    aspectRatio = varargin{1};
end

cdata = zeros(aspectRatio);
cdata(coordinates) = 1;
[y, x] = ind2sub(size(cdata), coordinates(1));
%TO012708A - Added a morphological bridge, to close small gaps. -- Tim O'Connor 1/27/09
%TO012809A - Only attempt to close gaps if there are gaps in the first place. Note that this is a pretty involved operation, for the simplicity of the statement. -- Tim O'Connor 1/28/09
% if length(unique(bwlabel(cdata, 8))) > 3
    annotation.boundary = bwtraceboundary(bwmorph(cdata, 'bridge', Inf), [y, x], 'NE', 8, Inf, 'clockwise');
% else
%     annotation.boundary = bwtraceboundary(cdata, [y, x], 'NE', 8, Inf, 'clockwise');
% end

annotation.guid = getGUID(hObject);%TO012309C

return;

% ------------------------------------------------------------------
function [labels, nlabels] = autoDetect(hObject, cdata)

[diskFilterRadius, xcorrThreshold, minObjectSize] = getLocalBatch(progmanager, hObject, 'diskFilterRadius', 'xcorrThreshold', 'minObjectSize');

%Create a 2D filter.
% diskFilterRadius = 2;
diskFilter = fspecial('disk', diskFilterRadius) > 0;
diskFilter = padarray(diskFilter, [2 2], 'both');

%Cross-correlation.
% xcorrThreshold = 0.4;
xcorred = normxcorr2(diskFilter, cdata) > xcorrThreshold;

%Trim the cross correlated array (the filter had been previously padded).
len = size(diskFilter, 1);
a = round(len / 2);
b = round((len - 1) / 2);

xcorred = xcorred(a:end-b, a:end-b);

%Remove small objects.
% minObjectSize = 4;
prunedXCorred = bwareaopen(xcorred, minObjectSize);

%Label 8-connected, then 4-connected (why are we doing two labelling operations?!?)
[labels, nlabels] = bwlabel(prunedXCorred, 8);
% [labels, nlabels] = bwlabel(labels, 4);

return;

% ------------------------------------------------------------------
% Returns a cell array, with each cell being the coordinates of an autodetected object.
function objectCoords = autodetectObjects(hObject)

[borderMask] = getLocalBatch(progmanager, hObject, 'borderMask');
cdata = getCData(hObject);

[labels, nlabels] = autoDetect(hObject, cdata);

masked = cdata;
masked(1:borderMask, :) = 0;
masked(:, 1:borderMask) = 0;
masked(end-borderMask:end, :) = 0;
masked(:, end-borderMask:end) = 0;

% objectCoords = cell(nlabels, 1);
% for i = 1 : nlabels
%     objectCoords{i} = find(labels == i);
% end
objectCoords = {};
for i = 1 : nlabels
    coords = find(labels == i);
    if sum(sum(masked(coords))) >= 0.5 * sum(sum(cdata(coords)))
        objectCoords{length(objectCoords) + 1} = coords;
    end
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in autoDetect.
function autoDetect_Callback(hObject, eventdata, handles)

coords = autodetectObjects(hObject);
if isempty(coords)
    return;
end
aspectRatio = size(getCData(hObject));%Cache this, because createAnnotationByPixels's bottleneck is `getCData`.

for i = 1 : length(coords)
    annotations(i) = createAnnotationByPixels(hObject, coords{i}, aspectRatio);
end
setLocalBatch(progmanager, hObject, 'annotations', annotations, 'objectCount', length(annotations), 'annotationsAspectRatio', aspectRatio);

displayAnnotations(hObject);

setAnnotation(hObject, length(annotations));

return;

% ------------------------------------------------------------------
% --- Executes on button press in deleteObject.
function deleteObject_Callback(hObject, eventdata, handles)

[annotations, annotationHandles, currentAnnotation, numberLabelHandles] = getLocalBatch(progmanager, hObject, 'annotations', 'annotationHandles', 'currentAnnotation', 'numberLabelHandles');
% if get(annotationHandles(currentAnnotation), 'UserData') ~= get(numberLabelHandles(currentAnnotation), 'UserData')
%     fprintf(2, 'deleteObject_Callback: Error - UserData Mismatch\n  annotationHandles(%s).UserData = %s\n  numberLabelHandles(%s).UserData = %s\n', ...
%         num2str(currentAnnotation), num2str(get(annotationHandles(currentAnnotation), 'UserData')), num2str(currentAnnotation), num2str(get(numberLabelHandles(currentAnnotation), 'UserData')));
%     mismatches = [];
%     for i = 1 : length(annotationHandles)
%         if get(annotationHandles(i), 'UserData') ~= get(numberLabelHandles(i), 'UserData')
%             mismatches(end + 1) = i;
%         end
%     end
%     fprintf(2, '                               Mismatches found for objects: %s\n', mat2str(mismatches));
% end

%TO012309A - Nevermind TO012209A, we talked on the phone and plans have changed.
%TO012209A - Deleting can't remove elements, because Takaki wants the numbering to remain consistent. -- Tim O'Connor 1/22/09
indices = cat(2, 1 : currentAnnotation - 1, currentAnnotation + 1 : length(annotations));
if ~isempty(annotations)
    annotations = annotations(indices);
end
% annotations(currentAnnotation).pixels = [];
% annotations(currentAnnotation).boundary = [];

if ~isempty(annotationHandles)
    delete(annotationHandles(currentAnnotation));
    %annotationHandles(currentAnnotation) = [];
    annotationHandles = annotationHandles(indices);
end

%To012709B
if ~isempty(numberLabelHandles)
    delete(numberLabelHandles(currentAnnotation));
    numberLabelHandles = numberLabelHandles(indices);
    for i = currentAnnotation : length(numberLabelHandles)
        set(numberLabelHandles(i), 'String', num2str(i));
    end
end

if isempty(annotations)
    currentAnnotation = -1;
elseif currentAnnotation < length(annotations)
    currentAnnotation = currentAnnotation + 1;
elseif currentAnnotation > 1
    currentAnnotation = currentAnnotation - 1;
else
    currentAnnotation = -1;
end

setLocalBatch(progmanager, hObject, 'annotations', annotations, 'annotationHandles', annotationHandles, 'objectCount', length(annotations), 'numberLabelHandles', numberLabelHandles);
setAnnotation(hObject, currentAnnotation);

return;

% ------------------------------------------------------------------
% --- Executes on slider movement.
function objectNumberSlider_Callback(hObject, eventdata, handles)

[currentAnnotation, objectNumberSlider, objectCount] = getLocalBatch(progmanager, hObject, 'currentAnnotation', 'objectNumberSlider', 'objectCount');
setLocal(progmanager, hObject, 'objectNumberSlider', 0.5);

if objectNumberSlider < 0.5
    if currentAnnotation > 1
        currentAnnotation = currentAnnotation - 1;
    end
elseif objectNumberSlider > 0.5
    if currentAnnotation < objectCount
        currentAnnotation = currentAnnotation + 1;
    end
end

setAnnotation(hObject, currentAnnotation);

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function objectNumberSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
return;

% ------------------------------------------------------------------
function selectAnnotation(currentObject, eventdata, hObject, nextCallback)

[annotationHandles] = getLocalBatch(progmanager, hObject, 'annotationHandles');

currentAnnotation = find(gcbo == annotationHandles);
if isempty(annotationHandles)
   currentAnnotation = 0;
end

setAnnotation(hObject, currentAnnotation);

feval(nextCallback{1}, gcbo, [], nextCallback{2:end});%Execute any mouse movements (drag/stretch).

return;

% ------------------------------------------------------------------
function setAnnotation(hObject, annotationIndex)

setLocal(progmanager, hObject, 'currentAnnotation', annotationIndex);
objectNumber_Callback(hObject, [], []);

return;

% ------------------------------------------------------------------
function objectNumber_Callback(hObject, eventdata, handles)

[annotations, currentAnnotation, annotationHandles] = getLocalBatch(progmanager, hObject, 'annotations', 'currentAnnotation', 'annotationHandles');

%TO012209A
if isempty(currentAnnotation)
    return;
end

if currentAnnotation > length(annotations)
    currentAnnotation = length(annotations);
    setLocal(progmanager, hObject, 'currentAnnotation', currentAnnotation);
elseif currentAnnotation < 1 && ~isempty(annotations)
    currentAnnotation = 1;
elseif currentAnnotation < 1
    currentAnnotation = 0;
    setLocal(progmanager, hObject, 'currentAnnotation', currentAnnotation);
end

set(annotationHandles(ishandle(annotationHandles)), 'Color', [.2, 1, .2]);%TO012209A
if currentAnnotation >=1 && currentAnnotation <= length(annotationHandles) && ~isempty(annotationHandles)
    if ishandle(annotationHandles(currentAnnotation))
        set(annotationHandles(currentAnnotation), 'Color', [1, 0, 0]);
        %f = fill(annotations(currentAnnotation).boundary(:, 2), annotations(currentAnnotation).boundary(:, 1), 'r');
    end
end

% numberLabelHandles = getLocal(progmanager, hObject, 'numberLabelHandles');
% if get(annotationHandles(currentAnnotation), 'UserData') ~= get(numberLabelHandles(currentAnnotation), 'UserData')
%     fprintf(2, 'objectNumber_Callback: Error - UserData Mismatch\n  annotationHandles(%s).UserData = %s\n  numberLabelHandles(%s).UserData = %s\n', ...
%         num2str(currentAnnotation), num2str(get(annotationHandles(currentAnnotation), 'UserData')), num2str(currentAnnotation), num2str(get(numberLabelHandles(currentAnnotation), 'UserData')));
%     for i = 1 : length(annotationHandles)
%         if get(annotationHandles(i), 'UserData') ~= get(numberLabelHandles(i), 'UserData')
%             mismatches(end + 1) = i;
%         end
%     end
%     fprintf(2, '                               Mismatches found for objects: %s\n', mat2str(mismatches));
% end

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function objectNumber_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% ------------------------------------------------------------------
% --- Executes on button press in manualAdd.
function manualAdd_Callback(hObject, eventdata, handles)

[annotations, annotationHandles, imageAxes, numberLabelHandles] = getLocalBatch(progmanager, hObject, 'annotations', 'annotationHandles', 'imageAxes', 'numberLabelHandles');

[x, y] = getPointsFromAxes(imageAxes);%TO031910D
x(end + 1) = x(1);
y(end + 1) = y(1);

if isempty(annotations)
    annotations = createAnnotationByBoundary(hObject, cat(2, y, x));
else
    annotations(end + 1) = createAnnotationByBoundary(hObject, cat(2, y, x));
end

if isempty(annotationHandles)
    [h, label] = displayAnnotation(hObject, annotations(end), length(annotations));
    annotationHandles = h;
    numberLabelHandles = label;
else
     [h, label] = displayAnnotation(hObject, annotations(end), length(annotations));
     annotationHandles(end + 1) = h;
     numberLabelHandles(end + 1) = label;
end

setLocalBatch(progmanager, hObject, 'annotations', annotations, 'objectCount', length(annotations), 'annotationHandles', annotationHandles, 'annotationsAspectRatio', size(getCData(hObject)), 'numberLabelHandles', numberLabelHandles);
setAnnotation(hObject, length(annotations));

return;

% ------------------------------------------------------------------
function diskFilterRadius_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function diskFilterRadius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% ------------------------------------------------------------------
function xcorrThreshold_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function xcorrThreshold_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% ------------------------------------------------------------------
function minObjectSize_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function minObjectSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% ------------------------------------------------------------------
%TO041509A - Allow all objects to be moved en-masse. -- Tim O'Connor 4/15/09
%TO041609A
function keyPressFcn(currentObject, eventdata, hObject)

[annotations, annotationHandles, currentAnnotation, originalMoveAll] = getLocalBatch(progmanager, hObject, 'annotations', 'annotationHandles', 'currentAnnotation', 'moveAll');
if isempty(eventdata.Modifier)
    eventdata.Modifier = '';
end

%TO041609A
if any(strcmpi(eventdata.Modifier, 'shift'))
    stepSize = 10;%pixels
else
    stepSize = 1;%pixels
end
switch eventdata.Key
    case {'uparrow', 'w'}
        %TO041509A
        if any(strcmpi(eventdata.Modifier, 'control'))
            setLocal(progmanager, hObject, 'moveAll', 1);
            annotationMove_Callback(hObject, annotationHandles(currentAnnotation), [0, -stepSize], 'drag');
            setLocal(progmanager, hObject, 'moveAll', originalMoveAll);
        else
            annotationMove_Callback(hObject, annotationHandles(currentAnnotation), [0, -stepSize], 'drag');
        end
    case {'downarrow', 's'}
        %TO041509A
        if any(strcmpi(eventdata.Modifier, 'control'))
            setLocal(progmanager, hObject, 'moveAll', 1);
            annotationMove_Callback(hObject, annotationHandles(currentAnnotation), [0, stepSize], 'drag');
            setLocal(progmanager, hObject, 'moveAll', originalMoveAll);
        else
            annotationMove_Callback(hObject, annotationHandles(currentAnnotation), [0, stepSize], 'drag');
        end
    case {'leftarrow', 'a'}
        %TO041509A
        if any(strcmpi(eventdata.Modifier, 'control'))
            setLocal(progmanager, hObject, 'moveAll', 1);
            annotationMove_Callback(hObject, annotationHandles(currentAnnotation), [-stepSize, 0], 'drag');
            setLocal(progmanager, hObject, 'moveAll', originalMoveAll);
        else
            annotationMove_Callback(hObject, annotationHandles(currentAnnotation), [-stepSize, 0], 'drag');
        end
    case {'rightarrow', 'd'}
        %TO041509A
        if any(strcmpi(eventdata.Modifier, 'control'))
            setLocal(progmanager, hObject, 'moveAll', 1);
            annotationMove_Callback(hObject, annotationHandles(currentAnnotation), [stepSize, 0], 'drag');
            setLocal(progmanager, hObject, 'moveAll', originalMoveAll);
        else
            annotationMove_Callback(hObject, annotationHandles(currentAnnotation), [stepSize, 0], 'drag');
        end
    case {'backspace', 'delete'}
        deleteObject_Callback(hObject, [], []);
    case 'x'
        if strcmpi(eventdata.Modifier, 'control')
            deleteObject_Callback(hObject, [], []);
        end
    case 'n'
        if strcmpi(eventdata.Modifier, 'control')
            manualAdd_Callback(hObject, [], []);
        end
    case 'h'
        if strcmpi(eventdata.Modifier, 'control')
            hintDetect(hObject);
        end
    case 'i'
        if strcmpi(eventdata.Modifier, 'control')
            fileBrowse_Callback(hObject, [], []);
        end
    case 'o'
        if strcmpi(eventdata.Modifier, 'control')
            genericOpenData(hObject, [], []);
        end
    case 's'
        if strcmpi(eventdata.Modifier, 'control')
            genericSaveDataAs(hObject, [], []);
        end
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in hintAdd.
function hintAdd_Callback(hObject, eventdata, handles)

hintDetect(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in deleteAll.
function deleteAll_Callback(hObject, eventdata, handles)

[annotations, annotationHandles, numberLabelHandles] = getLocalBatch(progmanager, hObject, 'annotations', 'annotationHandles', 'numberLabelHandles');

if ~isempty(annotationHandles) && any(ishandle(annotationHandles))
    delete(annotationHandles(ishandle(annotationHandles)));
    annotationHandles = [];
    
    %TO012709B
    if any(ishandle(numberLabelHandles))
        delete(numberLabelHandles(ishandle(numberLabelHandles)));
    end
end

setLocalBatch(progmanager, hObject, 'annotations', [], 'annotationHandles', [], 'currentAnnotation', -1, 'objectCount', 0, 'numberLabelHandles', []);

return;

% ------------------------------------------------------------------
% --- Executes on button press in forceAspectRatioSquare.
function forceAspectRatioSquare_Callback(hObject, eventdata, handles)

updateFrame(hObject);

return;

% ------------------------------------------------------------------
% --- Executes on button press in showObjects.
function showObjects_Callback(hObject, eventdata, handles)

[showObjects, annotationHandles, numberLabelHandles, showNumberLabels] = getLocalBatch(progmanager, hObject, 'showObjects', 'annotationHandles', 'numberLabelHandles', 'showNumberLabels');

if ~isempty(annotationHandles)
    if showObjects
        set(annotationHandles(ishandle(annotationHandles)), 'Visible', 'On');
    else
        set(annotationHandles(ishandle(annotationHandles)), 'Visible', 'Off');
    end
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in averageFrames.
function averageFrames_Callback(hObject, eventdata, handles)

loadImage(hObject);

return;

% ------------------------------------------------------------------
function averageRange_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function averageRange_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


% ------------------------------------------------------------------
function borderMask_Callback(hObject, eventdata, handles)

return;

% ------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function borderMask_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

% ------------------------------------------------------------------
% --- Executes on button press in showLabels.
function showLabels_Callback(hObject, eventdata, handles)

[showObjects, numberLabelHandles, showNumberLabels] = getLocalBatch(progmanager, hObject, 'showObjects', 'numberLabelHandles', 'showNumberLabels');

if ~isempty(numberLabelHandles)
    if showObjects
        if showNumberLabels
            set(numberLabelHandles(ishandle(numberLabelHandles)), 'Visible', 'On');
        else
            set(numberLabelHandles(ishandle(numberLabelHandles)), 'Visible', 'Off');
        end
    else
        set(numberLabelHandles(ishandle(numberLabelHandles)), 'Visible', 'Off');
    end
end

return;

% ------------------------------------------------------------------
% --- Executes on button press in moveAll.
%TO031309D - Allow all objects to be moved together, en masse.
function moveAll_Callback(hObject, eventdata, handles)
return;