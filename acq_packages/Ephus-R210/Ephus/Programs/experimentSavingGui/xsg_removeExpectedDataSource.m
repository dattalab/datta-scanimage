% xsg_removeExpectedDataSource - Remove a program to the list of expected data sources.
%
% SYNTAX
%  xsg_removeExpectedDataSource
%
% USAGE
%
% NOTES
%  This is meant to be employed when a program has finished acquiring all data or has aborted acquisition of data.
%
% CHANGES
%  TO012706B: DEPRECATED - See @startmanager/addExpectedDataSource and @startmanager/addExpectedDataSink -- Tim O'Connor 1/27/06
%
% Created 1/26/06 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function xsg_removeExpectedDataSource(sourceName)

error('DEPRECATED - See @startmanager/removeExpectedDataSource and @startmanager/removeExpectedDataSink');

hObject = xsg_getHandle;

expectedDataSourceList = getLocal(progmanager, hObject, 'expectedDataSourceList');
index = find(strcmp(lower(sourceName), expectedDataSourceList));
if ~isempty(index)
    if length(expectedDataSourceList) == 0
        expectedDataSourceList = {};
    else
        expectedDataSourceList = cat(2, expectedDataSourceList(1:index-1), expectedDataSourceList(index+1:end));
    end
end
setLocal(progmanager, hObject, expectedDataSourceList);

return;