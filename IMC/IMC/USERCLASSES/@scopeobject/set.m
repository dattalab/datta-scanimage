% SCOPEOBJECT/SET - Set any non-read-only fields in a SCOPEOBJECT object.
%
% SYNTAX
%  PROPERTIES = set(SCOPEOBJECT) - Gets all the fields in a SCOPEOBJECT object.
%  set(SCOPEOBJECT, NAME, VALUE) - Sets the value of the NAME field in a SCOPEOBJECT object to VALUE.
%  set(SCOPEOBJECT, NAME, VALUE, ...) - Gets the value of each named field in a SCOPEOBJECT object to the corresponding value.
%  set(handle, eventdata, SCOPEOBJECT, NAME, VALUE, ...) - For direct use in GUI callbacks.
%
% CHANGES
%  2/4/05 - Tim O'Connor TO020405a: Implemented 'setListeners'.
%  Tim O'Connor 4/20/05 TO042005A: Added the displayOptions optimization.
%  5/5/05 Tim O'Connor TO050505B: Allow set to be called directly from GUI callbacks, which force the handle into the first argument.
%  9/21/05 Tim O'Connor TO092105A: Allow multiple scope objects to be set at once.
%  12/19/05 Tim O'Connor TO121905B: Update the 'declaredGridOn' and 'declaredPureDisplay' values to follow the 'gridOn' and 'pureDisplay' values.
%  Jinyang Liu  & Tim O'Connor 8/2/07 JL080207A: Added holdOn as a field, implemented functionality in addData.m. Assorted UI tweaks.
%
% Created 1/21/05 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout = set(this, varargin)
global scopeObjects;

%TO092105A - Allow multiple scope objects to be set at once. -- Tim O'Connor 9/21/05
if length(this) > 1
    for i = 1 : length(this)
        set(this(i), varargin{:});
    end
    return;
end

%TO050505B
if ishandle(this)
    this = varargin{2};
    varargin = varargin(3:end);
end

if isempty(varargin)
    varargout{1} = get(this);
    return;
end

if mod(length(varargin), 2) ~= 0
    error('An equal number of names and values must be supplied.');
end

fnames = fieldnames(scopeObjects);
fnamesLow = lower(fnames);
unrecognized = {};
recognized = {};
unwriteable = {};
updateDisplay = 0;%TO042005A

%It's slower, but doing it in two passes allows better error handling/reporting.
for i = 1 : 2 : length(varargin)
    name = lower(varargin{i});
    
    if ~ismember(name, fnamesLow)
        unrecognized{length(unrecognized) + 1} = varargin{i};
    elseif ismember(name, scopeObjects(this.ptr).readOnlyFields)
        unwriteable{length(unwriteable) + 1} = varargin{i};
    else
        recognized{length(recognized) + 1} = fnames{find(strcmpi(fnames, varargin{i}))};
        values{length(recognized)} = varargin{i + 1};
    end
    
    if ~updateDisplay
        %There's no need to do this comparison for every value being set, if we already know
        %that the update needs to be done, hence the `if ~updateDisplay` statement.
        if ismember(name, scopeObjects(this.ptr).displayOptions)
            updateDisplay = 1;
        end
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
% fprintf(1, '%s - %s: ', num2str(this.ptr), recognized{i});
% if strcmpi(class(values{i}), 'char')
%     fprintf(1, '%s\n', values{i})
% elseif isnumeric(values{i})
%     fprintf(1, '%s\n', num2str(values{i}));
% end
% getStackTraceString
    scopeObjects(this.ptr).(recognized{i}) = values{i};
end

%TO121905B - If these get set externally, the declared values need to be updated. I hate having a special case like this, but it seems necessary.
if any(strcmpi(recognized, 'gridOn'))
    scopeObjects(this.ptr).declaredGridOn = scopeObjects(this.ptr).gridOn;
end
if any(strcmpi(recognized, 'pureDisplay'))
    scopeObjects(this.ptr).declaredPureDisplay = scopeObjects(this.ptr).pureDisplay;
end

if updateDisplay %TO042005A
    updateDisplayOptions(this);
end

%JL080207A - Make sure the toggle button matches the field, in case the field is changed programatically.
%smallmenu = strcmpi(get(scopeObjects(this.ptr).figure,'MenuBar'),'None'); %JL080707 add this because when resizefcn detects smallmenu, it hides the menubar and handles of hautoscale, hholdOn are lost.

%if ~smallmenu
    if scopeObjects(this.ptr).autoRange
    set(scopeObjects(this.ptr).hautoscale, 'State', 'On');
    else
    set(scopeObjects(this.ptr).hautoscale, 'State', 'Off');
    end

    %JL080207A - Make sure the toggle button matches the field, in case the field is changed programatically.
    if scopeObjects(this.ptr).holdOn
        set(scopeObjects(this.ptr).hholdon, 'State', 'On');
    else
        set(scopeObjects(this.ptr).hholdon, 'State', 'Off');
    end
%end

%TO020405a - Let other objects listen for calls to 'set'. 2/4/05 Tim O'Connor
for i = 1 : length(scopeObjects(this.ptr).setListeners)
    try
        switch lower(class(scopeObjects(this.ptr).setListeners{i}))
            case 'cell'
                callback = scopeObjects(this.ptr).setListeners{i};
                feval(callback{:}, varargin{1 : 2 : length(varargin)});
                
            case 'char'
                eval(scopeObjects(this.ptr).setListeners{i})
                
            case 'function_handle'
                feval(scopeObjects(this.ptr).setListeners{i}, varargin{1 : 2 : length(varargin)});
                
            otherwise
                warning('Failed to notify this scopeObject''s setListener: Invalid callback class: %s', class(scopeObjects(this.ptr).setListeners{i}));
        end
    catch
        warning('Failed to notify this scopeObject''s setListener: %s', lasterr);
    end
end

return;