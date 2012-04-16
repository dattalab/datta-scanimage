
%% INITIALIZE/VERIFY
import Devices.QImaging.*

loadlibrary('QCamDriver',@QCamDriver_2_0_8);

fprintf(1,'Loading driver...');
err = calllib('QCamDriver','QCam_LoadDriver');
fprintf(1,[err '\n']);

fprintf(1,'Listing Cameras...');
cameraList = libpointer('QCam_CamListItem');
cameraList.Value.m_reserved = zeros(10,1,'uint32');  %Deal with array nested in structure
[err,cameraList] = calllib('QCamDriver','QCam_ListCameras',cameraList,1);
fprintf(1,[err '\n']);

fprintf(1,'Getting Camera Handle...');
[err,cameraHandle] = calllib('QCamDriver','QCam_OpenCamera',cameraList.cameraId,0); %This works, after we changed the type of QCam_Handle in the header file from (void *) to (unsigned long)
fprintf(1,[err '\n']);

fprintf(1,'Getting Camera Model Descriptor...');
[err,modelString] = calllib('QCamDriver','QCam_GetCameraModelString',cameraHandle,repmat('a',256,1),256);
fprintf(1,[err '\n']);
fprintf(1,['Model String: ' modelString '\n']);

fprintf(1,'Getting Camera Setings...');
cameraSettings = libpointer('QCam_Settings');
cameraSettings.Value.m_private_data = zeros(64,1,'uint32'); 
err = calllib('QCamDriver','QCam_ReadSettingsFromCam',cameraHandle,cameraSettings);
fprintf(1,[err '\n']);

fprintf(1,'Reading Camera Parameters...');
[err,~,exposure] = calllib('QCamDriver','QCam_GetParam',cameraSettings,'qprmExposure',0);
[err,~,binning] = calllib('QCamDriver','QCam_GetParam',cameraSettings,'qprmBinning',0);
[err,~,exposureNs] = calllib('QCamDriver','QCam_GetParam64',cameraSettings,'qprm64Exposure',0);
[err,~,imageFormat] = calllib('QCamDriver','QCam_GetParam',cameraSettings,'qprmImageFormat',0); %Retrieves image format

fprintf(1,[err '\n']);
fprintf(1,'Exposure: %d\tBinning: %d\tExposure(ns): %d\n',exposure,binning,exposureNs);

fprintf(1,'Reading Camera Info...');
[err, bitDepth] = calllib('QCamDriver','QCam_GetInfo',cameraHandle,'qinfBitDepth',0);
[err, imageWidth] = calllib('QCamDriver','QCam_GetInfo',cameraHandle,'qinfImageWidth',0);
[err, imageHeight] = calllib('QCamDriver','QCam_GetInfo',cameraHandle,'qinfImageHeight',0);
[err, imageSize] = calllib('QCamDriver','QCam_GetInfo',cameraHandle,'qinfImageSize',0); %Retrieves image size, in bytes

fprintf(1,[err '\n']);
fprintf(1,'Bit Depth: %d\tImage Width: %d\tImage Height: %d\n',bitDepth,imageWidth,imageHeight);

%% GRAB A FRAME
fprintf(1,'Grabbing One Frame...');
frameBuffer = libpointer('QCam_Frame');
numPixels = imageWidth*imageHeight;
switch imageFormat  %Should store Map of image formats in driverData.mat, determined from header file
    %'frameMultiplicity' specifies the number of 'sub' frames with each image packet. I.e. for cases where color data is retrieved as separate frames, rather than extra bytes/pixel.
    %The valuesPerPixel and frameMultiplicity would be used in reshaping/interpreting the retrieved frame data
    case {0,2,4}
        valueType = 'uint8';
        valuesPerPixel = 1;  
        frameMultiplicity = 1;
    case {1,3,5}
        valueType = 'uint16';
        valuesPerPixel = 1;  
        frameMultiplicity = 1;
    case 6
        valueType = 'uint8';
        valuesPerPixel = 1;  
        frameMultiplicity = 3; % for each red,green,blue
    case 7
        valueType = 'uint16';
        valuesPerPixel = 1;  
        frameMultiplicity = 3; %One for each red,green,blue        
    case {8,9}
        valueType = 'uint8';
        valuesPerPixel = 3;
        frameMultiplicity = 1;
    case 10
        valueType = 'uint8'; %Must be retrieved byte-wise since not possible to retrieve 6-byte value otherwise
        valuesPerPixel = 6; 
        frameMultiplicity = 1;
    case {11,12}
        valueType = 'uint8'; 
        valuesPerPixel = 4;
        frameMultiplicity = 1;
end       

frameBuffer.Value.pBuffer = zeros(imageSize,1,valueType); %Matlab will treat buffer as array of uint32 values
frameBuffer.Value.bufferSize = imageSize; %Specified in bytes
err = calllib('QCamDriver','QCam_GrabFrame',cameraHandle,frameBuffer); %For the 1392x1040 camera, this takes 160ms -- way too long. Using MEX function will definitely be required.
fprintf(1,[err '\n']);
figure;
imagesc(reshape(frameBuffer.Value.pBuffer,imageHeight,imageWidth));

%% CLOSE CAMERA
fprintf(1,'Closing Camera...')
err = calllib('QCamDriver','QCam_CloseCamera',cameraHandle);
fprintf(1,[err '\n']);




