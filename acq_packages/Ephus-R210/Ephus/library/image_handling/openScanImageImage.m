function [Aout,header] = openScanImageImage(filename,varargin)
% openScanImageImage   - Opens a scanImage image file (with TIF extension).
% Store images in Aout.
%   
% 
%   See also CONVERTSTACKTOLS, PARSEHEADER

Aout=[];
header=[];

% Parse the inputs....
%filter=0;
%blocksize=3;
splitIntoCellArray=0;
linescan=0;
if nargin > 1
    % Parse input parameter pairs and rewrite values.
    counter=1;
    while counter+1 <= length(varargin)
        eval([varargin{counter} '=[(varargin{counter+1})];']);
        counter=counter+2;
    end
end


h = waitbar(0,'Opening Tif image...', 'Name', 'Open TIF Image', 'Pointer', 'watch');
try
    info=imfinfo(filename);
    frames = length(info);
    header=info(1).ImageDescription;
    header=parseHeader(header);
    for i = 1:frames
        waitbar(i/frames,h, ['Loading Frame Number ' num2str(i)]);    
        Aout(:,:,i) = imread(filename, i);
		%if filter
		%	Aout(:,:,i)=medfilt2(Aout(:,:,i),[blocksize blocksize]);
        %end
    end
    waitbar(1,h, 'Done');
    close(h);
catch
    close(h);
    disp(['Cant load file: ' filename ]);
end


% Pushes the data into cell arrays according to the number of channels read....
if splitIntoCellArray
    channels=header.acq.numberOfChannelsAcquire;
    for channelCounter=1:channels
        data{channelCounter}=Aout(:,:,channelCounter:channels:end);
    end
    Aout=data;
end

if linescan
    if iscell(Aout)
        for j=1:length(Aout)
            Aout{j}=convertStackToLS(Aout{j});
        end
    else
        Aout=convertStackToLS(Aout);
    end
end
