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
%
% NOTES:
%   The multiclamp object relies on a text fiel to read params from.  
%   See the @multi_clamp directory for example files.
%
% CHANGES:
%  TO062305A: Moved over to using "pointers". Moved over to work with the @AIMUX/@AOMUX architecture. -- Tim O'Connor 6/23/05
%  TO070605B: Updated some text file parsing. -- Tim O'Connor 7/6/05
%  TO112008D: Switch to using MulticlampTelegraph.mexw32 as an interface. -- Tim O'Connor 11/20/08
%  TO012709B: Made a NOT_FOUND error more informative. -- Tim O'Connor 1/27/09
%  VITO022110A - Update amplifier object 'input_units' value and signal change, if units value returned from Multiclamp has changed -- Vijay Iyer/Tim O'Connor 2/21/10
%  VI022310A: Restore code setting 'input_gain' that had been accidentally lost in merge of changes from 5/21/09 (see r1166 and r1169 in SVN repository)
%
% Created 1/13/05 - Tom Pologruto
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical
% Institute 2005
function update(this)

changed = 0;

filename=get(this,'text_file_location'); % filename where info is located
%TO112008D
if isempty(filename)
    uComPortID = get(this, 'uComPortID');
    uChannelID = get(this, 'uChannelID');
    if uComPortID == -1
        %700B
        uSerialNum = get(this, 'uSerialNum');
        %ID = MultiClampTelegraph('get700BID', uint(uSerialNum), uint(uChannelID));
        ID = [uSerialNum, uChannelID];
        
        % %This is a temporary hack, until the ID parsing for 700B is corrected.
        % MultiClampTelegraph('broadcast');
        % amps = MultiClampTelegraph('getAllAmplifiers');
        %
        % for i = 1 : length(amps)
        %    if amps{i}.uSerialNum == uSerialNum
        %        ampState = amps{i};
        %        break;
        %     end
        % end
    else
        %700A
        uAxoBusID = get(this, 'uAxoBusID');
        % ID = MultiClampTelegraph('get700AID', uint(uComPortID), uint(uAxoBusID), uint(uChannelID));
        ID = [uComPortID, uAxoBusID, uChannelID];
    end

    %The subscription mechanism makes this call superfluous. Although, if the subscription turns out to be unreliable, this could be used as a fallback.
    % try
    %     MultiClampTelegraph('requestTelegraph', ID);
    % catch
    %     fprintf(2, 'multi_clamp/update - ''%s'' Error - Failed to request telegraph for amplifier: %s\n', get(this, 'name'), lasterr);
    %     return;
    % end

    %This approach should work, but requires further processing, to determine the gain based on the mode and scaled output signal.
    %Using the 'getScaledGain', 'getUnits', and 'getMode' commands should make things much easier.
    % try
    %     ampState = MultiClampTelegraph('getAmplifier', ID);
    % catch
    %     fprintf(2, 'multi_clamp/update - ''%s'' Error - Failed to get amplifier state: %s\n', get(this, 'name'), getLastErrorStack);
    %     return;
    % end
    %
    % if isempty(ampState)
    %     %TO012709B - Make this error message more useful.
    %     MultiClampTelegraph('broadcast');
    %     fprintf(2, 'multi_clamp/update - ''%s'' Error - Failed to get amplifier state: NOT_FOUND\n', get(this, 'name'));
    %     if uAxoBusID == -1
    %         fprintf(1, '                     No 700A amplifier found with uComPortID:%s, uAxoBusID:%s, uChannelID:%s\n', num2str(uComPortID), num2str(uAxoBusID), num2str(uChannelID));
    %         fprintf(1, '                      For a 700A, make sure that uComPortID, uAxoBusID, and uChannelID are correct.\n');
    %     else
    %         fprintf(1, '                     No 700B amplifier found with uSerialNum:%s, uChannelID:%s\n', num2str(uSerialNum), num2str(uChannelID));
    %         fprintf(1, '                      For a 700B, make sure that uSerialNum and uChannelID are correct.\n');
    %     end
    %     fprintf(1, '                      Ensure that MultiClamp Commander is running and the amplifier is connected to the computer.\n');
    %     fprintf(1, '                     In some cases, MultiClamp Commander may just be slow to respond, and future state updates may work correctly.\n\n');
    %     return;
    % end
    [gain, units, mode] = MultiClampTelegraph('getScaledGain', ID, 'getScaledUnits', ID, 'getMode', ID);
