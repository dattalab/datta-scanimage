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
%  BSTO060910A - Allow non-numeric values in the experiment number, without choking this function. -- Ben Suter/Tim O'Connor 6/9/10
%
% Created 4/7/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function xsg_incrementExperimentNumber

expNumber = str2num(xsg_getExperimentNumber) + 1;
if isempty(expNumber) %BSTO060910A
    return;
end

if expNumber > 9999
    expNumber = 0;
end

xsg_setExperimentNumber(expNumber);

return;