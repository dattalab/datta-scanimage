function readTelegraphs
	global state

	readAxon=0;
	for counter=0:1
		type=getfield(state.phys.settings, ['channelType' num2str(counter)]);
		switch type
		case 2  % 700A
			if ~readAxon
				readAxonTelegraphs;
				readAxon=1;
			end
		case 3  % 200B
			readMultiClampParams(counter);
        case 4   % am systems 1800
            %use state/gui values
            switch eval(['state.phys.settings.amSys1800Chan' num2str(counter) 'HWGain'])
                case 1
                    eval(['state.phys.settings.inputGain' num2str(counter) '=100;']);
                case 2
                    eval(['state.phys.settings.inputGain' num2str(counter) '=1000;']);
                case 3
                    eval(['state.phys.settings.inputGain' num2str(counter) '=10000;']);
            end
            eval(['state.phys.settings.currentClamp' num2str(counter) '=1;']);
        end
    end
	phSetChannelGains
	