function out = loadobj(this)
global globalDumbampObjects;

globalDumbampObjects(this.ptr) = this.serialized;
globalDumbampObjects(this.ptr).loadTime = clock;

return;