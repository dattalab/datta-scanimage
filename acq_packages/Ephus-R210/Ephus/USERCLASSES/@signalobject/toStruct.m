% SIGNAL/toStruct - Converts this object into a simplified structure.
%
% SYNTAX
%  strct = toStruct(SIGNAL) - Create a simplified structure.
%
% NOTES
%  Copy & paste job from @signalobject/getdata.m and @signalobject/private/getRecursiveData.m
%
% CHANGES
%  TO060108C - Delete linked children, when using recursive signals. -- Tim O'Connor 6/1/08
%  VI052908A - Typo fixes. -- Vijay Iyer 5/29/08
%  TO061110C - Promoted stepFcn to a formal type. -- Tim O'Connor 6/11/10
%  TO061110D - Filled in missing part of the raster implementation. -- Tim O'Connor 6/11/10
%
% Created 5/5/06 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function strct = toStruct(this)
global signalobjects;

pointer = indexOf(this);

strct.type = signalobjects(pointer).type;
strct.instantiationTime = signalobjects(pointer).instantiationTime;
if signalobjects(pointer).saveTime ~= -1
    strct.saveTime = signalobjects(pointer).saveTime;
end
if signalobjects(pointer).loadTime ~= -1
    strct.loadTime = signalobjects(pointer).loadTime;
end
strct.version = 1.0;%signalobjects(pointer).version;
strct.name = signalobjects(pointer).name;
if signalobjects(pointer).length ~= -1
    strct.length = signalobjects(pointer).length;
    strct.repeatable = signalobjects(pointer).repeatable;
end
strct.sampleRate = signalobjects(pointer).sampleRate;

linkedChildren = 0;

switch lower(signalobjects(pointer).type)
    case 'analytic'
        strct.amplitude = signalobjects(pointer).amplitude;
        strct.offset = signalobjects(pointer).offset;
        strct.phi = signalobjects(pointer).phi;
        strct.symmetry = signalobjects(pointer).symmetry;
        strct.periodic = signalobjects(pointer).periodic;
        if signalobjects(pointer).periodic
            strct.frequency = signalobjects(pointer).frequency;
            strct.waveform = signalobjects(pointer).waveform;
        end
        strct.equational = signalobjects(pointer).equational;
        if signalobjects(pointer).equational
           strct.equation = signalobjects(pointer).equation; %VI052908A
        end
        strct.distributional = signalobjects(pointer).distributional;
        if signalobjects(pointer).distributional
            strct.distribution = signalobjects(pointer).distribution;
            strct.arg1 = signalobjects(pointer).arg1;
            strct.arg2 = signalobjects(pointer).arg2;
            strct.arg3 = signalobjects(pointer).arg3;
        end

    case 'literal'
        strct.repeatable = signalobjects(pointer).repeatable;
        strct.signal = signalobjects(pointer).signal;
        strct.noPadding = signalobjects(pointer).noPadding; %VI052908A

    case 'functional'
        strct.fcn = signalobjects(pointer).fcnTakesArgs;
        if ischar(signalobjects(pointer).fcn)
            strct.fcn = signalobjects(pointer).fcn;
        elseif iscell(signalobjects(pointer).fcn)
            strct.fcn = signalobjects(pointer).fcn;
        elseif strcmpi(class(signalobjects(pointer).fcn), 'function_handle')
            strct.fcn = signalobjects(pointer).fcn;
        end

    case 'functionalwithargs'
        strct.fcn = signalobjects(pointer).fcnTakesArgs;
        if ischar(signalobjects(pointer).fcn)
            strct.fcn = signalobjects(pointer).fcn;
        elseif iscell(signalobjects(pointer).fcn)
            strct.fcn = signalobjects(pointer).fcn;
        elseif strcmpi(class(signalobjects(pointer).fcn), 'function_handle')
            strct.fcn = signalobjects(pointer).fcn;
        end
        
    case 'recursive'
        linkedChildren = 0;%TO102605C
        %TO101305A - Load children from disk, if neccessary.
        if strcmpi(class(signalobjects(pointer).children), 'signalobject')
            kids = signalobjects(pointer).children;
        else
            linkedChildren = 1;%TO102605C
            for i = 1 : length(signalobjects(pointer).children)
                loaded = load(signalobjects(pointer).children{i}, '-mat');
                kids(i) = loaded.signal;
            end
        end
        for i = 1 : length(kids)
            strct.children{i} = toStruct(kids(i));
            %TO060108C
            if linkedChildren
                delete(kids(i));
            end
        end
        strct.phaseUnits = signalobjects(pointer).phaseUnits;
        strct.signalPhaseShift = signalobjects(pointer).signalPhaseShift;
        strct.method = signalobjects(pointer).method;
        
    case 'squarepulsetrain'
        strct.amplitude = signalobjects(pointer).amplitude;
        strct.offset = signalobjects(pointer).offset;
        strct.squarePulseTrainNumber = signalobjects(pointer).squarePulseTrainNumber;
        strct.squarePulseTrainISI = signalobjects(pointer).squarePulseTrainISI;
        strct.squarePulseTrainWidth = signalobjects(pointer).squarePulseTrainWidth;
        strct.squarePulseTrainDelay = signalobjects(pointer).squarePulseTrainDelay;

    %TO120809A TO061110D
    case 'raster'
        strct.amplitude = signalobjects(pointer).amplitude;
        strct.offset = signalobjects(pointer).offset;
        strct.phi = signalobjects(pointer).phi;
        strct.rasterLinesPerFrame = signalobjects(pointer).rasterLinesPerFrame;
        strct.rasterAxis = signalobjects(pointer).rasterAxis;
        strct.rasterInterFrameInterval = signalobjects(pointer).rasterInterFrameInterval;
        strct.rasterPark = signalobjects(pointer).rasterPark;
        strct.rasterNumberOfFrames = signalobjects(pointer).rasterNumberOfFrames;

    %TO061110C
    case 'stepfcn'
        strct.amplitude = signalobjects(pointer).amplitude;
        strct.offset = signalobjects(pointer).offset;
        strct.stepFcnOnsetTimes = signalobjects(pointer).stepFcnOnsetTimes;
        strct.stepFcnWidths = signalobjects(pointer).stepFcnWidths;

    otherwise
        error('This @signal object ''%s'' does not have a type (analytic, literal, functional, functionalWithArgs) specified. No data is available.', ...
            signalobjects(pointer).name);
end

%TO102605C
if linkedChildren
    for i = 1 : length(kids)
        delete(kids(i));
    end
end

return;

%---------------------------------------------------------------
function data = getFunctionalData(pointer)

error('NOT_YET_IMPLEMENTED and/or DEPRECATED');

if strcmpi(class(signalobjects(pointer).fcn), 'char')
    data = eval(signalobjects(pointer).fcn);
elseif strcmpi(class(signalobjects(pointer).fcn), 'cell')
    data = feval(signalobjects(pointer).fcn);
elseif strcmpi(class(signalobjects(pointer).fcn), 'function_handle')
    data = feval(signalobjects(pointer).fcn);
end

return;

%---------------------------------------------------------------
function data = getFunctionalDataWithArgs(pointer)

error('NOT_YET_IMPLEMENTED and/or DEPRECATED');

data = [];

return;