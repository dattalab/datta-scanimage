% qcammex.m - Interface to a QImaging Retiga-2000RV via a mex file and QCamAPI.
%
% SYNTAX
%  qcammex(command, ...)
%  version = qcammex('getVersion')
%  frames = qcammex('getFrames', filename, frameNumbers)
%  numberOfFrames = qcammex('getNumberOfFrames')
%  header = qcammex('getHeader', filename)
%  frame = qcammex('getCurrentFrame')
%  [frame, frameRate, frameCount] = qcammex('getCurrentFrame')
%  frame = qcammex('getSnapshot')
%  filename = qcammex('getOutputFileName')
%
%  frameRate = qcammex('getEstimatedFrameRate')
%   command - A string corresponding to a qcapmex command (described below).
%             Subsequent command-specific arguments may be included/required.
%   frames - Acquired frames, either from the camera or read from a file.
%   header - Header information retrieved from a file.
%   frame - The most recent frame intended for display (this may not be the most recent frame, as display is frequency limited).
%   frameRate - The estimated frame rate, over the life of the currently running acquisition.
%
% COMMANDS
%  General:
%   'printState' - Print the entire mex file's state to the command-line.
%   'printCamera' - Print camera information to the command-line.
%   'loadCamera' - Force the driver to be loaded and the camera opened immediately.
%   'releaseDriver' - Releases the driver to make it available to other software processes (ie. QCapture Pro or QCapture Suite).
%                     The driver is held until explicitly released or until the mex file is cleared.
%   'reset' - Reset the camera and drivers. This does not affect configuration variables within the mex file.
%   'getVersion' - Returns the version number of the compiled code.
%   'setStreamingMode' <qcammex | API> - Either use the internal qcammex multithreading for streaming frames or use the API's native streaming implementation.
%   'debugOn' - Enables print statements, for debugging.
%   'setInputQueueSize' <numberOfFrames> - For fine-grained performance tuning, sets the size of the input queue (used to buffer frames directly from the camera).
%                                          Note: May get overridden when configuring frame averaging. To ensure the value takes effect, do not adjust averaging after setting this value.
%   'setOutputQueueSize' <numberOfFrames> - For fine-grained performance tuning, sets the size of the output queue (used to buffer frames while writing to disk).
%                                          Note: May get overridden when configuring frame averaging. To ensure the value takes effect, do not adjust averaging after setting this value.
%   'commitSettingsToCam' - Forces the current settings to be sent to the camera immediately. Normally, settings are committed when starting an acqusition.
%
%  Control:
%   'start' - Begin streaming data from the camera based on the current settings.
%             Setting properties while data is streaming is not currently supported.
%   'stop' - Cease streaming data from the camera. Implies 'finalizeFile'.
%
%  Disk Logging (see Data Retrieval and FILE FORMAT, for details of reading files):
%   'setFilename' <filename> - Set the base filename for disk logging. Use an empty string to disable disk logging.
%                              No file extension should be included in the name, the mex file will append its own extension.
%   'setFramesPerFile' <frames> - Set the number of frames to be stored to a single file, before automatically rolling over.
%                                 If no new frames arrive, the file will not be rolled over. Rolled over files have a 3 digit
%                                 number appended to their name (before the file extension). Rolling over beyond 1000 files
%                                 is not supported.
%   'setUserHeaderField' <string> - Allows an arbitrary string to be encoded as a header field (Note: No '\r\n' sequence is allowed).
%   'setUserTimingField' <string> - A user-definable header intended specifically for storing trigger/timing information (Note: No '\r\n' sequence is allowed).
%   'finalizeFile' - Closes out any file that is currently open for disk logging. Disables disk logging if an acquisition is currently running.
%   'saveFrameBuffer' <string> - Saves the current frame buffer to the specified file, regardless of disk logging.
%                                This is not meant to be used while streaming data from the camera, but should work in that case anyway.
%   'getOutputFileName' - Returns the name of the file currently being used for disk logging, and empty if logging is not active.
%   'setFramesToAcquire' - Sets the number of frames after which to automatically stop acquisition.
%
%  Online Data Reduction:
%   'setBinFactor' <binFactor> - Set the spatial bin factor, in pixels. Setting it to 1 disables binning.
%   'setROI' <x> <y> <width> <height> - Sets the boundary of the image region that is acquired. This must be set correctly
%                                       for the specific CCD being used to get the correct field of view.
%   'setAverageFrames' <numOfFrames2Average> - Set the temporal averaging factor, in frames. Setting this to 1 disables averaging.
%                                              The intermediate raw frames are unavailable for displaying or writing to disk.
%
%  Buffering Configuration:
%   'enableDisplayFrameBuffer' <'on' | 'off'> - Create an overwritable frame buffer (useful for live preview, where it's okay to drop frames).
%                                               This buffer is guaranteed to not be updated at more than 25Hz.
%   'clearBuffers' - Release all memory allocated for buffering (the online averaging buffer, the acquired frame buffer, and the double buffer).
%
%  Acquisition Properties:
%   'setExposureTime' <nanoseconds> - Sets the exposure time, per frame.
%   'setTriggerType' <'edgeLow' | 'edgeHigh' | 'auto'> - Configure triggering. The 'auto' mode is intended for implementing a live preview.
%
%  Data Retrieval (see FILE FORMAT, for details):
%   'getCurrentFrame' - Get the most recently acquired frame (intended to be used in implementing online display).
%                       An empty array is returned if no new frames have been streamed from the camera since starting acquisition or since the last call to getCurrentFrame.
%                       This frame is limited, in C, to not update at more than 25Hz (once every 40ms), even if more frequent updates are requested from Matlab.
%                       If two output arguments are requested, the second argument will contain the current frame rate (regardless of the first argument being empty).
%                       If a third output argument is requested, the current frame count will also be returned.
%   'getSnapshot' - Acquire and return a single frame immediately, do not log to disk or average frames. Binning and ROIs still apply.
%   'getEstimatedFrameRate' - Returns the current estimated frame rate, in Hz. This value only has meaning while streaming data from the camera.
%   'getFrames' <filename> <frameNumber(s)> - Retrieve specified frames from the file. May be an array. If no frames are specified, they are all returned.
%   'getNumberOfFrames' <filename> - Returns the number of frames stored in the specified file.
%   'getFFTFrames' <filename> <frameNumbers> <frameRate> - Scans through the specified frames, and returns a single frame whose pixels are FFTs of
%                                                          the original pixels. The original frameRate is necessary to calculate the FFT.
%                                                          This operation can be memory intensive, enough memory for buffering and calculating on
%                                                          all specified frames (simultaneously) may be required. The exact details of the memory
%                                                          scheme used in the implementation is not specified here (see qcammex.c for details).
%   'getSparseFFTFrames' <filename> <frameNumbers> <frameRate> - Similar to getFFTFrames, except the entire set of frames is not loaded into direct memory immediately.
%                                                                Instead, a single buffer, equal in size to frameNumbers, is reloaded for each pixel.
%                                                                This consumes less memory overall, but may suffer in speed due to frequent seeking on the disk.
%   'getHeaderString' <filename> - Returns the header information (a string) from the file.
%
% USAGE
%  Intended to expose the major desired features of the QImaging hardware/software, 
%  with little overhead and higher performance/stability than is available with the imaq toolbox.
%
% NOTES
%  While aimed for the Retiga-2000RV camera, other cameras may be supported with little or no code changes. Cameras with very similar specs (bit depth, monochrome, etc)
%  should work with no modifications.
%
% FILE FORMAT
%  The native file format implemented in the C-code, dubbed 'qcamraw', is a fixed-length character array (a header) followed by binary data.
%  The header format is one of key-value pairs, using ':' as a delimiter. Header fields are delimited by CRLF ('\r\n') pairs. Similar to HTTP/MIME style headers.
%  The meaningful header section is terminated by a double-set of CRLFs. The rest of the header is padded with whitespace before being NULL terminated.
%  In this sense, the beginning of the file may be treated as a standard C-style string, and should be easily human-interpretable.
%  The first 8 header fields are considered critical for parsing the rest of the file, and their order is guaranteed. All other headers are considered purely
%  informational, and no guarantees are made about their order.
%  Example headers:
%   Encoding-Version: 0.10
%   Fixed-Header-Size: 768 [bytes]
%   ROI: 0, 0, 800, 600
%   Frame-Size: 960000 [bytes]
%   Image-Encoding: raw16
%   Image-Format: Mono16
%   Bytes-Per-Pixel: 2
%   Bits-Per-Pixel: 12
%   Temporal-Averaging: 1 [frames]
%   Exposure: 12200000 [ns]
%   Spatial-Binning: 1x1 [pixels]
%   High-Sensitivity-Mode: On
%   Normalized-Gain: 1000000
%   Absolute-Offset: 0
%   File-Init-Timestamp: 02-20-2008_15:44:26
%   Header-Creation-Timestamp: 02-20-2008_15:44:31
%   User-Timing-Data: 40Hz
%   User-Defined-Header: User notes go here.
%
%  Only one QImaging camera may currently be accessed through this API. If multiple cameras are detected, the first one is loaded.
%
% CHANGES
%
% Created 2/19/08 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2008

%For testing purposes, the following code can subsitute for the mex file.
function varargout = qcammex(command, varargin)
global qwidth qheight;

fprintf(1, 'qcammex(''%s'', {%s})\n%s\n', command, num2str(length(varargin)), getStackTraceString);
if strcmpi(command, 'getCurrentFrame')
    varargout{1} = uint16(1000 * rand(qwidth, qheight));
    if nargout == 2
        varargout{2} = 30.2;
    end
elseif strcmpi(command, 'setROI')
    qwidth = varargin{3};
    qheight = varargin{4};
elseif strcmpi(command, 'getHeaderString')
    varargout{1} = 'DummyHeader';
end

return;