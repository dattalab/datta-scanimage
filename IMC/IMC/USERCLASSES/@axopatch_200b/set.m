%Set - method for @AXOPATCH_200B class.
% 
% CHANGES:
%  TO021505a - Modified to use a "pointer" system, like our other objects. -- Tim O'Connor 2/15/05
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%
% NOTES
%  Why did the original implementation use 'eval' statements?!?
%
function  out = set(mc_obj, varargin)
global axopatch200bs;
%Set - method for @AMPLIFIER class.
% Remember you need to call obj = set(obj,...)! - Not any more. TO021505a

[fieldnames,default_vals,data_types] = getfieldnames;
while length(varargin) >= 2
    if any(strcmpi(fieldnames,varargin{1})) % if it is a field of the derived class...
        if isa(varargin{2},data_types{find(strcmp(fieldnames,varargin{1}))});  %Check data type
            axopatch200bs(mc_obj.ptr).(varargin{1}) = varargin{2};%TO021505a
%             eval(['mc_obj.' varargin{1} '=varargin{2};']);
            varargin=varargin(3:end);
        else
            error(['multi_clamp: ' varargin{1} ' must be of class ' data_types{find(strcmp(fieldnames,varargin{1}))} '.']);
        end
    else % if it is a field of the base class...
        set(mc_obj.AMPLIFIER, varargin{1}, varargin{2});%TO122205A
%         temp=set(eval(['mc_obj.' get(mc_obj,'parent') ';']),varargin{1},varargin{2});
%         eval(['mc_obj.' get(mc_obj,'parent') '=temp;'])
        varargin=varargin(3:end);
    end
end
out = mc_obj;