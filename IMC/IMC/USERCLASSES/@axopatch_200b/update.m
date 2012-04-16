% UPDATE - Method that will update the amplifier with the current hardware
% settings.
%
% SYNTAX
%  obj = update(obj);
%
% USAGE
%  This method will call the appropriate method so that the multi_clamp
%  object will contain the correct input and output gains based on the
%  hardware settings.
%
% NOTES
%
% CHANGES
%  TO021005b - Moved indexTelegraph from being a subfunction in update to a private function. -- Tim O'Connor 2/10/05
%  TO022305c - Changed this to pick up the new variable(s) 'gain_daq_board_id'. -- Tim O'Connor 2/23/05
%  TO062405B - Send update notifications. -- Tim O'Connor 6/24/05
%  TO010906A - Optimization(s). Only notify listeners if there has been a change. -- Tim O'Connor 1/9/06
%  TO080606B - Use the daqmanager, like it should have originally, to avoid conflicts (see TO080406E). -- Tim O'Connor 8/6/06
%  TO073107B - Change over to nimex. -- Tim O'Connor 7/31/07
%  TO121507A - Mode is a string, not a scalar, use `strcmpi`. -- Tim O'Connor 12/15/07
%  TO050508A - Something of a kluge, to handle the sharing of a single board across programs. The board may need to be "silently" restarted here. -- Tim O'Connor 5/5/08
%  TO050508B - Do some averaging of telegraph samples, which may be a bit slower, but sometimes these lines can get noisey. -- Tim O'Connor 5/5/08
%
% Created 1/13/05 - Tom Pologruto
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical
% Institute 2005
function out = update(obj)
%Um, why is this being done? Oh, right, this didn't originally use pointers it was "pure" Matlab class (which is not a good thing). 
%It's like our design discussions went in one ear and out the other. More than a year and a half later and there's still kruft from that time. -- Tim O'Connor 8/6/06
out = obj; % copy input...

%TO080606B - This was implemented all wrong upon creation. It should not create analoginput objects, and it certainly should not
%            assume that all the telegraphs will be read in on the same board. How crap like this got written, I'll never know...
%TODO (as of 8/6/06) - Implement this as a single call to getDaqSample (which will currently print a warning, since the multichannel
%                      functionality is not optimally implemented, yet).
% setup the daq to read the telegraphs.
% aiobject_default = analoginput('nidaq',get(out,'gain_daq_board_id'));
% set(aiobject_default,'TriggerType','Immediate');
% addchannel(aiobject_default,[get(out,'gain_channel') get(out,'mode_channel') get(out,'v_hold_channel')]);
% gain_mode_vhold = getsample(aiobject_default); % get telegraph voltages
% delete(aiobject_default);
% dm = getDaqmanager;%Using the default daqmanager object may be a little bit conflict prone, but will most likely be okay. It's cleaner than attaching a @daqmanager instance to the object.
global axopatch200bs;

job = daqjob('acquisition');%Using the default daqmanager (now a @daqjob, but the same thought applies) object may be a little bit conflict prone, but will most likely be okay. It's cleaner than attaching a @daqmanager instance to the object.
%TO050508A - Stop any channels that are using the board. Let the user know what's going on, because this is really shady.
startedChannels = {};
if isStarted(job)
    startedChannels = getStartedChannels(daqjob('acquisition'));
    if ~isempty(startedChannels)
        fprintf(1, '%s - @axopatch_200b/update: Device(s) were in use when a request to update amplifier ''%s'' by telegraphs. Those channels are being temporarily stopped and restarted.\n Channels:\n', ...
            datestr(now), axopatch200bs(obj.ptr).name);
        for i = 1 : length(startedChannels)
            fprintf(1, '          ''%s''\n', startedChannels{i});
        end
        fprintf(1, 'This is not necessarily an error, it is typically just an unavoidable consequence of sharing a board for multiple uses.\n');
        stop(job, startedChannels{:});
    end
