function outVal = waitbarUpdate(fraction, wb,message)
%Used to update waitbar figure's fraction and display string during a multi-step operation, and to determine whether the waitbar is cancelled
%
% USAGE
%    outval = waitbarUpdate(fraction,wb,message)
%       fraction: number (from 0-1) indicating fraction complete at point of this call
%       wb: handle of waitbar object (created with waitbar())
%       message: string indicating message to display at point of this call
%       outval: 1 if cancelled, 0 otherwise
%
% CHANGES
%
% Created
%  Vijay Iyer - ??/??/08
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute/Janelia Farm Research Center 2008
try
    if ishandle(wb)
        waitbar(fraction, wb, message);
        figure(wb);
        outVal = 0;
        %     if isWaitbarCancelled(wb)
        %         delete(wb);
        %         evalin('caller','return');
        %     end
    else
        outVal = 1;
    end
catch
    outVal = 1;
end