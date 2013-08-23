function out = valvenum2hexstr(valveNum)  % can be a numbers, 1-16
switch(valveNum)
    case {1,2,3,4,5,6,7,8,9,10}
        out = num2str(valveNum - 1);
    case 11
        out = 'a';
    case 12
        out = 'b';
    case 13
        out = 'c';
    case 14
        out = 'd';
    case 15
        out = 'e';
    case 16
        out = 'f';
end
end