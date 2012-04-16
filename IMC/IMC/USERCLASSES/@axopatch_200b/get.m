%Get - method for @AXOPATCH_200B class.
% 
% CHANGES:
%  TO021505a - Modified to use a "pointer" system, like our other objects. -- Tim O'Connor 2/15/05
%  TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%
% NOTES
%  Why did the original implementation use 'eval' statements?!?
%
function  out = get(mc_obj, fieldname)
global axopatch200bs;
%Get - method for @multi_clamp class.

[fieldnames] = getfieldnames;
if any(strcmpi(fieldnames,fieldname))
    %TO021505a
    out = axopatch200bs(mc_obj.ptr).(fieldname);
%     out = eval(['mc_obj.' fieldname]);
else
    %TO021505a
    out = get(mc_obj.AMPLIFIER, fieldname);%TO122205A
%     out = get(eval(['mc_obj.' get(mc_obj,'parent')]),fieldname);
end