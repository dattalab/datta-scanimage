function unloadImage4Mapper
global state

delete(getParent(state.video.imageHandle, 'figure'));

return;