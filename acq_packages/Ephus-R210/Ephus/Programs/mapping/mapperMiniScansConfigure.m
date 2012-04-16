% mapperMiniScansConfigure - Enable and configure miniScans during turbo maps.
%
% SYNTAX
%  mapperMiniScanConfig = mapperMiniScansConfigure
%  mapperMiniScansConfigure(enable)
%  mapperMiniScanConfig = mapperMiniScansConfigure(enable)
%  mapperMiniScansConfigure(enable, wobbleAmplitude, wobbleFrequency)
%  mapperMiniScanConfig = mapperMiniScansConfigure(enable, wobbleAmplitude, wobbleFrequency)
%   mapperMiniScanConfig - A structure describing the current miniScan state.
%                          Fields: enable, wobbleAmplitude, wobbleFrequency
%   enable          - Non-zero values enable this functionality, zero values disable it.
%   wobbleAmplitude - Amplitude of modulation, in microns.
%                     Default: 50 um
%   wobbleFrequency - Frequency of oscillation, in Hz.
%                     Default: 1000 Hz.
%
% USAGE
%  This will tell the mapper to modify the mirror position signals to oscillate around each point.
%
% NOTES
%
% CHANGES
%
% SEE ALSO
%  mapper.m @ TO052207A
%
% Created 5/22/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function varargout = mapperMiniScansConfigure(varargin)

mapperMiniScanSettings = getGlobal(progmanager, 'mapperMiniScanSettings', 'mapper', 'mapper');

if isempty(mapperMiniScanSettings)
    mapperMiniScanSettings.enable = 0;
    mapperMiniScanSettings.wobbleAmplitude = 50;
    mapperMiniScanSettings.wobbleFrequency = 1000;
end

if length(varargin) == 1
    mapperMiniScanSettings.enable = varargin{1};
elseif length(varargin) == 2
    mapperMiniScanSettings.wobbleAmplitude = varargin{1};
    mapperMiniScanSettings.wobbleFrequency = varargin{2};
elseif length(varargin) == 3
    mapperMiniScanSettings.enable = varargin{1};
    mapperMiniScanSettings.wobbleAmplitude = varargin{2};
    mapperMiniScanSettings.wobbleFrequency = varargin{3};
end

if nargout == 1
    varargout{1} = mapperMiniScanSettings;
end

setGlobal(progmanager, 'mapperMiniScanSettings', 'mapper', 'mapper', mapperMiniScanSettings);

return;