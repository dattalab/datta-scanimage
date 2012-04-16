% SIGNAL/GETDATA - Retrieve a raw numeric array of SIGNAL data.
%
% SYNTAX
%  data = getdata(SIGNAL) - Gets a signal consisting of SIGNAL.length datapoints.
%  data = getdata(SIGNAL, time) - Gets (time / SIGNAL.sampleRate) datapoints of SIGNAL, repeating the 
%                                    signal if SIGNAL.length is less than (time / SIGNAL.sampleRate) and SIGNAL.repeatable is true.
%                                    If SIGNAL.length is less than (time / SIGNAL.sampleRate) and SIGNAL.repeatable is false, an array of
%                                    length SIGNAL.length is returned and a warning is issued.
%  data = getdata(SIGNAL, samples, 'Samples') - Gets samples datapoints of SIGNAL, repeating the 
%                                    signal if SIGNAL.length is less than samples and SIGNAL.repeatable is true.
%                                    If SIGNAL.length is less than samples and SIGNAL.repeatable is false, an array of
%                                    length SIGNAL.length is returned and a warning is issued.
%
% Changed:
%  2/3/05 Tim O'Connor (TO020305d): Added the noPadding variable.
%  Added the squarePulseTrain type, to simply port over the parameters from the original Physiology software. -- Tim O'Connor 5/2/05 TO050205A
%  8/11/05 Tim O'Connor (TO081105B): Fixed multiple improper uses of this.ptr instead of pointer.
%  6/28/06 Tim O'Connor (TO062806K): Enforce length constraint.
%  TO111006A: Fixed calculation of number of samples. -- Tim O'Connor 11/10/06
%  TO101707H: Vectorize (operate on arrays of signalobjects). An Nx1 array should produce (N * time) samples. -- Tim O'Connor 10/17/07
%  TO033108D - Add support for multiline/multibit digital data. -- Tim O'Connor 3/31/08
%  TO060208D - Allow the length to be shorter than the requested time if it's a repetable signal. -- Tim O'Connor 6/2/08
%  TO120809A - Added a 'raster' type. -- Tim O'Connor 12/08/09
%  TO061110C - Promoted 'stepFcn' to a full-fledged type. -- Tim O'Connor 6/11/10
%
% Created 8/19/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function data = getdata(this, time, varargin)
global signalobjects;

pointer = indexOf(this(1));%TO101707H

unitsInSamples = 0;
data = [];

%TO101707H: Vectorize (operate on arrays of signalobjects). An Nx1 array should produce (N * time) samples. -- Tim O'Connor 10/17/07
if length(this) > 1
    pointer1 = pointer;
    %First check for consistency.
    sampleRate = signalobjects(pointer).sampleRate;
    for i = 1 : length(this)
        pointer = indexOf(this(i));
        if sampleRate ~= signalobjects(pointer).sampleRate
            error('Mismatched sample rates for array of @signalobjects. Calls to @signalobject/getdata using arrays of @signalobjects must have uniform sample rates across instances.');
        end
    end
    pointer = pointer1;
end

if ~isempty(varargin)
    if length(varargin) > 1
        error('Matlab:badopt', 'Too many input arguments.');
    end
    if strcmpi(varargin{1}, 'samples')
        samples = time;
        time = samples * signalobjects(pointer).sampleRate;
    elseif ischar(varargin{1})
        error('Matlab:badopt', 'Invalid string argument ''%s''.', varargin{1});
    else
        error('Matlab:badopt', 'Invalid argument type ''%s''.', class(varargin{1}));
    end
else
    samples = time * signalobjects(pointer).sampleRate;%TO111006A
end


%TO101707H: Vectorize (operate on arrays of signalobjects). An Nx1 array should produce (N * time) samples. -- Tim O'Connor 10/17/07
if length(this) > 1
    data = zeros(samples * length(this), 1);
    offset = 1;
    for i = 1 : length(this)
        data(offset : samples) = getdata(this(i));
        offset = offset + samples;
    end
    return;
end

%An empty signal gets returned.
if signalobjects(pointer).length == 0
    data = [];
    return;
elseif time > signalobjects(pointer).length && signalobjects(pointer).length > 0 && ...
        ~(any(strcmpi(signalobjects(pointer).type, {'analytic', 'squarePulseTrain', 'raster'})) && signalobjects(pointer).repeatable)
    %TO060208D - Allow the length to be shorter than the requested time if it's a repetable signal.
    %TO062806K
    error('The requested time duration (%s [s]) exceeds this @signalobject''s length (%s [s]).', num2str(time), num2str(signalobjects(pointer).length));
end

