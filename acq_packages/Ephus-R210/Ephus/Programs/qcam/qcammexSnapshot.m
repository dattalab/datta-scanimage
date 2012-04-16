%User function for the mapper to access the current qcam frame.
% Tim O'Connor 3/31/08
function qcammexSnapshot(varargin)
global state

R = qcammex('getSnapshot')';

f = figure;
state.video.imageHandle = imagesc(R);% put its handle in the state variable so ephus mapper can find it
colormap gray;
set(f, 'Visible', 'off');
daspect([1 1 1]);

% set(state.video.imageHandle, 'CLim', [getGlobal(progmanager, 'black', 'qcam', 'qcam'), getGlobal(progmanager, 'white', 'qcam', 'qcam')]);
% get(state.video.imageHandle);

return;