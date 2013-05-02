function histogramFrameFunction(eventName, eventData)
    global state
    
    asdf = state.acq.acquiredData(1);
    chan1 = asdf{1}{1};
    chan2 = asdf{1}{2};
    
    chan = chan1;
    
    maxval1 = double(max(max(chan1)));
    try
        f = get(998);
    catch ME
        f = figure(998);
    end
    
    try
        ax = get(f,'CurrentAxes');
        hist(ax, chan(:), linspace(0, maxval1, 500));
        axis([0, maxval1, 0, 400])
    catch
        hist(chan1(:), linspace(0, maxval1, 500));
        axis([0, maxval1, 0, 400])
    end
end
