% mapper_userFcn_laserPowerCalculation - Analyze a photodiode trace and update the mapper GUI with the excitation power figures.
%
% SYNTAX
%  mapper_userFcn_laserPowerCalculation
%  mapper_userFcn_laserPowerCalculation(acqObj)
%  mapper_userFcn_laserPowerCalculation(header, data)
%    acqObj - The handle or program object for the Acquirer.
%             Note: Passing the handle to any other program will cause unspecified errors, but they may not be obvious.
%    header - The first argument passed for the xsg:Save event. The current acquisition's header.
%    data - The second argument passed for the xsg:Save event. The current acquisition's data.
%
% NOTES
%  This also acts as an example of how to write robust and optimized user function in the current schema.
%  Changes to the user function interface may obsolete this as a valid example. It is valid as of 3/9/06.
%
% CHANGES
%  TO030906D: Revised considerably from an original 'prototype'. Added support for multiple events and error checking. -- Tim O'Connor 3/9/06
%  TO031306C: Fixed thresholding criteria, it had been looking for  values greater than `avg + 0.5 * mx`, which is not what was intended. -- Tim O'Connor 3/13/06
%  TO033006C: Modified to also bind nicely to the acq:SamplesAcquired event. -- Tim O'Connor 3/30/06
%  TO021610D: Quit if not in mapper (map/mouse/flash) context. -- Tim O'Connor 2/16/10
%
% Created 3/7/06 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2006
function mapper_userFcn_laserPowerCalculation(varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%
%This first section deals with retrieving the photodiode data.
%It is also written in a way to give a few different examples for how this may be done, 
%when using the first method could have worked in all cases.
%
%This function is hardcoded to look for trace_1, this may not be the best implementation,
%but it will do for now. If the channels on the acquirer are configured in some other way
%this function may no longer work properly.
if isempty(varargin)
    saveBuffers = getGlobal(progmanager, 'saveBuffers', 'acquirer', 'acquirer');
    photodiodeData = saveBuffers.trace_1.data;
elseif length(varargin) == 1
    saveBuffers = getLocal(progmanager, varargin{1}, 'saveBuffers');
    photodiodeData = saveBuffers.trace_1.data;
elseif length(varargin) == 2
    %TO033006C: Look at the arguments for one other case.
    %The SamplesAcquired event passes the program's tracelet array and the name of the associated trace.
    if isnumeric(varargin{1})
        if ischar(varargin{2})
            if ~strcmp(varargin{2}, 'trace_1')
                %Not the data we're interested in here.
                return;
            end
            photodiodeData = varargin{1};
        end
    else
        saveBuffers = varargin{2};
        photodiodeData = saveBuffers.acquirer.trace_1;
    end
else
    saveBuffers = varargin{2};
    photodiodeData = saveBuffers.acquirer.trace_1;
end

if isempty(photodiodeData)
    return;
end

%Notice that the handle to the program is retrieved via getGlobal, this allows the use of
%`setLocalBatch` towards the end (there currently is no global analog of this function).
%Using batched set/get operations is a good way to save time when dealing with anything
%running under program manager control.
%
%Because, in this case, only two variables are being set at the end it may not make sense to 
%use a getGlobal here, as the overhead of it ends up balancing out any gains from setLocalBatch.
%It is only done for illustrative purposes (the performance of either method should be roughly
%equivalent when only two variables are being manipulated).
mapperObj = getGlobal(progmanager, 'hObject', 'mapper', 'mapper');

%TO021610D
%If this channel is not being used in the context of the mapper (for a map/mouse/flash), then quit.
[mapping, mousing, flashing, map, mouse] = getLocalBatch(progmanager, mapperObj, 'mapping', 'mousing', 'flashing', 'map', 'mouse');
if ~(mapping || mousing || flashing || map || mouse)
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%This section handles extracting the pulse information from the photodiode trace data.
%It will also quit and set the power to 0 if it can not detect a meanigful pulse.
%
%Over time, it's quite possible that user functions will become the bottleneck in program execution speed.
%So, it's best to optimize user functions as much as possible. The interactions with the programs have a
%more or less fixed overhead, which can not be reduced (at least not by the user function) with the notable
%exception of using batched get/set calls. Therefore, any calculations done by user functions should be 
%optimized.
%
%The algorithm is O(3N) in complexity (assuming the actual pulse is small compared to the entire trace),
%that is to say that it calls for three passes over the entire data set (max, mean, find). If the
%pulse is large, relative to the trace length, the complexity is O(4N).
%
%For a typical Matlab implementation, this is minimized in complexity. It could be sped up by 
%calculating the first mean and the max in a single pass. However, the overhead in doing so is prohibitive.
%Such is the world of Matlab's for-loop-less vector-based operations.
mx = max(photodiodeData);
avg = mean(photodiodeData);

%Make sure there is a detectable pulse. A pulse is defined as being at least 2 times the baseline illumination.
pulseExists = 1;%Assume one exists, flag otherwise if it can not be found.
if ~(mx > 2 * avg)
    %Printing to the console (command-line), issuing an error/warning, or popping up a dialog box is recommended
    %whenever abnormal conditions are encountered. Try to make the message useful for a user, but at a minimum
    %make sure that it will clue the programmer in to exactly what the condition is and where it occured.
    %
    %An error/warning should print a stack trace (although it is not 100% reliable that they will), which shows 
    %everything leading up to the abnormal condition. In the case of a user function, we know what lead up to it 
    %(the appropriate userFcn event was executed). Therefore, an error/warning is generally unnecessary in user 
    %functions, instead just printing the name of the function that encountered the condition should be sufficient.
    %In any case, always make sure that it is possible to identify where the message came from. Vague statements that
    %something somewhere did not go as expected are effectively useless. Nice formatting also aids in making messages
    %readable, which is very handy when trying to sort through them. Putting extra effort into these details will
    %almost certainly help you in the long run with the maintenance of your code.
    %
    %A timestamp is usually nice to have as well. Unless there's a good reason not to, always terminate a print statement
    %with at least one carriage return, so messages remain distinct from each other on the console.
    %
    %Notice that error messages get printed to filehandle 2, instead of 1. This is the error stream
    %which comes from the UNIX environment and C language conventions. See the `fprintf` documentation for details.
    fprintf(2, '%s - mapper_userFcn_laserPowerCalculation: No significant light pulse detected.\n', datestr(now));

    pulseExists = 0;
end

%The pulse itself includes all points that are greater than half the difference between the mean and the max of the whole trace.
%
%Notice that there's a multiplication by 0.5 instead of a division by 2. Most floating point hardware is implemented in such a
%way that multiplication is faster than division.
threshold = avg + 0.5 * (mx - avg);%TO031306C
superThresholdIndices = find(photodiodeData > threshold);

%In general, whenever a find is used, it's advisable to make sure that it has not returned an empty array.
%If we've already determined that no pulse exists, this would produce a redundant message, so only bother with
%it if has already been determined that there is a valid pulse.
if pulseExists && isempty(superThresholdIndices)
    fprintf(2, '%s - mapper_userFcn_laserPowerCalculation: Expected pulse data not found.\n', datestr(now));
    pulseExists = 0;
end

if pulseExists
    %The mean gives the average instantaneous power delivery, it would make more sense to integrate
    %thereby accounting for the duration of the pulse as well as the peak power delivered.
    %The mean is used just to maintain backwards compatibility with the previous software.
    pdiodeData = mean(photodiodeData(superThresholdIndices));
else
    %No discernable pulse was found, so the exposure should be close to the mean.
    pdiodeData = avg;
end

%Here a specialized object is retrieved (of class @photodiode). It carries all necessary information
%about a photodiode in an imaging system, and provides relevant services (voltage to power conversions).
pdiodeCalibration = getGlobal(progmanager, 'photodiodeObject', 'mapper', 'mapper');

%%%%%%%%%%%%%%%%%%%%%%%%%
%This section actually converts the photodiode voltage during the pulse into milliwats and updates the mapper gui.

%The @photodiode object handles the calculation itself, based on whatever voodoo goes on in there,
%explicit knowledge of what a photodiode is and how it works is not necessary for this function.
%At some point in the future, the @photodiode may be changed to correct problems or to add functionality
%and this function will automatically see the benefits of that, without any code changes made here.
[bfpPower specimenPower] = convertVoltage(pdiodeCalibration, pdiodeData);

%Rounding is done in a semi-intelligent fashion, to enhance readability in a small variety of cases.
if bfpPower > 10
    bfpPower = roundTo(bfpPower, 0);
elseif bfpPower > 0.005
    bfpPower = roundTo(bfpPower, 3);
end

if specimenPower > 10
    specimenPower = roundTo(specimenPower, 0);
elseif specimenPower > 0.005
    specimenPower = roundTo(specimenPower, 3);
end

%Using setLocalBatch is preferred for performance when setting multiple values, however getGlobal is still usable.
% setGlobal(progmanager, 'backFocalPlanePower', 'mapper', 'mapper', bfpPower);
% setGlobal(progmanager, 'specimenPlanePower', 'mapper', 'mapper', specimenPower);
setLocalBatch(progmanager, mapperObj, 'backFocalPlanePower', bfpPower, 'specimenPlanePower', specimenPower);

return;