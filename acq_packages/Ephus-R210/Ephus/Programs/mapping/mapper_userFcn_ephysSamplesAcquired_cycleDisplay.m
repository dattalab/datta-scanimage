% mapper_userFcn_ephysSamplesAcquired_cycleDisplay - Used to implement online display of map data during a cycle of maps.
%
% SYNTAX
%  mapper_userFcn_ephysSamplesAcquired_cycleDisplay(data)
%   data - The entire block of acquired chunk of data (a single trace).
%
% USAGE
%  Bind this function to the ephys:SamplesAcquired event.
%
% NOTES
%  This tricks mapper_userFcn_ephysSamplesAcquired_display into thinking it's processing a real map online.
%
% CHANGES
%
% Created 6/2/08 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008
function mapper_userFcn_ephysSamplesAcquired_cycleDisplay(data, bufferName)
global mapper_userFcn_display;

mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');
[sampleRate, isi, mapPatternArray] = getLocalBatch(progmanager, mapperObj, 'sampleRate', 'isi', 'mapPatternArray');
samplesPerTrace = ceil(sampleRate * isi);
setLocal(progmanager, mapperObj, 'map', 1);
try
    mapper_userFcn_mapStart_display;
    try
        for i = 0 : length(mapPatternArray) - 1
            mapper_userFcn_display.position = i + 1;
            mapper_userFcn_display.traceNumber = i + 1;
            mapper_userFcn_ephysSamplesAcquired_display(data(i * samplesPerTrace + 1 : min((i + 1) * samplesPerTrace, length(data))), bufferName);
        end
    catch
        fprintf(2, 'mapper_userFcn_ephysSamplesAcquired_cycleDisplay failed to pass user analysis to mapper_userFcn_ephysSamplesAcquired_display.\n%s', getLastErrorStack);
    end
    mapper_userFcn_display.position = 0;
    mapper_userFcn_display.traceNumber = 0;
    mapper_userFcn_mapStop_display;
catch
    fprintf(2, 'mapper_userFcn_ephysSamplesAcquired_cycleDisplay failed to analyze data.\n%s', getLastErrorStack);
end
setLocal(progmanager, mapperObj, 'map', 0);

return;