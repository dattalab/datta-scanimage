function out = valve2hex(valveString)  % can be a string of chars, 0-f
switch(valveString)
    case {'1','2','3','4','5','6','7','8','9','10'}
        out = num2str(str2num(valveString) - 1);
    case '11'
        out = 'a';
    case '12'
        out = 'b';
    case '13'
        out = 'c';
    case '14'
        out = 'd';
    case '15'
        out = 'e';
    case '16'
        out = 'f';
end
end
