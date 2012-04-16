classdef AndorCamera < Programming.Interfaces.VClassic
    % ANDORCAMERA Class encapsulating functionality of a single camera device under the Andor SDK
    %
    % The goal of this class is to provide a thin wrapper around Andor's C API, 
    % in the form of a Matlab class. 
    %
    %% DEVICE PROPERTIES:
    % Most of the Andor SDK SetXXX(), GetXXX(), and IsXXX() functions in the SDK have been translated 
    % into properties of this Matlab class. The pattern followed is that 'SetPropertyName()'
    % and/or 'GetPropertyName()' functions in the API are mapped to the property
    % named 'propertyName', and accessed as Matlab properties normally are. 
    % Note the case convention. For example:
    %
    % GetReadOutTime(&readOutTime); (in C)
    % becomes:
    % readOutTime = cameraHandle.readOutTime; (in Matlab)
    %
    % and similarly, 
    %
    % SetAccumulationCycleTime(time); (in C)
    % becomes:
    % cameraHandle.accumulationCycleTime = accumulationCycleTime; (in Matlab)
    %
    % Besides this general pattern, there are several special cases in the Andor SDK
    % which are handled in standard ways by the Matlab wrapper class.
    %   
    % /Binary Properties/
    %  Those IsXXX() functions in SDK which are implemented as properties are named 'isXXX' in the wrapper class. 
    %  For example, IsCoolerOn() in SDK maps to a Matlab property 'isCoolerOn'. Values are returned as logical type ('true' or 'false').
    %    
    % /Multiple Arguments/
    % For cases whre the SetXXX() functions require multiple arguments to be passed, 
    % a cell array should be passed.  For example:
    %
    % SetFastKinetics(exposedRows, seriesLength, time, mode, hbin, vbin);
    % becomes:
    % cameraHandle.fastKinetics = {exposedRows seriesLength time mode hbin vbin};
    %
    % For cases where the GetXXX() functions return multiple arguments, the wrapper
    % class returns either a cell array or a numeric array (where appropriate). For example:
    %
    % GetImageFlip(&hFlip, &vFlip);
    % becomes:
    % [hFlip,vFlip] = cameraHandle.imageFlip; 
    %
    % /Index-Accessed Properties/
    % For cases where the GetXXX() and SetXXX() SDK functions methods require an index argument 
    % (which is set by a separate SetXXX() call), the wrapper adds a XXXIdx property which is 
    % recommended for setting the property. The XXXIdx properties use Matlab one-based indexing.
    % For example:
    %
    % GetPreAmpGain(preAmpGainIndex, &gain);
    % becomes:
    % gain = cameraHandle.preAmpGain; (which internally passes the current value of 'preAmpGainIdx')
    %
    % and similarly,
    %
    % SetVSSpeed(VSSpeedIdx);
    % becomes:
    % cameraHandle.VSSpeedIdx = index; (recommended, uses one-based index)
    % or:
    % cameraHandle.VSSpeed = index; (available, uses zero-based index)
    %
    % (Note that ability to set the XXX property directly is retained, using zero-based indexing (to match the C API).
    %
    % /Dependent Properties/
    % For cases where SDK SetXXX/GetXXX functions request on the value of another
    % property, the wrapper accesses the currently set value of the
    % other property, and passes this to the SDK call.  For example:
    %
    % GetNumberHSSpeeds(ADChannelIdx, outputAmplifier, &speeds);
    % becomes:
    % speeds = cameraHandle.numberHSSpeeds; (which internally passes the current value of 'ADChannelIdx' and 'outputAmplifier')
    %
    % /Named Option Properties/
    % Some SetXXX() methods accept an index into a list of named options (described in the SDK documentation).
    % In these cases, the wrapper class adds a XXXOptions property which provides a list of the option names (strings).
    % These names would typically be used instead of setting the property according to the index specified in the SDK documentation.
    % For example:
    %
    % SetReadMode(4);
    % becomes:
    % cameraHandle.readMode = 'image'; 
    % where:
    % cameraHandle.readModeOptions returns: {'full vertical binning'; 'multi-track'; 'random-track'; 'single-track'; 'image'};
    %
    %% CREDITS
    %   Created Spring 2010 by Vijay Iyer (HHMI/JFRC) and David Earl (5AM Solutions)
    %
    %% *******************************************************************************
    
    %% TODO
    %   * Reorganize the private/hidden methods into some sensible grouping
    %   * Refactor driverData and driverCall handling to general superclass or interface (5AM)
    %   * Handle transpose operation in data retrieval methods (5AM)
    %   * Add externalShutterOpen/Close() methods and externalShutterXXX properties that can be used to cache individual components of shutter and shutterEx properties.
    %   * Investigate expectedM/N for complexImage case
    %   * Investigate if invalidUntilInitProps mechanism is working and actually needed. Seems to be unnecessary.
    %   * Filter by event type for eventing mechanism -- should help prevent stray callbacks due to done event in some circumstances
            
    %% CONSTRUCTOR PROPERTIES        
    %Properties Initialized on Construction
    
    properties (SetAccess=private)
        cameraHandle; % Handle returned by API identifying camera        
        cameraSerialNumber; %(GET-ONLY) See Andor SDK documentation.
        cameraType; % String descriptor of type of Andor camera, e.g. 'IXON'
    end
    
    %% ABSTRACT PROPERTY REALIZATION
    properties(GetAccess=protected,Constant)
        setErrorStrategy = 'restoreCached'; % tell VClass to cache the current value before calling a Set function, and fall back to this cached value if an error occurs.
    end
    
    %% DEVICE PROPERTIES (ADDED BY CLASS)
    
    properties
        % Index variables stored local to class, related to API SetXXX() functions taking ZERO-based index as argument specifying value to set
        % Our interface allows index-variables to be set (and get) using Matlab ONE-based indexing, as alternative to using the property directly mapped to API
        FKVShiftSpeedIdx; % Index of FKV shift speed currently set
        HSSpeedIdx; % Index of HS speed currently set
        VSSpeedIdx; % Index of vertical shift speed currently set
        preAmpGainIdx;  % Index of pre amp gain currently set        
        
        % Class-added properties for finer-grained control of 'spool' property
        spoolActive;
        spoolFrameBufferSize;
        spoolMethod;
        spoolPath;
        
        temperatureStatus; %One of {DRV_TEMP_OFF, DRV_TEMP_STABILIZED, DRV_TEMP_NOT_REACHED, DRV_TEMP_DRIFT, DRV_TEMP_NOT_STABILIZED}. Status string associated with current temperature of detector.
        temperatureTarget; %Desired temperature, in degrees, of the detector. NOTE: When Cooler is disabled, the value retrieved will reflect the ambient temperature, regardless of what has been set.
    end
    
    properties (Dependent)
        % Device properties added by class, to allow access to singular pieces of information for multi-argument GetXXX() functions
        fastestRecommendedVSSpeedValue; % Value of the fastest recommended VSSpeed
        fastestRecommendedVSSpeedIdx; %The VSSpeedIdx value (1-based index) corresponding to fastest recommended VSSpeed value
                
        imageFlipHorizontal;
        imageFlipVertical;
        
        versionInfoDriver; %This property reports the SDK version. See Andor SDK documentation of GetVersionInfo() function.
        versionInfoFirmware %This property reports the device firmware version. See Andor SDK documentation of GetVersionInfo() function.
    end
    
    properties (SetAccess=protected)        
        
        % Device properties added by class, for convenience/information
        pixelCountDetector; %2 element array indicating number of X & Y (horizontal and vertical) pixels on detector.
        pixelCountImage; %2 element array indicating number of X & Y (horizontal and vertical) pixels used with current binning/subimage/crop settings (via set of 'image' property)
        pixelCountImageTotal; % Product of pixelCountImage elements, giving total number of pixels
        
        %Properties added by class giving information particular to the current device's model
        HSSpeedOptions; % a list enumerating valid options for 'HSSpeed' property.
        VSSpeedOptions; % a list enumerating valid options for 'VSSpeed' property.
        FKVShiftSpeedOptions; % a list enumerating valid options for 'FKVShiftSpeed' property.
        preAmpGainOptions; % a list enumerating valid options for 'preAmpGain' property.
        readModeOptions; % a list enumerating valid options for 'readMode' property.
        acquisitionModeOptions; % a list enumerating valid options for 'acquisitionMode' property.
        triggerModeOptions; % a list enumerating valid options for 'triggerMode' property.
        outputAmplifierOptions; % a list enumerating valid options for 'outputAmplifier' property.
        
        modelNumADChannels; % the number of AD channels provided by the current camera
    end
    
    properties (SetAccess=protected,Hidden)        
        % Used to store the expected number of pixels being used for the current readMode
        expectedM;
        expectedN;
        expectedDimensions;
        
        DDGPulseDelay; % This must be stored -- no getter!
        DDGPulseWidth; % This must be stored -- no getter!
        multiTrackBottomRow; % This must be stored -- no getter!
        multiTrackGap; % This must be stored -- no getter!
    end
    
    
    %% PRIVATE/PROTECTED PROPERTIES
    
    % Properties to be explicitly initialized on object construction
    properties (Access=protected, Hidden)
        methodNargoutMap; % Map keyed by driver function names, containing number of output arguments for each function, not including 'status'
        responseCodeMap;
        cameraTypeMap;
        
        % Maps converting from string descriptors to index values
        outputAmplifierMap;
        acquisitionModeMap;
        readModeMap;
        triggerModeMap;
        indexMap;
        initialValuesMap;
        invalidUntilInitProps;
                                              
        % Capabilities Data structures/values
        HSSpeedOptionsStruct;
        preAmpGainOptionsStruct;
        preAmpGainOptionsAll; %List of all available preAmpGainOptions values, independent of other parameters
        maxNumberHSSpeeds; %The largest value of numberHSSpeeds
        
        % Used for filtering (ignoring) certain response codes. This is useful as adjunct to driverCallFiltered() method for property set/get operations (not handled via driverCallXXX())
        filteredDriverCodes; % a list of driver error codes to ignore globally (due to their irrrelevance in certain contexts)
        
        isConstructed=false; %a global flag indicating if the object has been successfully constructed
        preAmpGainIdxInitValue; 
    end

    properties (GetAccess=private,Hidden, Constant)
        driverPrettyName = 'Andor Technology SDK';
        driverHeaderFilename = 'ATMCD32D_2_87'; %TODO: Handle case of multiple versions!
        driverLib = 'ATMCD32D';
        driverPath = 'c:\program files\Andor Solis\Drivers'; %Was '\Andor Ixon' folder in the v2.85
        driverDataFilename = 'DriverData.mat';
        
        palettePath = 'c:\program files\Andor Solis';
        
        %TODO: Maybe cache header files from different versions, similar to DAQmx
        dataFileFields = {'methodNargoutMap' 'responseCodeMap' 'cameraTypeMap'};
        supportedVersions = {'2.87'};
        driverHeaderFilenames = {'ATMCD32D_2_87'};
        
        displayProperties = sort({'cameraSerialNumber' 'cameraType' 'statusString' 'isCoolerOn' 'EMCCDGain' 'EMAdvanced' 'EMGainMode' 'frameTransferMode'  ...
            'acquisitionMode' 'readMode' 'triggerMode'...
            'accumulationCycleTime' 'exposureTime' 'kineticCycleTime'...
            'numberAccumulations' 'numberKinetics' 'numberPrescans' ...
            'image' 'imageFlip' 'imageRotate' ...
            'ADChannel' 'preAmpGain' 'outputAmplifier'...
            'FKVShiftSpeed' 'HSSpeed' 'VSSpeed' 'fastestRecommendedVSSpeedIdx' 'fastestRecommendedVSSpeedValue'...            
            'filterMode' 'fastExtTrigger' 'overlapMode' ...
            'photonCounting' 'photonCountingThreshold'  ...
            'HSSpeedOptions' 'VSSpeedOptions' 'FKVShiftSpeedOptions' 'preAmpGainOptions' 'readModeOptions' 'acquisitionModeOptions' 'triggerModeOptions' ... % TODO: Fix 'outputAmplifierOptions' 
            'spoolActive' 'spoolFrameBufferSize' 'spoolMethod' 'spoolPath' 'temperature' 'temperatureStatus' ...
            'pixelCountDetector' 'pixelCountImage' ...
            ... % 'ADChannelIdx' 'FKVShiftSpeedIdx' 'HSSpeedIdx' 'VSSpeedIdx' 'fastestRecommendedVSSpeedIdx' 'preAmpGainIdx' ...
            });                        
        
        temperatureStatusCodes = [20034 20035 20036 20037 20040];
    end
    
    
    %% PSEUDO-DEPENDENT DEVICE PROPERTIES
    
    %Properties directly or simply mapped to GetXXX() functions from API
    properties (GetObservable,SetObservable)
        acquisitionTimings; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTES: 1) The multiple output values are returned as a cell array. 2)
        ampDesc; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: It is recommended to access 'outputAmplifierOptions' property instead.
        ampMaxSpeed; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: A single value is returned, pertaining to currently set 'outputAmplifier' value, rather than to a specified index value.
        bitDepth; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: A single value is returned, pertaining to currently set 'ADChannel' value, rather than to a specified index value.
        cameraEventStatus; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        controllerCardModel; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        DDGPulse; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: This function takes four args (two input, two output).  The input args (width, resolution) are not tied to any API properties.
        DDGIOCPulses; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        detector; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: The multiple output values are returned as a numeric array.
        EMGainRange; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: The multiple output values are returned as a numeric array.
        fastestRecommendedVSSpeed; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTES: 1) The multiple output values are returned as a cell array. 2) The added properties 'fastestRecommendedVSSpeedValue' and 'fastestRecommendedVSSpeedIdx' are available/recommended instead.
        FKExposureTime; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        FKVShiftSpeed; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTES: 1) It is recommended to set the FKVShiftSpeedIdx property instead, which represents index into values given by FKVShiftSpeedOptions property 2) When accessing property, value output pertains to currently set FKVShiftSpeedIdx property value 3) When setting this property directly, zero-based indexing into the list of FKVShiftSpeedOptions is used
        hardwareVersion; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: The multiple output values are returned as a cell array.
        headModel; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        HVFlag; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        imagesPerDMA; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        keepCleanTime; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        maximumBinning; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTES: 1) When accessing property, value output pertains to currently set ReadModeIdx property value 2)The multiple output values are returned as a numeric array
        maximumExposure; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        MCPGainRange; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: The multiple output values are returned as a numeric array.
        MCPVoltage; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        minimumImageLength; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        numberADChannels; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        numberAmp; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        numberAvailableImages; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: The multiple output values are returned as a numeric array.
        numberFKVShiftSpeeds; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        numberHSSpeeds; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTES: 1) When accessing property, value output pertains to currently set 'ReadModeIdx' and 'outputAmplifierIdx' property values
        numberNewImages; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: The multiple output values are returned as a numeric array.
        numberPreAmpGains; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        numberRingExposureTimes; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        numberIO; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        numberVSAmplitudes; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        numberVSSpeeds; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        pixelSize; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: The multiple output values are returned as a numeric array
        readOutTime; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        ringExposureRange; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: The multiple output values are returned as a numeric array
        sizeOfCircularBuffer; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        softwareVersion; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation. NOTE: The multiple output values are returned as a numeric array
        status; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
        statusString; %(GET-ONLY) A decoded string representation of 'status' property
        temperatureRange; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation NOTE: The multiple output values are returned as a numeric array
        totalNumberImagesAcquired; %(GET-ONLY) This property wraps a GetXXX() method of the same name. See Andor SDK documentation.
    end
    
    %Properties directly mapped to IsXXX() functions from API
    properties (GetObservable,SetObservable)
        isCoolerOn; %(GET-ONLY) This property wraps a IsXXX() method of the same name. See Andor SDK documentation.
        isInternalMechanicalShutter; %(GET-ONLY) This property wraps a IsXXX() method of the same name. See Andor SDK documentation.
    end

    %Properties directly or simply mapped to SetXXX() functions from API
    %These /DO NOT/ have a GetXXX() function in the API.
    properties (GetObservable,SetObservable)
        acquisitionMode; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation. NOTES: 1) Instead of index value, value get/set is one of those specified by acquisitionModeOptions property.
        ADChannel; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        advancedTriggerModeState; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        baselineClamp; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        baselineOffset; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        cameraStatusEnable; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        complexImage; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        coolerMode; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        customTrackHBin; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        DACOutputScale;  % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        DACOutput;  % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        DDGGateStep; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        DDGInsertionDelay; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        DDGIntelligate; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        DDGIOC; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        DDGTimes; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        DDGTriggerMode; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        DDGVariableGateStep; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        EMAdvanced; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        EMGainMode; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        fanMode; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        fastKinetics; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        fastKineticsEx; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        fastExtTrigger; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        frameTransferMode; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        FVBHBin; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        gate; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        gateMode; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        highCapacity; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        image; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        isolatedCropMode; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        MCPGain; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        MCPGating; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        multiTrack; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation. Note: This function takes five args: three input args specifying multitrack params, and two output values containing the calculated track properties
        multiTrackHBin; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        multiTrackHRange; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        numberAccumulations; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        numberKinetics; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        numberPrescans; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        outputAmplifier; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation. NOTES: 1) Instead of index value, value get/set is one of those specified by outputAmplifierOptions property.
        overlapMode; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        PCIMode; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        photonCounting; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        photonCountingThreshold; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        randomTracks; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        readMode; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation. NOTES: 1) Instead of index value, value get/set is one of those specified by readModeOptions property.
        ringExposureTimes; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        shutter; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        shutterEx; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        sifComment; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        singleTrack; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        singleTrackHBin; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        spool; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        triggerInvert; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        triggerMode; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        IODirection; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        IOLevel; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
        VSAmplitude; % This property wraps a SetXXX() method of the same name. See Andor SDK documentation.
    end
    
    %Properties directly or simply mapped to GetXXX() and SetXXX() functions from API
    properties (GetObservable,SetObservable)
        accumulationCycleTime; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation.
        DDGIOCFrequency; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation.
        DDGIOCNumber; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation.
        EMCCDGain; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation.
        exposureTime; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation.
        filterMode; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation.
        HSSpeed; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation. NOTES: 1) A single value is returned, pertaining to currently set 'ADChannel' value, rather than to a specified index value. 2) It is recommended to set property using 'HSSpeedIdx' instead. 3) SET: The multiple input parameters should be supplied as cell array. 4) GET: A single value is returned, pertaining to currently set 'HSSpeedIdx' property
        imageFlip; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation.
        imageRotate; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation.
        kineticCycleTime; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation.
        metaData; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation.
        preAmpGain; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation. NOTES: 1) It is recommended to set property using 'preAmpGainIdx' instead. 2) SET: The multiple input parameters should be supplied as cell array. 3) GET: A single value is returned, pertaining to currently set 'preAmpGainIdx' property
        temperature; % TODO: Clean up doc string! We will disallow set access to temperature, and refer to temperatureTarget
        temperatureF; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation.
        VSSpeed; % This property wraps GetXXX()/SetXXX() methods of the same name. See Andor SDK documentation. NOTES: 1) It is recommended to set property using 'VSSpeedIdx' instead. 2) SET: The multiple input parameters should be supplied as cell array. 3) GET: A single value is returned, pertaining to currently set 'VSSpeedIdx' property
    end
    
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = AndorCamera(cameraSerialNumber)
            %Constructs a Devices.Andor.AnderCamera class instance, encapsulating an Andor Camera device.
            %
            %function obj = AndorCamera(cameraSerialNumber)
            %   cameraSerialNumber: The serial number uniquely identifying the device. If only one camera is present, then this need not be supplied.
            %
            
            obj.acquisitionModeMap = containers.Map({'single scan' 'accumulate' 'kinetics' 'fast kinetics' 'run till abort'},num2cell(1:5));
            obj.readModeMap = containers.Map({'full vertical binning' 'multi track' 'random track' 'single track' 'image'},num2cell(0:4));
            obj.triggerModeMap = containers.Map({'internal' 'external' 'external start' 'external exposure' 'external fvb em' 'software trigger'},num2cell([0 1 6 7 9 10]));
            obj.indexMap = containers.Map({'bitDepth' 'preAmpGain' 'VSSpeed'},{'ADChannel' 'preAmpGainIdx' 'VSSpeedIdx'});
            obj.initialValuesMap = containers.Map({'accumulationCycleTime' 'acquisitionMode'   'ADChannel' 'advancedTriggerModeState'  'baselineClamp' 'baselineOffset'    'cameraStatusEnable' 'coolerMode'    'customTrackHBin'   'DACOutputScale'    'DACOutput' 'DDGGateStep'   'DDGInsertionDelay'      'DDGIntelligate'   'EMAdvanced'    'EMGainMode'    'exposureTime'  'fanMode'    'fastExtTrigger'    'frameTransferMode' 'FVBHBin'   'gateMode'  'highCapacity' 'metaData'  'multiTrackHBin'    'numberAccumulations'   'numberKinetics'    'numberPrescans'    'outputAmplifier'        	'overlapMode'   'PCIMode'   'photonCounting'    'photonCountingThreshold'   'readMode'  'sifComment'   'singleTrackHBin'    'spoolFrameBufferSize'  'spoolMethod'   'triggerMode'   'VSAmplitude'}, ...
                {1                      'single scan'        0           0                           1               0                   0                   0               1                   1                   {1,16,5}     1               0                       0                   0               0               1e-4            0           0                   0                   1           0           0               0           1                  1                       1                   0                   'electron_multiplying'      0               {1 0}       0                   {1 1}                       'image'     ''             1                    10                      7               'internal'      0});
            obj.invalidUntilInitProps = containers.Map( {'complexImage' 'cropMode'  'fastKinetics'  'image' 'isolatedCropMode'  'multiTrack'    'randomTracks'  'ringExposureTimes' 'singleTrack'}, ...
                                                {1              1           1               1       1                   1               1               1                   1});                                                                              

            import Devices.Andor.*;
                        
            % Load the Andor  DLL, if needed
            % TODO: At moment, we cache header file as part of class, but rely on DLL to be installed in particular path. Is this right approach?
            if ~libisloaded(obj.driverLib)
                disp([obj.driverPrettyName ': Initializing...']);
                warning('off','MATLAB:loadlibrary:parsewarnings');
                warning('off','MATLAB:loadlibrary:FunctionNotFound'); %ANDOR: There is a function declaration in 2.87 (GetStartUpTime) of a function that does not exist in DLL
                loadlibrary(fullfile(obj.driverPath, [obj.driverLib '.dll']),fullfile(obj.classPrivatePath,[obj.driverHeaderFilename '.h'])); %TODO: Append version decoration if multiple header versions are stored
                warning('on','MATLAB:loadlibrary:parsewarnings');
                warning('on','MATLAB:loadlibrary:FunctionNotFound'); %ANDOR: There is a function declaration in 2.87 (GetStartUpTime) of a function that does not exist in DLL
            end
            
            %Update the driver data file, if needed
            dataFullFileName = fullfile(obj.classPrivatePath,obj.driverDataFilename);
            if ~exist(dataFullFileName,'file')
                obj.driverDataUpdate() %This loads header file and data, and loads the library as well
            else
                %Load properties from file
                fileProps = obj.dataFileFields;
                foundFileProps = who('-file',dataFullFileName);
                if ~isempty(setdiff(fileProps,foundFileProps)) %Some properties weren't found
                    if ~obj.driverDataUpdate(); %Update en masse
                        delete(obj);
                        return;
                    end
                else
                    %A silly two-step
                    structVar = load(dataFullFileName, fileProps{:});
                    for i=1:length(fileProps)
                        obj.(fileProps{i}) = structVar.(fileProps{i});
                    end
                end
            end
            
            
            %Determine # of cameras & obtain handle to this particular camera
            [status,numCameras] = obj.driverCallRaw('GetAvailableCameras',0);
            obj.validateStatus(status,'GetAvailableCameras');
            
            %Handle input arguments
            if ~nargin && numCameras > 1
                error(['A camera serial number must be specified when there is more than one camera (' num2str(numCameras) ' cameras detected).']);
            end
            
            if numCameras > 1
                for i=1:numCameras
                    % get the handle for the current index
                    [status,cameraHandle] = obj.driverCallRaw('GetCameraHandle', i-1, 0);
                    obj.validateStatus(status,'GetCameraHandle');
                    
                    status = obj.driverCallRaw('SetCurrentCamera',cameraHandle);
                    obj.validateStatus(status,'SetCurrentCamera');
                    
                    %Initialize camera (needed before getting serial number)
                    status = obj.driverCallRaw('Initialize',obj.driverPath);
                    obj.validateStatus(status,'Initialize');
                    
                    % get the serial number for the current handle
                    [status, currentSerialNumber] = obj.driverCallRaw('GetCameraSerialNumber',0);
                    obj.validateStatus(status,'GetCameraSerialNumber');
                    
                    if currentSerialNumber == cameraSerialNumber
                        obj.cameraHandle = cameraHandle;
                        break;
                    end
                end
                
                if isempty(obj.cameraHandle)
                    error('Could not find given serial number');
                end
            else
                [status,obj.cameraHandle] = obj.driverCallRaw('GetCameraHandle', 0, 0);
                obj.validateStatus(status,'GetCameraHandle');
            end
            
            %Store the cameraSerialNumber to the class instance, rather than using a pseudo-dependent property
            [status,obj.cameraSerialNumber] = obj.driverCallRaw('GetCameraSerialNumber',0);
            
            %Initialize the Andor SDK
            obj.driverCall('Initialize', obj.driverPath); %This takes camera handle and its control is reserved to this object (i.e. can't use in Solis)

            
            %Initialize properties                                 
%             disp('#######PRE INITMPV');
             obj.initializeModelPropValues(); %Initialize properties which depend on particular camera model
%             disp('#######POST INITMPV');
             obj.initializeDefaultPropValues(); %Initialize properties to a default startup state -- including several properties with SetXXX() call, but no corresponding GetXXX() function.
            
            obj.customDisplayPropertyList = obj.displayProperties;
            
            obj.spoolPath = regexpi(fileparts(mfilename('fullpath')),'([a-z]:\\).*','tokens','once'); %Initialize spool path to drive on which this class is defined
            
            %Signal construction completion
            obj.isConstructed = true;
        end
        
        function delete(obj)
            
            %Handle invalid handle (e.g. error in constructor)
            if ~isvalid(obj)
                return;
            end
            
            %Handle array case
            if length(obj) > 1
                for i=1:length(obj)
                    delete(obj(i));
                end
                return;
            end
            
            if ~isempty(obj.cameraHandle)
                %            status = calllib(obj.driverLib, 'CoolerOFF');
                %            [status,currentTemperature] = calllib(obj.driverLib,'GetTemperature',0);
                %            while currentTemperature < 0
                %                pause(1)
                %                [status,currentTemperature] = calllib(obj.driverLib,'GetTemperature',0);
                %            end
                
                obj.coolerOFF();
                if obj.isInternalMechanicalShutter()
                    obj.internalShutterClose();
                end
                obj.registerEventCallback(); %Clears resources, if any, associated with event signalling
                
                startTemperature = obj.driverCallFiltered('GetTemperature',20034, 0); %Only status code returned should be DRV_TEMP_OFF (since cooler is now off)
                waitForWarmup = startTemperature < -20;
                
                if waitForWarmup
                    if ismember(obj.cameraType,{'ICCD'}) %ANDOR: What are 'Classic' cameras? 
                        currentTemperature = startTemperature;
                        while currentTemperature < -20
                            currentTemperature = obj.driverCallFiltered('GetTemperature',20034, 0); %Only status code returned should be DRV_TEMP_OFF (since cooler is now off)
                            fprintf(1,'Waiting for camera (serial number: %d)  temperature to warm up before shutting down. Current temperature: %d\n',obj.cameraSerialNumber, currentTemperature);
                            pause(2);
                        end
                    else
                        while obj.driverCallFiltered('GetTemperature',20034, 0) < (startTemperature + 2)   %Only status code returned should be DRV_TEMP_OFF (since cooler is now off)
                            pause(.5);
                        end
                        fprintf(1,'Camera (serial number: %d) has begun warm-up.\n', obj.cameraSerialNumber);
                    end
                end
                
                %Shut down system
                obj.shutDown();
                if waitForWarmup
                    fprintf(1,'Camera (serial number: %d) has been shut down.\n', obj.cameraSerialNumber);
                end
            end
            
        end
    end
    
    %% PROPERTY ACCESS
    methods
        

        function val = get.pixelCountImageTotal(obj)
            % Gets the total number of pixels in the current acquisistion.
            
            pixelCountImageVal = obj.pixelCountImage;
            if isnan(pixelCountImageVal)
                val = nan;
            else
                val = pixelCountImageVal(1) * pixelCountImageVal(2); %prod doesn't work with int32 values
            end
        end
        
        function val = get.pixelCountImage(obj)
            % Returns a vector containing the number of pixels in the X and Y dimensions.
            
            %TODO: Consider whether this should be stored in a cached value, every time 'image' property is set, to avoid constantly computing
            
            imageVal = obj.image;
            if isempty(imageVal)
                val = nan; %'image' value has not yet been set! SDK won't allow, so don't return default value
            else
                val = [round((imageVal{4} - imageVal{3}+1)/imageVal{1})  round((imageVal{6}-imageVal{5}+1)/imageVal{2})];
            end
        end
        
        
        function val = get.fastestRecommendedVSSpeedValue(obj)
            val = obj.fastestRecommendedVSSpeed{2};            
        end
        
        function val = get.fastestRecommendedVSSpeedIdx(obj)
            val = obj.fastestRecommendedVSSpeed{1} + 1; %Convert from zero-based to one-based indexing
        end
        
        function val = get.HSSpeedOptions(obj)
            speedList = obj.HSSpeedOptionsStruct(obj.ADChannel+1).(obj.outputAmplifier);
            if isempty(speedList)
                val = [];
            else
                val = speedList;
            end
        end
        
        function val = get.imageFlipHorizontal(obj)
            val = obj.imageFlip(1);
        end
        
        function val = get.imageFlipVertical(obj)
            val = obj.imageFlip(2);
        end
        
        function val = get.preAmpGainOptions(obj)
            
            gainAvailableArray = obj.preAmpGainOptionsStruct(obj.ADChannel+1).(obj.outputAmplifier){obj.HSSpeedIdx}; %Cached results of isPreAmpGainAvailable with all possible combinations
            invalidIndices = find(~gainAvailableArray);            
      
            val = obj.preAmpGainOptionsAll; %cell array with all preAmpGain options listed                                                     
            
            if ~isempty(invalidIndices)
                if min(invalidIndices) > find(gainAvailableArray,1,'last') %Determine if invalid indices are all higher than the valid indices
                    val(invalidIndices) = []; %Simply return truncated list of options
                else
                    val(invalidIndices) = nan; %ANDOR: Could this ever occur? It is not beleived so.
                end
            end
        end
        
        function val = get.spoolActive(obj)
            if isempty(obj.spool)
                val = 0;
            else
                val = obj.spool{1};
            end
        end
        
        function val = get.spoolFrameBufferSize(obj)
            if ~obj.spoolActive
                val = obj.spoolFrameBufferSize;
            else
                val = obj.spool{4};
            end
        end
        
        function val = get.spoolMethod(obj)
            if ~obj.spoolActive
                val = obj.spoolMethod;
            else
                val = obj.spool{2};
            end
        end
        
        function val = get.spoolPath(obj)
            if ~obj.spoolActive
                val = obj.spoolPath;
            else
                val = obj.spool{3};
            end
        end
        
        function val = get.statusString(obj)
            val = obj.responseCodeMap(obj.status);
        end
        
        function val = get.temperatureStatus(obj)
            status = obj.driverCallRaw('GetTemperature',0);
            if ismember(status,obj.temperatureStatusCodes)
                val = obj.responseCodeMap(status);
            else
                obj.validateStatus(status,'GetTemperature');
            end
        end
        
        function val = get.temperatureTarget(obj)
            %
            [~,val,~,~] = obj.driverCall('GetTemperatureStatus',0,0,0,0);
        end
        
                
        function val = get.versionInfoDriver(obj)            
            a = char(zeros(512,1));
            val = obj.driverCall('GetVersionInfo','AT_SDKVersion',a,512); %TMW: This works sometimes, but is prone to seg faults
            %val = obj.driverCall('GetVersionInfo',1073741825,a,512);
        end
        
        function val = get.versionInfoFirmware(obj)
            a = char(zeros(512,1));
            val = obj.driverCall('GetVersionInfo','AT_DeviceDriverVersion',a,512);            
            %val = obj.driverCall('GetVersionInfo',1073741824,a,512);
        end
        
        
        %%Setters
                
        function set.imageFlipHorizontal(obj,val)
            obj.imageFlip = {val obj.imageFlipVertical};
        end
        
        function set.imageFlipVertical(obj,val)
            obj.imageFlip = {obj.imageFlipHorizontal val};
        end
        
        function set.FKVShiftSpeedIdx(obj,val)
            obj.setIndexedRaw('FKVShiftSpeed',val);
            obj.FKVShiftSpeedIdx = val;
        end
        
        function set.HSSpeedIdx(obj, val)
            %   val: A ONE-based index of HSSpeedIdx values valid at currently set ADChannel and outputAmplifier values
            %
            %   NOTE: The HSSpeedOptions property lists available HSSpeed values at currently set ADChannel and outputAmplifier values
            
            errMsg = 'A valid HS Speed index (one-based) must be supplied for ''HSSpeedIdx''';

            assert(isnumeric(val) && round(val)==val && val,errMsg);
            currVal = obj.HSSpeedIdx; 
            
            try 
                
                if isnumeric(val) && isscalar(val) && ismember(val,1:obj.maxNumberHSSpeeds)
                    if val > length(obj.HSSpeedOptions)
                        obj.VException('','HSSpeedUnavailable','Specified ''HSSpeedIdx'' value is not valid, with currently set properties. Value must be a valid index into ''HSSpeedOptions'' cell array');                                                
                    end
                    
                    obj.driverCall('SetHSSpeed',obj.outputAmplifierMap(obj.outputAmplifier),val-1);                    
                    obj.HSSpeedIdx = val;
                else
                    error(errMsg);
                end
                
                obj.updateSecondaryParameters('HSSpeedIdx'); %Verify/update other properties that depend on HSSpeed value
            catch ME
                obj.HSSpeedIdx = currVal;
                ME.rethrow();
            end
            
        end
        
        function set.preAmpGainIdx(obj,val)
            obj.setIndexedRaw('preAmpGain',val);
            obj.preAmpGainIdx = val;
        end
        
        function set.spoolActive(obj,val)
            obj.spoolActive = val;
            
            obj.spool = {val,obj.spoolMethod,obj.spoolPath,obj.spoolFrameBufferSize};
        end
        
        function set.spoolFrameBufferSize(obj,val)
            obj.spoolFrameBufferSize = val;
            
            if ~isempty(obj.spool)
                obj.spool = {obj.spoolActive,obj.spoolMethod,obj.spoolPath,val};
            end
        end
        
        function set.spoolMethod(obj,val)
            obj.spoolMethod = val;
            
            if ~isempty(obj.spool)
                obj.spool = {obj.spoolActive,val,obj.spoolPath,obj.spoolFrameBufferSize};
            end
        end
        
        function set.spoolPath(obj,val)
            obj.spoolPath = val;
            
            if ~isempty(obj.spool)
                obj.spool = {obj.spoolActive,obj.spoolMethod,val,obj.spoolFrameBufferSize};
            end
        end
        
        function set.temperatureTarget(obj,val)
            assert(logical(obj.isCoolerOn),'The cooler feature must be enabled in order to set the ''temperatureTarget'' value');
            obj.driverCall('SetTemperature',val);
            obj.temperatureTarget = val;
        end
        
        function set.VSSpeedIdx(obj, val)
            if val > obj.fastestRecommendedVSSpeedIdx
                % TODO: allow user to override fastest recommended speed by setting VSAmplitude??
                error('You are attempting to set the VSSpeed to a speed that exceeds the device''s recommended fastest speed.');
            else
                obj.setIndexedRaw('VSSpeed',val);
                obj.VSSpeedIdx = val;
            end
        end
        
    end
    
    methods (Access=protected)
        function pdepPropHandleGet(obj,src,evnt)
            propName = src.Name;
            
            if ismember(propName,obj.invalidUntilInitProps.keys) && obj.invalidUntilInitProps(propName)
               warning(['''' propName ''''' has not been initialized.']);  
            end
            
            switch propName
                case { 'accumulationCycleTime' 'ampDesc' 'ampMaxSpeed' 'cameraEventStatus' 'controllerCardModel' 'DDGPulse' 'exposureTime' 'FKVShiftSpeed' 'HSSpeed' ...
                          'isAmplifierAvailable' 'isPreAmpGainAvailable' 'isTriggerModeAvailable' 'kineticCycleTime' 'maximumBinning' ...
                        'numberHSSpeeds'}
                    obj.pdepPropIndividualGet(src, evnt);
                    
                    % signatures of the form: FunctionName(<TYPE>* number)
                case {'DDGIOCFrequency' 'DDGIOCNumber' 'DDGIOCPulses' 'EMCCDGain' 'filterMode' 'FKExposureTime' ...
                        'HVFlag' 'imagesPerDMA' 'imageRotate' 'keepCleanTime' 'maximumExposure' 'MCPGain' ...
                        'MCPVoltage' 'minimumImageLength' 'numberADChannels' 'numberAmp' 'numberFKVShiftSpeeds' ...
                        'numberPreAmpGains' 'numberRingExposureTimes' 'numberIO' 'numberVSAmplitudes' ...
                        'numberVSSpeeds' 'readOutTime' 'sizeOfCircularBuffer' 'status' 'totalNumberImagesAcquired'}
                    obj.pdepPropGroupedGet(@obj.getSimple,src,evnt);
                    
                    % properties mapped to IsXXX() functions in SDK with 'trivial' signature of the form: FunctionName(<TYPE>* number)
                case {'isCoolerOn' 'isInternalMechanicalShutter'}
                    obj.pdepPropGroupedGet(@obj.getSimpleBinary,src,evnt);
                    
                    % signatures of the form: FunctionName(<TYPE>* n1, <TYPE>* n2, ... <TYPE>* nN)
                case {'acquisitionTimings' 'detector' 'fastestRecommendedVSSpeed' 'hardwareVersion' 'imageFlip' ...
                        'numberAvailableImages' 'numberNewImages' 'softwareVersion' }
                    obj.pdepPropGroupedGet(@obj.getSimpleMultiple,src,evnt);
                    
                    % properties with multiple return arguments that are naturally represented as an ordered numeric array
                case {'EMGainRange' 'MCPGainRange' 'pixelSize' 'ringExposureRange' 'temperatureRange'}
                    obj.pdepPropGroupedGet(@obj.getMultipleOrderedArray,src,evnt);
                    
                    % signatures of the form: FunctionName(int idx, <TYPE>* number)
                case {'bitDepth' 'preAmpGain' 'VSSpeed'}
                    obj.pdepPropGroupedGet(@obj.getSimpleIndexed,src,evnt);
                    
                    % signatures of the form: FunctionName(char* returnString)
                case {'headModel'}
                    obj.pdepPropGroupedGet(@obj.getSimpleString,src,evnt);
                    
                    % shared handling for temperature value access
                case {'temperature' 'temperatureF'}
                    obj.pdepPropGroupedGet(@obj.getTemperatureValue,src,evnt);

                    % shared handling for shutter value access
                case {'shutter' 'shutterEx'}
                    obj.pdepPropGroupedGet(@obj.getShutterValue,src,evnt);                    
                    
                otherwise
            end
            
            % ensure we return numbers as doubles
            if isnumeric(obj.(propName))
                obj.pdepPropLockMap(propName) = true;
                obj.(propName) = double(obj.(propName));
                obj.pdepPropLockMap(propName) = false;
            end
        end
        
        function pdepPropHandleSet(obj,src,evnt)
            
            propName = src.Name;
            switch propName
                case {'HSSpeed' 'multiTrack' 'outputAmplifier' 'temperature'}
                    obj.pdepPropIndividualSet(src,evnt);
                    
                case { 'accumulationCycleTime' 'ADChannel' 'advancedTriggerModeState' ...
                        'baselineClamp' 'baselineOffset' 'cameraStatusEnable' 'coolerMode' 'customTrackHBin' ...
                        'DACOutputScale' 'DDGGateStep' 'DDGInsertionDelay' 'DDGIntelligate' 'EMAdvanced' ...
                        'EMCCDGain' 'EMGainMode' 'exposureTime' 'fanMode' 'fastExtTrigger' 'filterMode' 'frameTransferMode' ...
                        'FVBHBin' 'gateMode' 'highCapacity' 'imageRotate' 'kineticCycleTime' 'MCPGain' ...
                        'MCPGating' 'metaData' 'multiTrackHBin' 'numberAccumulations' 'numberKinetics' ...
                        'numberPrescans' 'overlapMode' 'photonCounting' 'sifComment' 'singleTrackHBin' 'VSAmplitude'
                        }
                    obj.pdepPropGroupedSet(@obj.setSimple,src,evnt);
                    
                case {'preAmpGain' 'VSSpeed'}
                    obj.pdepPropGroupedSet(@obj.setSimpleIndexed,src,evnt);
                    
                case {'acquisitionMode' 'readMode' 'triggerMode'}
                    obj.pdepPropGroupedSet(@obj.setSimpleIndexedString,src,evnt);
                    
                case {'complexImage' 'DACOutput' 'fastKinetics' 'fastKineticsEx' 'gate' 'image' 'imageFlip' ...
                        'IODirection' 'IOLevel' 'isolatedCropMode' 'multiTrackHRange' 'PCIMode' ...
                        'photonCountingThreshold' 'randomTracks' 'ringExposureTimes'  ...
                        'singleTrack' 'spool'
                        }
                    obj.pdepPropGroupedSet(@obj.setSimpleMultiple,src,evnt);
                    
                case {'shutter' 'shutterEx'}
                    obj.pdepPropGroupedSet(@obj.setShutterValue,src,evnt);

                otherwise %Set-access not allowed
                    obj.pdepPropSetDisallow(src,evnt);
                    
            end
            
            %When certain variables are changed ('high level'), other variables should/must be reset to ensure they are not in an invalid state
            if obj.isConstructed && ismember(propName,{'ADChannel' 'outputAmplifier' 'HSSpeed'}) 
                obj.updateSecondaryParameters(propName);              
            end
            
            % Determine if we need to recalculate the 'expectedXXX' props
            if obj.isConstructed && ismember(propName,{ 'complexImage' 'image' 'isolatedCropMode' 'multiTrack' 'randomTracks' 'readMode' 'singleTrack' ...
                                                        'customTrackHBin' 'FVBHBin' 'multiTrackHBin' 'singleTrackHBin'})
                obj.calculateExpectedDimensions(propName);
            end
            
            if ismember(propName,obj.invalidUntilInitProps.keys) && obj.invalidUntilInitProps(propName)
               obj.invalidUntilInitProps(propName) = 0;
            end
                
        end
    end
    
    
    methods (Hidden)
        
        %GROUPED PDEP GET METHODS
        function val = getMultipleOrderedArray(obj,propName)
            val = cell2mat(getSimpleMultiple(obj,propName));
        end
        
        function val = getSimple(obj,propName)
            val = obj.driverCall(['Get' upper(propName(1)) propName(2:end)], 0);
        end
        
        function val = getSimpleString(obj,propName)
           val = obj.driverCall(['Get' upper(propName(1)) propName(2:end)], char(zeros(1,255)));
        end
        
        function val = getSimpleBinary(obj,propName)
            sdkFuncName = [upper(propName(1)) propName(2:end)]; %Convert from isXXX to IsXXX
            val = logical(obj.driverCall(sdkFuncName,0));                                  
        end
        
        function val = getSimpleIndexed(obj,propName)
            val = obj.driverCall(['Get' upper(propName(1)) propName(2:end)], obj.(obj.indexMap(propName))-1, 0); %Switch from our 1-based to API 0-based indexing
        end
        
        function val = getSimpleMultiple(obj,propName)
            funcName = ['Get' upper(propName(1)) propName(2:end)];
            numOutputArgs = obj.methodNargoutMap(funcName);
            dummyArgs = num2cell(zeros(numOutputArgs,1));
            
            val = cell(1,numOutputArgs);
            [val{:}] = obj.driverCall(funcName, dummyArgs{:});
            
            %val = {obj.driverCall(funcName, dummyArgs{:})}; % Seems to work too!
        end
        
        
        function val = getTemperatureValue(obj,propName)
            propName(1) = upper(propName(1));
            val = obj.driverCallFiltered(['Get' propName],obj.temperatureStatusCodes, 0);
        end
        
        function val = getShutterValue(obj,propName,vals)
            
            %Throws an error if incorrect property is used for this camera model
            obj.validateShutterProperty(propName);
            
            val = obj.(propName); %Simple pass-through can be used -- there are no GetShutter() functions in SDK         
        end
        
        
        %INDIVIDUAL PDEP GET METHODS
        
        function val = getAccumulationCycleTime(obj)
            acqTimings = obj.acquisitionTimings;
            val = acqTimings{2};
        end
        
        function val = getAmpDesc(obj)
            dummyString = char(zeros(1,21));
            val = obj.driverCall('GetAmpDesc',obj.outputAmplifierMap(obj.outputAmplifier),dummyString,length(dummyString));
        end
        
        function val = getAmpMaxSpeed(obj)
            val = obj.driverCall('GetAmpMaxSpeed',obj.outputAmplifierMap(obj.outputAmplifier),0);
        end
        
        function val = getControllerCardModel(obj)
            dummyString = char(zeros(1,10));
            val = obj.driverCall('GetControllerCardModel',dummyString);
        end
        
        function getDDGPulse(obj)
            
        end
        
        function val = getFKVShiftSpeed(obj)
            val =  obj.driverCall('GetFKVShiftSpeedF',obj.FKVShiftSpeedIdx-1,0);
        end
        
        function val = getExposureTime(obj)
            acqTimings = obj.acquisitionTimings;
            val = acqTimings{1};
        end
        
        function val = getKineticCycleTime(obj)
            acqTimings = obj.acquisitionTimings;
            val = acqTimings{3};
        end
        
        function val = getMaximumBinning(obj)
            maximumBinningHorizontal = obj.driverCall('GetMaximumBinning',obj.readModeIdx-1,0,0);
            maximumBinningVertical = obj.driverCall('GetMaximumBinning',obj.readModeIdx-1,1,0);
            
            val = [maximumBinningHorizontal maximumBinningVertical];
        end
        
        function val = getHSSpeed(obj)
            
            speedList = obj.HSSpeedOptionsStruct(obj.ADChannel+1).(obj.outputAmplifier);
            
            if isempty(speedList)
                val = [];
            else
                val = speedList{obj.HSSpeedIdx};
            end
        end       
        
        function val = getNumberHSSpeeds(obj)
            val = length(obj.HSSpeedOptions);
        end

        %GROUPED PDEP SET METHODS
        function setSimple(obj,propName,val)
            obj.driverCall(['Set' upper(propName(1)) propName(2:end)], val);
        end
        
        function setSimpleIndexed(obj,propName,val)
            obj.([propName 'Idx']) = val+1;
        end
        
        function setSimpleIndexedString(obj,propName,val)
            propMap = obj.([propName 'Map']);
            
            if isnumeric(val) && isscalar(val) && ismember(val,cell2mat(propMap.values))
                idx = val;
                obj.(propName) = obj.mapReverseDecode(propMap,val);
            elseif ischar(val) && ismember(lower(val),propMap.keys)
                idx  = propMap(lower(val));
            else
                error(['Invalid ' propName]);
            end
            
            obj.driverCall(['Set' upper(propName(1)) propName(2:end)],idx);
        end
        
        function setSimpleMultiple(obj,propName,vals)
            % Assume that caller passed in a cell array of vals
            obj.driverCall(['Set' upper(propName(1)) propName(2:end)], vals{:});
        end
        
        function setShutterValue(obj,propName,vals)
            
            %Throws an error if incorrect property is used for this camera model
            obj.validateShutterProperty(propName);
            
            %Otherwise, this is just a simpleMultiple case
            obj.setSimpleMultiple(propName,vals);            
        end
        
        %INDIVIDUAL PDEP SET METHODS
        function setHSSpeed(obj,val)
            %   val: A cell array specifying outputAmplifier and ZERO-based index, at current ADChannel value
            %
            %   NOTE: The HSSpeedOptions property lists available HSSpeed values at currently set ADChannel and outputAmplifier values
            %   NOTE: The HSSpeedIdx property can be set instead of HSSpeed in a simpler fashion; the HSSpeedIdx value is a ONE-based index into HSSpeedOptions
            
            if iscell(val) && length(val) == 2 % val = {[outputAmplifierType], [HSSpeed]}
                obj.outputAmpliferIdx = val{1}; %MUST be supplied as index in cell array input mode (for power users)
                obj.HSSpeedIdx = val{2} + 1;  %Convert from ZERO to ONE based indexing
            else
                fprintf(2,'NOTE: It is recommended to set the ''HSSpeedIdx'' property instead.\n');
                error('A cell array argument specifying 1) outputAmplifier and 2) zero-based HSSpeed index must be specified for ''HSSpeed''');
            end
        end
        
        function setMultiTrack(obj, val)
            % this case is a little tricky, because 'SetMultiTrack' actually
            % returns two values. in order to store all 5 values inside
            % the 'multiTrack' property, we'll call this function twice:
            % once with 3 args (actually calling the API method), and again
            % with 5 args, to exploit the Set functionality of VClass, which
            % will store all 5 params.
            
            assert(iscell(val) && (length(val) == 3 || length(val) == 5), 'Error setting ''multiTrack'' property: invalid input parameters.');
            
            if length(val) == 3
                [bottom, gap] = obj.driverCall('SetMultiTrack',val{1},val{2},val{3},0,0);    
                obj.multiTrack = {val{1},val{2},val{3},bottom,gap};
            elseif length(val) == 5
               % do nothing, our PDEP mechanism just stored the values we need 
            end   
        end
        
        function setOutputAmplifier(obj, val)
            if isnumeric(val)
                outputAmplifierIdx = val;
                val = obj.mapReverseDecode(obj.outputAmplifierMap,val); %Converts to string descriptor, so this is stored in the pdep property
            else
                outputAmplifierVal = obj.contigString(lower(val)); %Remove any spaces in the specified string  
                if ~obj.outputAmplifierMap.isKey(outputAmplifierVal)
                    error('Specified ''outputAmplifier'' value is not allowed. See ''outputAmplifierOptions'' property for list of valid options.');
                end
                outputAmplifierIdx = obj.outputAmplifierMap(outputAmplifierVal);
                obj.outputAmplifier = outputAmplifierVal;
            end
            obj.driverCall('SetOutputAmplifier',outputAmplifierIdx);           
        end
        
        function setTemperature(obj,val)
            fprintf(2,'Specified property (''temperature'') cannot be set for objects of class %s. The ''temperatureTarget'' value should be set instead.\n',class(obj));
        end
        
    end
    
    %Property Access Helpers
    methods (Access=private)        

        function setIndexedRaw(obj,propName,val)
            errMsg = 'A valid index must be supplied.';
            
            if isnumeric(val) && isscalar(val) && ismember(val,1:length(obj.([propName 'Options'])))
                obj.driverCall(['Set' upper(propName(1)) propName(2:end)],val-1);
            else
                error(errMsg);
            end
        end
        
        function validateShutterProperty(obj,propName)
        
            if obj.isInternalMechanicalShutter
                correctPropName = 'shutterEx';
            else
                correctPropName = 'shutter';
            end
            
            if ~strcmp(propName,correctPropName)
                error('The specified property (''%s'') should not be used for this camera model. Use ''%s'' instead.',propName,correctPropName);
            end
        end
        
    end
    
    %% ABSTRACT METHOD REALIZATIONS / FUNCTION OVERRIDES
    methods (Access=protected)
        %          function printErrorMessage(obj,src,ME)
        %              % handle the error code
        %              [startIdx endIdx] = regexp(ME.message,'(\d+)');
        %              warning(['Error while setting ' src.Name ': ' obj.mapReverseDecode(obj.responseCodeMap,str2num(ME.message(startIdx:endIdx)))]);
        %          end
    end
    
    methods
        function display(obj)
            obj.VClassDisplay();
        end
    end
    
    
    %% PUBLIC METHODS
    
    methods
        
        function abortAcquisition(obj)
            obj.driverCallFiltered('AbortAcquisition',[20073]);
        end
        
        function cancelWait(obj)
           obj.driverCall('CancelWait'); 
        end
	
     

        
        function coolerOFF(obj)
            obj.driverCall('CoolerOFF');
        end
        
        function coolerON(obj)
            obj.driverCall('CoolerON');
        end
        
        function freeInternalMemory(obj)
            obj.driverCall('FreeInternalMemory');
        end
        
        function GPIBReceive(obj,id,address,text,size)
            %See Andor SDK documentation for description of this function and its arguments 
            
            obj.driverCall('GPIBReceive',id,address,text,size);
        end
        
        function GPIBSend(obj,id,address,text)
            %See Andor SDK documentation for description of this function and its arguments 
            
            obj.driverCall('GPIBSend',id,address,text);
        end
        
        %         function outputData = getAcquiredDataM(obj,outputClassNumBits, varargin)
        %             % //Matlab signature
        %             % //outputData = GetAcquiredData(cameraObj,outputClassNumBits,outputVarOrSize)
        %             % //	cameraObj: Handle to Devices.Andor.AndorCamera object for which data is being retrieved
        %             % //	outputClassNumBits: One of {16 32}, indicating size, in bits, of integer class to return.
        %             % //	outputVarOrSize: (OPTIONAL) Either name of preallocated MATLAB variable into which to store read data, or the size in pixels of the output variable to create (to be returned as outputData argument).
        %             % //						If empty/omitted, array is allocated of size matching number of configured pixels
        %             % //
        %             % //	outputData: Array of output data. This value is not output if outputVarOrSize is a string specifying a preallocated output variable.
        %             %
        %
        %             if nargout
        %                 tic;
        %                 outputData = GetAcquiredData(obj,outputClassNumBits,varargin{:});
        %                 toc;
        %             else
        %                 tic;
        %                 GetAcquiredData(obj,outputClassNumBits,varargin{:});
        %                 toc;
        %             end
        %
        %             %TEST CODE -- how much slower is it to use calllib, vs the MEX function?!?
        %             %Result: For 1MPixel camera, was ~38ms for calllib, vs ~13ms with MEX function -- 4/13/10 @ 5AM Solutions
        %             %Allocate memory for output data
        %             %             numPixels = obj.imagePixelsTotal;
        %             %             outputData = zeros(numPixels,1,'int16');
        %             %             tic;[status,outputData] =  calllib(obj.driverLib,'GetAcquiredData16',outputData,numPixels);toc;
        %         end
        %
        %
        %         function outputData = getOldestImageM(obj,outputClassNumBits, varargin)
        %             % //Matlab signature
        %             % //outputData = GetOldestImageM(cameraObj,outputClassNumBits,outputVarOrSize)
        %             % //	cameraObj: Handle to Devices.Andor.AndorCamera object for which data is being retrieved
        %             % //	outputClassNumBits: One of {16 32}, indicating size, in bits, of integer class to return.
        %             % //	outputVarOrSize: (OPTIONAL) Either name of preallocated MATLAB variable into which to store read data, or the size in pixels of the output variable to create (to be returned as outputData argument).
        %             % //						If empty/omitted, array is allocated of size matching number of configured pixels
        %             % //
        %             % //	outputData: Array of output data. This value is not output if outputVarOrSize is a string specifying a preallocated output variable.
        %             %
        %
        %             if nargout
        %                 outputData = GetOldestImage(obj,outputClassNumBits,varargin{:});
        %             else
        %                 GetOldestImage(obj,outputClassNumBits,varargin{:});
        %             end
        %
        %         end
        %
        %          function outputData = getMostRecentImageM(obj,outputClassNumBits, varargin)
        %             % //Matlab signature
        %             % //outputData = getMostRecentImageM(cameraObj,outputClassNumBits,outputVarOrSize)
        %             % //	cameraObj: Handle to Devices.Andor.AndorCamera object for which data is being retrieved
        %             % //	outputClassNumBits: One of {16 32}, indicating size, in bits, of integer class to return.
        %             % //	outputVarOrSize: (OPTIONAL) Either name of preallocated MATLAB variable into which to store read data, or the size in pixels of the output variable to create (to be returned as outputData argument).
        %             % //						If empty/omitted, array is allocated of size matching number of configured pixels
        %             % //
        %             % //	outputData: Array of output data. This value is not output if outputVarOrSize is a string specifying a preallocated output variable.
        %             %
        %
        %             if nargout
        %                 outputData = GetMostRecentImage(obj,outputClassNumBits,varargin{:});
        %             else
        %                 GetMostRecentImage(obj,outputClassNumBits,varargin{:});
        %             end
        %
        %         end
        
        function val = inAuxPort(obj,port)
           %See Andor SDK documentation for description of this function and its arguments 
           
           val = obj.driverCall('InAuxPort',port,0);
        end
        
        function internalShutterClose(obj)
            %Utility method to close camera's internal shutter

            for i=1:length(obj)
                if (obj(i).isInternalMechanicalShutter)
                    obj(i).shutterEx = {1 2 0 0 0}; %TODO: Use cached external shutter settings here
                else
                    error('Camera model does not have an internal mechanical shutter');
                end
            end
            
        end       
        
        function internalShutterOpen(obj)
            %Utility method to open camera's internal shutter
            
            for i=1:length(obj)
                if obj(i).isInternalMechanicalShutter
                    obj(i).shutterEx = {1 1 0 0 0}; %TODO: Use cached external shutter settings here
                else
                    error('Camera model does not have an internal mechanical shutter');
                end
            end
            
        end
        
        function internalShutterAuto(obj)
            %Utility method to set camera's internal shutter to automatically open/close            
            
            for i=1:length(obj)                
                if obj(i).isInternalMechanicalShutter
                    obj(i).shutterEx = {1 0 0 0 1}; %ANDOR: is it really /required/ that extmode= 'open' for such cases where internal mode ='auto'? could still be useful to have an external shutter signal generated!
                else
                    error('Camera model does not have an internal mechanical shutter');
                end
            end
            
        end
        
        function val = isAmplifierAvailable(obj,outputAmplifier)
            %See Andor SDK documentation for description of this function and its arguments
            %NOTES:
            %   1) 'outputAmplifier' can be supplied as a numeric index (as in the SDK) or as one of the 'outputAmplifierOptions' string values
            %   2) if 'outputAmplifier' argument is empty/omitted, the currently set value of 'outputAmplifier' is assumed            
            
            %ANDOR: This can sometimes return false, but you can set the value accordingly without any notice or apparent error. But there is no getter to verify the actual state!
            
           val = obj.isXXXAvailableHelper('IsAmplifierAvailable', 'outputAmplifier', 'DRV_INVALID_AMPLIFIER', outputAmplifier);

        end
        
        function val = isPreAmpGainAvailable(obj, preAmpGainIdx, ADChannel, outputAmplifier, HSSpeedIdx)
            %See Andor SDK documentation for description of this function and its arguments
            %NOTES:
            %   1) The 'preAmpGainIdx' and 'HSSpeedIdx' values employ Matlab 1-based indexing, rather than C zero-based indexing used by SDK
            %   2) If 'ADChannel', 'outputAmplifier' and/or 'HSSpeedIdx' arguments are empty/omitted, then their current value(s) are assumed
            %   3) The 'outputAmplifier' can be supplied as a numeric index (as in the SDK) or as one of the 'outputAmplifierOptions' string values
            
            %ANDOR: This can sometimes return false, but you can set the value accordingly without any notice or apparent error. But there is no getter to verify the actual state!  
           
            if nargin < 5 || isempty(HSSpeedIdx)
              HSSpeedIdx = obj.HSSpeedIdx;
            end
            
            if nargin < 4 || isempty(outputAmplifier)
              outputAmplifier = obj.outputAmplifierMap(obj.outputAmplifier);
            % if passed a string, use the integer representation...
            elseif ischar(outputAmplifier)
                outputAmplifier = obj.outputAmplifierMap(outputAmplifier);
            end
            
            if nargin < 3 || isempty(ADChannel)
              ADChannel = obj.ADChannel;
            end
            
            if nargin < 2 || isempty(preAmpGainIdx)
              error('Please specify a preampGainIdx');
            end
            
            val = obj.driverCall('IsPreAmpGainAvailable',ADChannel,outputAmplifier,HSSpeedIdx-1,preAmpGainIdx-1,0);
                        
        end
        
        function val = isTriggerModeAvailable(obj,triggerMode)
            %See Andor SDK documentation for description of this function and its arguments
            %NOTES:
            %   1) 'triggerMode' can be supplied as a numeric index (as in the SDK) or as one of the 'triggerModeOptions' string values
            %   2) if 'triggerMode' argument is empty/omitted, the currently set value of 'triggerMode' is assumed            
            
            %ANDOR: This can sometimes return false, but you can set the value accordingly without any notice or apparent error. But there is no getter to verify the actual state!

           val = obj.isXXXAvailableHelper('IsTriggerModeAvailable', 'triggerMode', 'DRV_INVALID_MODE', triggerMode);
        end       
        
        
        function outAuxPort(obj,port,state)
            %See Andor SDK documentation for description of this function and its arguments 
            
            obj.driverCall('OutAuxPort',port,state);
        end
        
        function prepareAcquisition(obj)
            obj.driverCall('PrepareAcquisition');
        end
        
        function saveAsBmp(obj,path,palette,ymin,ymax)
            %See Andor SDK documentation for description of this function and its arguments   
            %NOTES: 1) Trailing arguments can be omitted/left empty, and defaults will be used, as described below.
            %'palette': Default='grey' 
            %'ymin': Default='0
            %'ymax': Default=0 
            
            if nargin < 3 || isempty(palette)
                palette = 'grey';
            end  
            
            if nargin < 4 || isempty(ymin)
                ymin = 0;
            end  
            
            if nargin < 5 || isempty(ymax)
                ymax = 0;
            end  
            
            if isempty(strfind(palette,filesep))
                palette = fullfile(obj.palettePath,[palette '.pal']);
            end  
            
            obj.driverCall('SaveAsBmp',path,comment);  
        end
        
        function saveAsCommentedSif(obj,path,comment)
            %See Andor SDK documentation for description of this function and its arguments   
            %NOTES: 1) Trailing arguments can be omitted/left empty, and defaults will be used, as described below.
            %'comment': Default=''
            if nargin < 2 || isempty(comment)
                comment = '';
            end      
            
            obj.driverCall('SaveAsCommentedSif',path,comment);  
        end
        
        function saveAsEDF(obj,path,imode)
            %See Andor SDK documentation for description of this function and its arguments   
            %NOTES: 1) Trailing arguments can be omitted/left empty, and defaults will be used, as described below.
            %'imode': Default=0
            if nargin < 2 || isempty(imode)
                imode = 1;
            end      
            
            obj.driverCall('SaveAsEDF',path,imode);  
        end
        
        function saveAsFITS(obj,path,typ)
            %See Andor SDK documentation for description of this function and its arguments   
            %NOTES: 1) Trailing arguments can be omitted/left empty, and defaults will be used, as described below.
            %'typ': Default=0
            if nargin < 2 || isempty(typ)
                typ = 0;
            end      
            
            obj.driverCall('SaveAsFITS',path,typ);  
        end
        
        function saveAsPC(obj,path)
            %See Andor SDK documentation for description of this function and its arguments                       
            
            obj.driverCall('SaveAsPC',path);  
        end
        
        function saveAsRaw(obj,path,typ)
            %See Andor SDK documentation for description of this function and its arguments   
            %NOTES: 1) Trailing arguments can be omitted/left empty, and defaults will be used, as described below.
            %'typ': Default=1
            if nargin < 2 || isempty(typ)
                typ = 1;
            end      
            
            obj.driverCall('SaveAsRaw',path,typ);  
        end
        
        function saveAsSif(obj,path)
            %See Andor SDK documentation for description of this function and its arguments                       
            
            obj.driverCall('SaveAsSif',path);  
        end
        
        function saveAsTiff(obj,path,typ,position,palette)
            %See Andor SDK documentation for description of this function and its arguments
            %NOTES: 1) Argument order has been changed from the SDK
            %       2) Trailing arguments can be omitted/left empty, and defaults will be used, as described below.
            %'typ': Default=0
            %'position': Default=1
            %'palette': In place of full specification of path to .PAL file, a simple name can be provided instead, identifying one of the *.PAL files pre-installed to Andor driver directory
            %           (e.g. 'grey', 'greyovun', 'false1', 'false2', 'glow')be provided. The corresponding *.PAL file installed with driver will then be used.
            %           Default='grey'
             
            %Handle defaults
            if nargin < 3 || isempty(typ)
                typ = 0;
            end                
            if nargin < 4 || isempty(position)
                position = 1;
            end            
            if nargin < 5 || isempty(palette)                
                palette = 'grey';
            end
            
            if isempty(strfind(palette,filesep))
                palette = fullfile(obj.palettePath,[palette '.pal']);
            end                          
            
            obj.driverCall('SaveAsTiff',path,palette,position,typ);  
        end
        
        function saveAsTiffEx(obj,path,typ,position,palette,mode)
            %See Andor SDK documentation for description of this function and its arguments
            %NOTES: 1) Argument order has been changed from the SDK. 2) ''palette'' argument dif
            %       3) Trailing arguments can be omitted/left empty, and defaults will be used, as described below.
            %'typ': Default=0
            %'position': Default=1
            %'palette': In place of full specification of path to .PAL file, a simple name can be provided instead, identifying one of the *.PAL files pre-installed to Andor driver directory
            %           (e.g. 'grey', 'greyovun', 'false1', 'false2', 'glow')be provided. The corresponding *.PAL file installed with driver will then be used.
            %           Default='grey'
            %'mode': Default=0
             
            %Handle defaults
            if nargin < 3 || isempty(typ)
                typ = 0;
            end                
            if nargin < 4 || isempty(position)
                position = 1;
            end            
            if nargin < 5 || isempty(palette)                
                palette = 'grey';
            end
            if nargin < 6 || isempty(mode)
                mode = 0;
            end
            
            if isempty(strfind(palette,filesep))
                palette = fullfile(obj.palettePath,[palette '.pal']);
            end                          
            
            obj.driverCall('SaveAsTiffEx',path,palette,position,typ,mode);            
        end
        
        function sendSoftwareTrigger(obj)
            %See Andor SDK documentation for description of this function and its arguments
            
            assert(strcmp(obj.readMode,'image'),'The camera must be set to readMode=''image'' in order to send a software trigger.');
            assert(strcmp(obj.acquisitionMode,'run till abort'), 'The camera must be set to acquisitionMode=''run till abort'' in order to send a software trigger.');
            assert(strcmp(obj.triggerMode,'software trigger'), 'The camera must be set to triggerMode=''software trigger'' in order to send a software trigger.');
            
            obj.driverCall('SendSoftwareTrigger');
        end
        
        function shutDown(obj)
            %See Andor SDK documentation for description of this function and its arguments
            
            obj.driverCall('ShutDown');
        end
        
        function startAcquisition(obj)
            %See Andor SDK documentation for description of this function and its arguments
            
            obj.driverCall('StartAcquisition');
        end
        
        function waitForAcquisition(obj)
            %See Andor SDK documentation for description of this function and its arguments
            
            obj.driverCall('WaitForAcquisition');
        end
        
        function waitForAcquisitionTimeOut(obj,val)
            %See Andor SDK documentation for description of this function and its arguments
            
            obj.driverCall('WaitForAcquisitionTimeOut',val);
        end
        
    end
    
    
    
    %% STATIC METHODS
    methods (Static,Hidden)
        
        
        function [status,varargout] = driverCallRaw(funcName,varargin)
            % A static variant of driverCall() used before the class is fully
            % constructed.  See driverCall() documentation.
            
            %Determine # of output arguments
            varargout = cell(nargout-1,1);
            
            %Call the Andor driver function
            [status varargout{:}] = calllib(Devices.Andor.AndorCamera.driverLib,funcName,varargin{:});
        end
        
    end
    
    
    %% PRIVATE/PROTECTED METHODS
    methods (Access=private)
        
        
        function initializeDefaultPropValues(obj)
            % An initialization function handling initialization of device properties to default initial state.
            % Several SDK SetXXX() functions have no corresponding GetXXX() function. For these properties, initialization is /required/, to ensure that our local stores of values are not left empty
            % Most properties are initialized via values in initialValuesMap property, but some require additional logic to determine initial value.
            % NOTE: skipping: 'complexImage' 'fastKinetics'  'fastKineticsEx' 'gate' 'isolatedCropMode' 'MCPGating' 'multiTrack' 'randomTracks' 'ringExposureTimes' 'singleTrack' 'spool' 'IODirection' 'IOLevel'
            
            % TODO: May need to deal with case where default is 'conventional' -- IF new Andor CMOS cameras use same API
            obj.filteredDriverCodes = [20991 20992];
            for propKey=obj.initialValuesMap.keys
                key = propKey{:};
                obj.(key) = obj.initialValuesMap(key);
            end
            obj.filteredDriverCodes = [];
            
            % set values that couldn't be included in the bulk list:
            obj.image = {1 1 1 obj.detector{1} 1 obj.detector{2}};
            
            obj.multiTrackHRange = {1 obj.pixelCountDetector(1)};
            
            %Refresh properties dependent on high level state 
            %TODO: Identify all properties that are considered 'high level' -- i.e. that constrain valid values of other properties (and in particular properties with no GetXXX() function -- so that constraint/change would not be known to user!) At moment, only outputAmplifier seems to be in this category.
            obj.ADChannel = 0;
            obj.HSSpeedIdx = 1; %Should always be at least one HS speed option in the default outputAmplifier/ADChannel state
            obj.VSSpeedIdx = obj.fastestRecommendedVSSpeedIdx; %ANDOR: Is fastestRecommendedVSSpeed a model invariant property? Is there any disadvantage to always setting it to the fastest?
            %obj.preAmpGainIdx = length(obj.preAmpGainOptions); %ANDOR: For ixon897, only preAmpGainIdx=1 seems to work, though 1-3 are 'available'! %ANDOR: For ixon888, it seems this /must/ be initialized to max value to work without being set again, although lower values seem available.
            obj.FKVShiftSpeedIdx = 1;            
            obj.preAmpGainIdx = obj.preAmpGainIdxInitValue; %Use model-dependent value determined in initializeModelPropValues(). %ANDOR: The fact that initial valid value must be determined model-dependent way is related to apparent bugs in preAmpGain handling 
            
            obj.calculateExpectedDimensions();            
        end
        
        function initializeModelPropValues(obj)
            % A method to initialize map/struct values (that depend on camera model) through use of several GetXXX() calls.  
            %
            % Creates outputAmplifierMap keyed by human-readable descriptions of amplifier options, with values providing index used by SDK
            % Creates HSSpeed structure indexed by ADChannel and with fields given by outputAmplifier values. 
            %   Each field value is a cell array of available HSSpeed values.
            % Creates a preamp gain structure indexed by ADChannel and with fields given by outputAmplifier values. 
            %   Each field value is a cell array of logical arrays (indexed by HSSpeedIdx --> preampGainIndex) containing logical values 
            %   indicating if the given ADChannel->outputAmplifier->HSSpeed->preampGainIndex combination is available
            

            %Extract infomation from the 'Capabilities' structure 
            andorCapsStruct = libstruct('ANDORCAPS');
            andorCapsStruct.ulSize = andorCapsStruct.structsize();
            obj.driverCall('GetCapabilities',andorCapsStruct);
            
            obj.cameraType = obj.cameraTypeMap(andorCapsStruct.ulCameraType);            
            
            %Cache value of 'detector' property
            obj.pixelCountDetector = double(cell2mat(obj.detector));
            
            %%%Initialize HSSpeedOptionsStruct and preAmpGainOptionsStruct
            numADChans = obj.numberADChannels;
            obj.maxNumberHSSpeeds = 0;
            obj.HSSpeedOptionsStruct = struct();
            obj.preAmpGainOptionsStruct = struct();            

