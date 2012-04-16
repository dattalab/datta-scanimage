% mapper_userFcn_preGrabVideo_simulatedWhiteNoise - Takes the place of the DigitalVideo software.
%
% SYNTAX
%  mapper_userFcn_preGrabVideo_simulatedWhiteNoise
%
% USAGE
%  Bind this function to the mapper:PreGrabVideo event.
%
% NOTES
%
% CHANGES
%
% Created 10/22/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function mapper_userFcn_preGrabVideo_simulatedWhiteNoise(varargin)
global state;

state.video.figureHandle = figure('ColorMap', gray);
title('Video Capture Preview');
ax = axes('Parent', state.video.figureHandle, 'YDir', 'reverse');
state.video.imageHandle = imagesc(rand(512, 512) * 256, 'Parent', ax);

return;