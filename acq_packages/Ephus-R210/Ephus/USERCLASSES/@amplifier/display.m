%Display - method for @AMPLIFIER class.
% 
% CHANGES:
%  TO021505a - Modified to use a "pointer" system, like our other objects. -- Tim O'Connor 2/15/05
%
function  out = display(amplifier_obj)
%Display - method for @AMPLIFIER class.
global amplifierObjects;

disp(' ');
disp([inputname(1) ' = ']);
disp(' ');
amplifier_obj_struct = amplifierObjects(amplifier_obj.ptr);%TO021505a
disp(amplifier_obj_struct);
if isfield(amplifier_obj,'parent')
    disp(amplifier_obj.parent);
%     disp('Parent Amplifier Properties');
%     disp(' ');
%     disp(struct(amplifier_obj_struct.(amplifier_obj_struct.parent)));
%     disp(' ');
end