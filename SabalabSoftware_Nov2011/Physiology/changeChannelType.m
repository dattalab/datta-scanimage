function changeChannelType(channelList)
	global state
	
	for channel=channelList
		switch getfield(state.phys.settings, ['channelType' num2str(channel)])
		case 1     
			eval(['state.phys.settings.mVPerVIn' num2str(channel) '=1;']);
			eval(['state.phys.settings.mVPerVOut' num2str(channel) '=1;']);
			eval(['state.phys.settings.pAPerVIn' num2str(channel) '=1;']);
			eval(['state.phys.settings.pAPerVOut' num2str(channel) '=1;']);
		case 2  % axon
			eval(['state.phys.settings.mVPerVIn' num2str(channel) '=state.phys.settings.axoPatchMVPerVIn;']);
			eval(['state.phys.settings.mVPerVOut' num2str(channel) '=state.phys.settings.axoPatchMVPerVOut;']);
			eval(['state.phys.settings.pAPerVIn' num2str(channel) '=state.phys.settings.axoPatchPAPerVIn;']);
			eval(['state.phys.settings.pAPerVOut' num2str(channel) '=state.phys.settings.axoPatchPAPerVOut;']);
			setupAxonTelegraphs;
		case 3 % multiclamp
			eval(['state.phys.settings.mVPerVIn' num2str(channel) '=state.phys.settings.multiClampMVPerVIn;']);
			eval(['state.phys.settings.mVPerVOut' num2str(channel) '= state.phys.settings.multiClampMVPerVOut;']);
			eval(['state.phys.settings.pAPerVIn' num2str(channel) '=state.phys.settings.multiClampPAPerVIn;']);
			eval(['state.phys.settings.pAPerVOut' num2str(channel) '= state.phys.settings.multiClampPAPerVOut;']);
        case 4 % AM Systems 1800 Extracellular Amp   AJG
            eval(['state.phys.settings.mVPerVIn' num2str(channel) '=state.phys.settings.amSys1800MVPerVIn;']);
			eval(['state.phys.settings.mVPerVOut' num2str(channel) '= state.phys.settings.amSys1800MVPerVOut;']);
			eval(['state.phys.settings.pAPerVIn' num2str(channel) '=state.phys.settings.amSys1800PAPerVIn;']);  %  But never actually in VC
			eval(['state.phys.settings.pAPerVOut' num2str(channel) '=state.phys.settings.amSys1800PAPerVIn;']);  % But never actually in VC
        end
		
		updateGuiByGlobal(['state.phys.settings.mVPerVIn' num2str(channel)]);		
		updateGuiByGlobal(['state.phys.settings.mVPerVOut' num2str(channel)]);
		updateGuiByGlobal(['state.phys.settings.pAPerVIn' num2str(channel)]);
		updateGuiByGlobal(['state.phys.settings.pAPerVOut' num2str(channel)]);
	end
	
	setupBaselineReading;