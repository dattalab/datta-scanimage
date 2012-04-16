classdef PE
    %PE Contruct CoolLED PE object.
    % hpe = PE('PORT') construct a CoolLED PE object associated with serial port, PORT.
    % If PORT does not exist or is in use you will not be able to connect the serial port
    % object to the device.
    %
    %There are two properties in for the class PE: ChannelsIntensity and ChannelsStatus.
    %ChannelsIntensity is an array which keep the value of intensity (ranging from 0 to
    %100) for all channels.
    %
    %ChannelsStatus is a cell array which keeps the status of all channels. Each channel
    %can be in one of the three states: ON, OFF, or ARMED. ON means the channels LED is
    %on. OFF means the channel LED is off. If you want to turn on the LED,
    %you can use (1) the pod rotary button, 2)hpe.ChannelsStatus{chanNUm} = 'on' , or 3) TTL trigger 
    %input to do that. High TTL turns on LED and low one turns it off.
    
    
    %ARMED is in fact the simultaneous mode. If you want to turn on more than one channel LED,
    %you can set these channels to ARMED, then you can use (1) the pod
    %rotary button, 2) hpe.ARM2ON, or 3) TTL trigger input(*) to turn on these
    %channels at the same time.
    
    % Examples:
    % %To construct a CoolLED PE object
    % Import dabs.coolled.*
    % hpe = PE(3);
    %
    % % To get all channels’ status
    % hpe.ChannelsStatus
    %
    % % To get all channels’ intensity
    % hpe.ChannelsIntensity
    %
    % % You can also get one channel’s status/intensity
    % hpe.ChannelsStatus{2}
    %
    % hpe.ChannelsIntensity(2)
    %
    %% To set all channels' intensity
    % hpe.ChannelsIntensity = [0, 60, 60, 0];
    %
    %% To set all channels's status
    % hpe.ChannelsStatus = {'off', 'on', 'on', 'off'};
    %
    % % You can also set one channel’s status/intensity
    % hpe.ChannelsStatus{2} = 'ON';
    %
    % hpe.ChannelsIntensity(2) = 50;
    %
    
    % Known limitations:
    % 1)	Once the TTL trigger level is high and turns on an ARMED channel, we cannot set the channel properties any more until the TTL level goes low.
    % 2)	If one channel is on. Another channel is ARMED and connected to TTL trigger input. The high TTL input turned on the ARMED channel, at the same time, the system automatically set the first
    %       channel to ARMED state.
   
    % (*)   We cannot turn on multiple armed channel simultaneously
    % with trigger,  it is fine currently because no body need to turn on
    % multiple LED at the same time. ARM2ON function works.
    
    %% PSEUDO-DEPENDENT PROPERTIES
    
    properties (Dependent = true)
        
        ChannelsIntensity;
        ChannelsStatus;
        
    end
    
    %% PRIVATE PROPERTIES
    
    properties (Hidden, SetAccess=private)
        
        hSerial; %Handle to RS232 interface
        
    end
    
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = PE(comPort,varargin)
            % Optional Property-Value Arguments:
            %   baudRate:
            
            import dabs.interfaces.*;
            
            %RS232DeviceBasic Initialization (association)
            %obj.hSerial = RS232DeviceBasic(obj,'comPort', comPort,'availableBaudRates',[9600 19200 38400],'standardBaudRate',9600, 'deviceSimpleResp','R');
            %obj.hSerial.initialize('comPort',comPort,varargin{:}); %Prop-Val pairs include
            obj.hSerial = serial(['COM', num2str(comPort)]);
            set(obj.hSerial,'BaudRate', 9600); %Use this for both send & receive
            %obj.hSerial.replyTimeoutDefault = 1;
            fopen(obj.hSerial);
            
            try
                obj.sendCommandMultiStringReply(['XVER']),
            catch ME
                error('A serial device was detected, but was not of type %s',mfilename('class'));
            end
            
        end
        
        function delete(obj)
            delete(obj.hSerial);
        end
        
    end
    
    
    %% PROPERTY ACCESS METHODS
    
    methods
        %____________________get property___________________%
        
        function status = get.ChannelsStatus (obj)
            respString= obj.sendCommandSingleStringReply(['CSS?']);
            if length(respString) == 28
                startPoint = 5;
                status = cell(1,4);
                for i = 1:4
                    temp = respString(startPoint:startPoint+1);
                    switch temp
                        case {'SN','XN'}
                            status{i} = 'ON';
                        case 'SF'
                            status{i} = 'ARMED';
                        otherwise
                            status{i} = 'OFF';
                    end
                    startPoint = startPoint + 6;
                end
            else
                error('the repsonse is in a wrong format.');
            end
        end
        
        function intensity = get.ChannelsIntensity(obj)
            respString= obj.sendCommandSingleStringReply(['CSS?']);
            if length(respString) == 28
                intensity = zeros(1,4);
                startPoint = 7;
                for i = 1:4
                    temp = respString(startPoint:startPoint+2);
                    intensity(i) = str2double(temp);
                    startPoint = startPoint + 6;
                end
            else
                error('the repsonse is in a wrong format.');
            end
        end
        
        
        %______________________set property_____________________________%
        
        function obj = set.ChannelsIntensity(obj, array)
            %Input is a 4-element array
            respString= obj.sendCommandSingleStringReply(['CSS?']);
            if length(respString) == 28 %use fgetl, remove newline character
                startPoint = 7;
                for i = 1:4
                    temp = array(i);
                    if 0<= temp && temp <10
                        respString(startPoint:startPoint+2) = ['00',num2str(temp)];
                    elseif 10<=temp && temp <100
                        respString(startPoint:startPoint+2) = ['0',num2str(temp)];
                    elseif temp==100
                        respString(startPoint:startPoint+2) = [num2str(temp)];
                    else
                        error('The 4 elements in the iput array should range from 0 to 100');
                    end
                    startPoint = startPoint + 6;
                end
                %obj.hSerial.sendCommandStringReply(sprintf('%s\n', respString)); %add new line character
                %fprintf(obj.hSerial,respString(1:27));
                obj.sendCommandSingleStringReply(respString(1:27));
            else
                error('the repsonse is in a wrong format.');
            end
        end
        
        function obj = set.ChannelsStatus(obj, array)
            %Input is a 4-element cell array
            respString= obj.sendCommandSingleStringReply(['CSS?']);
            if length(respString) == 28
                startPoint = 5;
                for i = 1:4
                    temp = upper(array{i});
                    switch temp
                        case 'ON'
                            respString(startPoint:startPoint+1) = 'SN';
                        case 'ARMED'
                            respString(startPoint:startPoint+1) = 'SF';
                        case 'OFF'
                            respString(startPoint:startPoint+1) = 'XF';
                        otherwise
                            error('the input should be ON, ARMED, or OFF.');
                    end
                    startPoint = startPoint + 6;
                end
                %obj.hSerial.sendCommandStringReply(sprintf('%s\n', respString));  %add new line character
                %fprintf(obj.hSerial,respString(1:27));
                obj.sendCommandSingleStringReply(respString(1:27));
            else
                error('the repsonse is in a wrong format.');
            end
        end
        
        
        %% PUBLIC METHODS
        %------------------------General commands----------------------%
        
        function ArmChannel(obj, chan, mode)
            if isnumeric(chan) && (1<= chan <=4)
                channel = 'A' + chan -1;
            else
                errror('The first argument should be a channel number range from 1 to 4');
            end
            
            switch mode
                case 'rising'
                    mode = '+';
                case 'falling'
                    mode = '-';
                case 'both'
                    mode = '*';
                case 'follow'
                    mode = '#';
                otherwise
                    error('the second argument should be rising, falling, both, or follow');
            end
            
            % send arm channel command
             obj.sendCommandMultiStringReply(['A' char(channel) mode]);
        end
        
        
        function TTLControl(obj)
            % revert to TTL direct controls
            obj.sendCommandMultiStringReply(['AX']);
        end
        
        function DisableTTL(obj)
            % revert to TTL direct controls
            obj.sendCommandMultiStringReply(['AZ'])
        end
        
        function ARM2ON(obj)
            % send arm channel command
            obj.sendCommandMultiStringReply(['CSN']);
        end
        
        function reset(obj)
            % send arm channel command
            obj.sendCommandMultiStringReply(['RESET']);
        end
        
        function reply = sendCommandSingleStringReply(obj, command)
            reply = '';
            fprintf(obj.hSerial, command);
            pause(0.2);
            %obj.hSerial.BytesAvailable
            reply = fscanf(obj.hSerial);
        end
        
        function reply = sendCommandMultiStringReply(obj, command)
            reply = '';
            fprintf(obj.hSerial, command);
            pause(0.5);
            while obj.hSerial.BytesAvailable ~= 0
                temp = fscanf(obj.hSerial);
                reply = [reply, temp];
            end
        end
        

    end
    
end


