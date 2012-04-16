/*
 * Auto created header file xps_load_drivers.h for API headings for Matlab 
 */


#ifndef _SHELL_H_
#define _SHELL_H_

#ifndef EXPORT
#define EXPORT
#endif

EXPORT int TCP_ConnectToServer(char *Ip_Address, int Ip_Port, double TimeOut); 
EXPORT void TCP_SetTimeout(int SocketIndex, double Timeout); 
EXPORT void TCP_CloseSocket(int SocketIndex); 
EXPORT char * TCP_GetError(int SocketIndex); 
EXPORT char * GetLibraryVersion(void); 
EXPORT int ElapsedTimeGet (int SocketIndex, double * ElapsedTime);  /* Return elapsed time from controller power on */
EXPORT int ErrorStringGet (int SocketIndex, int ErrorCode, char * ErrorString);  /* Return the error string corresponding to the error code */
EXPORT int FirmwareVersionGet (int SocketIndex, char * Version);  /* Return firmware version */
EXPORT int TCLScriptExecute (int SocketIndex, char * TCLFileName, char * TaskName, char * ParametersList);  /* Execute a TCL script from a TCL file */
EXPORT int TCLScriptExecuteAndWait (int SocketIndex, char * TCLFileName, char * TaskName, char * InputParametersList, char * OutputParametersList);  /* Execute a TCL script from a TCL file and wait the end of execution to return */
EXPORT int TCLScriptKill (int SocketIndex, char * TaskName);  /* Kill TCL Task */
EXPORT int TimerGet (int SocketIndex, char * TimerName, int * FrequencyTicks);  /* Get a timer */
EXPORT int TimerSet (int SocketIndex, char * TimerName, int FrequencyTicks);  /* Set a timer */
EXPORT int Reboot (int SocketIndex);  /* Reboot the controller */
EXPORT int Login (int SocketIndex, char * Name, char * Password);  /* Log in */
EXPORT int CloseAllOtherSockets (int SocketIndex);  /* Close all socket beside the one used to send this command */
EXPORT int EventAdd (int SocketIndex, char * PositionerName, char * EventName, char * EventParameter, char * ActionName, char * ActionParameter1, char * ActionParameter2, char * ActionParameter3);  /* ** OBSOLETE ** Add an event */
EXPORT int EventGet (int SocketIndex, char * PositionerName, char * EventsAndActionsList);  /* ** OBSOLETE ** Read events and actions list */
EXPORT int EventRemove (int SocketIndex, char * PositionerName, char * EventName, char * EventParameter);  /* ** OBSOLETE ** Delete an event */
EXPORT int EventWait (int SocketIndex, char * PositionerName, char * EventName, char * EventParameter);  /* ** OBSOLETE ** Wait an event */
EXPORT int EventExtendedConfigurationTriggerSet (int SocketIndex, int NbElements, char * ExtendedEventNameList, char * EventParameter1List, char * EventParameter2List, char * EventParameter3List, char * EventParameter4List);  /* Configure one or several events */
EXPORT int EventExtendedConfigurationTriggerGet (int SocketIndex, char * EventTriggerConfiguration);  /* Read the event configuration */
EXPORT int EventExtendedConfigurationActionSet (int SocketIndex, int NbElements, char * ExtendedActionNameList, char * ActionParameter1List, char * ActionParameter2List, char * ActionParameter3List, char * ActionParameter4List);  /* Configure one or several actions */
EXPORT int EventExtendedConfigurationActionGet (int SocketIndex, char * ActionConfiguration);  /* Read the action configuration */
EXPORT int EventExtendedStart (int SocketIndex, int * ID);  /* Launch the last event and action configuration and return an ID */
EXPORT int EventExtendedAllGet (int SocketIndex, char * EventActionConfigurations);  /* Read all event and action configurations */
EXPORT int EventExtendedGet (int SocketIndex, int ID, char * EventTriggerConfiguration, char * ActionConfiguration);  /* Read the event and action configuration defined by ID */
EXPORT int EventExtendedRemove (int SocketIndex, int ID);  /* Remove the event and action configuration defined by ID */
EXPORT int EventExtendedWait (int SocketIndex);  /* Wait events from the last event configuration */
EXPORT int GatheringConfigurationGet (int SocketIndex, char * Type);  /*Read different mnemonique type */
EXPORT int GatheringConfigurationSet (int SocketIndex, int NbElements, char * TypeList);  /* Configuration acquisition */
EXPORT int GatheringCurrentNumberGet (int SocketIndex, int * CurrentNumber, int * MaximumSamplesNumber);  /* Maximum number of samples and current number during acquisition */
EXPORT int GatheringStopAndSave (int SocketIndex);  /* Stop acquisition and save data */
EXPORT int GatheringDataAcquire (int SocketIndex);  /* Acquire a configured data */
EXPORT int GatheringDataGet (int SocketIndex, int IndexPoint, char * DataBufferLine);  /* Get a data line from gathering buffer */
EXPORT int GatheringReset (int SocketIndex);  /* Empty the gathered data in memory to start new gathering from scratch */
EXPORT int GatheringRun (int SocketIndex, int DataNumber, int Divisor);  /* Start a new gathering */
EXPORT int GatheringStop (int SocketIndex);  /* Stop the data gathering (without saving to file) */
EXPORT int GatheringExternalConfigurationSet (int SocketIndex, int NbElements, char * TypeList);  /* Configuration acquisition */
EXPORT int GatheringExternalConfigurationGet (int SocketIndex, char * Type);  /* Read different mnemonique type */
EXPORT int GatheringExternalCurrentNumberGet (int SocketIndex, int * CurrentNumber, int * MaximumSamplesNumber);  /* Maximum number of samples and current number during acquisition */
EXPORT int GatheringExternalStopAndSave (int SocketIndex);  /* Stop acquisition and save data */
EXPORT int GlobalArrayGet (int SocketIndex, int Number, char * ValueString);  /* Get global array value */
EXPORT int GlobalArraySet (int SocketIndex, int Number, char * ValueString);  /* Set global array value */
EXPORT int DoubleGlobalArrayGet (int SocketIndex, int Number, double * DoubleValue);  /* Get double global array value */
EXPORT int DoubleGlobalArraySet (int SocketIndex, int Number, double DoubleValue);  /* Set double global array value */
EXPORT int GPIOAnalogGet (int SocketIndex, int NbElements, char * GPIONameList, double AnalogValue[]);  /* Read analog input or analog output for one or few input */
EXPORT int GPIOAnalogSet (int SocketIndex, int NbElements, char * GPIONameList, double AnalogOutputValue[]);  /* Set analog output for one or few output */
EXPORT int GPIOAnalogGainGet (int SocketIndex, int NbElements, char * GPIONameList, int AnalogInputGainValue[]);  /* Read analog input gain (1, 2, 4 or 8) for one or few input */
EXPORT int GPIOAnalogGainSet (int SocketIndex, int NbElements, char * GPIONameList, int AnalogInputGainValue[]);  /* Set analog input gain (1, 2, 4 or 8) for one or few input */
EXPORT int GPIODigitalGet (int SocketIndex, char * GPIOName, unsigned short * DigitalValue);  /* Read digital output or digital input  */
EXPORT int GPIODigitalSet (int SocketIndex, char * GPIOName, unsigned short Mask, unsigned short DigitalOutputValue);  /* Set Digital Output for one or few output TTL */
EXPORT int GroupAnalogTrackingModeEnable (int SocketIndex, char * GroupName, char * Type);  /* Enable Analog Tracking mode on selected group */
EXPORT int GroupAnalogTrackingModeDisable (int SocketIndex, char * GroupName);  /* Disable Analog Tracking mode on selected group */
EXPORT int GroupCorrectorOutputGet (int SocketIndex, char * GroupName, int NbElements, double CorrectorOutput[]);  /* Return corrector outputs */
EXPORT int GroupHomeSearch (int SocketIndex, char * GroupName);  /* Start home search sequence */
EXPORT int GroupHomeSearchAndRelativeMove (int SocketIndex, char * GroupName, int NbElements, double TargetDisplacement[]);  /* Start home search sequence and execute a displacement */
EXPORT int GroupInitialize (int SocketIndex, char * GroupName);  /* Start the initialization */
EXPORT int GroupInitializeWithEncoderCalibration (int SocketIndex, char * GroupName);  /* Start the initialization with encoder calibration */
EXPORT int GroupJogParametersSet (int SocketIndex, char * GroupName, int NbElements, double Velocity[], double Acceleration[]);  /* Modify Jog parameters on selected group and activate the continuous move */
EXPORT int GroupJogParametersGet (int SocketIndex, char * GroupName, int NbElements, double Velocity[], double Acceleration[]);  /* Get Jog parameters on selected group */
EXPORT int GroupJogCurrentGet (int SocketIndex, char * GroupName, int NbElements, double Velocity[], double Acceleration[]);  /* Get Jog current on selected group */
EXPORT int GroupJogModeEnable (int SocketIndex, char * GroupName);  /* Enable Jog mode on selected group */
EXPORT int GroupJogModeDisable (int SocketIndex, char * GroupName);  /* Disable Jog mode on selected group */
EXPORT int GroupKill (int SocketIndex, char * GroupName);  /* Kill the group */
EXPORT int GroupMoveAbort (int SocketIndex, char * GroupName);  /* Abort a move */
EXPORT int GroupMoveAbsolute (int SocketIndex, char * GroupName, int NbElements, double TargetPosition[]);  /* Do an absolute move */
EXPORT int GroupMoveRelative (int SocketIndex, char * GroupName, int NbElements, double TargetDisplacement[]);  /* Do a relative move */
EXPORT int GroupMotionDisable (int SocketIndex, char * GroupName);  /* Set Motion disable on selected group */
EXPORT int GroupMotionEnable (int SocketIndex, char * GroupName);  /* Set Motion enable on selected group */
EXPORT int GroupPositionCorrectedProfilerGet (int SocketIndex, char * GroupName, double PositionX, double PositionY, double * CorrectedProfilerPositionX, double * CorrectedProfilerPositionY);  /* Return corrected profiler positions */
EXPORT int GroupPositionCurrentGet (int SocketIndex, char * GroupName, int NbElements, double CurrentEncoderPosition[]);  /* Return current positions */
EXPORT int GroupPositionSetpointGet (int SocketIndex, char * GroupName, int NbElements, double SetPointPosition[]);  /* Return setpoint positions */
EXPORT int GroupPositionTargetGet (int SocketIndex, char * GroupName, int NbElements, double TargetPosition[]);  /* Return target positions */
EXPORT int GroupReferencingActionExecute (int SocketIndex, char * PositionerName, char * ReferencingAction, char * ReferencingSensor, double ReferencingParameter);  /* Execute an action in referencing mode */
EXPORT int GroupReferencingStart (int SocketIndex, char * GroupName);  /* Enter referencing mode */
EXPORT int GroupReferencingStop (int SocketIndex, char * GroupName);  /* Exit referencing mode */
EXPORT int GroupStatusGet (int SocketIndex, char * GroupName, int * Status);  /* Return group status */
EXPORT int GroupStatusStringGet (int SocketIndex, int GroupStatusCode, char * GroupStatusString);  /* Return the group status string corresponding to the group status code */
EXPORT int GroupVelocityCurrentGet (int SocketIndex, char * GroupName, int NbElements, double CurrentVelocity[]);  /* Return current velocities */
EXPORT int KillAll (int SocketIndex);  /* Put all groups in 'Not initialized' state */
EXPORT int PositionerAnalogTrackingPositionParametersGet (int SocketIndex, char * PositionerName, char * GPIOName, double * Offset, double * Scale, double * Velocity, double * Acceleration);  /* Read dynamic parameters for one axe of a group for a future analog tracking position */
EXPORT int PositionerAnalogTrackingPositionParametersSet (int SocketIndex, char * PositionerName, char * GPIOName, double Offset, double Scale, double Velocity, double Acceleration);  /* Update dynamic parameters for one axe of a group for a future analog tracking position */
EXPORT int PositionerAnalogTrackingVelocityParametersGet (int SocketIndex, char * PositionerName, char * GPIOName, double * Offset, double * Scale, double * DeadBandThreshold, int * Order, double * Velocity, double * Acceleration);  /* Read dynamic parameters for one axe of a group for a future analog tracking velocity */
EXPORT int PositionerAnalogTrackingVelocityParametersSet (int SocketIndex, char * PositionerName, char * GPIOName, double Offset, double Scale, double DeadBandThreshold, int Order, double Velocity, double Acceleration);  /* Update dynamic parameters for one axe of a group for a future analog tracking velocity */
EXPORT int PositionerBacklashGet (int SocketIndex, char * PositionerName, double * BacklashValue, char * BacklaskStatus);  /* Read backlash value and status */
EXPORT int PositionerBacklashSet (int SocketIndex, char * PositionerName, double BacklashValue);  /* Set backlash value */
EXPORT int PositionerBacklashEnable (int SocketIndex, char * PositionerName);  /* Enable the backlash */
EXPORT int PositionerBacklashDisable (int SocketIndex, char * PositionerName);  /* Disable the backlash */
EXPORT int PositionerCorrectorNotchFiltersSet (int SocketIndex, char * PositionerName, double NotchFrequency1, double NotchBandwith1, double NotchGain1, double NotchFrequency2, double NotchBandwith2, double NotchGain2);  /* Update filters parameters  */
EXPORT int PositionerCorrectorNotchFiltersGet (int SocketIndex, char * PositionerName, double * NotchFrequency1, double * NotchBandwith1, double * NotchGain1, double * NotchFrequency2, double * NotchBandwith2, double * NotchGain2);  /* Read filters parameters  */
EXPORT int PositionerCorrectorPIDFFAccelerationSet (int SocketIndex, char * PositionerName, int ClosedLoopStatus, double KP, double KI, double KD, double KS, double IntegrationTime, double DerivativeFilterCutOffFrequency, double GKP, double GKI, double GKD, double KForm, double FeedForwardGainAcceleration);  /* Update corrector parameters */
EXPORT int PositionerCorrectorPIDFFAccelerationGet (int SocketIndex, char * PositionerName, int * ClosedLoopStatus, double * KP, double * KI, double * KD, double * KS, double * IntegrationTime, double * DerivativeFilterCutOffFrequency, double * GKP, double * GKI, double * GKD, double * KForm, double * FeedForwardGainAcceleration);  /* Read corrector parameters */
EXPORT int PositionerCorrectorPIDFFVelocitySet (int SocketIndex, char * PositionerName, int ClosedLoopStatus, double KP, double KI, double KD, double KS, double IntegrationTime, double DerivativeFilterCutOffFrequency, double GKP, double GKI, double GKD, double KForm, double FeedForwardGainVelocity);  /* Update corrector parameters */
EXPORT int PositionerCorrectorPIDFFVelocityGet (int SocketIndex, char * PositionerName, int * ClosedLoopStatus, double * KP, double * KI, double * KD, double * KS, double * IntegrationTime, double * DerivativeFilterCutOffFrequency, double * GKP, double * GKI, double * GKD, double * KForm, double * FeedForwardGainVelocity);  /* Read corrector parameters */
EXPORT int PositionerCorrectorPIDDualFFVoltageSet (int SocketIndex, char * PositionerName, int ClosedLoopStatus, double KP, double KI, double KD, double KS, double IntegrationTime, double DerivativeFilterCutOffFrequency, double GKP, double GKI, double GKD, double KForm, double FeedForwardGainVelocity, double FeedForwardGainAcceleration, double Friction);  /* Update corrector parameters */
EXPORT int PositionerCorrectorPIDDualFFVoltageGet (int SocketIndex, char * PositionerName, int * ClosedLoopStatus, double * KP, double * KI, double * KD, double * KS, double * IntegrationTime, double * DerivativeFilterCutOffFrequency, double * GKP, double * GKI, double * GKD, double * KForm, double * FeedForwardGainVelocity, double * FeedForwardGainAcceleration, double * Friction);  /* Read corrector parameters */
EXPORT int PositionerCorrectorPIPositionSet (int SocketIndex, char * PositionerName, int ClosedLoopStatus, double KP, double KI, double IntegrationTime);  /* Update corrector parameters */
EXPORT int PositionerCorrectorPIPositionGet (int SocketIndex, char * PositionerName, int * ClosedLoopStatus, double * KP, double * KI, double * IntegrationTime);  /* Read corrector parameters */
EXPORT int PositionerCorrectorTypeGet (int SocketIndex, char * PositionerName, char * CorrectorType);  /* Read corrector type */
EXPORT int PositionerCurrentVelocityAccelerationFiltersSet (int SocketIndex, char * PositionerName, double CurrentVelocityCutOffFrequency, double CurrentAccelerationCutOffFrequency);  /* Set current velocity and acceleration cut off frequencies */
EXPORT int PositionerCurrentVelocityAccelerationFiltersGet (int SocketIndex, char * PositionerName, double * CurrentVelocityCutOffFrequency, double * CurrentAccelerationCutOffFrequency);  /* Get current velocity and acceleration cut off frequencies */
EXPORT int PositionerDriverStatusGet (int SocketIndex, char * PositionerName, int * DriverStatus);  /* Read positioner driver status */
EXPORT int PositionerDriverStatusStringGet (int SocketIndex, int PositionerDriverStatus, char * PositionerDriverStatusString);  /* Return the positioner driver status string corresponding to the positioner error code */
EXPORT int PositionerEncoderAmplitudeValuesGet (int SocketIndex, char * PositionerName, double * CalibrationSinusAmplitude, double * CurrentSinusAmplitude, double * CalibrationCosinusAmplitude, double * CurrentCosinusAmplitude);  /* Read analog interpolated encoder amplitude values */
EXPORT int PositionerEncoderCalibrationParametersGet (int SocketIndex, char * PositionerName, double * SinusOffset, double * CosinusOffset, double * DifferentialGain, double * PhaseCompensation);  /* Read analog interpolated encoder calibration parameters */
EXPORT int PositionerErrorGet (int SocketIndex, char * PositionerName, int * ErrorCode);  /* Read and clear positioner error code */
EXPORT int PositionerErrorRead (int SocketIndex, char * PositionerName, int * ErrorCode);  /* Read only positioner error code without clear it */
EXPORT int PositionerErrorStringGet (int SocketIndex, int PositionerErrorCode, char * PositionerErrorString);  /* Return the positioner status string corresponding to the positioner error code */
EXPORT int PositionerHardwareStatusGet (int SocketIndex, char * PositionerName, int * HardwareStatus);  /* Read positioner hardware status */
EXPORT int PositionerHardwareStatusStringGet (int SocketIndex, int PositionerHardwareStatus, char * PositionerHardwareStatusString);  /* Return the positioner hardware status string corresponding to the positioner error code */
EXPORT int PositionerHardInterpolatorFactorGet (int SocketIndex, char * PositionerName, int * InterpolationFactor);  /* Get hard interpolator parameters */
EXPORT int PositionerHardInterpolatorFactorSet (int SocketIndex, char * PositionerName, int InterpolationFactor);  /* Set hard interpolator parameters */
EXPORT int PositionerMaximumVelocityAndAccelerationGet (int SocketIndex, char * PositionerName, double * MaximumVelocity, double * MaximumAcceleration);  /* Return maximum velocity and acceleration of the positioner */
EXPORT int PositionerMotionDoneGet (int SocketIndex, char * PositionerName, double * PositionWindow, double * VelocityWindow, double * CheckingTime, double * MeanPeriod, double * TimeOut);  /* Read motion done parameters */
EXPORT int PositionerMotionDoneSet (int SocketIndex, char * PositionerName, double PositionWindow, double VelocityWindow, double CheckingTime, double MeanPeriod, double TimeOut);  /* Update motion done parameters */
EXPORT int PositionerPositionCompareGet (int SocketIndex, char * PositionerName, double * MinimumPosition, double * MaximumPosition, double * PositionStep, int * EnableState);  /* Read position compare parameters */
EXPORT int PositionerPositionCompareSet (int SocketIndex, char * PositionerName, double MinimumPosition, double MaximumPosition, double PositionStep);  /* Set position compare parameters */
EXPORT int PositionerPositionCompareEnable (int SocketIndex, char * PositionerName);  /* Enable position compare */
EXPORT int PositionerPositionCompareDisable (int SocketIndex, char * PositionerName);  /* Disable position compare */
EXPORT int PositionerPositionComparePulseParametersGet (int SocketIndex, char * PositionerName, double * PCOPulseWidth, double * EncoderSettlingTime);  /* Get position compare PCO pulse parameters */
EXPORT int PositionerPositionComparePulseParametersSet (int SocketIndex, char * PositionerName, double PCOPulseWidth, double EncoderSettlingTime);  /* Set position compare PCO pulse parameters */
EXPORT int PositionersEncoderIndexDifferenceGet (int SocketIndex, char * PositionerName, double * distance);  /* Return the difference between index of primary axis and secondary axis (only after homesearch) */
EXPORT int PositionerSGammaExactVelocityAjustedDisplacementGet (int SocketIndex, char * PositionerName, double DesiredDisplacement, double * AdjustedDisplacement);  /* Return adjusted displacement to get exact velocity */
EXPORT int PositionerSGammaParametersGet (int SocketIndex, char * PositionerName, double * Velocity, double * Acceleration, double * MinimumTjerkTime, double * MaximumTjerkTime);  /* Read dynamic parameters for one axe of a group for a future displacement  */
EXPORT int PositionerSGammaParametersSet (int SocketIndex, char * PositionerName, double Velocity, double Acceleration, double MinimumTjerkTime, double MaximumTjerkTime);  /* Update dynamic parameters for one axe of a group for a future displacement */
EXPORT int PositionerSGammaPreviousMotionTimesGet (int SocketIndex, char * PositionerName, double * SettingTime, double * SettlingTime);  /* Read SettingTime and SettlingTime */
EXPORT int PositionerStageParameterGet (int SocketIndex, char * PositionerName, char * ParameterName, char * ParameterValue);  /* Return the stage parameter */
EXPORT int PositionerStageParameterSet (int SocketIndex, char * PositionerName, char * ParameterName, char * ParameterValue);  /* Save the stage parameter */
EXPORT int PositionerTimeFlasherGet (int SocketIndex, char * PositionerName, double * MinimumPosition, double * MaximumPosition, double * PositionStep, int * EnableState);  /* Read time flasher parameters */
EXPORT int PositionerTimeFlasherSet (int SocketIndex, char * PositionerName, double MinimumPosition, double MaximumPosition, double TimeInterval);  /* Set time flasher parameters */
EXPORT int PositionerTimeFlasherEnable (int SocketIndex, char * PositionerName);  /* Enable time flasher */
EXPORT int PositionerTimeFlasherDisable (int SocketIndex, char * PositionerName);  /* Disable time flasher */
EXPORT int PositionerUserTravelLimitsGet (int SocketIndex, char * PositionerName, double * UserMinimumTarget, double * UserMaximumTarget);  /* Read UserMinimumTarget and UserMaximumTarget */
EXPORT int PositionerUserTravelLimitsSet (int SocketIndex, char * PositionerName, double UserMinimumTarget, double UserMaximumTarget);  /* Update UserMinimumTarget and UserMaximumTarget */
EXPORT int PositionerCorrectorAutoTuning (int SocketIndex, char * PositionerName, int TuningMode, double * KP, double * KI, double * KD);  /* Astrom&Hagglund based auto-tuning */
EXPORT int PositionerAccelerationAutoScaling (int SocketIndex, char * PositionerName, double * Scaling);  /* Astrom&Hagglund based auto-scaling */
EXPORT int MultipleAxesPVTVerification (int SocketIndex, char * GroupName, char * TrajectoryFileName);  /* Multiple axes PVT trajectory verification */
EXPORT int MultipleAxesPVTVerificationResultGet (int SocketIndex, char * PositionerName, char * FileName, double * MinimumPosition, double * MaximumPosition, double * MaximumVelocity, double * MaximumAcceleration);  /* Multiple axes PVT trajectory verification result get */
EXPORT int MultipleAxesPVTExecution (int SocketIndex, char * GroupName, char * TrajectoryFileName, int ExecutionNumber);  /* Multiple axes PVT trajectory execution */
EXPORT int MultipleAxesPVTParametersGet (int SocketIndex, char * GroupName, char * FileName, int * CurrentElementNumber);  /* Multiple axes PVT trajectory get parameters */
EXPORT int MultipleAxesPVTPulseOutputSet (int SocketIndex, char * GroupName, int StartElement, int EndElement, double TimeInterval);  /* Configure pulse output on trajectory */
EXPORT int MultipleAxesPVTPulseOutputGet (int SocketIndex, char * GroupName, int * StartElement, int * EndElement, double * TimeInterval);  /* Get pulse output on trajectory configuration */
EXPORT int SingleAxisSlaveModeEnable (int SocketIndex, char * GroupName);  /* Enable the slave mode */
EXPORT int SingleAxisSlaveModeDisable (int SocketIndex, char * GroupName);  /* Disable the slave mode */
EXPORT int SingleAxisSlaveParametersSet (int SocketIndex, char * GroupName, char * PositionerName, double Ratio);  /* Set slave parameters */
EXPORT int SingleAxisSlaveParametersGet (int SocketIndex, char * GroupName, char * PositionerName, double * Ratio);  /* Get slave parameters */
EXPORT int SpindleSlaveModeEnable (int SocketIndex, char * GroupName);  /* Enable the slave mode */
EXPORT int SpindleSlaveModeDisable (int SocketIndex, char * GroupName);  /* Disable the slave mode */
EXPORT int SpindleSlaveParametersSet (int SocketIndex, char * GroupName, char * PositionerName, double Ratio);  /* Set slave parameters */
EXPORT int SpindleSlaveParametersGet (int SocketIndex, char * GroupName, char * PositionerName, double * Ratio);  /* Get slave parameters */
EXPORT int GroupSpinParametersSet (int SocketIndex, char * GroupName, double Velocity, double Acceleration);  /* Modify Spin parameters on selected group and activate the continuous move */
EXPORT int GroupSpinParametersGet (int SocketIndex, char * GroupName, double * Velocity, double * Acceleration);  /* Get Spin parameters on selected group */
EXPORT int GroupSpinCurrentGet (int SocketIndex, char * GroupName, double * Velocity, double * Acceleration);  /* Get Spin current on selected group */
EXPORT int GroupSpinModeStop (int SocketIndex, char * GroupName, double Acceleration);  /* Stop Spin mode on selected group with specified acceleration */
EXPORT int XYLineArcVerification (int SocketIndex, char * GroupName, char * TrajectoryFileName);  /* XY trajectory verification */
EXPORT int XYLineArcVerificationResultGet (int SocketIndex, char * PositionerName, char * FileName, double * MinimumPosition, double * MaximumPosition, double * MaximumVelocity, double * MaximumAcceleration);  /* XY trajectory verification result get */
EXPORT int XYLineArcExecution (int SocketIndex, char * GroupName, char * TrajectoryFileName, double Velocity, double Acceleration, int ExecutionNumber);  /* XY trajectory execution */
EXPORT int XYLineArcParametersGet (int SocketIndex, char * GroupName, char * FileName, double * Velocity, double * Acceleration, int * CurrentElementNumber);  /* XY trajectory get parameters */
EXPORT int XYLineArcPulseOutputSet (int SocketIndex, char * GroupName, double StartLength, double EndLength, double PathLengthInterval);  /* Configure pulse output on trajectory */
EXPORT int XYLineArcPulseOutputGet (int SocketIndex, char * GroupName, double * StartLength, double * EndLength, double * PathLengthInterval);  /* Get pulse output on trajectory configuration */
EXPORT int XYZSplineVerification (int SocketIndex, char * GroupName, char * TrajectoryFileName);  /* XYZ trajectory verifivation */
EXPORT int XYZSplineVerificationResultGet (int SocketIndex, char * PositionerName, char * FileName, double * MinimumPosition, double * MaximumPosition, double * MaximumVelocity, double * MaximumAcceleration);  /* XYZ trajectory verification result get */
EXPORT int XYZSplineExecution (int SocketIndex, char * GroupName, char * TrajectoryFileName, double Velocity, double Acceleration);  /* XYZ trajectory execution */
EXPORT int XYZSplineParametersGet (int SocketIndex, char * GroupName, char * FileName, double * Velocity, double * Acceleration, int * CurrentElementNumber);  /* XYZ trajectory get parameters */
EXPORT int OptionalModuleExecute (int SocketIndex, char * ModuleFileName, char * TaskName);  /* Execute an optional module */
EXPORT int OptionalModuleKill (int SocketIndex, char * TaskName);  /* Kill an optional module */
EXPORT int EEPROMCIESet (int SocketIndex, int CardNumber, char * ReferenceString);  /* Set CIE EEPROM reference string */
EXPORT int EEPROMDACOffsetCIESet (int SocketIndex, int PlugNumber, double DAC1Offset, double DAC2Offset);  /* Set CIE DAC offsets */
EXPORT int EEPROMDriverSet (int SocketIndex, int PlugNumber, char * ReferenceString);  /* Set Driver EEPROM reference string */
EXPORT int EEPROMINTSet (int SocketIndex, int CardNumber, char * ReferenceString);  /* Set INT EEPROM reference string */
EXPORT int CPUCoreAndBoardSupplyVoltagesGet (int SocketIndex, double * VoltageCPUCore, double * SupplyVoltage1P5V, double * SupplyVoltage3P3V, double * SupplyVoltage5V, double * SupplyVoltage12V, double * SupplyVoltageM12V, double * SupplyVoltageM5V, double * SupplyVoltage5VSB);  /* Get power informations */
EXPORT int CPUTemperatureAndFanSpeedGet (int SocketIndex, double * CPUTemperature, double * CPUFanSpeed);  /* Get CPU temperature and fan speed */
EXPORT int ActionListGet (int SocketIndex, char * ActionList);  /* Action list */
EXPORT int ActionExtendedListGet (int SocketIndex, char * ActionList);  /* Action extended list */
EXPORT int APIExtendedListGet (int SocketIndex, char * Method);  /* API method list */
EXPORT int APIListGet (int SocketIndex, char * Method);  /* API method list without extended API */
EXPORT int ErrorListGet (int SocketIndex, char * ErrorsList);  /* Error list */
EXPORT int EventListGet (int SocketIndex, char * EventList);  /* General event list */
EXPORT int GatheringListGet (int SocketIndex, char * list);  /* Gathering type list */
EXPORT int GatheringExtendedListGet (int SocketIndex, char * list);  /* Gathering type extended list */
EXPORT int GatheringExternalListGet (int SocketIndex, char * list);  /* External Gathering type list */
EXPORT int GroupStatusListGet (int SocketIndex, char * GroupStatusList);  /* Group status list */
EXPORT int HardwareInternalListGet (int SocketIndex, char * InternalHardwareList);  /* Internal hardware list */
EXPORT int HardwareDriverAndStageGet (int SocketIndex, int PlugNumber, char * DriverName, char * StageName);  /* Smart hardware */
EXPORT int ObjectsListGet (int SocketIndex, char * ObjectsList);  /* Group name and positioner name */
EXPORT int PositionerErrorListGet (int SocketIndex, char * PositionerErrorList);  /* Positioner error list */
EXPORT int PositionerHardwareStatusListGet (int SocketIndex, char * PositionerHardwareStatusList);  /* Positioner hardware status list */
EXPORT int PositionerDriverStatusListGet (int SocketIndex, char * PositionerDriverStatusList);  /* Positioner driver status list */
EXPORT int ReferencingActionListGet (int SocketIndex, char * list);  /* Get referencing action list */
EXPORT int ReferencingSensorListGet (int SocketIndex, char * list);  /* Get referencing sensor list */
EXPORT int GatheringUserDatasGet (int SocketIndex, double * UserData1, double * UserData2, double * UserData3, double * UserData4, double * UserData5, double * UserData6, double * UserData7, double * UserData8);  /* Return UserDatas values */
EXPORT int TestTCP (int SocketIndex, char * InputString, char * ReturnString);  /* Test TCP/IP transfert */

#endif /* _SHELL_H_ */

