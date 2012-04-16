% @MULTI_CLAMP/getHeaderInfo - Creates a structure of information that should get stored into headers of any program using this object.
%
% SYNTAX
%  headerInfo = getHeaderInfo(AMPLIFIER)
%   AMPLIFIER - An @amplifier instance.
%   headerInfo - A structure with hardware specific information for this instance.
%
% USAGE
%
% NOTES
%
% CHANGES
%   TO122205A - Upgrade to Matlab 7.1, case sensitivity. -- Tim O'Connor 12/22/05
%   TO031109B - Updated to use the MEX interface to communicate with the MultiClamp.
%
% Created 12/2/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function headerInfo = getHeaderInfo(this)

headerInfo = getHeaderInfo(this.AMPLIFIER);%TO122205A

headerInfo.v_clamp_input_factor = get(this, 'v_clamp_input_factor');
headerInfo.i_clamp_input_factor = get(this, 'i_clamp_input_factor');
headerInfo.v_clamp_output_factor = get(this, 'v_clamp_output_factor');
headerInfo.i_clamp_output_factor = get(this, 'i_clamp_output_factor');

%TO031109B
filename=get(this,'text_file_location');
if isempty(filename)
    try
        uComPortID = get(this, 'uComPortID');
        uChannelID = get(this, 'uChannelID');
        if uComPortID == -1
            %700B
            uSerialNum = get(this, 'uSerialNum');
            ID = [uSerialNum, uChannelID];
        else
            %700A
            uAxoBusID = get(this, 'uAxoBusID');
            ID = [uComPortID, uAxoBusID, uChannelID];
        end
        ampState = MultiClampTelegraph('getAmplifier', ID);
        headerInfo.ampState = ampState;
    catch
        fprintf(2, 'Error retrieving MultiClamp state to construct header information.\n%s\n', getLastErrorStack);
    end
end

return;