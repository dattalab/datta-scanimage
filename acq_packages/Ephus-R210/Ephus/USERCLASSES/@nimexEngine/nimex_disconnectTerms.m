% @nimexEngine/nimex_disconnectTerms - Tear down an immediate route between device terminals.
%
% SYNTAX
%  nimex_disconnectTerms(eng, source, destination)
%   eng - @nimexEngine instance.
%   source - The NIDAQmx source terminal.
%            Example: '/dev1/20MhzTimebase'
%   destination - The NIDAQmx destination terminal.
%            Example: '/dev1/RTSI7'
%
% NOTES
%  Relies on NIMEXEng_disconnectTerms.mex32.
%
%  See nimexEngine/nimex_connectTerms for details on immediate signal routing.
%  
% Created
%  Timothy O'Connor 5/5/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function nimex_disconnectTerms(this, source, destination)

NIMEXEng_disconnectTerms(source, destination);

return;