disp('########## MARKER1');
            
            %%%Create outputAmplifierMap
            numOutputAmplifiers = obj.driverCall('GetNumberAmp',0);
            obj.outputAmplifierMap = containers.Map({'dummy'},{1});
            obj.outputAmplifierMap.remove('dummy');
            for i=0:numOutputAmplifiers-1
                dummyString = char(zeros(1,21)); %API specifically says max number is 21 characters..using longer results in seg violations                              
                
                numTries = 0;
                while numTries < 10
                    numTries = numTries + 1;
                    name = obj.driverCall('GetAmpDesc',i,dummyString,length(dummyString));
                    if isvarname(obj.contigString(lower(name)))                        
                        if numTries > 1
                            fprintf(1,'WARNING: Retrieved valid amplifier description on try # %d\n',numTries);
                        end
                        break;
                    end
                    if numTries == 10
                        error('Unable to correctly retrieve Output Amplifier descriptions during camera initialization');
                    end
                end
                obj.outputAmplifierMap(obj.contigString(lower(name))) = i;
            end
                            
            numPreAmpGains = obj.driverCall('GetNumberPreAmpGains',0);
            obj.preAmpGainOptions = cell(numPreAmpGains,1);
            
            for m=1:numPreAmpGains   
                obj.preAmpGainOptionsAll{m} = obj.driverCall('GetPreAmpGain',m-1,0);
            end

            for i=1:numADChans
                for j=1:numOutputAmplifiers
                    %Determine number of speeds
                    numHSSpeeds = obj.driverCall('GetNumberHSSpeeds',i-1,j-1,0);
                    obj.maxNumberHSSpeeds = max(numHSSpeeds, obj.maxNumberHSSpeeds);
                    
                    %Create cell arrays of speed values and preamp gain values
                    speedValCell = cell(numHSSpeeds,1);
                    preAmpGainCell = cell(numHSSpeeds,1);
                    
                    for k=1:numHSSpeeds                        
                        speedValCell{k} = obj.driverCall('GetHSSpeed',i-1,j-1,k-1,0);
                        
                        preAmpGainCell{k} = false(numPreAmpGains,1); %Initialize logical array
                        for m=1:numPreAmpGains                                                        
                            preAmpGainCell{k}(m) = obj.driverCall('IsPreAmpGainAvailable',i-1,j-1,k-1,m-1,0);
                        end
                    end
                    
                    outputAmplifierType = obj.mapReverseDecode(obj.outputAmplifierMap,j-1);
                    obj.HSSpeedOptionsStruct(i).(outputAmplifierType) = speedValCell;
                    obj.preAmpGainOptionsStruct(i).(outputAmplifierType) = preAmpGainCell;
                end
            end

