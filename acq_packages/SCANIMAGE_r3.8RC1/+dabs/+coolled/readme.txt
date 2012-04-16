To programmatically control the CoolLED PE excitation system, we create a Matlab class PE. 

hpe = PE('PORT') constructs a CoolLED PE object associated with serial port, PORT. If PORT does not exist or is in use you will not be able to connect the serial port object to the device. 

To find the port number, 
_______________________________________
Start -> settings -> Control Panel
Double-click System -> Hardware -> Device Manager
Click the [+] by ports to see the list of COM ports.
The PE port will be identified with a string in the form

pEx USB COM PORT (Com3)

From that string use the part COM3 only
_______________________________________

There are two properties in for the class PE: ChannelsIntensity and ChannelsStatus. ChannelsIntensity is an array which keep the value of intensity (ranging from 0 to 100) for all channels. ChannelsStatus is a cell array which keeps the status of all channels. 

Each channel can be in one of the three states: ON, OFF, or ARMED. ON means the channels LED is on. OFF means the channel LED is off. If you want to turn on the LED, you can use (1) the pod rotary button, 2)hpe.ChannelsStatus{chanNUm} = 'on' , or 3) TTL trigger input to do that. High TTL turns on LED and low one turns it off.

ARMED is in fact the simultaneous mode. If you want to turn on more than one channel LED, you can set these channels to ARMED, then you can use (1) the pod rotary button, 2) hpe.ARM2ON, or 3) TTL trigger input(*) to turn on these channels at the same time.
    
    
    
    %ARMED is in fact the simultaneous mode. If you want to turn on more than one channel LED,
    %you can set these channels to ARMED, then you can use (1) the pod
    %rotary button, 2) hpe.ARM2ON, or #) TTL trigger input(*) to turn on these
    %channels at the same time.
    % Examples:
        % %To construct a CoolLED PE object
        % Import dabs.coolled.*
        % hpe = PE(3);
        
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

Known limitations: 
1)	Once the TTL trigger level is high and turns on an ARMED channel, we cannot set the channel properties any more until the TTL level goes low. 
2)	If one channel is on. Another channel is ARMED and connected to TTL trigger input. The high TTL input turned on the ARMED channel, at the same time, the system automatically set the first channel to ARMED state.

Known issue
(*)   We cannot turn on multiple armed channel simultaneously with trigger,  it is fine currently because no body need to turn on multiple LED at the same time. ARM2ON function works.
