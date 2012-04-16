% SIGNAL/SET - Set any non-read-only fields in a SIGNAL object.
%
% SYNTAX
%  PROPERTIES = set(SIGNAL) - Gets all the fields in a SIGNAL object.
%  set(SIGNAL_OBJ, NAME, VALUE) - Sets the value of the NAME field in a SIGNAL object to VALUE.
%  set(SIGNAL_OBJ, NAME, VALUE, ...) - Gets the value of each named field in a SIGNAL object to the corresponding value.
%
% CHANGES
%  TO022505d - Allow multiple signals to be set at once. -- Tim O'Connor 2/25/05
%  TO022706D - Optimization(s). Keep the read-only fields in a lower-case list to facilitate compare operations. -- Tim O'Connor 2/27/06
%
% Created 8/18/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function varargout = set(this, varargin)
global signalobjects;

%TO022505d
if length(this) > 1
    for i = 1 : length(this)
        set(this(i), varargin{:});
    end
    return;
end
    
pointer = indexOf(this);

if isempty(varargin)
    varargout{1} = get(this);
    return;
end

if mod(length(varargin), 2) ~= 0
    error('An equal number of names and values must be supplied.');
end

fnames = fieldnames(signalobjects);
fnamesLow = lower(fnames);
unrecognized = {};
% readOnly = lower({'signal', 'signals', 'signalPhaseShift', 'method', 'waveform', 'frequency', 'amplitude', ...
%             'offset', 'phi', 'symmetry', 'fcn', 'fcnTakesArgs'});
recognized = {};
unwriteable = {};

%It's slower, but doing it in two passes allows better error handling/reporting.
for i = 1 : 2 : length(varargin)
    if ~ismember(lower(varargin{i}), fnamesLow)
        unrecognized{length(unrecognized) + 1} = varargin{i};
    elseif ismember(lower(varargin{i}), signalobjects(pointer).readOnlyFields) %TO022706D
        unwriteable{length(unwriteable) + 1} = varargin{i};
    else
        recognized{length(recognized) + 1} = fnames{find(strcmpi(fnames, varargin{i}))};
        values{length(recognized)} = varargin{i + 1};
    end
end

if ~isempty(unrecognized)
    s = 'Unrecognized field(s) - ';
    for i = 1 : length(unrecognized) - 1
        s = sprintf('%s''%s'', ', s, unrecognized{i});
    end
    s = sprintf('%s''%s''.', s, unrecognized{end});
    
    error(s);
end

if ~isempty(unwriteable)
    s = 'Can not set read-only field(s) - ';
    for i = 1 : length(unwriteable) - 1
        s = sprintf('%s''%s'', ', s, unwriteable{i});
    end
    s = sprintf('%s''%s''.', s, unwriteable{end});
    
    error(s);
end

for i = 1 : length(recognized)
    signalobjects(pointer).(recognized{i}) = values{i};
% if strcmp(recognized{i}, 'length')
% fprintf(1, '@signalobject/set(...''length'', %s,...): this.ptr=%s, pointer=%s, indexOf=%s, name=''%s''\n', num2str(values{i}), num2str(this.ptr), num2str(pointer), num2str(indexOf(this)), signalobjects(pointer).name);
%     fprintf(1, '@signalobject(%s)/set(..., ''length'', %s, ...) --> this.length = %s [s]\n%s', ...
%         signalobjects(pointer).name, num2str(values{i}), num2str(signalobjects(pointer).length), getStackTraceString);
% end
end

return;