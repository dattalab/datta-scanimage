function saveHeaderToTxt

    global state
    fid=fopen([state.files.fullFileName '_e' num2str(state.epoch) '_hdr.txt'], 'a');
    
    fprintf(fid, '%s', state.headerString);
    fclose(fid);