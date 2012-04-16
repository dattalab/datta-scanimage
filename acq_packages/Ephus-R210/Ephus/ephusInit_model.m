% This is a model Ephus initialization file. Users should copy and rename this file to something meaningful (e.g. 'ephusInit_karel.m') and edit settings to match their rig/experiment. 
% This edited file should then either be specified when starting ephus (e.g. 'ephus(<filename>') or selected when prompted by Ephus (after starting simply with 'ephus' at command line)
%
%% *******************************************************

%% GENERAL CONFIGURATION
mapperEnabled = false;                          % Logical (true/false) indicating whether this Ephus installation uses Mapper (Laser Scanning Photostimulation) functionality
qcamEnabled = false;                            % Logical (true/false) indicating whether this Ephus installation uses QCam (QImaging Retiga CCD camera suport) functionality
xsgStartDirectory = 'C:\DATA\';                 % Default root directory used by XSG program for saving data files. NOTE: This value can be overridden by a saved XSG configuration, which is often desirable.

%% MAPPER CONFIGURATION - Configuration of 'Mapping' (Laser-Scanning Photostimulation) Components of Ephus
%If mapperEnabled = true, edit following fields to configure the various input/output channels, and other settings, related to Mapping components of Ephus. 
%(If not, skip to next section)
%
%The xMirror and yMirror channels MUST be configured. The pockelsCell can be configured or left empty (feature disabled).
%If pockels channel is configured, then shutter and photodiode MUST also be configured.
%The Mapper controls shutter channel only to open/close shutter before/after Pockels calibration.
%If no physical shutter is present, specify an unused digital output port/line.

%These mandatory channels will appear in Stimulator program as 'xMirror' and 'yMirror'
xMirrorBoardID = [];                    % Number identifying DAQmx board (e.g. 1 for 'Dev1') on which command signal from Ephus is output to X Mirror command input.
xMirrorChannelID = [];                  % Number identifying DAQmx analog output channel on board identified by 'xMirrorBoardID' on which command signal from Ephus is output to X mirror command input.
yMirrorBoardID = [];                    % Number identifying DAQmx board (e.g. 1 for 'Dev1') on which command signal from Ephus is output to Y Mirror command input.
yMirrorChannelID = [];                  % Number identifying DAQmx analog output channel on board identified by 'xMirrorBoardID' on which command signal from Ephus is output to Y mirror command input.  NOTE: This configures an analog output channel that appears in the Stimulator program as 'yMirror'.

%Configuring 'pockelsBoardID'/'pockelsChannelID' enables Pockels modulation feature of Mapper
%If configured, Pockels channel appears in Stimulator program as 'pockelsCell'
pockelsBoardID = [];                    % Number identifying DAQmx board (e.g. 1 for 'Dev1') on which command signal from Ephus is output to Pockels cell command input.
pockelsChannelID = [];                  % Number identifying DAQmx analog output channel on board identified by 'pockelsBoardID' on which command signal from Ephus is output to Pockels cell command input.

pockelsModulatorMax = 2; %Maximum value, in volts, to use when calibrating Pockels cell. Set this level somewhat above the maximum expected value.

%If Pockels feature is enabled, photodiode MUST be configured to allow Pockels (power) control of beam to be calibrated
%If configured,  photodiode channel appears in Acquirer program as 'photodiode1'
photodiodeBoardID = [];                 % Number identifying DAQmx board (e.g. 1 for 'Dev1') on which photodiode signal is input to Ephus.
photodiodeChannelID = [];               % Number identifying DAQmx analog input channel on board identified by 'photodiodeBoardID' on which photodiode signal is input to Ephus.

%If Pockels feature is enabled, shutter MUST be enabled by specifying 'shutterBoardID' and either (but not both):
%   'shutterPortID' and 'shutterLineID' must be specified, if shutterDigital=true
%   'shutterChannelID' must be specified, if shutterDigital=false
%If configured,  shutter channel appears in Stimulator program as 'shutter0'
shutterBoardID = [];                    % Number identifying DAQmx board (e.g. 1 for 'Dev1') on which command signal from Ephus is output to shutter TTL input.
shutterDigital = true;                  % Logical (true/false) indicating, if true, that shutter control signal is output by Ephus on a digital output line; if false, then signal is output on an analog output line.
shutterPortID = [];                     % Number identifying DAQmx digital port on board identified by 'shutterBoardID' on which command signal from Ephus is output to shutter TTL input.
shutterLineID = [];                     % Number identifying DAQmx digital line on board identified by 'shutterBoardID' on which command signal from Ephus is output to shutter TTL input.
shutterChannelID = [];                  % Number identifying DAQmx analog output channel on board identified by 'shutterBoardID' on which command signal from Ephus is output to shutter command input.

%Following specify the image size, in microns, of the reference image imported by the Mapper (Grab Video command).
%This should be calibrated by measurement. This is independent from the calibration of the laser scan range done in the imagingSys program.
xVideoImageSize = [];
yVideoImageSize = [];

