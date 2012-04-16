% mapper_startCircularScanner - Start the lsps2pCircular module to run with the mapper and no ScanImage.
%
% SYNTAX
%  mapper_startCircularScanner
%
% USAGE
%
% NOTES
%  Spoofs ScanImage's existence, and starts the lsps2pCircular program.
%
% CHANGES
%
% SEE ALSO
%
% Created 5/21/07 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function mapper_startCircularScanner
global state;

state.init.mirrorOutputBoardIndex = 1;
state.init.eom.pockelsBoardIndex2 = 2;
state.init.eom.pockelsChannelIndex2 = 0;
state.init.eom.lut = zeros(2, 100);
%See mapper_pockelsCellPreProcessor for how to do this properly.
coeffs = getGlobal(progmanager, 'coeffs', 'mapper', 'mapper');
if isempty(coeffs)
    preprocessed = zeros(size(data));
    warning('Pockels cell appears to be uncalibrated.');
    return;
end
data = (1:100)';
basis = cat(2, ones(size(data)), data, data.^2, data.^3);
data = basis * coeffs;
state.init.eom.lut(2, 1:100) = data;
state.init.eom.powerConversion2 = 1;
state.init.eom.maxPhotodiodeVoltage = [1 1];
state.acq.scanAmplitudeX = 2;
state.acq.zoomFactor = 1;
state.acq.scanAmplitudeY = 2;
state.acq.scanOffsetX = 0;
state.acq.scanOffsetY = 0;
state.acq.scanRotation = 0;
state.init.pockelsOn = 1;

startCircularScanner;