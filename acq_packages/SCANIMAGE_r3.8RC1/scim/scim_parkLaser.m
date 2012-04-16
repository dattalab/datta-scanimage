function scim_parkLaser(varargin)  
%% function scim_parkLaser(varargin)
% Function to park the laser beam(s), at either standard or user-specified angular position
%% USAGE
%   scim_parkLaser(): parks laser at standard.ini defined park location (vars state.acq.parkAngleX & state.acq.parkAngleY); closes shutter and turns off beam with Pockels Cell
%   scim_parkLaser(xy): parks laser at user defined location xy, a 2 element vector of optical degree values
%   scim_parkLaser(...,'soft'): 'soft' flag causes function to blank beam with Pockels, but leave shutter open
%
%% NOTES
%   When parking at the standard.ini location, the Pockels Cell is set to transmit the minimum possible vlaue.
%
%   Note that X&Y correspond to channels as per the X/YMirrorChannelID settings in the INI file
%   When xy is passed, note that 1) scanOffsetAngleX/Y is NOT added, and 2) value is converted to voltage via voltsPerOpticalDegree value in INI file
%
%   The 'soft' option is intended for 'quick' parking, avoiding frequent open/close of the shutter
%
%
%% ******************************************************************************************

si_parkOrPointLaser(varargin{:});