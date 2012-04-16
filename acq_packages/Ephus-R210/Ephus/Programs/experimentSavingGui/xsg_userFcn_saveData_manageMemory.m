% xsg_userFcn_saveData_manageMemory - Attempt to optimize memory usage by clearing large arrays and defragmenting.
%
% SYNTAX
%  xsg_userFcn_saveData_manageMemory
%
% USAGE
%
% NOTES
%  This will clear the data arrays in both ephys and acquirer and then defragment the memory, using `pack(fullfile(matlabroot, 'work', 'xsg_userFcn_saveData_manageMemory.tmp'));`
%
% CHANGES
%
% Created 6/23/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function xsg_userFcn_saveData_manageMemory(varargin)

setGlobal(progmanager, 'saveBuffers', 'ephys', 'ephys', []);
setGlobal(progmanager, 'saveBuffers', 'acquirer', 'acquirer', []);

pack(fullfile(matlabroot, 'work', 'xsg_userFcn_saveData_manageMemory.tmp'));

return;