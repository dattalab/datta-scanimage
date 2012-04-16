% @nimex/nimex_sendTrigger - Send a digital output trigger signal.
%
% SYNTAX
%  nimex_sendTrigger(nimextask)
%  nimex_sendTrigger(nimextask, deviceID)
%   nimextask - An instance of the nimex class.
%   deviceID - A string identifying the digital line(s) to use.
%              If not specified, the default is '/dev1/port0/line0:7'.
%
% NOTES
%  Relies on NIMEX_sendTrigger.mex32.
%  See TO120806B.
%  
% Created
%  Timothy O'Connor 12/8/06
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function nimex_sendTrigger(this, varargin)

if isempty(varargin)
    deviceID = '/dev1/port0/line0:7';
else
    deviceID = varargin{1};
end

NIMEX_sendTrigger(this.NIMEX_TaskDefinition, deviceID);

% fprintf(1, 'nimex_sendTrigger: this.NIMEX_TaskDefinition = %s\n', num2str(this.NIMEX_TaskDefinition));

return;