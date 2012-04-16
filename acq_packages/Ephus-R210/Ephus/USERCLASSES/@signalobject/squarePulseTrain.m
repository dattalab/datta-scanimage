% squarePulseTrain(SIGNAL, amplitude, offset, delay, width, isi) - Parameterizes this SIGNAL object as train of square pulses.
% squarePulseTrain(SIGNAL, amplitude, offset, delay, width, isi, number)
%
% SYNTAX
%   squarePulseTrain(SIGNAL, amplitude, offset, delay, width, isi)
%   squarePulseTrain(SIGNAL, amplitude, offset, delay, width, isi, number)
%       SIGNAL - The signal object.
%       amplitude - The amplitude (in arbitrary units) of this signal.
%       offset - The offset (in amplitude space) of this signal, relative to the origin.
%       delay - The offset (in time space) of this signal, relative to the origin.
%       width - The width (duration) of the pulse.
%       isi - The spacing, in time, of subsequent pulses.
%       number - The total number of pulses, if this is unspecified or less than 0 it is set to 1.
%
% CHANGES:
%   Tim O'Connor 2/3/05 TO020305b: Added optional parameter, repetitions, to set a fixed number of pulses.
%   Tim O'Connor 5/2/05 TO050205A: Implemented a squarePulseTrain type for optimization.
%   Tim O'Connor 8/11/05 TO081105B: Fixed multiple improper uses of this.ptr instead of pointer.
%
% Created: Timothy O'Connor 11/03/04 
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function squarePulseTrain(this, amplitude, offset, delay, width, isi, varargin)
global signalobjects;

if delay < 0
    error('Negative phase shifts (delay) are not allowed: %s', num2str(delay));
elseif width < 0
    error('Negative widths are not allowed: %s', num2str(width));
elseif isi < 0
    error('Negative isis are not allowed: %s', num2str(isi));
end

if isempty(varargin)
    number = 1;
elseif isnumeric(varargin{1})    
    number = varargin{1};
    if number < 0
        warning('Negative number will be interpreted as 1: %s', num2str(number));
    end
else
    error('number must be specified by a number: ''%s''', class(varargin{1}));
end

pointer = indexOf(this);

if signalobjects(pointer).deleteChildrenAutomatically
    delete(signalobjects(pointer).children);
end
signalobjects(pointer).children = [];    

set(this, 'Type', 'squarePulseTrain');
setDefaultsByType(this);

%TO081105B
signalobjects(pointer).squarePulseTrainNumber = number;
signalobjects(pointer).squarePulseTrainISI = isi;
signalobjects(pointer).squarePulseTrainWidth = width;
signalobjects(pointer).amplitude = amplitude;
signalobjects(pointer).offset = offset;
signalobjects(pointer).squarePulseTrainDelay = delay;

% f = figure;
% a = gca;
% plot(this, a, 4 * width);
return;