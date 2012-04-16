% @nimexEngine/nimex_tristateOutputTerm - Sets an output terminal to high impedance mode.
%
% SYNTAX
%  nimex_tristateOutputTerm(eng, terminalName)
%   eng - @nimexEngine instance.
%   terminalName - The NIDAQmx terminal.
%            Examples: '/dev1/DIO0' or '/dev1/PFI0' or '/dev1/ai/StartTrigger'
%
% NOTES
%  Relies on NIMEXEng_tristateOutputTerm.mex32.
%  
% Created
%  Timothy O'Connor 5/5/08
%  
% Copyright
%  Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function nimex_tristateOutputTerm(this, terminalName)

NIMEXEng_tristateOutputTerm(terminalName);

return;