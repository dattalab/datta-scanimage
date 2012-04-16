% hardwareManager/hardwareManager - A repository in which hardware may be stored. Implemented as a singleton.
%
% SYNTAX
%  hw = hardwareManager
%
% USAGE
%  This is a singleton, for every call to the constructor the same instance is always returned.
%
% NOTES
%
% CHANGES
%
% Created 12/2/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function this = hardwareManager

this = [];
% 
% 
% patch1 = axopatch_200B('gain_daq_board_id', 2, 'mode_daq_board_id', 2, 'v_hold_daq_board_id', 2, 'gain_channel', 5, 'mode_channel', 7, 'v_hold_channel', 2, ...
%     'vComBoardID', 2, 'vComChannelID', 0, 'scaledOutputChannelID', 0, 'scaledOutputBoardID', 2);
% patch2 = axopatch_200B('gain_daq_board_id', 2, 'mode_daq_board_id', 2, 'v_hold_daq_board_id', 2, 'gain_channel', 2, 'mode_channel', 3, 'v_hold_channel', 1, ...
%     'vComBoardID', 1, 'vComChannelID', 1, 'scaledOutputChannelID', 1, 'scaledOutputBoardID', 1);
% patch3 = multi_clamp('text_file_location', 'C:\MATLAB6p1\work\Physiology\MClamp700BChannel1.txt', 'scaledOutputBoardID', 2, 'scaledOutputChannelID', 1, ...
%     'vComBoardID', 2, 'vComChannelID', 0, 'channel', 1, 'name', '700B-1');
% patch4 = multi_clamp('text_file_location', 'C:\MATLAB6p1\work\Physiology\MClamp700BChannel2.txt', 'scaledOutputBoardID', 1, 'scaledOutputChannelID', 1, ...
%     'vComBoardID', 1, 'vComChannelID', 0, 'channel', 2, 'name', '700B-2');



return;