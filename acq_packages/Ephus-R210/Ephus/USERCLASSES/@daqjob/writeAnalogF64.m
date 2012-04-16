% @daqjob/writeAnalogF64 - Write analog data to specified (analog output) channel
%
% SYNTAX
%   written = writeAnalogF64(this,channelName,data)
%   written = writeAnalogF64(this,channelName,data,timeout)
%     this - a @daqjob object
%     channelName - a channel belong to 'this' @daqjob
%     data - vector of doubles specifying data to be written
%     timeout - A time, in seconds, after which to give up
%     written - the number of samples actually written
%
% NOTES
%   This calls through to the underlying nimex_writeAnalogF64() method
%   
%   Should consider supporting a multi-channel, matrix input, version?
%
% CHANGES
%  TO072208C - This apparently wasn't tested at all, since it never assigned its return argument. Also, the error handling should tell which @dajob (the name). -- Tim O'Connor 7/22/08
%  TO073008A - Implemented pseudochannels. -- Tim O'Connor 7/30/08
%
% Created
%  Vijay Iyer ??/??/08
%
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute/Janelia Farm Research Center 2008
function written = writeAnalogF64(this, channelName, data, varargin)
global daqjobGlobalStructure;

task = getTaskByChannelName(this, channelName);

if isempty(task)
    error('Channel ''%s'' not found for this @daqjob (''%s'').', channelName, daqjobGlobalStructure(this.ptr).name);
end

if ~isnumeric(data) || ~isvector(data)
    error('Second argument must be a numeric vector.');
end

written = nimex_writeAnalogF64(task, getDeviceNameByChannelName(this, channelName), data, length(data), varargin{:});%TO072208C

return;




    
    

