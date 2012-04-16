% @nimexEngine/nimexEngine - Returns an instance of the singleton nimexEngine.
%
% SYNTAX
%  eng = nimexEngine
%   eng - @nimexEngine instance.
%
% NOTES
%  This class is essentially a hollow proxy, to allow for an object oriented wrapper to non-task based calls to Nimex.
%  
% Created
%  Timothy O'Connor 5/5/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function this = nimexEngine

%No fields or properties are necessary.
this.ptr = 1;

this = class(this, 'nimexEngine');

return;