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
%
% Created 1/13/05 - Tom Pologruto
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical
% Institute 2005
function update(this)

changed = 0;

filename=get(this,'text_file_location'); % filename where info is located
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
    
    % Now set the generic amplifier properties...
    if get(this, 'current_clamp')
        set(this, 'input_units', 'mV');
        set(this, 'input_gain', get(this, 'i_clamp_input_factor') * gain);
    else
        set(this, 'input_units', 'pA');
        set(this, 'input_gain', get(this, 'v_clamp_input_factor') * gain);
    end
    set(this, 'modeString', mode);%TO062305A
else
    fprintf(1, 'Warning - multi_clamp->update: File %s does not exist. Using previous gain and mode.\n', filename);
end

%TO062305A - Update registered listeners (handled by the @amplifier class), if necessary.
if changed
    notifyStateListeners(this);
end

return;