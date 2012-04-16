function agSetPath(exptNumber, exptLetter)

    global state
    
    basedir='C:\Users\user\Desktop\DATA\giessel\';
	disp(basedir);
	
    cd(basedir);
   
    if (nargin == 0)
        today=[datestr(now, 'dd') datestr(now, 'mmm') datestr(now, 'yy')];
        
        notFoundDir=1;
        incChar='a';
        while(notFoundDir)
            dirname=[basedir today char(incChar)];
            try
                cd(dirname);
                incChar=incChar+1; %this will only happen if cd was successful
            catch
                notFoundDir=0;
            end
        end     
        state.files.baseName=[today char(incChar)];
    else
        dirname = [basedir 'ag' num2str(exptNumber) exptLetter];
        state.files.baseName = ['ag' num2str(exptNumber) exptLetter '_e1_'];
    end
    
    state.files.savePath=[dirname '\'];
   
    FoundDir=1;
    
    try
       cd(state.files.savePath);
       FoundDir=1;
       cd('..')
    catch
       FoundDir=0;
    end 

    if FoundDir>0.1
        disp([' ']);
        disp(['!!!!!!!!!!!!!!!!!!! DIRECTORY ALREADY EXISTS !!!!!!!!!!!!!!!!!!!!!!!!!!']);    
        disp([' ']);
        beep;
        beep;
        return
    end
 
	disp(state.files.savePath);
	
	%% make the data dir
	evalin('base', ['!mkdir "' state.files.savePath '"']);
    
    
    state.files.savePath=[dirname '\'];
	updateFullFileName(0);
	cd(state.files.savePath);

	
	state.files.autoSave=1;    
    updateGUIByGlobal('state.files.autoSave');
    updateGUIByGlobal('state.files.baseName');
    
    disp(['*** SAVE PATH = ' state.files.savePath ' ***']);
    disp(['*** BASE NAME = ' state.files.baseName ' ***']);	