%% EPHYS CHANNELS - Amplifier Input/Output Channel Configuration
%Edit following field values to configure an amplifier 'channel', i.e. the input and output channels pertaining to a single electrode. 
%Some fields values only require editing for particular amplifier types
%To add additional amplifier channels: copy and paste, and increment index on each line (i.e. 'amp(2).<field> = <value>')

amp(1).amplifierType = '';              % One of {'multi_clamp' 'axopatch_200B'}. Identifies type of amplifier device.
amp(1).scaledOutputBoardID = [];        % Number identifying DAQmx board (e.g. 1 for 'Dev1') on which 'scaled output' signal from amplifier channel is input to Ephus
amp(1).scaledOutputChannelID = [];      % Number identifying DAQmx channel on board identified by 'scaledOutputBoardID' on which 'scaled output' signal from amplifier channelis input to Ephus
amp(1).vComBoardID = [];                % Number identifying DAQmx board (e.g. 2 for 'Dev2') on which command signal from Ephus is output to amplifier channel   
amp(1).vComChannelID = [];              % Number identifying DAQmx channel on board identified by 'vComBoardID' on which command signal from Ephus is output to amplifier channel   
amp(1).amplifierChannelID = [];         %(MULTICLAMP ONLY) Identifies which amplifier 'channel' on the amplifier device, e.g. 1 or 2 on Multiclamp amplifiers.
amp(1).serialNumber = [];               %(MULTICLAMP 700B ONLY) Identifies serial number of amplifier device on which this channel is located
amp(1).comPortID = [];                  %(MULTICLAMP 700A ONLY) Identifies which serial port (e.g. 3 for COM3 port) is used to connect to amplifier device
amp(1).axoBusID = [];                   %(MULTICLAMP 700A ONLY) Identifies which 'Axo Bus' is used for this amplifier channel
amp(1).gainBoardID = [];                %(AXOPATCH 200B ONLY) Number identifying DAQmx board (e.g. 1 for 'Dev1') on which 'gain' telegraph signal from amplifier channel is input to Ephus
amp(1).gainChannelID = [];              %(AXOPATCH 200B ONLY) Number identifying DAQmx channel on board identified by 'gainBoardID' on which 'gain' telegraph signal from amplifier channel is input to Ephus
amp(1).modeBoardID = [];                %(AXOPATCH 200B ONLY) Number identifying DAQmx board (e.g. 1 for 'Dev1') on which 'mode' telegraph signal from amplifier channel is input to Ephus
amp(1).modeChannelID = [];              %(AXOPATCH 200B ONLY) Number identifying DAQmx channel on board identified by 'modeBoardID' on which 'mode' telegraph signal from amplifier channel is input to Ephus
amp(1).vHoldBoardID = [];               %(AXOPATCH 200B ONLY) Number identifying DAQmx board (e.g. 1 for 'Dev1') on which '10Vm' telegraph signal from amplifier channel is input to Ephus
amp(1).vHoldChannelID = [];             %(AXOPATCH 200B ONLY) Number identifying DAQmx channel on board identified by 'vHoldBoardID' on which '10Vm' telegraph signal from amplifier channel is input to Ephus

%% ACQUIRER/STIMULATOR CHANNELS - General Input/Output Channel Configuration
%Following section configures general (non-Mapper) input/output channels to be made available for use by Ephus 

%Acquirer channels (Analog Input)
acqChannelNames = {};                   % Cell array of descriptive names for analog input acquisition channels to configure, e.g. {'Lick Sensor' 'Nose Poke Sensor'}, 
acqBoardIDs = [];                       % A single number (e.g. 1 for 'Dev1') specifying DAQmx board for /all/ named acquisition channels; or, an array of numbers of length equal to 'acqChannelNames' (e.g. [1 1 1 2 2] indicating 'Dev1' for first 3 channels, 'Dev2' for last 2 channels) identifying DAQmx board on which each of the named acquisition channels appears. 
acqChannelIDs =  [];                    % Array of numbers, of length equal to 'acqChannelNames', identifying DAQmx channel number (e.g. 1 for AI1) for each of the named acquisition channels (e.g. [0 1 2 0 1] indicating AI0-2 for first 3 channels  and AI0-1 for last 2 channels, for case of multiple boards). 

%Stimulator channels (Analog Output) 
stimChannelNames = {};                  % Cell array of descriptive names for analog output stimulus channels to configure, e.g. {'Whisker Stimulator' 'Position Encoder'}, 
stimBoardIDs = [];                      % A single number (e.g. 1 for 'Dev1') specifying DAQmx board for /all/ named analog stimulus channels; or, an array of numbers of length equal to 'stimChannelNames' (e.g. [1 1 1 2 2] indicating 'Dev1' for first 3 channels, 'Dev2' for last 2 channels) identifying DAQmx board on which each of the named analog stimulus channels appears. 
stimChannelIDs = [];                    % Array of numbers, of length equal to 'stimChannelNames', identifying DAQmx channel number (e.g. 1 for AI1) for each of the named analog stimulus channels (e.g. [0 1 2 0 1] indicating AI0-2 for first 3 channels  and AI0-1 for last 2 channels, for case of multiple boards). 

