% mapper_enablePockelsCell - Enables Pockels cell (or other analog power control) features.
%
% SYNTAX
%  mapper_enablePockelsCell
%
% USAGE
%
% NOTES
%  This is a copy & paste job from genericStartFcn in mapper.m.
%
% CHANGES
%
% SEE ALSO
%  TO021510E
%
% Created 2/16/10 Tim O'Connor
% Copyright - Northwestern University/Howard Hughes Medical Institute 2010
function mapper_enablePockelsCell

hObject = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');

setLocal(progmanager, hObject, 'noPockelsCell', 0);

%Could handle Pockels found/not-found cases here more explicitly (VI060108)
try
    mapper('calibratePockels_Callback', hObject, [], []);
catch
    fprintf(2, '%s - mapper: Failed to calibrate Pockels cell. - ''%s''\n', datestr(now), lasterr);
end

%Register output channel preprocessors
acqJob = daqjob('acquisition');
nimex_registerOutputDataPreprocessor(getTaskByChannelName(acqJob, 'pockelsCell'), getDeviceNameByChannelName(acqJob, 'pockelsCell'), ...
    {@mapper_pockelsCellPreprocessor, mapper}, 'pockelsCell', 5);

setLocalGh(progmanager, hObject, 'calibratePockels', 'Enable', 'On');

return;
