% qcapmex_grab - Grabs a single frame from a QImaging camera.
%
% SYNTAX
%  imageData = qcapmex_grab
%  imageData = qcapmex_grab(propertyName, propertyValue, ...)
%   imageData - The pixels composing the frame.
%   propertyName - The name of a settable camera property.
%   propertyValue - A uint64, int32, or uint32 value corresponding to the propertyName.
%  
% NOTES
%  Relies on qcapmex_grab.mex.
%  Multiple propertyName & propertyValue pairs may be specified.
%  See QCam API 1.90.0 documentation v2.0 and QCamApi.h for parameter listings.
%
% EXAMPLE
%   imdata = qcapmex_grab('qprmExposure', uint32(200));%Takes a 200 microsecond exposure. All other properties are defaulted.
% 
% CAMERA PROPERTIES
%  uint64:
% 	qprm64Exposure		           // Exposure in nanoseconds
% 	qprm64ExposureRed	           // For LCD filter mode: exposure (ns) of red shot
% 	qprm64ExposureBlue	           // For LCD filter mode: exposure (ns) of green shot
% 	qprm64NormIntensGain           // Normalized intensifier gain (micro units)
%  int32:
% 	qprmS32NormalizedGaindB        // Normalized camera gain in dB (micro units)
% 	qprmS32AbsoluteOffset	       // Absolute camera offset (offset in CCD ADC)
% 	qprmS32RegulatedCoolingTemp
%  uint32:
% 	qprmGain				       // Camera gain (gain on CCD output)
% 	qprmOffset		    		   // Camera offset (offset in CCD ADC)
% 	qprmExposure		    	   // Exposure in microseconds
% 	qprmBinning				       // Binning, for cameras with square binning
% 	qprmHorizontalBinning    	   // Binning, if camera has separate horiz value
% 	qprmVerticalBinning		       // Binning, if camera has separate vert value
% 	qprmReadoutSpeed		       // See readout speed constants
% 	qprmTriggerType		    	   // See trigger constants
% 	qprmColorWheel		    	   // Manual control of wheel color
% 	qprmCoolerActive	    	   // 1 turns on cooler, 0 turns off
% 	qprmExposureRed		    	   // For LCD filter mode: exposure (ms) of red shot
% 	qprmExposureBlue	    	   // For LCD filter mode: exposure (ms) of green shot
% 	qprmImageFormat			       // See QCam_ImageFormat
% 	qprmRoiX			           // Upper left X of ROI
% 	qprmRoiY			           // Upper left Y of ROI
% 	qprmRoiWidth		    	   // Width of ROI, in pixels
% 	qprmRoiHeight		            // Height of ROI, in pixels
% 	qprmReserved1
% 	qprmShutterState	    	   // Shutter position
% 	qprmReserved2
% 	qprmSyncb			           // SyncB output on some model-B cameras
% 	qprmReserved3
% 	qprmIntensifierGain	           // Gain value for the intensifier (Intensified cameras only)
% 	qprmTriggerDelay		       // Trigger delay in nanoseconds.
% 	qprmCameraMode		    	   // Camera mode
% 	qprmNormalizedGain		       // Normalized camera gain (micro units)
% 	qprmNormIntensGaindB    	   // Normalized intensifier gain dB (micro units)
% 	qprmDoPostProcessing    	   // Turns post processing on and off, 1 = On 0 = Off
% 	qprmPostProcessGainRed	       // parameter to set bayer gain
% 	qprmPostProcessGainGreen       // parameter to set bayer gain
% 	qprmPostProcessGainBlue	       // parameter to set bayer gain
% 	qprmPostProcessBayerAlgorithm  // specify the bayer interpolation. QCam_qcBayerInterp enum 
%                                  // with the possible algorithms is located in QCamImgfnc.h  	
% 	qprmPostProcessImageFormat	   // image format for post processed images	
% 	qprmFan					       // use QCam_qcFanSpeed to modify speed
% 	qprmBlackoutMode		       // 1 turns all lights off, 0 turns them back on
% 	qprmHighSensitivityMode	       // 1 turns high sensitivity mode on, 0 turn it off
% 	qprmReadoutPort			       // Set the normal or EM readout port 
% 	qprmEMGain				       // Set the EM gain
% 	qprmOpenDelay			       // each bit is 10us rangeis 0-655.35ms (must be entered as us)
% 							       // cannot be longer then (Texp - 10us) where Texp = exposure time
% 	qprmCloseDelay			       // each bit is 10us rangeis 0-655.35ms (must be entered as us)
% 							       // cannot be longer then (Texp - 10us) where Texp = exposure time
% 	qprmCCDClearingMode		       // can be set to qcPreFrameClearing or qcNonClearing
% 
%
% CHANGES
%  TO030207C: Updated to expose settable camera properties. -- Tim O'Connor 3/2/07
%  
% Created
%  Timothy O'Connor 3/1/07
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007