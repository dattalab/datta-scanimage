% SCOPEOBJECT/private/scopeObjectResizeFcn - A callback for resizing of the scope figure.
%
% SYNTAX
%  scopeObjectResizeFcn(hObject, eventdata, scopeObjectInstance)
%  See Matlab's documentation on GUI callbacks.
%
% USAGE
%  This function will update the window, so that visibility/clarity is
%  maximized as the size crosses various thresholds.
%
% NOTES
%  The threshold(s) may take some tweaking, after continued use, to see
%  what "feels" right.
%
% CHANGES
%  JL080707 Disabled the function to hide menubar
%  TO032106C: Fixed so that axes return. -- Tim O'Connor 3/21/06
%
% Created 7/8/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function scopeObjectResizeFcn(hObject, eventdata, this)

gridSmall = 0;
pureSmall = 0;
menuSmall = 0;
pos = get(hObject, 'Position');

switch lower(get(hObject, 'Units'))
    case 'pixels'
        if pos(3) < 360 | pos(4) < 360
            gridSmall = 1;
        else
            gridSmall = 0;
        end
        if pos(3) < 435 | pos(4) < 200
            pureSmall = 1;
        else
            pureSmall = 0;
        end
        if pos(3) < 350 | pos(4) < 105
            menuSmall = 0;  % JL080707Set this to 0 because when hide the menubar and then show it again, only builtin menubar appear.
        else
            menuSmall = 0; 
        end
        
    otherwise
        smallWindow = 0;
end

    declaredGridOn = get(this, 'declaredGridOn');
if ~gridSmall
    if declaredGridOn
        set(this, 'gridOn', 1);
        set(this, 'declaredGridOn', declaredGridOn);
    end
else
    set(this, 'gridOn', declaredGridOn);
end

if pureSmall
    declaredPureDisplay = get(this, 'declaredPureDisplay');
    if ~declaredPureDisplay
        set(this, 'pureDisplay', 1);
        set(this, 'declaredPureDisplay', declaredPureDisplay);
    end
else
    set(this, 'pureDisplay', get(this, 'declaredPureDisplay'));
end

if menuSmall
    set(hObject, 'MenuBar', 'None');
else
    set(hObject, 'MenuBar', 'Figure');
end

return;