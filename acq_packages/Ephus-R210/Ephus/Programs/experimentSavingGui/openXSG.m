function [header,data] = openXSG(xsgFileName)
%OPENXSG Convenience function for opening XSG files in Matlab
%% USAGE
%   openXSG(xsgFileName)
%       xsgFileName: valid XSG filename
%% NOTES
%   This function returns nothing...it saves extracted header/data to base workspace vars
%
%% CHANGES
%% CREDITS
%   Created 6/12/08 -- Vijay Iyer
%   Janelia Farm Research Campus, Howard Hughes Medical Institute
%% ****************************************************************

[header,data] = xsg_openXSG(xsgFileName);
assignin('base','xsgHeader',header);
assignin('base','xsgData',data);
evalin('base','xsgHeader');
evalin('base','xsgData');


