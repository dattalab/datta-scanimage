% aod/connect - Open and initialize the com port(s), replacing current ones, if necessary.
%
% SYNTAX
%  connect(aod_instance)
%   aod_instance - The instance of the @aod object to be (re)connected.
%
% Created 3/16/06 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function connect(this)
global isometAodObjects;

if ~isempty(isometAodObjects(this.ptr).horizontalSerialObj)
    if ~strcmpi(get(isometAodObjects(this.ptr).horizontalSerialObj, 'Port'), isometAodObjects(this.ptr).horizontalComPort)
        try
            fclose(isometAodObjects(this.ptr).horizontalSerialObj);
        catch
            warning('Failed to properly close serial port for the horizontal axis: %s', lasterr);
        end

        try
            delete(isometAodObjects(this.ptr).horizontalSerialObj);
        catch
            warning('Failed to delete serial port for the horizontal axis: %s', lasterr);
            isometAodObjects(this.ptr).horizontalSerialObj = [];
        end
    end
end

if ~isempty(isometAodObjects(this.ptr).horizontalSerialObj)
    try
        isometAodObjects(this.ptr).horizontalSerialObj = serial(isometAodObjects(this.ptr).horizontalComPort, ...
            'Name', [isometAodObjects(this.ptr).name '-horizontal'], 'Tag', [isometAodObjects(this.ptr).name '-horizontal']);
    catch
        warning('Failed to initialize horizontal axis com port ''%s'' for aod ''%s'': %s', isometAodObjects(this.ptr).horizontalComPort, ...
            isometAodObjects(this.ptr).name, lasterr);
        isometAodObjects(this.ptr).horizontalSerialObj = [];
    end
end


if ~isempty(isometAodObjects(this.ptr).verticalSerialObj)
    if ~strcmpi(get(isometAodObjects(this.ptr).verticalSerialObj, 'Port'), isometAodObjects(this.ptr).verticalComPort)
        try
            fclose(isometAodObjects(this.ptr).verticalSerialObj);
        catch
            warning('Failed to properly close serial port for the vertical axis: %s', lasterr);
        end

        try
            delete(isometAodObjects(this.ptr).verticalSerialObj);
        catch
            warning('Failed to delete serial port for the vertical axis: %s', lasterr);
            isometAodObjects(this.ptr).verticalSerialObj = [];
        end
    end
end

if ~isempty(isometAodObjects(this.ptr).verticalSerialObj)
    try
        isometAodObjects(this.ptr).verticalSerialObj = serial(isometAodObjects(this.ptr).verticalComPort, ...
            'Name', [isometAodObjects(this.ptr).name '-vertical'], 'Tag', [isometAodObjects(this.ptr).name '-vertical']);
    catch
        warning('Failed to initialize vertical axis com port ''%s'' for aod ''%s'': %s', isometAodObjects(this.ptr).verticalComPort, ...
            isometAodObjects(this.ptr).name, lasterr);
        isometAodObjects(this.ptr).verticalSerialObj = [];
    end
end

return;