% CHANGES
%  TO062305A: Moved over to using "pointers". Moved over to work with the @AIMUX/@AOMUX architecture. -- Tim O'Connor 6/23/05
%  TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%  TO012709C - Deprecate the old text file nonsense, and broadcast early for immediate detection. -- Tim O'Connor 1/27/09
%
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function  set(this, varargin)
global multi_clampObjects;
%Set - method for @AMPLIFIER class.
% Remember you need to call obj = set(obj,...)!

[fieldnames,default_vals,data_types] = getfieldnames;
while length(varargin) >= 2
    if any(strcmp(fieldnames,varargin{1})) % if it is a field of the derived class...
        %TO012709C
        if strcmpi(varargin{1}, 'text_file_location')
            warning('The @multi_clamp property ''text_file_location'' has been deprecated. For a 700A set the uComPortID, uAxoBusID, and uChannelID properties. For a 700B set the uSerialNum and uChannelID properties.');
        end

        if isa(varargin{2},data_types{find(strcmp(fieldnames,varargin{1}))});  %Check data type
            multi_clampObjects(this.ptr).(varargin{1}) = varargin{2};
%             eval(['mc_obj.' varargin{1} '=varargin{2};']);
            varargin=varargin(3:end);
        else
            error(['multi_clamp: ' varargin{1} ' must be of class ' data_types{find(strcmp(fieldnames,varargin{1}))} '.']);
        end
    else % if it is a field of the base class...
        set(this.AMPLIFIER, varargin{1}, varargin{2});%TO122205A
%         temp=set(eval(['mc_obj.' get(mc_obj,'parent') ';']),varargin{1},varargin{2});
%         eval(['mc_obj.' get(mc_obj,'parent') '=temp;'])
        varargin=varargin(3:end);
    end
end
% out = mc_obj;

return;
