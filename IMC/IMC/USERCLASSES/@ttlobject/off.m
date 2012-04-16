% ttlObject/off - Immediately output an "off" signal for this ttlObject.
%
% SYNTAX
%
% USAGE
%
% STRUCTURE
%
% NOTES
%
% CHANGES
%
% Created 8/4/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function off(this)
global ttlObjects;

if ttlObjects(this.pointer).type == 0
    dio = digitalio('nidaq', ttlObjects(this.ptr).boardID);
    addline(dio, ttlObjects(this.ptr).channelID);
    if ttlObjects(this.ptr).offValue < ttlObjects(this.ptr).onValue
        putvalue(dio, 0);
    else
        putvalue(dio, 1);
    end
    delete(dio);
elseif ttlObjects(this.pointer).type == 1
    ao = analogoutput('nidaq', ttlObjects(this.ptr).boardID);
    addchannel(ao, ttlObjects(this.ptr).channelID);
    if ttlObjects(this.ptr).offValue < ttlObjects(this.ptr).onValue
        putsample(dio, 0);
    else
        putsample(dio, 5);
    end
    delete(ao);
end

return;