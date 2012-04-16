%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
function same = eq(amp1, amp2)

same = logical(0);
if ~strcmpi(class(amp2), 'multi_clamp')
    return;
end

same = (amp1.AMPLIFIER == amp2.AMPLIFIER);%TO122205A

return;