%Stimulator channels (Digital Output)
digStimChannelNames = {};               % Cell array of descriptive names for digital output stimulus channels to configure, e.g. {'Camera Trigger' 'LED Pulse'}
digStimBoardIDs = [];                   % A single number (e.g. 1 for 'Dev1') specifying DAQmx board for /all/ named digital stimulus channels; or, an array of numbers of length equal to 'digStimChannelNames' (e.g. [1 1 1 2 2] indicating 'Dev1' for first 3 channels, 'Dev2' for last 2 channels) identifying DAQmx board on which each of the named digital stimulus channels appears. 
digStimPortIDs = [];                    % A single number (e.g. 0 for Port 0 (P0)), or array of numbers of length equal to 'digStimChannelNames' (e.g. [0 0 0 1 1] indicating Port 0 (P0) for first 3 channels and Port 1 (P1) for for last 2 channels), identifying DAQmx board on which each of the named digital stimulus channels appears.
digStimLineIDs =  [];                   % Array of numbers, of length equal to 'digStimChannelNames', identifying DAQmx line number (e.g. 1 for P0.1, P1.1, etc) for each of the named digital stimulus channels (e.g. [0 1 2 0 1] indicating P#.0-2 for first 3 channels and P#.0-1 for last 2 channels, for case of multiple ports).

%Acquirer/Stimulator Channel Ordering
%If ordering of channels in Acquirer and/or Stimulator is important, specify the order here. Otherwise, leave these empty.
%If Mapper is enabled, lists must include all Mapper-configured Stimulator channels ('xMirror' 'yMirror' 'pockelsCell' 'shutter0') and Mapper-configured Acquirer channels ('photodiode1').
%NOTE: Users who have employed 'legacy' startup files (prior to release r2.1.0) should set these to match the order in those startup files, in order to correctly use previously saved configuration sets
stimChannelNamesOrder = {};             % Cell array of all Stimulator channel names -- analog, digital, and Mapper configured -- in desired order of appearance in Stimulator
acqChannelNamesOrder = {};              % Cell array of all Acquirer channel names -- includig Mapper configured -- in desired order of appearance in Acquirer

%% TIMING/TRIGGERING CONFIGURATION
initialSampleRate = 10000;              %(REQUIRED) Initial rate, in Hz, to use for all analog and digital input/output channels configured for use in Ephus

%The /single/ digital line identified by 'triggerOrigin' should be connected to /first/ of the terminal names (i.e. the default terminal) identified in the 'triggerDestination' list, on /all/ of the DAQmx boards configured for use by Ephus
triggerOrigin = '';                     %(REQUIRED) Full DAQmx specification of single digital line on /one/ board (e.g. '/dev1/port0/line0') used as the Ephus default trigger pulse to synchronize the one or more boards.
triggerDestinations = {''};               %(REQUIRED) Cell array of one or more DAQmx PFI terminal names configured as the choice of PFI terminals on which Ephus must receive a trigger input signal, on /all/ of the DAQmx boards configured for use by Ephus.

%The 'sampleClockOrigin' and/or 'sampleClockDestination need be configured only IF one or more of the following is true:
%   1) using multiple boards AND employing digital stimulator lines. 
%   2) using multiple boards, and it is desired that all channels across boards should share a master timebase.
%   3) it is desired to export the sample clock used by Ephus for use by external software/hardware.
%   4) it is desired to import a sample clock generated by external software/hardware for use by Ephus.
% If cases 1-3 apply, both variables must be configured. The clock signal generated on 'sampleClockOrigin' (on /one/ board) should be routed to the input terminal specified by 'sampleClockDestination' on /all/ boards.
% For case 4, only 'sampleClockDestination' need be set, and external clock should be connected to specified terminal on /all/ boards used by Ephus.
sampleClockOrigin = '';                 % Full DAQmx specification of single counter output channel on /one/ board (e.g. '/dev1/ctr0') on which the sample clock generated by Ephus appears. Ephus employs the default DAQmx routing of counter output channels to PFI output terminals (PFI12 for CTR0, PFI13 for CTR1; refer to DAQmx documentation for further information)
sampleClockDestination = '';            % A DAQmx PFI or RTSI terminal name (e.g. 'PFI1' or 'RTSI7') on which sample clock is input on /all/ of the boards configured for use by Ephus

%% ADVANCED CONFIGURATION
%Rarely re-configured variables are contained here. In addition, other variables/functions may be appended to this section for advanced configuration options.
%Refer to Ephus documentation for up-to-date listing of such 'mods'.

%Following vars should only ever require (possible) adjustment from their defaults when multiple programs share a board subsystem
clearInputBuffersOnStop = false;                % Logical (true/false) indicating, if true, that data buffers are cleared on stop command. Setting this to true may lead to loss of data, under certain circumstances, so it is generally set to false.
zeroOutputChannelsOnStop = true;                % Logical (true/false) specifying whether to clear data buffers following stop command
