function odorTrig(num,delay,length)
global progmanagerglobal;

pause(delay);
for i=1:num
    OlfactoTrig('advanceOdor_Callback',progmanagerglobal.programs.OlfactoTrig.OlfactoTrig.guihandles.advanceOdor,[],[]);
end
pause(length);
    OlfactoTrig('resetOdor_Callback',progmanagerglobal.programs.OlfactoTrig.OlfactoTrig.guihandles.resetOdor,[],[]);

end