% cycler_registerProgram - Register a program that may be cycled.
%
% SYNTAX
%  cycler_registerProgram(hObject, programHandle)
%   hObject - The cycler handle.
%   programHandle - The handle (any graphics handle within the program or the @program object) of the program to be registered.
%
% USAGE
%
% CHANGES
%
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function cycler_registerProgram(hObject, programHandle)

programs = getLocal(progmanager, hObject, 'programs');
programName = getProgramName(progmanager, programHandle);

index = find(strcmpi({programs{:, 1}}, programName));
if isempty(index)
    index = size(programs, 1) + 1;
end
programs{index, 1} = programName;
programs{index, 2} = programHandle;

setLocal(progmanager, hObject, 'programs', programs);
setLocalGh(progmanager, hObject, 'currentProgram', 'String', {programs{:, 1}});

return;