function initOlfactometerTasks()
global state;

if ~isfield(state.olfactometer, 'triggertask')
    state.olfactometer.triggertask=[];
end
triggertask = state.olfactometer.triggertask;
triggerboardname = state.olfactometer.triggerboardname;
triggerline = state.olfactometer.triggerline;

if ~isempty(triggertask)
    try
        stop(triggertask);
    catch
    end
    delete(triggertask);
end

%tcp_udp_ip doesn't play well with others, use the daqtoolbox instead of nimex.
triggertask = analoginput('nidaq', triggerboardname);
addchannel(triggertask, 0);
set(triggertask, 'samplerate', 10000, 'samplesacquiredfcn', {@incrementOdorByTrigger}, 'samplesacquiredfcncount', 2, 'samplespertrigger', 5000, ...
    'triggertype', 'hwdigital', 'hwdigitaltriggersource', triggerline, 'triggerrepeat', inf, 'bufferingconfig', [10000, 2]);
start(triggertask);

state.olfactometer.triggertask = triggertask;

end
