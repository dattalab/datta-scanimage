function [header,data] = xsg_openXSG(xsgFileName)
%XSG_OPENXSG Extracts header/data from an XSG file
%% USAGE
%   [header,data] = xsg_openXSG(xsgFileName)
%       xsgFileName: valid XSG filename
%       header, data: header and data associated with an XSG file 
%% NOTES
%   This function facilitates header/data extraction from an XSG file
%
%% CREDITS
%   Created 5/30/08 -- Vijay Iyer
%   Janelia Farm Research Campus, Howard Hughes Medical Institute
%% ****************************************************************

if nargin < 1
    try
        currentDirectory = getGlobal(progmanager,'directory','xsg','xsg');
    catch 
        currentDirectory = pwd;
    end
    
    [f,p] = uigetfile('.xsg', 'Select XSG file to read', currentDirectory);    
    
    if isnumeric(f) %User cancelled
        return;
    end
    xsgFileName = fullfile(p,f);       
end

[p,f,e] = fileparts(xsgFileName);
if isempty(e)
    xsgFileName = [xsgFileName '.xsg'];
end

errorMsg = 'A valid XSG filename must be specified as input argument, if provided';
if ~exist(xsgFileName,'file')
    error(errorMsg);
else
    try 
        xsgStruct = load('-mat',xsgFileName);
    catch
        error(errorMsg);
    end
end       

if nargout == 1
    header = xsgStruct.header;
else
    header = xsgStruct.header;
    data = xsgStruct.data;
end


