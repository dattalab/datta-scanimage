%Set - method for @AMPLIFIER class.
% 
% CHANGES:
%  TO021505a - Modified to use a "pointer" system, like our other objects. -- Tim O'Connor 2/15/05
%  TO022505b - Decided to do something with 'internal', and make it only allow this class and subclasses to write to the corresponding fields. - Tim O'Connor 2/25/05
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%   TO081696H - Switched case convention. See TO122205A. -- Tim O'Connor 8/16/06
%
function  out = set(amplifier_obj, varargin)
%Set - method for @AMPLIFIER class.
global amplifierObjects;
% fprintf(1, '@amplifier/set\n');

allowedAccess = 0;
%Check access rights.
%Make sure the call came from a subclass' method.
stackTraceStruct = dbstack;
fname = '';
if length(stackTraceStruct) > 1
    [path fname ext] = fileparts(stackTraceStruct(2).name);
end
if ismethod(amplifier_obj, fname)
    allowedAccess = 1;
end

if ~strcmpi(class(amplifier_obj), 'amplifier') % & ismember('amplifier', fieldnames(this))
    obj = struct(amplifier_obj);
    amplifier_obj = amplifier_obj.amplifier;%TO122205A %TO081606H
end

[fieldnames,default_vals,data_types] = getfieldnames;
while length(varargin) >= 2
    if any(strcmp(fieldnames,varargin{1}))
        index = find(strcmp(fieldnames,varargin{1}));%TO022505b
        if amplifierObjects(amplifier_obj.ptr).internal(index) & ~allowedAccess
            error('@AMPLIFIER/set - This method is only allowed to be called by subclasses for the ''%s'' property.', varargin{1});
        end
        if isa(varargin{2},data_types{index})  %Check data type
            amplifierObjects(amplifier_obj.ptr).(varargin{1}) = varargin{2};%TO021505a
%             eval(['amplifier_obj.' varargin{1} '=varargin{2};']);
            varargin=varargin(3:end);
        else
            error(['amplifier: ' varargin{1} ' must be of class ' data_types{find(strcmp(fieldnames,varargin{1}))} '.']);
        end
    else
        error(['amplifier: ' varargin{1} ' is not a field of the amplifier class.']);
    end
end
out = amplifier_obj;