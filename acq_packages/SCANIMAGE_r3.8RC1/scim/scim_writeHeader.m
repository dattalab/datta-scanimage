function scim_writeHeader(headerStruct,inFileName,outFileName)
%% function scim_writeHeader(headerStruct,inFileName,outFileName)
% Function to overwrite header info in ScanImage TIF file with user-supplied header structure (obtained via scim_openTif())
% This should be done with CAUTION - ovewriting the header information decouples the metadata from that captured during acquisition
%
%% SYNTAX
%   scim_writeHeader(headerStruct,inFileName)
%   scim_writeHeader(headerStruct,inFileName,outFileName)
%       headerStruct: A structure 
%       inFileName: 
%       outFileName: 
%
%% NOTES
%
%% CREDITS
%   Created 5/27/09, by Vijay Iyer
%
%% ****************************************************************


%Handle input file
[inPath, inFile, inExt] = fileparts(inFileName);
inExt = processExtension(inExt);
inFileName = fullfile(inPath,[inFile inExt]);

%Handle output file
if nargin < 3
    outFileName = inFileName;
else        
    [outPath, outFile, outExt] = fileparts(outFileName);
    outExt = processExtension(outExt);
    outFileName = fullfile(outPath,[outFile outExt]);
end
        

%Convert supplied structure to string
headerString = updateHeaderForAcquisition(headerVar);

%If 




    function processStateField(stateField)
        fNames = fieldnames(eval(headerStruct));
        for i=1:length(fNames)
            fieldName = [stateField '.' fNames{i}];
            if isstruct(eval(fieldName))
                processStateField(fieldName);
            else %current field is a variable
                processStateVar(fieldName);
            end
        end
    end

    function processStateVar(stateVar)
        %Determine if variable is already in the header string
        pos=findstr(state.headerString, [stateVar '=']);

        %Convert variable value into a string
        val = stateVar2String(stateVar);

        %Append string to header string
        if length(pos)==0 %Variable not already in header string; just add it!
            state.headerString=[state.headerString stateVar '=' val 13];
        else
            cr=findstr(state.headerString, 13);
            next=cr(find(cr>pos,1));
            if length(next)==0 %at end of header string
                state.headerString=[state.headerString(1:pos-1) stateVar '=' val 13];
            else %in middle of header string
                state.headerString=[state.headerString(1:pos-1) stateVar '=' val state.headerString(next:end)];
            end
        end

    end

        



        
    %Ensure .TIF extension
    function ext = processExtension(ext)
        if isempty(ext)
            ext = '.tif';
        elseif ~ismember(lower(ext),{'.tif' '.tiff'})
            error('Input and output file must be TIF files');
        end      
    end


end


