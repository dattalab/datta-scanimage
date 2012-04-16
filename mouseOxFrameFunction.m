function mouseOxFrameFunction(eventName, eventData)
    % This function polls a file ( hard coded to be
    % C:\Users\user\Desktop\mouseox.txt ) on every frame and drops that
    % data in a txt file for analysis. 
   
    % requires tail.exe and head.exe from http://unxutils.sourceforge.net
    % to be in the path
    
    % Field headers: "Elapsed Time","File Marker","Arterial O2 Saturation",
    % "Heart Rate","Pulse Distention","Breath Distention","Breath
    % Rate","Error Code"
    
    global state
    
    commandstring = ['tail -2 c:\Users\user\Desktop\mouseox.txt|head -1>>' state.files.baseName zeroPadNum2Str(state.files.fileCounter) '_mouseox.txt'];
   
    [status,result] = system(commandstring);