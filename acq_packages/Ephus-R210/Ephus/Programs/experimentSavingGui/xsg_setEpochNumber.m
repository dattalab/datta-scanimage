% xsg_setEpochNumber - Set the epoch number.
%
% SYNTAX
%  xsg_setEpochNumber(epoch)
%  xsg_setEpochNumber(hObject, epoch)
%   epoch - Any integer from 0 to 9999.
%
% USAGE
%
% NOTES
%
% CHANGES
%
% Created 8/29/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function xsg_setEpochNumber(varargin)

if length(varargin) == 1
    hObject = xsg_getHandle;
    epoch = varargin{1};
else
    hObject = varargin{1};
    epoch = varargin{2};
end

if isnumeric(epoch)
    epoch = num2str(epoch);
end

% if length(epoch) > 4
%     epoch = epoch(1:4);
% elseif length(epoch) == 1
%     epoch = ['000' epoch];
% elseif length(epoch) == 2
%     epoch = ['00' epoch];
% elseif length(epoch) == 3
%     epoch = ['0' epoch];
% end

% for i = 1 : length(epoch)
%     if isempty(str2num(epoch(i)))
%         epoch(i) = '0';
%     end
% end

setLocal(progmanager, hObject, 'epoch', epoch);
% autonotes_addNote([sprintf('\n\t') '    EPOCH: ' epoch]);
autonotes_addNote(['EPOCH: ' epoch]);

return;