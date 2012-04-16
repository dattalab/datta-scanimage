% mapper_userFcn_preGrabVideo - Takes the place of the DigitalVideo software.
%
% SYNTAX
%  mapper_userFcn_preGrabVideo
%
% USAGE
%  Bind this function to the mapper:PreGrabVideo event.
%
% NOTES
%
% CHANGES
%  TO111706B: Make sure a state variable exists before checking if it has a valid handle. -- Tim O'Connor 11/17/06
%
% Created 8/26/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_userFcn_preGrabVideo(varargin)
global state;

ok = 0;

fprintf(1, '\n');
while ~ok
    fprintf(1, '%s - mapper_userFcn_preGrabVideo: Acquiring video without the aid of DigitalVideo...\n', datestr(now));
    
    imaqreset;

    adaptorName = 'winvideo';
    deviceId = 1;
    mode = 'RGB24_640x480';
    
    vid = videoinput(adaptorName, deviceId, mode);
    triggerconfig(vid, 'manual');
    frame = getsnapshot(vid);
    frame = sum(frame, 3) / size(frame, 3);
    
    %TO111706B
    if exist('state') ~= 1
        state.video.figureHandle = [];
    elseif ~isfield(state, 'video')
        state.video.figureHandle = [];
    elseif ~isfield(state.video, 'figureHandle')
        state.video.figureHandle = [];
    end
    
    if ishandle(state.video.figureHandle)
        delete(state.video.figureHandle);
    end
    
    state.video.figureHandle = figure('ColorMap', gray);
    title('Video Capture Preview');
    ax = axes('Parent', state.video.figureHandle, 'YDir', 'reverse');
    state.video.imageHandle = imagesc(frame, 'Parent', ax);
    drawnow expose;%TO042309A - Not using expose can cause C-spawned events to fire out of order.
    
    prompt = questdlg('Is this image okay?', 'Accept Video Capture Preview', 'Accept', 'Recapture', 'Cancel', 'Accept');
    switch lower(prompt)
        case 'accept'
            ok = 1;
        case 'recapture'
            ok = 0;
        case 'cancel'
            im = getGlobal(progmanager, 'videoImage', 'mapper', 'mapper');
            set(state.video.imageHandle, 'CData', get(im, 'CData'));
            drawnow expose;%TO042309A - Not using expose can cause C-spawned events to fire out of order.
            return;
        otherwise
            warning('Unrecognized switch option: %s', prompt);
            return;
    end
end

fprintf(1, '%s - mapper_userFcn_preGrabVideo: Acquired video image.\n\n', datestr(now));

return;