disp('########## MARKER2');

            %%%Initialize VSSpeedOptions%%%%%%%%%%%%%%%%%%%
            numVSSpeeds = obj.numberVSSpeeds;
            obj.VSSpeedOptions = cell(numVSSpeeds,1);
            
            % query for the speed corresponding to each index.
            % NOTE: we store these using one-based indexing, but the actual values are zero-indexed
            for i=1:numVSSpeeds
                obj.VSSpeedOptions{i} = obj.driverCall('GetVSSpeed',i-1,0);
            end

            %ANDOR: For now, do NOT treat fastestRecommendedVSSpeed as a model property -- does it depend on any other properties?? or is it invariant for a model?
            
            %%%Initialize FKVShiftSpeedOptions%%%%%%%%%%%%%%
            numFKVShiftSpeeds = obj.numberFKVShiftSpeeds;
            obj.FKVShiftSpeedOptions = cell(numFKVShiftSpeeds,1);
            for i=1:numFKVShiftSpeeds
                obj.FKVShiftSpeedOptions{i} = obj.driverCall('GetFKVShiftSpeed',i-1,0);
            end
            
            %Initialize preAmpGain value
            if strfind(obj.headModel,'DU897')
                obj.preAmpGainIdxInitValue = 1; %ANDOR: For 897, it seems only preAmpGainIdx = 1 works, though 1-3 are 'available'!
            else
                obj.preAmpGainIdxInitValue = length(obj.preAmpGainOptionsAll); %This matches Solis behavior -- default is the highest value
            end
            
            %Initialize shutter
