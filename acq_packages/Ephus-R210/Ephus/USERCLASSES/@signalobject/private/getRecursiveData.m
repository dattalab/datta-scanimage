% SIGNAL/private/getAnalyticData - Retrieve a raw numeric array of SIGNAL data.
%
% SYNTAX
%  data = getRecursiveData(SIGNAL, time) - Gets <time> seconds worth of datapoints at SIGNAL.sampleRate
%                                         of the recursively specified SIGNAL.
%
% CHANGES
%  2/3/05 Tim O'Connor (TO020305d): Added the noPadding variable.
%  2/3/05 Tim O'Connor (TO020305e): Special case(s) for concatenation.
%  2/3/05 Tim O'Connor (TO020305f): Trim excess data.
%  10/13/05 Tim O'Connor (TO101305A): Allow "links" to children.
%  10/25/05 Tim O'Connor (TO102505B): Allow the case of no children.
%  10/26/05 Tim O'Connor (TO102605C): Clean up after loading children from "links".
%  6/28/06 Tim O'Connor (TO062806L): Pad data, for parents whose length exceeds that of their children.
%  TO033108D - Add support for multiline/multibit digital data. -- Tim O'Connor 3/31/08
%
% Created 8/19/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function data = getRecursiveData(this, time, varargin)
global signalobjects;

pointer = indexOf(this);

if ~isempty(varargin)
    if strcmpi(varargin{1}, 'samples')
        samples = time;
        time = samples * signalobjects(pointer).sampleRate;
    end
else
    samples = ceil(time * signalobjects(pointer).sampleRate);
end

%TO102505B: Allow the case of no children. -- Tim O'Connor 10/25/05
if isempty(signalobjects(pointer).children)
    data = zeros(samples, 1);
    return;
end

switch lower(signalobjects(pointer).method)
    case {'add', 'subtract'}
        data = zeros(samples, 1);
    case {'multiply', 'divide'}
        data = ones(samples, 1);
    case {'cat', 'concat', 'concatenate', 'append'}
        data = [];
    otherwise
        error('This recursive @signal object does not have a combination method (add, subtract, multiply, divide) specified. No data is available: s', signalobjects(pointer).method);
end

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

%TO020305e - Sort by phase shift in ascending order.
if ismember(lower(signalobjects(pointer).method), {'cat', 'concat', 'concatenate', 'append'}) && ~isempty(signalobjects(pointer).signalPhaseShift)
    [temp indices] = sort(signalobjects(pointer).signalPhaseShift);
else
    indices = 1 : length(kids);%TO101305A
end

for i = indices
    childPointer = indexOf(kids(i));%TO101305A
    
    if signalobjects(pointer).debugMode
        fprintf(1, 'Parent: %s - Child: %s\n', signalobjects(pointer).name, signalobjects(childPointer).name);
    end

    %Get the child's data.
    %TO020305e: The data retrieval must be done differently for appends.
    if ismember(lower(signalobjects(pointer).method), {'cat', 'concat', 'concatenate', 'append'})
        if ~isempty(signalobjects(pointer).signalPhaseShift) && ~all(signalobjects(pointer).signalPhaseShift == 0)
            if i == length(signalobjects(pointer).signalPhaseShift)
                t = time - sum(signalobjects(pointer).signalPhaseShift(1:i));
            else
                t = signalobjects(pointer).signalPhaseShift(i + 1) - signalobjects(pointer).signalPhaseShift(i);
            end
            if t == 0
%  fprintf(1, '@signalobject/private/getRecursiveData: (t ==0) --> continue\n');
                continue;
            end
        else
            t = time;
        end
        
        kidlen = get(kids(i), 'length');
% if kidlen == -1
%     fprintf(1, '@signalobject/getRecursiveData - Parent: this.ptr=%s, pointer=%s, indexOf=%s, name=''%s''\n', num2str(this.ptr), num2str(pointer), num2str(indexOf(this)), signalobjects(pointer).name);
%     fprintf(1, '@signalobject/getRecursiveData - Child: this.ptr=%s, pointer=%s, indexOf=%s, name=''%s''\n', num2str(kids(i).ptr), num2str(indexOf(kids(i))), num2str(indexOf(kids(i))), signalobjects(indexOf(kids(i))).name);
% %     kidlen
% %     signalobjects(indexOf(kids(i))).length
% %     kids(i)
% %     getStackTraceString
% end
        if kidlen > 0
            t = min(t - length(data) / signalobjects(pointer).sampleRate, kidlen);
            if t == 0
%  fprintf(1, '@signalobject/private/getRecursiveData: All data has been obtained without using all children.\n');
                continue;
            end
        end
