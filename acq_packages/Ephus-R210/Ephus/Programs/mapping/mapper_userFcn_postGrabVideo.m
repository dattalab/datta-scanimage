% mapper_userFcn_postGrabVideo - Takes the place of the DigitalVideo software.
%
% SYNTAX
%  mapper_userFcn_postGrabVideo
%
% USAGE
%  Bind this function to the mapper:PostGrabVideo event.
%
% NOTES
%
% CHANGES
%
% Created 8/26/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_userFcn_preGrabVideo(varargin)
global state;

if ishandle(state.video.figureHandle)
    delete(state.video.figureHandle);
end


return;