%Get - method for @AMPLIFIER class.
% 
% CHANGES:
%  TO021505a - Modified to use a "pointer" system, like our other objects. -- Tim O'Connor 2/15/05
%
function  out = get(amplifier_obj, field)
%Get - method for @AMPLIFIER class.
global amplifierObjects;

[fieldnames] = getfieldnames;
if any(strcmp(fieldnames,field))
    out = amplifierObjects(amplifier_obj.ptr).(field);%TO021505a
%     out = eval(['amplifier_obj.' field]);
else
    error(['amplifier->get: ' field ' is not a field of the amplifier class.']);
end