%Register (or unregister) a Matlab callback function to be invoked upon camera device events (as reported by the device driver)
%% function registerEventCallback(obj,callbackFcn)
%   callbackFcn: (OPTIONAL) A function handle to a callback function which will be invoked when the Andor camera driver generates events.
%                           If empty/omitted, any previously registered function is unregistered. 
%
% NOTES
%   See 'SetDriverEvent' in the SDK documentation for information on the device events for which the SDK will generate this software event.
%
%   The registerEventCallback() method is a high-level Matlab function replacing (and utilizing) the SetDriverEvent Andor SDK function, which cannot be directly wrapped into Matlab.
%
%   The function handle supplied to registerEventCallback() must take two arguments, corresponding to the source object and event structure. This is the normal convention for Matlab callback functions.
%   To replace a previously registered callback, simply supply a new one. Any previously registed callback will be unregistered. 
%   
