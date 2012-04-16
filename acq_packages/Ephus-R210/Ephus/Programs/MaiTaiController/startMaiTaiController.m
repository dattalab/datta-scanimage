% startMaiTaiController
% 
% A basic GUI for issuing serial commands to a Spectra-Physics Mai-Tai laser system.
%
% Created: Tim O'Connor 3/1/04
% Copyright: Cold Spring Harbor Laboratories/Howard Hughes Medical Institute
function startMaiTaiController

openprogram(progmanager, program('MaiTaiController', 'maiTaiController'));
% global maiTaiControllerStruct gh;
%
% %Look for a default ini file.
% if nargin == 0 | isempty(iniFile)
%     iniFile = 'maiTaiController.ini';
% end
% 
% %No ini file means this can't work.
% if exist(iniFile) ~= 2
%     errMsg = sprintf('No ini file found with name: ''%s''', iniFile);
%     error(errMsg);
% end
% 
% gh.miniExporter = guidata(feval('maiTaiController'));
% 
% %Load variables from the ini file and link them to the GUI.
% initGUIs(iniFile);
% 
% %Set up the serial port.
% %See the Spectra-Physics MaiTai interface documentation for details.
% maiTaiControllerStruct.serial = serial(maiTaiControllerStruct.port, 'BaudRate', 9600, 'Parity', 'none', 'StopBits', 1, 'DataBits', 8, 'Terminator', {10, 10});