function AndorCameraTest1_Fcn1(src,hCamera,hFig,callbackReshape)


% if hCamera.status ~= 20072 %no longer acquiring
%     stop(src);
%     return;
% end

if nargin < 4
    callbackReshape = false;
end

figure(hFig);
frameCount = get(hFig,'UserData');

totalFramesAcquired = double(hCamera.totalNumberImagesAcquired);
newFrameCount = totalFramesAcquired - frameCount;

if newFrameCount           
    if callbackReshape
        tic;
        %imagesc(reshape(hCamera.getMostRecentImage(16,hCamera.pixelCountImageTotal),hCamera.pixelCountImage(1),hCamera.pixelCountImage(2)));
        imagesc(hCamera.getMostRecentImage(16,[hCamera.expectedN hCamera.expectedM])');
        fprintf('Processing & display time (ms): %g\n', 1000 * toc());
    else
        tic;
        imagesc(hCamera.getMostRecentImage(16)); 
        fprintf('Processing & display time (ms): %g\n', 1000 * toc());
    end   


    if newFrameCount > 1
        fprintf(1,'WARNING(%s): Skipped display of frame(s): %s\n',mfilename,mat2str(frameCount:(totalFramesAcquired-1)));
    end
    frameCount = totalFramesAcquired;
    
    set(hFig,'UserData',frameCount);
    set(hFig,'Name',['Frame # ' num2str(frameCount)]);
    drawnow expose;
    
else %No new data
    if hCamera.status == 20072 %still acquiring
        fprintf(1,'WARNING(%s): No frame data available during timer callback.\n',mfilename);
    end
end

%Stop timer if acquisition is done
if isa(src,'timer')
    if hCamera.status ~= 20072 %no longer acquiring
        switch hCamera.acquisitionMode
            case {'kinetics' 'fast kinetics'}
                if hCamera.totalNumberImagesAcquired == hCamera.numberKinetics && frameCount == hCamera.numberKinetics
                    stop(src);
                    if hCamera.isInternalMechanicalShutter
                        hCamera.closeInternalShutter();
                    end

                end
            otherwise
                stop(src);
                if hCamera.isInternalMechanicalShutter
                    hCamera.closeInternalShutter();
                end
        end
    end
end


% if selfStop()
%     stop(src);
% end

%     function tf = selfStop()
%         tf = false;
%         if hCamera.status ~= 20072 %no longer acquiring
%             switch hCamera.acquisitionMode
%                 case {'kinetic series' 'fast kinetics'}
%                     tf = (hCamera.totalNumberImagesAcquired == hCamera.numberKinetics);
%                 otherwise
%                     tf = true;
%             end
%         end
%
%     end

end
