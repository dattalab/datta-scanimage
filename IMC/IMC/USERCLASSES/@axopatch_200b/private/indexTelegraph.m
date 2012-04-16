% Pass in voltage from Axopatch 200B telegraph to get the value...
% must have a nidaq daq board installed.
%
% SYNTAX
%  gain = indexTelegraph(AXOPATCH, 'gain', gainVoltage)
%  [mode, currentClamp] = indexTelegraph('mode', modeVoltage)%
%
% CHANGED
%  TO021005b - Moved into from being a subfunction in update to a private function. -- Tim O'Connor 2/10/05
%  TO050505A - Take beta into account. -- Tim O'Connor 5/5/05
%  TO051205A - See AXOPATCH 200B Patch Clamp Theory And Operation manual, page 81. -- Tim O'Connor 5/12/05
%  TO062405A: Added modeString property to amplifiers. -- Tim O'Connor 6/24/05
%  TO062805A: Despite what the manual says, the actual device seems to put out 5V for V-Clamp, so accept that, as well. -- Tim O'Connor 6/28/05
%
% Copyright Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function varargout=indexTelegraph(this, parameter,voltage)

cc = get(this, 'current_clamp');
beta = get(this, 'beta');
switch parameter
case 'gain'
    if voltage < 2.1
        %TO050505A
        if beta == 0.1
            if voltage < .6 & cc
                output = 0.05;
            elseif voltage < 1.1 & cc
                output = 0.1;
            elseif voltage < 1.6 & cc
                output = 0.2;
            elseif ~cc
                warning('Illegal gain telegraph voltage for voltage clamp mode: %s on AXOPATCH 200B: %s with Beta=1', num2str(voltage), get(this, 'name'));
            else
                warning('Gain indeterminate; Set to 1. AXOPATCH 200B: %s', get(this, 'name'));
            end
        else
            output = .5;
        end
	elseif voltage > 2.1 & voltage < 2.6
		output = 1;
	elseif voltage > 2.6 & voltage < 3.1
		output = 2;
	elseif voltage > 3.1 & voltage < 3.6
		output = 5;
	elseif voltage > 3.6 & voltage < 4.1
		output = 10;
	elseif voltage > 4.1 & voltage < 4.6
		output = 20;
	elseif voltage > 4.6 & voltage < 5.1
		output = 50;
	elseif voltage > 5.1 & voltage < 5.6
        if cc & beta ~= 1
            warning('Illegal gain telegraph voltage for current clamp mode: %s on AXOPATCH 200B: %s with Beta=0.1', num2str(voltage), get(this, 'name'));
        end
		output = 100;
	elseif voltage > 5.6 & voltage < 6.1
        if cc & beta ~= 1
            warning('Illegal gain telegraph voltage for current clamp mode: %s on AXOPATCH 200B: %swith Beta=0.1', num2str(voltage), get(this, 'name'));
        end
		output = 200;
	elseif voltage > 6.1 & voltage < 6.6
        if cc & beta ~= 1
            warning('Illegal gain telegraph voltage for current clamp mode: %s on AXOPATCH 200B: %swith Beta=0.1', num2str(voltage), get(this, 'name'));
        end
		output = 500;
	else
		warning('Gain indeterminate; Set to 1. AXOPATCH 200B: %s', get(this, 'name'));
		output = 1;
	end

case 'mode'
    % 4V = VTrack; 5V = VClamp; 3V = I=0; 2V = IClampNormal; 1V = IClampFast
    if voltage < 1.2
        output='I-Clamp Fast';
        cc=1;
    elseif voltage > 1.8 & voltage < 2.2
        output='I-Clamp Normal';
        cc=1;
    elseif voltage > 2.8 & voltage < 3.2
        output='I = 0'; 
        cc=1;
    elseif voltage > 3.8 & voltage < 4.2
        output='V-Track';
         cc=0;
    elseif (voltage > 4.8 & voltage < 5.2) | (voltage > 5.8 & voltage < 6.2)
        %Changed from (voltage > 4.8 & voltage < 5.2) to (voltage > 5.8 & voltage < 6.2)
        %See AXOPATCH 200B Patch Clamp Theory And Operation manual, page 81. -- Tim O'Connor 5/12/05 TO051205A
        %Despite what the manual says, the actual device seems to put out 5V for V-Clamp, so accept that, as well. -- Tim O'Connor 6/28/05 TO062805A
        output='V-Clamp';
         cc=0;
    else
        warning('Mode indeterminate; Set to V-Clamp; Telegraph: %s V; Amplifier: %s', num2str(voltage), get(this, 'name'));
        output='V-Clamp';
        cc=0;
    end
    
    %TO062404A
    set(this, 'modeString', output);
end

if nargout == 1
    varargout{1}=output;
elseif nargout == 2
    varargout{1}=output;
    varargout{2}=cc;
end