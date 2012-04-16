clc
import dabs.andor.*

global imageData

if exist('hCamera','var') && isvalid(hCamera)
    delete(hCamera);
end

hCamera = AndorCamera();


%% TEST 1: Get data following single frame acquisition
hCamera.acquisitionMode = 'single scan';
hCamera.exposureTime = 1e-4; %Don't set if cap is off!!
hCamera.readMode = 'image';

tic;
if hCamera.isInternalMechanicalShutter
    hCamera.internalShutterOpen();
end
hCamera.startAcquisition();
hCamera.waitForAcquisition();
toc;

numPixels = hCamera.pixelCountImageTotal;
imageData = hCamera.getAcquiredData(16,[hCamera.expectedN hCamera.expectedM])';

figure;
imagesc(imageData);
disp(size(imageData));

%% TEST 2: Get data for multi-frame acquisitoin
close all;

numKinetics = 10;

hCamera.acquisitionMode = 'kinetics';
hCamera.exposureTime = .08; %Don't set if cap is off!!
hCamera.kineticCycleTime = 1;
hCamera.numberKinetics = numKinetics;
hCamera.readMode = 'image';

if hCamera.isInternalMechanicalShutter
    hCamera.internalShutterOpen();
end
hCamera.startAcquisition();
pause(numKinetics * hCamera.exposureTime);
while true
    if hCamera.status == 20073  %TODO: Consider returning status as decoded string??
        break;
        pause(.01);
    end
end  

imageData = hCamera.getAcquiredData(16,hCamera.pixelCountImageTotal * numKinetics);
imageData = reshape(imageData, ...
    hCamera.pixelCountDetector(2),hCamera.pixelCountDetector(1),hCamera.numberKinetics);
if hCamera.isInternalMechanicalShutter
    hCamera.closeInternalShutter();
end

%TODO: Make a movie here
hf = figure;
imagesc(imageData(:,:,1));
set(hf,'Name','Image # 1');
figure;
imagesc(imageData(:,:,numKinetics));
set(hf,'Name',['Image # ' num2str(numKinetics)]);

%% TEST 3: Display data for multi-frame Kinetics acquisition DURING acq

close all;
clear hTimer;

numKinetics = 10;

hCamera.acquisitionMode = 'kinetics';
hCamera.exposureTime = .08; %Don't set if cap is off!!
hCamera.kineticCycleTime = 0.1;
hCamera.numberKinetics = numKinetics;
hCamera.readMode = 'image';

kineticCycleTime = hCamera.kineticCycleTime;

hFig = figure;
set(hFig,'UserData',0);
hTimer = timer('StartDelay',kineticCycleTime,'Period',kineticCycleTime, 'TimerFcn',@(src,evnt)AndorCameraTest1_Fcn1(src,evnt,hCamera,hFig,true),'ExecutionMode','FixedRate','Name','Test 3 Timer');

if hCamera.isInternalMechanicalShutter
    hCamera.internalShutterOpen();
end
hCamera.startAcquisition();
start(hTimer);

%% TEST 4: Display data for multi-frame Run Till Abort acquisition DURING acq

close all;
clear hTimer;
%stop(timerfind('Name','Test 3 Timer'));

timeTillAbort = 10; %Time in seconds
useEvent = true;
callbackReshape = true; %specifies whether to do reshape operation in the callback

hCamera.readMode = 'image';
hCamera.image = {1,1,1,hCamera.pixelCountDetector(1),1,hCamera.pixelCountDetector(2)}; %Initializes the camera to use no binning and the entire sensor
hCamera.acquisitionMode = 'single scan'; %This seems to fix bug where a new kineticCycleTime (faster than previous acquisition) sometimes doesn't take
hCamera.acquisitionMode = 'run till abort';
hCamera.exposureTime = 1e-2; %Don't set if cap is off!!
hCamera.kineticCycleTime = 0; %Go as fast as possible
kineticCycleTime = hCamera.kineticCycleTime;

hFig = figure;
set(hFig,'UserData',0);

hTimer = [];
if ~useEvent
    hTimer = timer('StartDelay',kineticCycleTime,'Period',kineticCycleTime, 'TimerFcn', @(src,evnt)AndorCameraTest1_Fcn1(src,hCamera,hFig,callbackReshape),'ExecutionMode','FixedRate','Name','Test 3 Timer');
end
hStopTimer = timer('StartDelay',timeTillAbort,'TimerFcn',@(src,evnt)hCamera.abortAcquisition,'Name','StopAcquisitionTimer');

if useEvent
    hCamera.registerEventCallback(@(src,evnt)AndorCameraTest1_Fcn1(src,evnt,hCamera,hFig,callbackReshape));
end

if hCamera.isInternalMechanicalShutter
    hCamera.internalShutterOpen();
end
if useEvent
    hCamera.startAcquisition();
    start(hStopTimer);
else
    hCamera.startAcquisition();
    start([hTimer hStopTimer]);
end
    

%% TEST 5: Demonstrate ability to register and unregister events

close all;
clear hTimer;
%stop(timerfind('Name','Test 3 Timer'));

timeTillAbort = 5; %Time in seconds
callbacks = {@(src,event)disp('hello') [] @(src,event)disp('hello') []};

for i=1:length(callbacks)    
    hCamera.acquisitionMode = 'run till abort';
    hCamera.exposureTime = 1e-2; %Don't set if cap is off!!
    hCamera.kineticCycleTime = 1; %Go as fast as possible
    hCamera.readMode = 'image';
    kineticCycleTime = hCamera.kineticCycleTime;
    
    hCamera.registerEventCallback(callbacks{i});
    
    hStopTimer = timer('StartDelay',timeTillAbort,'TimerFcn',@(src,evnt)hCamera.abortAcquisition,'Name','StopAcquisitionTimer');
    
    if hCamera.isInternalMechanicalShutter
        hCamera.internalShutterOpen();
    end
    if isempty(callbacks{i})
        fprintf(1,'Starting acquisition with NO callback registered...\n');
    else
        fprintf(1,'Starting acquisition with callback registered: %s\n',func2str(callbacks{i}));
    end

    hCamera.startAcquisition();
    start(hStopTimer);
    wait(hStopTimer);
    disp(['Acquisition #' num2str(i) ' completed']);
end

%% TEST 6: Demonstrate spooling capability

close all;
clear hTimer;


numKinetics = 300;

hCamera.acquisitionMode = 'kinetics';
hCamera.frameTransferMode = true;
hCamera.exposureTime = 1e-3; %Don't set if cap is off!!
hCamera.kineticCycleTime = 0; %Go as fast as possible
hCamera.numberKinetics = numKinetics;
hCamera.readMode = 'image';
%hCamera.image = {1,1,1,hCamera.detectorPixels(1),1,hCamera.detectorPixels(2)}; %Initializes the camera to use no binning and the entire sensor

hCamera.spool = {1,7,fullfile('c:\data',datestr(now,30)),10};

hFig = figure;
set(hFig,'UserData',0);
hCamera.registerEventCallback(@(src,evnt)AndorCameraTest1_Fcn1(src,hCamera,hFig));

if hCamera.isInternalMechanicalShutter
    hCamera.internalShutterOpen();
end
hCamera.startAcquisition();


