function testEphys

if ~strcmpi(input('Warning: This script will clear all global variables. Continue? (y/n): ', 's'), 'y')
    return;
end

fprintf(1, 'Clearing ''all''...\n');
clear all;
fprintf(1, 'Clearing ''global''...\n');
clear global;
fprintf(1, 'Deleting all children of handle 0...\n');
delete(allchild(0));
fprintf(1, 'Clearing ''classes''...\n');
clear classes;

openprogram(progmanager, program('pulseEditor', 'pulseEditor', 'pulseEditor'));

return;