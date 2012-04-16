% ephys_pulseName_Callback - Exposes what would've typically been in the GUI's m-file.
%
% SYNTAX
%  ephys_pulseName_Callback(hObject)
%  ephys_pulseName_Callback(hObject, ampIndex)
%   hObject - The program handle.
%   ampIndex - The index of the amplifier for which to load a pulse.
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO081005D: Allow the amplifier to be specified. -- Tim O'Connor 8/10/05
%  TO083105A: Changed the storage of signals from a single file to a directory tree. -- Tim O'Connor 8/31/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%
% TODO
%  Unbind pulses when the empty name is selected. -- Tim O'Connor 8/10/05
%
% Created 8/9/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephys_pulseName_Callback(hObject, varargin)

%TO081005D
if isempty(varargin)
    ampIndex = getLocal(progmanager, hObject, 'amplifierList');
else
    ampIndex = varargin{1};
end

amplifiers = getLocal(progmanager, hObject, 'amplifiers');

pulseNameIndex = getLocal(progmanager, hObject, 'pulseName');
pulseNameMapping = getLocal(progmanager, hObject, 'pulseNameMapping');
pulseNameString = pulseNameMapping{ampIndex};

if pulseNameIndex == 1
    %Hmm, now what? -- Tim O'Connor, 6/23/05
end

pulseSetNameArray = getLocal(progmanager, hObject, 'pulseSetNameArray');
if isempty(pulseSetNameArray{ampIndex})
    error('No pulse set selected, pulse selection is impossible.');
end

if ~isempty(pulseNameString)
    filename = [fullfile(getLocal(progmanager, hObject, 'pulseSetDir'), pulseNameString) '.signal'];
    pulse = load(filename, '-mat');
    setPulse(pulseMap('acquisition'), getScaledOutputChannelName(amplifiers{ampIndex}), pulse);
end

return;