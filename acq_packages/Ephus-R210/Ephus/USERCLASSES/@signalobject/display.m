% SIGNAL/display - Return a string describing the state of this object.
%
% CHANGES
%  Added the squarePulseTrain type, to simply port over the parameters from the original Physiology software. -- Tim O'Connor 5/2/05 TO050205A
%  Watch out for empty type field in a switch statement, it'll choke it. -- Tim O'Connor 8/11/05 TO081105A
%  Print out the handle pointer. -- Tim O'Connor 6/28/06 TO062806I
%  Dereference pointers to children before accessing their fields. -- Tim O'Connor 6/28/06 TO062806J
%  Handle children in referenced files. See TO102605C in @signalobject/private/getRecursiveData. -- Tim O'Connor 8/6/06 TO080606C
%  Added a 'raster' type. -- Tim O'Connor 12/08/09 TO120809A
%  Added a version field. -- Tim O'Connor 3/3/10 TO030310B
%  Promoted 'stepFcn' to a full-fledged type. -- Tim O'Connor 6/11/10 TO061110C
%
% Created 10/22/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function varargout = display(this)
global signalobjects;

if length(this) > 1
    description = sprintf('@signal Object v0.1\n [%s] array of pointers\n', num2str(size(this)));
    for i = 1 : length(this)
        pointer = indexOf(this(i));
        description = sprintf('%s  ''%s''\n', description, signalobjects(pointer).name);
    end
    
    if nargout == 1
        varargout{1} = description;
    elseif nargout > 1
        error('Too many output arguments.');
    end
    
    fprintf(1, '%s', description);
    return;
end

pointer = indexOf(this);

description = sprintf('@signal Object v%2.1f\nHandlePointer: %s\nObjectPointer: %s\n Name: ''%s''\n', signalobjects(pointer).version, ...
    num2str(this.ptr), num2str(pointer), signalobjects(pointer).name);%TO030310B
description = sprintf('%s Common Options - \n', description);
description = sprintf('%s   Cache: %s\n', description, num2str(signalobjects(pointer).cache));
description = sprintf('%s   EagerCacheGeneration: %s\n', description, num2str(signalobjects(pointer).eagerCacheGeneration));
if signalobjects(pointer).length < 0
    description = sprintf('%s   Length: INFINITE\n', description);
else
    description = sprintf('%s   Length: %s [s]\n', description, num2str(signalobjects(pointer).length));
end
description = sprintf('%s   SampleRate: %s [Hz]\n', description, num2str(signalobjects(pointer).sampleRate));
description = sprintf('%s   Repeatable: %s\n', description, num2str(signalobjects(pointer).repeatable));
description = sprintf('%s   Phase Units: %s\n', description, signalobjects(pointer).phaseUnits);
description = sprintf('%s Debugging Options - \n', description);
description = sprintf('%s   DebugMode: %s\n', description, num2str(signalobjects(pointer).debugMode));
description = sprintf('%s   EagerWarningMode: %s\n', description, num2str(signalobjects(pointer).eagerWarningMode));
description = sprintf('%s   PlotAnalyticSignalGeneration: %s\n', description, num2str(signalobjects(pointer).plotAnalyticSignalGeneration));
description = sprintf('%s Specification Parameters -\n', description);
description = sprintf('%s   Type: %s\n', description, signalobjects(pointer).type);

% description = sprintf('%s   ', description);
%TO081105A
if isempty(signalobjects(pointer).type)
    description = sprintf('%s   NO_SIGNAL_PARAMETERS_SPECIFIED\n', description);
    fprintf(1, '%s', description);
    return;
end