switch lower(signalobjects(pointer).type)
    case 'analytic'
        if signalobjects(pointer).cache
            if length(signalobjects(pointer).signal) >= samples
                data = signalobjects(pointer).signal(1:samples);
            else
                if unitsInSamples
                    signalobjects(pointer).signal = getAnalyticData(this, time);
                else
                    signalobjects(pointer).signal = getAnalyticData(this, time);
                end
                data = signalobjects(pointer).signal;
            end
        else
            if unitsInSamples
                data = getAnalyticData(this, time);
            else
                data = getAnalyticData(this, time);
            end
        end

    case 'literal'
        if length(signalobjects(pointer).signal) < samples
            if signalobjects(pointer).repeatable
                repetitions = ceil(samples / length(signalobjects(pointer).signal));
                
                %Watch out for repetition on the first and last sample points.
                %Do this in two stages, because the second stage will be assured to have enough datapoints for the subsindex.                
                if size(signalobjects(pointer).signal, 1) > size(signalobjects(pointer).signal, 2)
                    data = repmat(signalobjects(pointer).signal(2 : end), repetitions, 1);
                    data = cat(1, data, data(2 : repetitions));
                else
                    data = repmat(signalobjects(pointer).signal(2 : end), 1, repetitions);
                    data = cat(2, data, data(2 : repetitions));
                end
            else
                %TO020305d - Configurable padding.
                %TO111006A
                if signalobjects(pointer).noPadding
                    data = signalobjects(pointer).signal;
                    
                    warning('The literal signal buffer (%s) was not large enough (%s) to provide the requested number of samples: %s', ...
                        signalobjects(pointer).name, num2str(length(signalobjects(pointer).signal)), num2str(samples));
                else
                    data = signalobjects(pointer).signal;
                    data(end + 1 : samples) = data(end);
                    warning('The literal signal buffer (%s) was not large enough (%s) to provide the requested number of samples: %s. The data has been padded to compensate.', ...
                        signalobjects(pointer).name, num2str(length(signalobjects(pointer).signal)), num2str(samples));
                end
            end
        else
            data = signalobjects(pointer).signal(1:samples);
        end
        
        %Make it a column vector (by default), to be easily compatible with the daq toolbox.
        if size(data, 2) > size(data, 1)
            data = data';
        end

    case 'functional'
        data = getFunctionalData(this, time, signalobjects(pointer).sampleRate);
        if length(data) < samples
            %TO020305d - Configurable padding.
            if ~signalobjects(pointer).noPadding
                warning('The external function failed to provide the requested number of samples: %s (%s provided)', ...
                    num2str(samples), length(data));
            elseif ~isempty(data)
                data = signalobjects(pointer).signal;
                data(end + 1 : samples) = data(end);
                warning('The external function failed to provide the requested number of samples: %s (%s provided). The data has been padded to compensate.', ...
                    num2str(samples), length(data));
            else
                error('The external function failed to provide any data.');
            end
        end

    case 'functionalwithargs'
        data = getFunctionalDataWithArgs(this, time, signalobjects(pointer).sampleRate);
        if length(data) < samples
            %TO020305d - Configurable padding.
            if ~signalobjects(pointer).noPadding
                warning('The external function failed to provide the requested number of samples: %s (%s provided)', ...
                    num2str(samples), length(data));
            elseif ~isempty(data)
                data = signalobjects(pointer).signal;
                data(end + 1 : samples) = data(end);
                warning('The external function failed to provide the requested number of samples: %s (%s provided). The data has been padded to compensate.', ...
                    num2str(samples), length(data));
            else
                error('The external function failed to provide any data.');
            end
        end
        
    case 'recursive'
        if signalobjects(pointer).cache
            if length(signalobjects(pointer).signal) >= samples
                data = signalobjects(pointer).signal(1:samples);
            else
                if unitsInSamples
                    signalobjects(pointer).signal = getRecursiveData(this, time, 'Samples');
                else
                    signalobjects(pointer).signal = getRecursiveData(this, time);
                end
                data = signalobjects(pointer).signal;
            end
        else
            if unitsInSamples
                data = getRecursiveData(this, time, 'Samples');
            else
                data = getRecursiveData(this, time);
            end
        end
        if length(data) < samples
            %TO020305d - Configurable padding.
            if ~signalobjects(pointer).noPadding
                warning('This recursive signal''s children failed to provide the requested number of samples: %s (%s provided)', ...
                    num2str(samples), length(data));
            elseif ~isempty(data)
                data = signalobjects(pointer).signal;
                data(end + 1 : samples) = data(end);
                warning('This recursive signal''s children failed to provide the requested number of samples: %s (%s provided). The data has been padded to compensate.', ...
                    num2str(samples), length(data));
            else
                warning('This recursive signal''s children failed to provide any data.');
            end
        end
        
    case {'squarepulsetrain' 'digitalpulsetrain'}
        if signalobjects(pointer).cache
            if length(signalobjects(pointer).signal) >= samples
                data = signalobjects(pointer).signal(1:samples);
            else
                if unitsInSamples
                    signalobjects(pointer).signal = getSquarePulseTrainData(this, time);
                else
                    signalobjects(pointer).signal = getSquarePulseTrainData(this, time);
                end
                data = signalobjects(pointer).signal;
            end
        else
            if unitsInSamples
                data = getSquarePulseTrainData(this, time);
            else
                data = getSquarePulseTrainData(this, time);
            end
        end
    case 'raster'
        %TO120809A
        if signalobjects(pointer).cache
            if length(signalobjects(pointer).signal) >= samples
                data = signalobjects(pointer).signal(1:samples);
            else
                if unitsInSamples
                    signalobjects(pointer).signal = getRasterData(this, time);
                else
                    signalobjects(pointer).signal = getRasterData(this, time);
                end
                data = signalobjects(pointer).signal;
            end
        else
            if unitsInSamples
                data = getRasterData(this, time);
            else
                data = getRasterData(this, time);
            end
        end
    case {'stepfcn'}
        if signalobjects(pointer).cache
            if length(signalobjects(pointer).signal) >= samples
                data = signalobjects(pointer).signal(1:samples);
            else
                if unitsInSamples
                    signalobjects(pointer).signal = getStepFcnData(this, time);
                else
                    signalobjects(pointer).signal = getStepFcnData(this, time);
                end
                data = signalobjects(pointer).signal;
            end
        else
            if unitsInSamples
                data = getStepFcnData(this, time);
            else
                data = getStepFcnData(this, time);
            end
        end
    otherwise
        error('This @signal object ''%s'' does not have a type (analytic, literal, functional, functionalWithArgs, squarePulseTrain, digitalPulseTrain) specified. No data is available.', ...
            signalobjects(pointer).name);
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