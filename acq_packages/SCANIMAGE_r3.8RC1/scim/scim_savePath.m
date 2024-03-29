function varargout = scim_savePath()
%% function varargout = scim_savePath()
%SCIM_SAVEPATH Changes directory to or returns currently specified ScanImage save directory
%
%% SYNTAX
%   scim_savePath(): Changes directory to current ScanImage save path
%   savePath = scim_savePath(): Returns current ScanImage save path
%
%% CREDITS
%   Created 9/24/10, by Vijay Iyer
%% *****************************************


global state

savePath = state.files.savePath;


error(nargoutchk(0,1,nargout,'struct'));
if nargout
    varargout = {savePath};
else
    if ~isempty(savePath) && exist(savePath,'dir')
        cd(savePath);
    elseif isempty(savePath)
        error('The ScanImage save path has not yet been set.');
    else
        error('The ScanImage save path (''%s'') cannot be found!', savePath);
    end
end