switch lower(signalobjects(pointer).type)
    case ''
        %Nothing more to see here, move along.
        description = sprintf('%s   NO_SIGNAL_PARAMETERS_SPECIFIED\n', description);
        
    case 'analytic'
        if signalobjects(pointer).periodic            
            description = sprintf('%s   Subtype: periodic\n', description);
            description = sprintf('%s   Waveform: %s\n', description, signalobjects(pointer).waveform);
            description = sprintf('%s   Amplitude: %s\n', description, num2str(signalobjects(pointer).amplitude));
            description = sprintf('%s   Offset: %s\n', description, num2str(signalobjects(pointer).offset));
            description = sprintf('%s   Frequency: %s\n', description, num2str(signalobjects(pointer).frequency));
            description = sprintf('%s   Phi: %s\n', description, num2str(signalobjects(pointer).phi));
            description = sprintf('%s   Symmetry: %s\n', description, num2str(signalobjects(pointer).symmetry));            
        elseif signalobjects(pointer).equational
            description = sprintf('%s   Subtype: equational\n', description);
            description = sprintf('%s   Equation: %s\n', description, signalobjects(pointer).equation);            
        elseif signalobjects(pointer).distributional
            description = sprintf('%s   Subtype: distributional\n', description);
            description = sprintf('%s   Distribution: %s\n', description, signalobjects(pointer).distribution);
            description = sprintf('%s   Amplitude: %s\n', description, num2str(signalobjects(pointer).amplitude));
            description = sprintf('%s   Offset: %s\n', description, num2str(signalobjects(pointer).offset));
            description = sprintf('%s   Arg1: %s\n', description, signalobjects(pointer).arg1);
            description = sprintf('%s   Arg2: %s\n', description, signalobjects(pointer).arg2);
            description = sprintf('%s   Arg3: %s\n', description, signalobjects(pointer).arg3);
        else
            description = sprintf('%s   Subtype: unspecified\n', description);
        end

    case 'literal'
        description = sprintf('%s   Data: %s array of class %s\n', description, ...
            num2str(size(signalobjects(pointer).signal)), class(signalobjects(pointer).signal));

    case 'functional'
        description = sprintf('%s   Type: Functional\n', description);

    case 'functionalwithargs'
        description = sprintf('%s   Type: FunctionalWithArgs\n', description);

    case 'recursive'
        description = sprintf('%s   Method: %s\n', description, signalobjects(pointer).method);
        description = sprintf('%s   Children -\n', description);
        %TO080606C - Handle children in referenced files. See TO102605C.
        if isempty(signalobjects(pointer).children)
            description = sprintf('%s     %s: %s @ %s samples/second\n', description, signalobjects(indexOf(signalobjects(pointer).children(i))).name, ...
                signalobjects(indexOf(signalobjects(pointer).children(i))).type, num2str(signalobjects(indexOf(signalobjects(pointer).children(i))).sampleRate));
        else
            linkedChildren = 0;%TO080606C - TO102605C
            if strcmpi(class(signalobjects(pointer).children), 'cell')
                %TO080606C - TO101305A - Load children from disk, if neccessary.
                linkedChildren = 1;%TO080606C - TO102605C
                children = signalobjects(pointer).children;
                for i = 1 : length(signalobjects(pointer).children)
                    loaded = load(signalobjects(pointer).children{i}, '-mat');
                    kids(i) = loaded.signal;
                end
                signalobjects(pointer).children = kids;
            end
            
            for i = 1 : length(signalobjects(pointer).children)
                %TO062806J
                description = sprintf('%s     %s: %s @ %s samples/second\n', description, signalobjects(indexOf(signalobjects(pointer).children(i))).name, ...
                    signalobjects(indexOf(signalobjects(pointer).children(i))).type, num2str(signalobjects(indexOf(signalobjects(pointer).children(i))).sampleRate));
            end
            
            %TO080606C - TO102605C
            if linkedChildren
                for i = 1 : length(kids)
                    delete(kids(i));
                end
                signalobjects(pointer).children = children;
            end   
        end
        
    case 'squarepulsetrain'
        %TO050205A
        description = sprintf('%s   Number: %s\n', description, num2str(signalobjects(pointer).squarePulseTrainNumber));
        description = sprintf('%s   Inter-Stimulus Interval: %s\n', description, num2str(signalobjects(pointer).squarePulseTrainISI));
        description = sprintf('%s   Width: %s\n', description, num2str(signalobjects(pointer).squarePulseTrainWidth));
        description = sprintf('%s   Amplitude: %s\n', description, num2str(signalobjects(pointer).amplitude));
        description = sprintf('%s   Delay: %s\n', description, num2str(signalobjects(pointer).squarePulseTrainDelay));

    case 'raster'
        %TO120809A
        description = sprintf('%s   Amplitude: %s\n', description, num2str(signalobjects(pointer).amplitude));
        description = sprintf('%s   Offset: %s\n', description, num2str(signalobjects(pointer).offset));
        description = sprintf('%s   msPerLine: %s\n', description, num2str(1000 / signalobjects(pointer).frequency));
        description = sprintf('%s   linesPerFrame: %s\n', description, num2str(signalobjects(pointer).rasterLinesPerFrame));
        description = sprintf('%s   Delay: %s\n', description, num2str(signalobjects(pointer).phi));
        description = sprintf('%s   InterFrameInterval: %s\n', description, num2str(signalobjects(pointer).rasterInterFrameInterval));
        description = sprintf('%s   Axis: %s\n', description, signalobjects(pointer).rasterAxis);
        description = sprintf('%s   ParkPosition: %s\n', description, num2str(signalobjects(pointer).rasterPark));
        description = sprintf('%s   NumberOfFrames: %s\n', description, num2str(signalobjects(pointer).rasterNumberOfFrames));

    case 'squarepulsetrain'
        %TO061110C
        description = sprintf('%s   Amplitude(s): %s\n', description, mat2str(signalobjects(pointer).amplitude));
        description = sprintf('%s   Offset: %s\n', description, num2str(signalobjects(pointer).offset));
        description = sprintf('%s   Onset Times(s): %s\n', description, mat2str(signalobjects(pointer).stepFcnOnsetTimes));
        description = sprintf('%s   Width(s): %s\n', description, mat2str(signalobjects(pointer).stepFcnWidths));
        
    otherwise
        description = sprintf('%s  UNRECOGNIZED_TYPE\n', description);
end        

if nargout == 1
    varargout{1} = description;
elseif nargout > 1
    error('Too many output arguments.');
end

fprintf(1, '%s', description);

return;