end
%TO050508B - Do some averaging of telegraph samples, which may be a bit slower, but sometimes these lines can get noisey. -- Tim O'Connor 5/5/08
gain_mode_vhold = zeros(3, 1);
for i = 1 : 5
    gain_mode_vhold(1) = gain_mode_vhold(1) + getSample(job, [axopatch200bs(obj.ptr).name '-gain']);%getDaqSample(dm, [axopatch200bs(obj.ptr).name '-gain']);
    gain_mode_vhold(2) = gain_mode_vhold(2) + getSample(job, [axopatch200bs(obj.ptr).name '-mode']);%getDaqSample(dm, [axopatch200bs(obj.ptr).name '-mode']);
    gain_mode_vhold(3) = gain_mode_vhold(3) + getSample(job, [axopatch200bs(obj.ptr).name '-v_hold']);%getDaqSample(dm, [axopatch200bs(obj.ptr).name '-v_hold']);
end
gain_mode_vhold = gain_mode_vhold / 5; 
%TO050508A
if ~isempty(startedChannels)
    start(job, startedChannels{:});
end

%TO010906A
oldGain = get(obj, 'gain');
oldMode = get(obj, 'mode');
oldVHold = get(obj, 'v_hold');
oldCC = get(obj, 'current_clamp');

% Assign voltages to values using the subfunction indexTelegraph
gain_voltage = gain_mode_vhold(1);
gain = indexTelegraph(obj, 'gain',gain_voltage);
mode_voltage = gain_mode_vhold(2);
[mode,current_clamp]=indexTelegraph(obj, 'mode',mode_voltage);
vhold_voltage = gain_mode_vhold(3);
v_hold = 100*vhold_voltage; % correct for scaling of channel voltage

% set the object properties...
out = set(out,'gain',gain);
out = set(out,'mode',mode);
out = set(out,'v_hold',v_hold);
out = set(out,'current_clamp',current_clamp);

% Now set the generic amplifier properties...
if get(out,'current_clamp')
    out = set(out,'input_units','mV');
    out = set(out,'input_gain',get(out,'i_clamp_input_factor')/gain);
else
    out = set(out,'input_units','pA');
    out = set(out,'input_gain',get(out,'v_clamp_input_factor')/gain);
end

%TO062405B, TO010906A, TO121507A
if (gain ~= oldGain) || ~strcmpi(mode, oldMode) || (v_hold ~= oldVHold) || (current_clamp ~= oldCC)
    notifyStateListeners(obj);
end

return;

%TO021005b
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% function varargout=indexTelegraph(parameter,voltage)
% % Pass in voltage from Axopatch 200B telegraph to get the value...
% % must have a nidaq daq board installed.
% cc=0;
% switch parameter
% case 'gain'
%     if voltage < 2.1
% 		output = .5;
% 	elseif voltage > 2.1 & voltage < 2.6
% 		output = 1;
% 	elseif voltage > 2.6 & voltage < 3.1
% 		output = 2;
% 	elseif voltage > 3.1 & voltage < 3.6
% 		output = 5;
% 	elseif voltage > 3.6 & voltage < 4.1
% 		output = 10;
% 	elseif voltage > 4.1 & voltage < 4.6
% 		output = 20;
% 	elseif voltage > 4.6 & voltage < 5.1
% 		output = 50;
% 	elseif voltage > 5.1 & voltage < 5.6
% 		output = 100;
% 	elseif voltage > 5.6 & voltage < 6.1
% 		output = 200;
% 	elseif voltage > 6.1 & voltage < 6.6
% 		output = 500;
% 	else
% 		disp('Gain indeterminate; Set to 1.');
% 		output = 1;
% 	end
% 	
% case 'mode'
%     % 4V = VTrack; 5V = VClamp; 3V = I=0; 2V = IClampNormal; 1V = IClampFast
%     if voltage < 1.2
%         output='I-Clamp Fast';
%         cc=1;
%     elseif voltage > 1.8 & voltage < 2.2
%         output='I-Clamp Normal';
%         cc=1;
%     elseif voltage > 2.8 & voltage < 3.2
%         output='I = 0'; 
%         cc=1;
%     elseif voltage > 3.8 & voltage < 4.2
%         output='V-Track';
%          cc=0;
%     elseif voltage > 4.8 & voltage < 5.2
%         output='V-Clamp';
%          cc=0;
%     else
%         disp('Mode indeterminate; Set to V-Clamp');
%         output='V-Clamp';
%         cc=0;
%     end
% end
% 
% if nargout == 1
%     varargout{1}=output;
% elseif nargout == 2
%     varargout{1}=output;
%     varargout{2}=cc;
% end