% @nimexEngine/nimex_connectTerms - Establish an immediate route between device terminals.
%
% SYNTAX
%  nimex_connectTerms(eng, source, destination)
%   eng - @nimexEngine instance.
%   source - The NIDAQmx source terminal.
%            Example: '/dev1/20MhzTimebase'
%   destination - The NIDAQmx destination terminal.
%            Example: '/dev1/RTSI7'
%
% NOTES
%  Relies on NIMEXEng_connectTerms.mex32.
%
%  Many boards natively use RTSI7 for the 20MHz clock (the MasterTimebase).
%  RTSI7 often corresponds to RTSI0SC in National Instruments RTSI pinout diagrams.
%
%  For M-Series devices (ie. the 6259), the input and output subsystems may take different
%  20MHz inputs, so they do not have a MasterTimebase terminal. Instead, use
%  ao/SampleClockTimebase and ai/SampleClockTimebase.
%
%  Consult the specific NI hardware's documentation for limits on signal routing
%  capabilities. Charts of sources and destinations are available in NI Max, for each device,
%  by selecting the 'Device Routes' tab at the bottom. - As of 5/5/08 and NIDAQmx 8.7
%
% EXAMPLE
%  To slave the clocks from devices 2 and 3 to the 20MHz clock on device 1, where device 3 is a 6259:
%   nimex_connectTerms(nimexEngine, '/dev1/20MHzTimebase', '/dev1/RTSI7');%Send the 20MHz clock out on RTSI7.
%   nimex_connectTerms(nimexEngine, '/dev2/RTSI7', '/dev2/MasterTimebase');%Take the 20MHz clock in on RTSI7.
%   nimex_connectTerms(nimexEngine, '/dev3/ao/SampleClockTimebase');%Take the 20MHz clock in on RTSI7 for the output subsystem.
%   nimex_connectTerms(nimexEngine, '/dev3/RTSI7', '/dev3/ai/SampleClockTimebase');%Take the 20MHz clock in on RTSI7 for the input subsystem.
%
%  After the above commands, all tasks will be using the same source for the master timebase.
%  The proper wiring is crucial, or else samples will not be acquired/generated.
%  It is possible to take a 20MHz signal from another source, such as a counter timer or
%  external hardware.
%  
% Created
%  Timothy O'Connor 5/5/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function nimex_connectTerms(this, source, destination)

NIMEXEng_connectTerms(source, destination);

return;