disp('#######PRE I REMOVED SHUTTER STUFF')
%             if obj.isInternalMechanicalShutter
%                 obj.shutterEx = {1 0 0 0 0}; %TODO(?): Bind this to externalShutterXXX properties (to be added)
%             else
%                 obj.shutter = {1 0 0 0}; %TODO: Bind this to externalShutterXXX properties (to be added)
%             end
disp('#######POST')
            
            %%%Initialize available modes
            % TODO: utilize GetCapabilities()???
            obj.readModeOptions = obj.readModeMap.keys';
            obj.acquisitionModeOptions = obj.acquisitionModeMap.keys';
            obj.triggerModeOptions = obj.triggerModeMap.keys';
            obj.outputAmplifierOptions = obj.outputAmplifierMap.keys';
        end
        
        
    end
    
    
    methods (Hidden)
        
        %TODO: Figure out if better way to avoid duplication between driverCall/driverCallRaw
        
        function varargout = driverCall(obj,funcName,varargin)
            % Method to wrap calls to Andor SDK functions. 
            % funcName: name of Andor SDK function to call
            % varargin: an optional list of input arguments
            
            for i=1:length(obj)
                obj(i).setCurrentCameraHandle(obj(i).cameraHandle);
                
                %Determine # of output arguments
                varargout = cell(nargout,1);
                
                %Call the driver function
                [status varargout{:}] = calllib(obj(i).driverLib,funcName,varargin{:});
                
                %Throw error if status code represent an error
                try
                    obj(i).validateStatus(status,funcName,obj(i).filteredDriverCodes);
                catch ME
                    ME.throwAsCaller();
                end
            end
        end
        
        function varargout = driverCallFiltered(obj,funcName,ignoredCodes,varargin)
            % A variant of driverCall() used to ignore certain device responses.
            % see driverCall() documentation.
            
            for i=1:length(obj)
                obj(i).setCurrentCameraHandle(obj(i).cameraHandle);
                
                %Determine # of output arguments
                varargout = cell(nargout,1);
                
                %Call the DAQmx driver function
                [status varargout{:}] = calllib(obj(i).driverLib,funcName,varargin{:});
                
                %Throw error if status code represent an error
                try
                    obj(i).validateStatus(status,funcName,ignoredCodes);
                catch ME
                    ME.throwAsCaller();
                end
            end
        end

    end
    
    methods (Access=private)
        
        function validateStatus(obj, status,funcName,filteredCodes)
            % Checks the response code returned by driverCall() to verify
            % a successful driver call.
            % status: the response code returned by driverCall()
            % funcName: the function name called by driverCall()
            % filteredCodes: an optional list of response codes to ignore
            
            if nargin < 4
                filteredCodes = [];
            end
            if status ~= 20002 && ~ismember(status,filteredCodes)
                statusString = obj.responseCodeMap(status);
                
                ME = MException('Andor:FailedCall',['Andor error (' num2str(status) ':' statusString ') in call to SDK function: ' funcName]);
                ME.throwAsCaller();
            end
        end
        
        function ok = driverDataUpdate(obj)
            % A utility method that loads (and caches) data from the device driver.
            
            try
                prototypes = libfunctions(obj.driverLib, '-full');
                
                %Determine methodNargoutMap
                tokens = regexp(prototypes,'(uint32|\[.*\])\s*(\w*)','tokens','once'); %Captures the output arguments of each function
                %tokens(cellfun(@isempty,tokens)) = []; %Shouldn't be any of these!
                tokens = cat(1,tokens{:}); %Converts from nested cell array to Nx2 cell array
                outArgs = tokens(:,1);
                funcNames = tokens(:,2);
                outArgs = regexp(outArgs,'uint32(.*)','tokens','once'); % A cell array of cell arrays, each containing 2 elements: the first containing the void* argument and the second the comma-delimited list of remaining arguments
                numOutArgs = cellfun(@(x)length(strfind(x{1},',')),outArgs);
                
                obj.methodNargoutMap = containers.Map(funcNames',num2cell(numOutArgs'));    
                
                % Scan the header file and store all device response code string/value pairs
                obj.responseCodeMap = containers.Map({1},{'dummy'});
                obj.cameraTypeMap = containers.Map({1},{'dummy'});

                fID = fopen(fullfile(obj.classPrivatePath,[obj.driverHeaderFilename '.h']), 'r');
                
                while (~feof(fID))
                    currentLine = textscan(fID,'%s', 1,'delimiter','\n','whitespace','');
                    
                    match = regexp(currentLine{:},'^#define DRV');
                    matchCameraType = regexp(currentLine{:},'^#define AC_CAMERATYPE');
                    
                    if (~isempty(match) && ~isempty(match{1}))
                        parts = regexp(currentLine{:},'\s+','split');
                        codeName = parts{1}{2};
                        codeValue = parts{1}{3};
                        
                        hexIdx = regexp(codeValue, '0x', 'once');
                        if (hexIdx == 1)
                            codeValue = hex2dec(codeValue(3:end));
                        else
                            codeValue = str2num(codeValue);
                        end
                        
                        obj.responseCodeMap(codeValue) = codeName;
                    end                    
                    
                    if (~isempty(matchCameraType) && ~isempty(matchCameraType{1}))
                        parts = regexp(currentLine{:},'\s+','split');
                        codeName = parts{1}{2};
                        codeValue = str2double(parts{1}{3});
                        
                        codeName = regexp(codeName,'AC_CAMERATYPE_(\S*).*','tokens','once');
                        codeName = codeName{1}; 
                        
                        obj.cameraTypeMap(codeValue) = codeName;
                    end
                    
                end
                fid = fclose(fID);                
  
                removeDummy(obj.responseCodeMap);                
                removeDummy(obj.cameraTypeMap);
                               
                %Save variables to file
                %TODO(?): Maybe a cleaner way to do this?
                tempStruct = struct();
                for i=1:length(obj.dataFileFields)
                    tempStruct.(obj.dataFileFields{i}) = obj.(obj.dataFileFields{i});
                end
                save(fullfile(obj.classPrivatePath,obj.driverDataFilename),'-struct','tempStruct',obj.dataFileFields{:});
                
            catch ME
                obj.VError('','DriverDataParseError','Error occurred while parsing driver data header file: \n%s',ME.message);
            end
            
            function removeDummy(mapVar)
                if strcmp(mapVar(1), 'dummy')
                    mapVar.remove(1);
                end
            end
            
        end
        
        function val = isXXXAvailableHelper(obj, xxxFuncName, xxxPropName, xxxUnavailableResponseCode, xxxSuppliedVal)
            
            xxxPropMap = obj.([xxxPropName 'Map']);
            
            if nargin < 2 || isempty(xxxSuppliedVal)
                xxxIdx = xxxPropMap(obj.(xxxPropName)); %NOTE: This should /always/ be true I think -- Vijay Iyer 5/26/10
            elseif isnumeric(xxxSuppliedVal)
                mapValues =xxxPropMap.values;
                assert(ismember(xxxSuppliedVal,[mapValues{:}]), 'The supplied ''%s'' index value (%d) is not recognized by the device software interface',xxxPropName, xxxSuppliedVal);
                xxxIdx = xxxSuppliedVal;
            elseif ischar(xxxSuppliedVal) && isvector(xxxSuppliedVal)
                assert(xxxPropMap.isKey(xxxSuppliedVal),  'The supplied ''%s'' value (%s) is not recognized by the device software interface',xxxPropName, xxxSuppliedVal);
                xxxIdx = xxxPropMap(xxxSuppliedVal);
            end
            
            status = obj.driverCallRaw(xxxFuncName,xxxIdx);
            if strcmpi(obj.responseCodeMap(status),xxxUnavailableResponseCode)
                val = false;
            else
                try
                    obj.validateStatus(status); %Throw any not 'expected' error
                catch ME
                    ME.throwAsCaller();
                end
                val = true;
            end
        end
        
        function updateSecondaryParameters(obj,modVarName)
           %Handles changes to 'primary' state vars, i.e. properties whose values constrain or affect values of other 'secondary' properties
           
           %Primary State Vars: ADChannel, outputAmplifier, HSSpeed
           %Secondary State Vars: HSSpeed, PreAmpGain
           
           if ~obj.isConstructed
               return;
           end
           
           if nargin < 2 || isempty(modVarName)
               modVarName = '';
           end
           
           %Ensure HSSpeed/HSSpeedIdx value
           if isempty(strfind(lower(modVarName),'hsspeed'))
               try
                   obj.HSSpeedIdx = obj.HSSpeedIdx; %Andor SDK supports separate HSSpeed value for each amplifier, but wrapper does not use it - instead, update HSSpeed value following all outputAmplifier changes 
               catch ME
                   if strfind(ME.identifier,'HSSpeedUnavailable')
                       fprintf(2,'WARNING: The ''HSSpeed'' value has been updated because previous value is no longer valid with currently set properties.\nTo avoid this warning, set ''HSSpeed'' or ''HSSpeedIdx'' property before changes to ''outputAmplifier'' and/or ''ADChannel''\n');                       
                       obj.HSSpeedIdx = 1; %There must always be one available HSSpeed 
                   else
                       ME.rethrow();
                   end
               end
           end
           
           %Ensure preAmpGain/preAmpGainIdx value
           if ~obj.isPreAmpGainAvailable(obj.preAmpGainIdx)
               obj.preAmpGainIdx = 1; %ANDOR: The lowest gain option is /always/ available, right?!
               fprintf(2,'WARNING: The ''preAmpGain'' value has been updated because previous value is no longer valid with currently set properties.\nTo avoid this warning, set ''preAmpGain'' or ''preAmpGainIdx'' property before changes to ''outputAmplifier'', ''ADChannel'', and/or ''HSSpeed''/''HSSpeedIdx''\n');
           end
           
            
        end
            
        
        function calculateExpectedDimensions(obj,propName)
            if nargin < 2 || isempty(propName)
                propName = obj.readMode;
            end
            
            [params] = obj.(propName);
            if isempty(params)
                warning(['Error while calculating expectedM and expectedN: ' propName ' property is not valid.']);
            end
            
            switch propName
                case 'complexImage'
                    %TODO: Implement this case!
                    
                    %                     xPixels = 0;
                    %                     yPixels = 0;
                    %                     % iterate through all tracks
                    %                     for i=1:params{1}
                    %                         xPixels = xPixels + ((params{2}((i-1)*6 + 4)) - (params{2}((i-1)*6 + 3)) + 1)/params{2}(5);
                    %                         yPixels = yPixels + ((params{2}((i-1)*6 + 1)) - (params{2}((i-1)*6 + 2)) + 1)/params{2}(6); %TODO: verify VBinning
                    %                     end
                    %
                    %                     obj.expectedM = yPixels;
                    %                     obj.expectedN = xPixels;
                    
                case 'image'
                    obj.expectedM = (params{6} - params{5} + 1)/params{2}; % add 1 because coords are inclusive
                    obj.expectedN = (params{4} - params{3} + 1)/params{1};
                    
                case 'isolatedCropMode'
                    obj.expectedM = params{2}/params{4};
                    obj.expectedN = params{3}/params{5};
                    
                case {'multiTrack' 'multiTrackHBin'}
                    obj.expectedM = params{1}*params{2};
                    obj.expectedN = obj.pixelCountDetector(1)/obj.multiTrackHBin;
                    
                case {'randomTracks' 'customTrackHBin'}
                    yPixels = 0;
                    % iterate through all tracks
                    for i=1:params{1}
                        yPixels = yPixels + (params{2}((i-1)*2 + 2)) - (params{2}((i-1)*2 + 1)) + 1; % add 1 because coords are inclusive
                    end
                    
                    obj.expectedM = yPixels;
                    obj.expectedN = obj.pixelCountDetector(1)/obj.customTrackHBin;
                    
                case {'readMode' 'FVBHBin'}
                    switch obj.readMode
                        case 'full vertical binning'
                            obj.expectedM = 1;
                            obj.expectedN = obj.pixelCountDetector(1)/obj.FVBHBin;
                        otherwise
                            obj.calculateExpectedDimensions(obj.readMode);
                    end
                    
                case {'singleTrack' 'singleTrackHBin'}
                    obj.expectedM = params{2};
                    obj.expectedN = obj.pixelCountDetector(1)/obj.singleTrackHBin;
            end
            
            %Convert expectedM/N to double, so they be used as manual inputs to the dataRetrieval MEX methods (which only accept double inputs when a [M N] array is specified)
            obj.expectedM = double(obj.expectedM);
            obj.expectedN = double(obj.expectedN);
            
            obj.expectedDimensions = obj.expectedM * obj.expectedN;
        end
        
        
        
    end
    
    methods (Access=private,Static)
        function setCurrentCameraHandle(cameraHandle)
            % Sets this object's 'cameraHandle' as the driver's current camera.
            
 %           persistent currentCameraHandle
            
 %           if isempty(currentCameraHandle) || currentCameraHandle ~= cameraHandle
                status = Devices.Andor.AndorCamera.driverCallRaw('SetCurrentCamera',cameraHandle); %TMW: Shorthand notation for 'this class' would be nice
                if status ~= 20002
                    error('Call to function ''SetCurrentCameraHandle'' failed with status code: %d\n',status);
                end
%             end
%             currentCameraHandle = cameraHandle;
        end
        
        
        
        function key = mapReverseDecode(map,value)
            %Method for reverse-lookup for Maps for which the key-value pairs are 1-1 and unique in both directions
            %Assumes values are numeric
            
            keys = map.keys;
            values = map.values;
            
            key = keys{find(value==cell2mat(values))};
        end
        
        function stringVal = contigString(stringVal)
            stringVal(isspace(stringVal)) = '_';
        end
        
        
    end
    
    
    
end

