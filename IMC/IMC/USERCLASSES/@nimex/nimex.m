% @nimex/nimex - Creates an underlying nimex structure in C.
% 
% SYNTAX
%  nimexTask = nimex
%  
% NOTES
%  Relies on NIMEX_createTask.mex32 to initialize the object. No
%  other function should call NIMEX_createTask.mex32.
%
%  This is intended to wrap the NIDAQmx interface in MATLAB. All relevant
%  NIDAQmx TaskHandle properties are fields in the NIMEX_TaskDefinition
%  and NIMEX_ChannelDefinition structure(s). These may be accessed via
%  the methods of this class. Familiarity with the underlying NIDAQmx
%  library is expected, but not entirely necessary.
%
% PROPERTIES
%  Task:
%     char             channels               (read-only)
%     char             clockSource
%     int32            clockActiveEdge
%     char             clockExportTerminal
%     ANY_TYPE         userData
%     char             triggerSource
%     int32            timeout
%     int32            lineGrouping
%     double           samplingRate
%     int32            sampleMode
%     uint64           sampsPerChanToAcquire
%     int32            triggerEdge
%     uint32           pretriggerSamples
%     int32            started                (boolean, read-only)
%     uint32           everyNSamples
%     uint32           repeatOutput
%  Channel:
%     int32            channelType
%     int32            terminalConfig
%     int32units
%     double           minVal
%     double           maxVal
%     CONTEXT_SPECIFIC dataBuffer            (read-only)
%     uint64           dataBufferSize
%     char             mnemonicName
%     char             physicalChannel       (read-only)
%     func             dataSource            (output channels only)
%   
%
%  For convenience, #define constants from NIDAQmx.h may be specified from 
%  Matlab as strings (they will be converted to the proper binary values in C).
%  The convertable constants include:
%    DAQmx_Val_ChanForAllLines
%    DAQmx_Val_ContSamps
%    DAQmx_Val_Diff
%    DAQmx_Val_Falling
%    DAQmx_Val_FiniteSamps
%    DAQmx_Val_HWTimedSinglePoint
%    DAQmx_Val_PseudoDiff
%    DAQmx_Val_Rising
%    DAQmx_Val_Volts
%    DAQmx_Val_MSeriesDAQ
%    DAQmx_Val_ESeriesDAQ
%    DAQmx_Val_SSeriesDAQ
%    DAQmx_Val_BSeriesDAQ
%    DAQmx_Val_Rising
%    DAQmx_Val_SCSeriesDAQ
%    DAQmx_Val_USBDAQ
%    DAQmx_Val_AOSeries
%    DAQmx_Val_Volts
%    DAQmx_Val_DigitalIO
%    DAQmx_Val_TIOSeries
%    DAQmx_Val_DynamicSignalAcquisition
%    DAQmx_Val_Switches
%    DAQmx_Val_CompactDAQChassis
%    DAQmx_Val_CSeriesModule
%    DAQmx_Val_SCXIModule
%    DAQmx_Val_Unknown
%
% CHANGES
%  TO040407A: Documentation update. -- Tim O'Connor 4/4/07
%  
% Created
%  Aleksander Sobczyk & Timothy O'Connor 11/16/06
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function this = nimex(varargin)

this.NIMEX_TaskDefinition = NIMEX_createTask(varargin{:});
this.valid = 1;
this.debug.instantiationTime = clock;
% this.debug.instantiationStack = getStackTraceString;

this = class(this, 'nimex');

% fprintf(1, 'nimex: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;