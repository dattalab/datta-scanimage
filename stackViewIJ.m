function stackViewIJ(acqNum)
% written by AJG.  launch imageJ to look at most recent image stack, or optionally
% any other acq#.

%requires a simple imageJ macro with the following commands:
%
% 

global state

if (nargin)
    fileNum=acqNum;
else
    fileNum=state.files.fileCounter-1;
end


fileName = dir(['*' zeroPadNum2str(fileNum) '*tif']);

eval(['!c:\MATLAB_LocalCode\ImageJ.exe ' ...
    state.files.savePath ...
    fileName.name  ...
    ' -macro zoomAndLoop.ijm']);


end
