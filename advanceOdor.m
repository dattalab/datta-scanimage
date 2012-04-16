function advanceOdor(num)
global progmanagerglobal;
if nargin<1
    num=1;
end

for i=1:num
    OlfactoTrig('advanceOdor_Callback',progmanagerglobal.programs.OlfactoTrig.OlfactoTrig.guihandles.advanceOdor,[],[]);
end
end