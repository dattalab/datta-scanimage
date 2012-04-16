% stepFcn - Parameterizes this SIGNAL object as an arbitrarily complex step function.
%
% SYNTAX
%   stepFcn(SIGNAL, amplitudes, offset, onsetTimes)
%   stepFcn(SIGNAL, amplitudes, offset, onsetTimes, widths)
%       SIGNAL - The signal object.
%       offset - The initial offset (nominal value) of the entire signal's amplitude.
%       amplitudes - The amplitude at each step.
%       onsetTimes - The onset time of each step, inclusive.
%       widths - The width of each step, afterwhich the signal returns to the offset.
%                If widths are not specified, each step will persist until the next step.
%
% EXAMPLES
%  s = signalobject;
%  stepFcn(s, 1, [1, 2, 3], [1, 2, 3]);
%  figure; plot(s, 4);
%  stepFcn(s, 1, [1, 2, 3], [1, 2, 3], [0.5, 0.5, 0.5]);
%  figure; plot(s, 4);
%
% CHANGES
%  TO060108D - Name children. -- Tim O'Connor 6/1/08
%  TO101609A - Allow steps to be specified in non-increasing temporal order. -- Tim O'Connor 10/16/09
%
% Created: Timothy O'Connor 5/31/08
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function stepFcn(this, amplitudes, offset, onsetTimes, varargin)
global signalobjects;

if length(amplitudes) ~= length(onsetTimes)
    if length(amplitudes) == 1
        amplitudes = amplitudes * ones(size(onsetTimes));
    elseif length(onsetTimes) == 1
        onsetTimes = onsetTimes * ones(size(amplitudes));
    else
        error('The number of amplitudes and number of onsetTimes must match, or be scalar.');
    end
end
if isempty(varargin)
    widths = Inf;
else
    widths = varargin{1};
end

set(this, 'Type', 'stepFcn');
setDefaultsByType(this);

pointer = indexOf(this);
signalobjects(pointer).amplitude = amplitudes;
signalobjects(pointer).offset = offset;
signalobjects(pointer).stepFcnOnsetTimes = onsetTimes;
signalobjects(pointer).stepFcnWidths = widths;

% if length(amplitudes) == 1 && length(onsetTimes) == 1
%     if length(varargin) >= 1
%         if length(varargin{1}) == 1
%             squarePulseTrain(this, amplitudes(1), offset, onsetTimes(1), varargin{1}, 2 * onsetTimes(1), 1);
%         end
%     end
%     return;
% end
% 
% if length(varargin) >= 1
%     widths = varargin{1};
%     if length(widths) ~= length(amplitudes)
%         if length(widths) == 1
%             widths = widths * ones(size(amplitudes));
%         else
%             error('The number of widths must match the number of amplitudes and onsetTimes, or be scalar.');
%         end
%     end
% else
%     widths = abs(diff(onsetTimes));%TO101609A
% end
% 
% for i = 1 : length(amplitudes)
%     children(i) = signalobject('sampleRate', get(this, 'sampleRate'), 'Name', [get(this, 'Name') '_step' num2str(i)]);%TO060108D
%     if length(widths) >= i
%         squarePulseTrain(children(i), amplitudes(i), offset, onsetTimes(i), widths(i), 1, 1);
%     else
%         squarePulseTrain(children(i), amplitudes(i), offset, onsetTimes(i), Inf, 1, 1);
%     end
% end
% 
% set(this, 'deleteChildrenAutomatically', 1);
% recursive(this, 'add', children);

return;