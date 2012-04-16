% Renders supplied object identical to one which created, via toStruct(), a supplied structure
%
% USAGE
%   this = fromStruct(this,structVal)
%
% NOTES
%   This is a companion function of signalobject\toStruct()
%   toStruct() represents the signalobject data in a more compact fashion
%   
%   Because this is not based on Matlab's new MCOS OOP system, this function is implemented as an ordinary (non-static) method. 
%   Thus, it must take a pre-created (generally empty) @signalobject as an argument.
%
% CHANGES
%  TO061110C - Promoted stepFcn to a formal type. -- Tim O'Connor 6/11/10
%  TO061110D - Filled in missing part of the raster implementation. -- Tim O'Connor 6/11/10
%  TO061110E - General cleanup (unused/unnecessary variables, trailing whitespace, readability: spaces after commas, consistent space around operators, etc). -- Tim O'Connor 6/11/10
%
% CREDITS
%  Created 5/29/2008 -- Vijay Iyer
%
%  Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function this = fromStruct(this, structVal)

set(this, 'Type', structVal.type);
setDefaultsByType(this);

switch lower(structVal.type)    
    case 'analytic'
        set(this, 'amplitude', structVal.amplitude, 'offset', structVal.offset, 'phi', structVal.phi, ...
            'periodic', structVal.periodic, 'equational', structVal.equational, 'distributional', structVal.distributional);
        
        if structVal.periodic
            set(this, 'frequency', structVal.frequency, 'waveform', structVal.waveform);
        end

        if structVal.equational
            set(this, 'equation', structVal.equation);
        end

        if structVal.distributional
            set(this, 'distribution', structVal.distribution, 'arg1', structVal.arg1, 'arg2', structVal.arg2, 'arg3', structVal.arg3);
        end

    case 'literal'
        set(this, 'repeatable', structVal.repeatable, 'signal', structVal.signal, 'noPadding', structVal.noPadding);                

    case 'functional'
        error(['signalObjects of type ''' structVal.type ''' not presently handled by fromStruct()']);

    case 'functionalwithargs'
        error(['signalObjects of type ''' structVal.type ''' not presently handled by fromStruct()']);        

    case 'recursive'
        kidObjs = [];
        for i = 1 : length(structVal.children)
            kidObjs = [fromStruct(signalobject(), structVal.children{i}), kidObjs];
        end
        set(this, 'children', kidObjs);
        set(this, 'phaseUnits', structVal.phaseUnits, 'signalPhaseShift', structVal.signalPhaseShift, 'method', structVal.method);

    case 'squarepulsetrain'
        set(this, 'amplitude', structVal.amplitude, 'offset', structVal.offset, 'squarePulseTrainNumber', structVal.squarePulseTrainNumber, ...
            'squarePulseTrainISI', structVal.squarePulseTrainISI, 'squarePulseTrainWidth', structVal.squarePulseTrainWidth, 'squarePulseTrainDelay', structVal.squarePulseTrainDelay);

    case 'raster'
        set(this, 'amplitude', structVal.amplitude, 'offset', structVal.offset, 'phi', structVal.phi, 'rasterLinesPerFrame', structVal.rasterLinesPerFrame, ...
            'rasterAxis', structVal.rasterAxis, 'rasterInterFrameInterval', structVal.rasterInterFrameInterval, 'rasterPark', structVal.rasterPark, ...
            'rasterNumberOfFrames', structVal.rasterNumberOfFrames);

    case 'stepfcn'
        set(this, 'amplitude', structVal.amplitude, 'offset', structVal.offset, 'stepFcnOnsetTimes', structVal.stepFcnOnsetTimes, 'stepFcnWidths', structVal.stepFcnWidths);

    otherwise
        error('The structure provided does not pertain to a recognized @signalobject type');
end

%set(this,'instantiationTime',structVal.instantiationTime,'saveTime',structVal.saveTime,'loadTime',structVal.loadTime);
set(this, 'Name', structVal.name);
if isfield(structVal,'length')
    set(this, 'length', structVal.length, 'repeatable', structVal.repeatable);
end

set(this, 'sampleRate', structVal.sampleRate);

return;