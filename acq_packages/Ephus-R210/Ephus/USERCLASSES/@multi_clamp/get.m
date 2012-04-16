% CHANGES
%  TO062305A: Moved over to using "pointers". Moved over to work with the @AIMUX/@AOMUX architecture. -- Tim O'Connor 6/23/05
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function  out = get(this, fieldname)
global multi_clampObjects;
%Get - method for @multi_clamp class.

[fieldnames] = getfieldnames;
if any(strcmpi(fieldnames, fieldname))
    out = multi_clampObjects(this.ptr).(fieldname);
%     out = eval(['mc_obj.' fieldname]);
else
    out = get(this.AMPLIFIER, fieldname);%TO122205A
%     out = get(eval(['mc_obj.' get(mc_obj,'parent')]),fieldname);
end