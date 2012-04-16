% SIGNAL/indexOf - Returns the global index associated with this pointer.
%
% CHANGES
%  TO062806N: Force stack trace to appear in error message(s). -- Tim O'Connor 6/28/06
%
% Created 10/25/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function pointer = indexOf(this)
global signalobjects;

if isempty(signalobjects)
    signalobjects(1).name = 'Master';
    signalobjects(1).signal = [];
end

if this.ptr < 2
    error('Invalid @signal object pointer: %s', num2str(this.ptr));
end

if isempty(signalobjects(1).signal)
    error('No @signal memory mapping defined.');
end

pointer = signalobjects(1).signal(find(signalobjects(1).signal(:, 1) == this.ptr), 2);

if isempty(pointer)
%    signalMap = signalobjects(1).signal
    error('Invalid @signal object pointer: %s\n', num2str(this.ptr), getStackTraceString);%TO062806N
elseif length(pointer) > 1
%    signalMap = signalobjects(1).signal
    error('Ambiguous @signal object pointer: %s --> %s\n%s', num2str(this.ptr), mat2str(pointer), getStackTraceString);%TO062806N
elseif pointer == -1
    error('Missing dereferenced value. This object may have been deleted. Pointer: %s  -- Map: %s\n%s', num2str(this.ptr), ...
        mat2str(signalobjects(1).signal), getStackTraceString);%TO062806N
end

return;