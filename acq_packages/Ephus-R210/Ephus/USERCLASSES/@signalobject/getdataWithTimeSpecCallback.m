% SIGNAL/getdataWithTimeSpecCallback - Retrieve a raw numeric array of SIGNAL data, using a dynamically specified time.
%
% SYNTAX
%  data = getdataWithTimeSpecCallback(SIGNAL, callback) - Gets with a dynamically specified total time.
%
% NOTES
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%
% Created 8/1/07 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2007
function data = getdataWithTimeSpecCallback(this, callback)

data = getdata(this, feval(callback{:}));

return;