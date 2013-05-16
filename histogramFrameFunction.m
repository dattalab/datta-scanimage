function histogramFrameFunction(eventName, eventData)
global state

asdf = state.acq.acquiredData(1);
chan1 = asdf{1}{1};
chan2 = asdf{1}{2};

chan = chan1;

maxval1 = double(max(max(chan1)));
maxval1 = 4096;
try
    f = get(998);
    ax = get(f,'CurrentAxes');
catch ME
    f = figure(998);
    ax = axes;
end
hist(ax, chan1(:), linspace(0, maxval1, 500));
axis(ax, [0, maxval1, 0, 400]);

y_pos = 200;
y_delta = 15;
text(2000, y_pos, ['mean: ' num2str(mean(chan(:)))]);
text(2000, y_pos-y_delta*1, ['median: ' num2str(median(chan(:)))]);

num_over = sum(sum(chan1>state.internal.highPixelValue1));
text(2000, y_pos-y_delta*2, ['% saturated: ' num2str(100*num_over/length(chan1(:)))]);
text(2000, y_pos-y_delta*3, ['# saturated: ' num2str(num_over)]);

end
