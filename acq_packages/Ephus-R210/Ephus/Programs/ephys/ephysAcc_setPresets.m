% ephysAcc_setPresets - Change the preset buttons on the ephysScopeAccessoryGui.
%
% SYNTAX
%  ephysAcc_setPresets(vClampPresets, iClampPresets)
%   vClampPresets - The two values for the vClamp presets, in mV.
%   iClampPresets - The two values for the iClamp presets, in pA.
%
% USAGE
%
% NOTES
%  See TO121307E.
%
% CHANGES
%  TO021610J - Fixed a copy & paste error (referencing channels, when it should've been amplifiers). -- Tim O'Connor 2/16/10
%
% Created 12/13/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function ephysAcc_setPresets(vClampPresets, iClampPresets)

ephysAcc = getGlobal(progmanager, 'hObject', 'ephysScopeAccessory', 'ScopeGui');
setGlobal(progmanager, 'vClampPresets', 'ephysScopeAccessory', 'ScopeGui', vClampPresets);
setGlobal(progmanager, 'iClampPresets', 'ephysScopeAccessory', 'ScopeGui', iClampPresets);
ephysScopeAccessory('genericUpdateFcn', ephysAcc, [], []);

return;