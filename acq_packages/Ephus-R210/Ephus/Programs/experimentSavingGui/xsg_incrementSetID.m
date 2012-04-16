% xsg_incrementSetID - Increment the setID.
%
% SYNTAX
%  xsg_incrementSetID
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO042106C: Increment the experiment number on rollover. Make case insensitive. -- Tim O'Connor 4/21/06
%
% Created 3/10/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function xsg_incrementSetID

setID = xsg_getSetID;

%TO042106C - For Windows, making it case-sensitive won't work. -- Tim O'Connor 4/21/06
% %There must be a cleverer way of doing this, I'm just not sure what it is at the moment... it's late.
% setID(4) = setID(4) + 1;
% if setID(4) > 'Z' & setID(4) < 'a'
%     setID(4) = 'a';
% elseif setID(4) > 'z'
%     setID(4) = 'A';
%     
%     setID(3) = setID(3) + 1;
%     if setID(3) > 'Z' & setID(3) < 'a'
%         setID(3) = 'a';
%     elseif setID(3) > 'z'
%         setID(3) = 'A';
%         
%         setID(2) = setID(2) + 1;
%         if setID(2) > 'Z' & setID(2) < 'a'
%             setID(2) = 'a';
%         elseif setID(2) > 'z'
%             setID(2) = 'A';
%             
%             setID(1) = setID(1) + 1;
%             if setID(1) > 'Z' & setID(1) < 'a'
%                 setID(1) = 'a';
%             elseif setID(1) > 'z'
%                 setID(1) = 'A';
%             end
%         end
%     end
% end

%TO042106C
%There must be a cleverer way of doing this, I'm just not sure what it is at the moment... it's late.
setID(4) = setID(4) + 1;
switch setID(4)
    case 'Z' + 1
        setID(4) = 'A';
        setID(3) = setID(3) + 1;
        
    case 'z' + 1
        setID(4) = 'a';
        setID(3) = setID(3) + 1;
end
switch setID(3)
    case 'Z' + 1
        setID(3) = 'A';
        setID(2) = setID(2) + 1;
        
    case 'z' + 1
        setID(3) = 'a';
        setID(2) = setID(2) + 1;
end
switch setID(2)
    case 'Z' + 1
        setID(2) = 'A';
        setID(1) = setID(1) + 1;
        
    case 'z' + 1
        setID(2) = 'a';
        setID(1) = setID(1) + 1;
end
switch setID(1)
    case 'Z' + 1
        setID(1) = 'A';
        
    case 'z' + 1
        setID(1) = 'a';
end

xsg_setSetID(setID);

%Check for complete rollover.
if strcmpi(setID, 'AAAA')
    xsg_incrementExperimentNumber;%TO042106C
end

return;