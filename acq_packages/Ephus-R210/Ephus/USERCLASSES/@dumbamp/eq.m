function same = eq(amp1, amp2)

same = logical(0);
if ~strcmpi(class(amp2), 'dumbamp')
    return;
end

same = (amp1.AMPLIFIER == amp2.AMPLIFIER);%TO122205A

return;