%  fprintf(1, '@signalobject/private/getRecursiveData: Getting %s seconds from child %s (of length %s)...\n', num2str(t), num2str(i), num2str(kidlen));
        data2 = getdata(kids(i), t, varargin{:});%TO101305A
    else
%  fprintf(1, '@signalobject/private/getRecursiveData: Getting %s seconds from child %s...\n', num2str(time), num2str(i));
        data2 = getdata(kids(i), time, varargin{:});%TO101305A
    end

    %Make sure it's properly sampled, interpolate if it's too slow.
    if signalobjects(pointer).sampleRate < signalobjects(childPointer).sampleRate
        downsampleFactor = ceil(signalobjects(childPointer).sampleRate / signalobjects(pointer).sampleRate);

        if signalobjects(pointer).debugMode || signalobjects(pointer).eagerWarningMode
            warning('Child sample rate is faster than the parent for @signal ''%s'', one out of every %s samples is being used.', ...
                signalobjects(pointer).name, num2str(downsampleFactor));
        end

        %Downsample for a faster child.
        data2 = downsample(data2, downsampleFactor);
    elseif signalobjects(pointer).sampleRate > signalobjects(childPointer).sampleRate
        if signalobjects(pointer).debugMode || signalobjects(pointer).eagerWarningMode
            warning('Child sample rate is slower than the parent for @signal ''%s'', upsampling by a factor of %s.', ...
                signalobjects(pointer).name, num2str(signalobjects(pointer).sampleRate / signalobjects(childPointer).sampleRate));
        end

        %Resample for a slower child (interpolate).
        data2 = resample(data2, signalobjects(pointer).sampleRate, signalobjects(childPointer).sampleRate);
    end

    if ~isempty(data2)
        phaseShiftInSamples = ceil(signalobjects(pointer).signalPhaseShift(i) * signalobjects(pointer).sampleRate) + 1;
        if length(data2) > length(data) - phaseShiftInSamples + 1 && ~ismember(lower(signalobjects(pointer).method), {'cat', 'concat', 'concatenate', 'append'})
            data2 = data2(1 : length(data) - phaseShiftInSamples + 1);
        end

        switch lower(signalobjects(pointer).method)
            case 'add'
                data(phaseShiftInSamples : phaseShiftInSamples + length(data2) - 1) = data(phaseShiftInSamples : phaseShiftInSamples + length(data2) - 1) + data2;
            case 'subtract'
                if phaseShiftInSamples < 1
                    phaseShiftInSamples = 1;
                end
                data(phaseShiftInSamples : phaseShiftInSamples + length(data2) - 1) = data(phaseShiftInSamples : phaseShiftInSamples + length(data2) - 1) - data2;
            case 'multiply'
                if phaseShiftInSamples < 1
                    phaseShiftInSamples = 1;
                end
                data(phaseShiftInSamples : phaseShiftInSamples + length(data2) - 1) = data(phaseShiftInSamples : phaseShiftInSamples + length(data2) - 1) .* data2;
            case 'divide'
                if phaseShiftInSamples < 1
                    phaseShiftInSamples = 1;
                end
                data(phaseShiftInSamples : phaseShiftInSamples + length(data2) - 1) = data(phaseShiftInSamples : phaseShiftInSamples + length(data2) - 1) ./ data2;
            case {'cat', 'concat', 'concatenate', 'append'}
% fprintf(1, '@signalobject/private/getRecursiveData: appending %s samples onto %s samples.\n', num2str(length(data2)), num2str(length(data)));
                data = cat(1, data, data2);
            case {'or'}
                data = uint32(bitor(uint32(data), uint32(data2)));
                % data = bitor(uint32(data), uint32(bitshift(data2, i - 1)));
            otherwise
                error('This recursive @signal object does not have a combination method (add, subtract, multiply, divide) specified. No data is available.');
        end
    else
        warning('@signal object ''%s'' did not return any data to its parent ''%s''.', signalobjects(childPointer).name, signalobjects(pointer).name);
%         if signalobjects(pointer).debugMode
            signalobjects(childPointer)
            signalobjects(pointer)
%         end
    end
end

% figure, plot(data), title(sprintf('@signalobject/private/getRecursiveData (%s samples)', num2str(length(data))));
% fprintf(1, '\n%s\n', getStackTraceString);

%TO020305f - Watch out for excess.
if length(data) > samples
    data = data(1 : samples);
end
%TO062806L - Pad data, for parents whose length exceeds that of their children.
if length(data) < samples
    data(length(data) + 1 : samples) = data(end);
end

%TO102605C
if linkedChildren
    for i = 1 : length(kids)
        delete(kids(i));
    end
end   

return;