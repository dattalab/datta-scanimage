function out = saveobj(this)
global globalDumbampObjects;

globalDumbampObjects(this.ptr).saveTime = clock;
this.serialized = globalDumbampObjects(this.ptr);

return;