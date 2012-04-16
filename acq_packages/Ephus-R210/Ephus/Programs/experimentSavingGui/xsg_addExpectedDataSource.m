% xsg_addExpectedDataSource - Add a program to the list of expected data sources, to ensure the saving of that program's data.
%
% SYNTAX
%  xsg_addExpectedDataSource
%
% USAGE
%
% NOTES
%
% CHANGES
%  TO012706B: DEPRECATED - See @startmanager/addExpectedDataSource and @startmanager/addExpectedDataSink -- Tim O'Connor 1/27/06
%
% Created 1/26/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function xsg_addExpectedDataSource(sourceName)

error('DEPRECATED - See @startmanager/addExpectedDataSource and @startmanager/addExpectedDataSink');

hObject = xsg_getHandle;

expectedDataSourceList = getLocal(progmanager, hObject, 'expectedDataSourceList');
expectedDataSourceList{end + 1} = lower(sourceName);
setLocal(progmanager, hObject, 'expectedDataSourceList', expectedDataSourceList);

return;