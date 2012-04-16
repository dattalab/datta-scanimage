function changePulsePatternNumber(n)

	global state

	if nargin<1
		n=state.pulses.patternNumber;
	else
		state.pulses.patternNumber=n;
		updateGuiByGlobal('state.pulses.patternNumber');
	end

	fn=fieldnames(state.pulses);

	for counter=1:length(fn)
		if findstr('List', fn{counter})
			fname=fn{counter}(1:end-4);
			if iscell(getfield(state.pulses, fn{counter}))  % is this a list of values?
				if length(getfield(state.pulses, fn{counter}))>=n
					eval(['state.pulses.' fname '=state.pulses.' fn{counter} '{n};']);
				else
					eval(['state.pulses.' fname '='''';']);
					eval(['state.pulses.' fn{counter} '{n}='''';']);
				end
			else
				if length(getfield(state.pulses, fn{counter}))>=n
					eval(['state.pulses.' fname '=state.pulses.' fn{counter} '(n);']);
				else
					if strcmp(fname, 'duration')
						eval(['state.pulses.' fname '=1000;']);
						eval(['state.pulses.'  fn{counter} '(n)=1000;']);
                    elseif strcmp(fname, 'waveType')
                        eval(['state.pulses.' fname '=1;']);
						eval(['state.pulses.'  fn{counter} '(n)=1;']);
					else
						eval(['state.pulses.' fname '=0;']);
						eval(['state.pulses.'  fn{counter} '(n)=0;']);
					end
				end
			end			
			updateGUIByGLobal(['state.pulses.' fname]);
		end
	end

	makePulsePattern(n);