% ampState = MultiClampTelegraph('getAmplifier', ID);
% fprintf(1, 'gain: %s, units: ''%s'', mode: ''%s''\n\n', num2str(gain), units, mode);
    % Now set the generic amplifier properties..
    if strcmpi(mode, 'V-Clamp')
        current_clamp = 0;        
        %set(this, 'input_units', 'pA'); %We always run in pA! %VITO022110A
        nominalGain = get(this, 'v_clamp_input_factor') * gain;
    else
        current_clamp = 1;
        %set(this, 'input_units', 'mV'); %We always run in mV! %VITO022110A
        nominalGain = get(this, 'i_clamp_input_factor') * gain;          
    end
    
    %Scale to pA and mV, as appropriate
    switch lower(units)
        case 'pa'
            totalGain = nominalGain;
            newUnits = 'pA'; %VITO022110A
        case 'na'
            totalGain = nominalGain / 1e3;
            newUnits = 'pA'; %VITO022110A
        case 'ua'
            totalGain = nominalGain / 1e6;
            newUnits = 'pA'; %VITO022110A
        case 'ma'
            totalGain = nominalGain / 1e9;
            newUnits = 'pA'; %VITO022110A
        case 'a'
            totalGain = nominalGain / 1e12;
            newUnits = 'pA'; %VITO022110A
        case 'uv'
            totalGain = nominalGain * 1e3;
            newUnits = 'mV'; %VITO022110A
        case 'mv'
            totalGain = nominalGain;
            newUnits = 'mV'; %VITO022110A
        case 'v'
            totalGain = nominalGain / 1e3;
            newUnits = 'mV'; %VITO022110A
        otherwise
            error('Unrecognized scale factor units for voltage clamp');
    end       
    
    set(this, 'input_gain', totalGain); %VI022310A    
    
    %%%VITO022110A
    if ~strcmpi(get(this, 'input_units'),newUnits)
        set(this, 'input_units', newUnits);
        changed = 1;
    end
 

else
    if doesFileExist(filename)
        % query the text file...
        text = textread(filename, '%s', 'headerlines', 0, 'delimiter', '\n');
        channel_start=findStrInCell(text, ['Channel ID: ' num2str(get(this,'channel'))]);
        if isempty(channel_start)
            error(['multi_clamp->update: File ' filename ' empty. Using previous gain and mode.']);
            return
        end

        % check the length of the cell array
        if length(channel_start) > 1
            channel_start=channel_start(1);
        end
        % tokenize the text and extract the info to the output object
        for i = channel_start:length(text)
            tokens = tokenize(text{i});
            if ~isempty(tokens)
                if strcmp(tokens{1},'Mode:')
                    mode=tokens{2};
                    %if strcmp(get(this, 'mode'), 'I')%Why was this ever here at all?!? -- TO070605B
                    %    mode = 'I = 0';
                    %end
                    if strcmp(mode, 'V-Clamp')
                        current_clamp = 0;
                    else
                        current_clamp = 1;
                    end
                elseif strcmp(tokens{1},'Gain:')
                    gain = str2num(tokens{2});
                end
            end
        end
        
        % Now set the generic amplifier properties...
        if get(this, 'current_clamp')
            set(this, 'input_units', 'mV');
            set(this, 'input_gain', get(this, 'i_clamp_input_factor') * gain);
        else
            set(this, 'input_units', 'pA');
            set(this, 'input_gain', get(this, 'v_clamp_input_factor') * gain);
        end
    else
        fprintf(1, 'Warning - multi_clamp->update: File %s does not exist. Using previous gain and mode.\n', filename);
    end
end

% set the object properties...
if get(this, 'gain') ~= gain
    set(this, 'gain', gain);
    changed = 1;
end
if ~strcmpi(get(this, 'mode'), mode)
    set(this, 'mode', mode);
    changed = 1;
end
if get(this, 'current_clamp') ~= current_clamp
    set(this, 'current_clamp', current_clamp);
    changed = 1;
end

set(this, 'modeString', mode);%TO062305A

%TO062305A - Update registered listeners (handled by the @amplifier class), if necessary.
if changed
    notifyStateListeners(this);
end

return;