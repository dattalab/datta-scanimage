% qImageCapture4Mapper - Grabs a single frame from a QImaging camera, and places it
%                where the mapper can access it.
% 
% SYNTAX
%  qImageCapture4Mapper
%  
% NOTES
%  Relies on qcapmex_grab.mex.
%  To set camera properties, see qcapmex_grab.m
%  Example:
%   imdata = qcapmex_grab('qprmExposure', uint32(200));%Takes a 200 microsecond exposure.
%
% CHANGES
%  
% Created
%  Timothy O'Connor 3/1/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function qImageCapture4Mapper(varargin)
global state

R = qcapmex_grab;
f = figure('ColorMap', gray, 'Visible', 'Off');
hSliceImg = imagesc(R);
% colormap gray;
% set(gca, 'Visible', 'off');
daspect([1 1 1]);

% put its handle in the state directory so ephus mapper can find it
state.video.imageHandle = hSliceImg;
% get(state.video.imageHandle);

return;