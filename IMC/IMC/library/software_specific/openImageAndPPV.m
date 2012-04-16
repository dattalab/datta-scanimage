function PPV=openImageAndPPV(filename)
% OPENIMAGEANDPPV   - Photons per Pixel Value Calculation.
%   OPENIMAGEANDPPV Opens an image whose filename is specified by filename for analysis of
%   the photons per pixel value.
%   If no filename is passed, it calls a GUI to open one.
% 
% See also PARSEHEADER, IMREAD

% Author: Thomas Pologruto
% Date Created: 1/7/04

PPV=[];
if nargin > 1
	error('Too many inputs to openImageAndPPV');
elseif nargin < 1
	[fname,pname]=uigetfile({'*.tif'},'Please select an image to open');
	if isnumeric(fname)
		return
	end
	filename=fullfile(pname,fname);
end
h = waitbar(.5,['Opening image ' filename], 'Name', 'Calculate PPV', 'Pointer', 'watch');
% Open the specified files for analysis.
[data,header] = openimagefile(filename);
waitbar(.8,h, 'Calculatiing PPV');    
% Calculate PPV for each channel
for j=1:length(data)
	PPV(j)=analyzePhotonsPerPixel(data{j});
end
close(h);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function PPV=analyzePhotonsPerPixel(image)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function takes a stack of images of any size and does a
% variance-mean analysis on it to determine the Photons Per Pixel (PPV).
% This measurement assumes that the first frame of the stack is dark noise,
% and uses the third through Nth frame for statistics.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[x,y,z]=size(image);
pixelsperframe=x*y;
image=reshape(image,1,pixelsperframe*z);
darknoiseMean=mean(image(1:pixelsperframe));
darknoiseVar=var(image(1:pixelsperframe));
dataForAnalysis=image(3*pixelsperframe:end)-darknoiseMean;
signalMean=mean(dataForAnalysis);
signalVar=var(dataForAnalysis);
PPV=signalVar./signalMean;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Aout,header] = openimagefile(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open a TIF image file and store its contents as cell array Aout.  Aout
% has one cell array for each channel collected.
%
% filename is the file name with extension.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Aout=[];
info=imfinfo(filename);
frames = length(info);
header=info(1).ImageDescription;
header=parseHeader(header);
for i = 1:frames
	Aout(:,:,i) = imread(filename, i);
end

% Pushes the data into cell arrays according to the number of channels read....
channels=header.acq.numberOfChannelsAcquire;
for channelCounter=1:channels
	data{channelCounter}=Aout(:,:,channelCounter:channels:end);
end
Aout=data;
        