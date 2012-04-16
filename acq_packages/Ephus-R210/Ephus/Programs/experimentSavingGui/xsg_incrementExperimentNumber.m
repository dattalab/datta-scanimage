% xsg_incrementExperimentNumber - Increment the experiment number.
%
% SYNTAX
%  xsg_incrementExperimentNumber
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO061010A - Do nothing when the value is not a valid number. -- Tim O'Connor 6/10/10
%
% Created 4/21/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function xsg_incrementExperimentNumber

expNumber = str2num(xsg_getExperimentNumber);
%TO061010A
if isempty(expNumber)
    expNumber = 0;
else
    expNumber = expNumber + 1;
end
if expNumber > 9999
    expNumber = 0;
end

xsg_setExperimentNumber(expNumber);

return;