%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%   TO081696H - Switched case convention. See TO122205A. -- Tim O'Connor 8/16/06
function same = eq(amp1, amp2)

same = logical(0);
if ~strcmpi(class(amp2), 'amplifier')
    return;
end

if ~strcmpi(class(amp1), 'amplifier')
    obj = struct(amp1);
    amp1 = obj.amplifier;%TO122205A %TO081696H
end

if ~strcmpi(class(amp2), 'amplifier')
    obj = struct(amp2);
    amp1 = obj.amplifier;%TO122205A %TO081696H
end

same = (amp1.ptr == amp2.ptr);

return;