%Collect some of the pointer-system data related to this object into a command-line accessible struct.
function mem = memoryDebug(this)
global signalobjects

mem.ptr = this.ptr;
mem.pointer = indexOf(this);
mem.map = signalobjects(1).signal;

return;