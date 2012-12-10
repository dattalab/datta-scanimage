function sweepFFT
    global progmanagerglobal
    
    
    trace = getfield(getfield(progmanagerglobal.programs.ephys.ephys.variables.saveBuffers,'trace_1'),'data');    
    Fs = progmanagerglobal.programs.ephys.ephys.variables.sampleRate;
    T = 1/Fs;
    seconds = progmanagerglobal.programs.ephys.ephys.variables.traceLength;
    L = Fs * seconds;
    NFFT=2^nextpow2(L);
    y = fft(trace, NFFT)/L;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    figure();
    plot(f, 2*abs(y(1:NFFT/2+1)));