% signalobject/plot - Generate a plot of this signal.
%
% SYNTAX
%   plot(SIGNAL)
%   plot(SIGNAL, axesHandle, time)
%   plot(SIGNAL, time)
%   p = plot(...)
%    SIGNAL - The @signalobject instance to be plotted.
%    axesHandle - A destination axes for the plot.
%    time - The seconds of data, from 0, to plot.
%    p - The handle to the newly generated plot.
%
% CHANGES
%  TO080905A: Make the plot use markers. This was previously removed by request, but it really can help reduce confusion, so I'm putting it back. -- Tim O'Connor 8/9/05
%  TO080905H: Added a title and axis labels. -- Tim O'Connor 8/9/05
%  TO121605B: Make sure the title, xlabel, and ylabel are all children of the specified axes. -- Tim O'Connor 12/16/05
%  TO121605C: Fixed the argument handling. Added the plot(SIGNAL, time) form. -- Tim O'Connor 12/16/05
%  TO053008C: Corrected handling of arguments when only the object is provided. -- Tim O'Connor 5/30/08
%
% Created: Timothy O'Connor 5/2/05
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function varargout = plot(this, varargin)
global signalobjects;

ax = [];
time = -1;

%TO121605C
if length(varargin) == 1
    time = varargin{1};
elseif length(varargin) == 2
    ax = varargin{1};
    time = varargin{2};
end

pointer = indexOf(this);

if time < 0
   if signalobjects(pointer).length < 0
       error('No length was specified, to generate a plot of signal data.');
   elseif signalobjects(pointer).length == 0
       error('No signal may be plotted for a time length of 0.');
   else
       time = signalobjects(pointer).length;
   end
end

if isempty(ax)
    f = figure;
    ax = gca;
end

data = getdata(this, time);
domain = (1 : length(data)) / signalobjects(pointer).sampleRate;
p = plot(domain, data', 'Parent', ax, 'Marker', 'o');

title(['@signalobject: ''' signalobjects(pointer).name ''''], 'Parent', ax);%TO121605B
ylabel('Amplitude [arbitrary]', 'Parent', ax);%TO121605B
xlabel('Time [s]', 'Parent', ax);%TO121605B

if nargout == 1
    varargout{1} = p;
end

return;