% ephysAcc_calcCellParams - Calculate cell parameters from the amplifier's output.
%
% SYNTAX
%  ephysAcc_calcCellParams(hObject, data, ampIndex)
%  ephysAcc_calcCellParams(hObject, ampIndex, data, ai, strct, varargin) - AIMUX form. (Obsoleted TO110907A)
%  ephysAcc_calcCellParams(hObject, ampIndex, data, sampleRate) - TO110907A
%
% USAGE
%
% NOTES
%
% CIRCUIT DIAGRAM
%
%                          Rm
%                  +---/\/\/\/\/\---+
%         Rs       |                |     |
%  ---/\/\/\/\/\---+                +-----|||
%                  |                |     |
%                  +-------||-------+
%                          Cm
%                                        TO121405D -- Tim O'Connor 12/14/05
%
% EXPONENTIAL EXTRAPOLATION
%  TO122305B - The peak is extrapolated by finding t1 (1ms after the pulse) and t2 (50% of t1):
%              (t1V / t2V) = [Ae^(-t1 / tau) / Ae^(-t2/tau)]
%              (t1V / t2V) = e^[(-t1 + t2) / tau]
%              tau = (t2 - t1) / ln(t1V / t2V)
%
%              I_t1 - baselineAfterExp = Ae^(-t1 / tau)
%              A = (I_t1 - baselineAfterExp) * e^(t1 / tau)
%
% CHANGES
%  TO070805A: Cache acquisition parameters, for faster calculations. -- Tim O'Connor 7/8/05
%  TO071105A: Watch out for divide by zero events. -- Tim O'Connor 7/11/05
%  TO092805D: Watch out for zero duration pulses. -- Tim O'Connor 9/28/05
%  TO120205A - Store amplifiers in a cell array, because of type incompatibilities. -- Tim O'Connor 12/2/05
%  TO120205C: Fixed a minor redundancy (tiny optimization). -- Tim O'Connor 12/2/05
%  TO121405D: Corrected calculations, as per Volker's explanation (Aleks also noticed a problem). See the diagram above. Removed Racc. -- Tim O'Connor 12/14/05
%  TO122005B: Corrected units on the capacitance calculation. -- Tim O'Connor 12/20/05
%  TO122305A: Expand the search window for extrema (changing filter settings phase shifts them around). -- Tim O'Connor 12/23/05
%  TO122305B: Extrapolate tau using a 2 point exponential fit. -- Tim O'Connor 12/23/05
%  TO021006A: Calculate pipette resistance, when not on a cell. -- Tim O'Connor 2/10/06
%  TO021706B: Reimplemented access resistance. -- Tim O'Connor 2/17/06
%  TO032106B, TO032206A, TO032406G: Watch out for divide by zero. -- Tim O'Connor 3/21/06 and 3/22/06 and 3/24/06
%  TO033106A: Switched a pair of `> 0` to a `~= 0` conditions to correct TO032406G. -- Tim O'Connor 3/31/06
%  TOLP040706A: Corrected some offset issues. -- Tim O'Connor 3/7/06 (after Leopoldo Petreanu 4/4/06)
%  TO110907A: Update for nimex. -- Tim O'Connor 11/9/07
%  TO012308C - Update amplifiers, online, as necessary. Some reorganization was needed, to ensure that updates always occur. -- Tim O'Connor 1/23/08
%  TO022110A - Just in case, when switching modes weird stuff happens, check the data array for validity. -- Tim O'Connor 2/21/10
%  TO031610F - Update the breakInTime display in here, so we don't need another timerObject or something like that. -- Tim O'Connor 3/16/10
%  TO032310A - Only update the breakInTime if the button is clicked and a breakInTime value is set. -- Tim O'Connor 3/23/10
%  TO032410A - Remove TO031610F and TO032310A, just set the break in time when the button is pressed, as a timestamp. -- Tim O'Connor 3/24/10
%  TO052810B - Use a try/catch when updating the amplifier state. -- Tim O'Connor 5/28/10
%
% Created 2/25/05 Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2005
function ephysAcc_calcCellParams(hObject, varargin)
global ephysScopeAccessory;
% tic;

%TO070805B: Created getLocalBatch optimization. -- Tim O'Connor 7/8/06
[startButton, amplifiers, amplifierList, lastCalcCellParamsTime, calcCellParams] = getLocalBatch(progmanager, hObject, ...
    'startButton', 'amplifiers', 'amplifierList', 'lastCalcCellParamsTime', 'calcCellParams');

%TO012308C
if ~startButton
    return;
end

%TO110907A %TO012308C
ampIndex = -1;
if length(varargin) == 1
    data = varargin{1};
    ampIndex = varargin{2};
elseif length(varargin) == 3
    ampIndex = varargin{1};
    data = varargin{2};
else
    error('Illegal number of arguments: %s', num2str(length(varargin)));
end

%TO012308C - Update amplifiers, online, as necessary. -- Tim O'Connor 1/23/08
if ~strcmpi(class(amplifiers{ampIndex}), 'axopatch_200b')
    try
        update(amplifiers{ampIndex});
    catch
        fprintf(2, 'ephysAcc_calcCellParams: Failed to update amplifier ''%s'' -\n%s\n', get(amplifiers{ampIndex}, 'name'), getLastErrorStack);%TO052810B
    end
end

if ~calcCellParams
    return;
end
% t = [];
% t(length(t) + 1) = toc; tic;

% amplifiers = getLocal(progmanager, hObject, 'amplifiers');%TO120205C: This was redundant due to TO070805B. -- Tim O'Connor 12/2/05
% t(length(t) + 1) = toc; tic;

% t(length(t) + 1) = toc; tic;
if ampIndex ~= amplifierList
    return;
end
% t(length(t) + 1) = toc; tic;
if etime(clock, lastCalcCellParamsTime) < 1.2
    return;
end
lastCalcCellParamsTime = clock;

%TO032410A
% %TO031610F %TO032310A
% % setLocalGh(progmanager, hObject, 'breakIn', 'String', [num2str(round(etime(lastCalcCellParamsTime, breakInTime))) ' [s]']);
% if breakIn && ~isempty(breakInTime)
%     setLocalGh(progmanager, hObject, 'breakIn', 'String', [datestr(now - datenum(breakInTime), 13) ' [elapsed]']);
% end

% t(length(t) + 1) = toc; tic;
% if get(amplifiers(ampIndex), 'current_clamp')
%     outputFactor = get(amplifiers{ampIndex}, 'i_clamp_output_factor');%TO120205A
% else
%     outputFactor = get(amplifiers{ampIndex}, 'v_clamp_output_factor');%TO120205A
% end
% t(length(t) + 1) = toc; tic;
%TO070805A: Cache acquisition parameters, for faster calculations. -- Tim O'Connor 7/8/05
% testPulses = getLocal(progmanager, hObject, 'testPulses');
% sampleRate = getLocal(progmanager, hObject, 'sampleRate');
% duration = ephysAcc_getDuration(hObject, ampIndex);
% samples = sampleRate * duration;
% amplitude = get(testPulses(ampIndex), 'amplitude') * outputFactor;
testPulses = ephysScopeAccessory.calc_cellParams.testPulses;
sampleRate = ephysScopeAccessory.calc_cellParams.sampleRate;
duration = ephysScopeAccessory.calc_cellParams.duration(ampIndex);
if duration == 0
    %TO092805D
    setLocalBatch(progmanager, hObject, 'seriesResistance', NaN, 'membraneResistance', NaN, ...
        'membraneCapacitance', NaN, 'lastCalcCellParamsTime', lastCalcCellParamsTime, 'accessResistance', NaN);
    return;
end

if length(ephysScopeAccessory.calc_cellParams.samples) > 1
    samples = ephysScopeAccessory.calc_cellParams.samples(ampIndex);
else
    samples = ephysScopeAccessory.calc_cellParams.samples;
end
amplitude = get(ephysScopeAccessory.calc_cellParams.testPulses(ampIndex), 'amplitude');% * outputFactor;

%TO022110A - Just in case, when switching modes weird stuff happens. -- Tim O'Connor 2/21/10
if length(data) < samples
    return;
end
% t(length(t) + 1) = toc; tic;
globalBaseline = mean(data(round(0.02 * samples) : round(0.23 * samples)));
baselineAfterExp = mean(data(round(0.65 * samples) : round(0.745 * samples)));

% t(length(t) + 1) = toc; tic;
%TO122305B - Remove the original search altogether.
% if amplitude < 0
%     if baselineAfterExp < globalBaseline        
%         %TO122305A - Moved the window from 0.24-0.26 to 0.14-0.36.
%         peak = min(data(round(0.14 * samples) : round(0.36 * samples)));
%         r = find(data(round(0.251 * samples) : round(0.745 * samples) > (baselineAfterExp - (baselineAfterExp - peak) / exp(1))));
%     else
%         %INCALCULABLE
%         peak = NaN;
%         r = [];
%     end
% else
%     if baselineAfterExp > globalBaseline
%         %TO122305A - Moved the window from 0.24-0.26 to 0.14-0.36.
%         peak = max(data(round(0.14 * samples) : round(0.36 * samples)));
%         r = find(data(round(0.251 * samples) : round(0.745 * samples)) < (baselineAfterExp + (peak - baselineAfterExp) / exp(1)));
%     else
%         %INCALCULABLE
%         peak = NaN;
%         r = [];
%     end
% end

% Rs = abs(amplitude / (globalBaseline - peak));%TO121405D - Reduced by a factor of 1000. -- Tim O'Connor 12/14/05
% %TO121405D - Just like Rm, this should never be negative. -- Tim O'Connor 12/14/05
% if Rs < 0
%     Rs = NaN;
% end
% Rm = abs(amplitude / (globalBaseline - baselineAfterExp)) - Rs;%TO121405D - Reduced by a factor of 1000. -- Tim O'Connor 12/14/05
% if Rm < 0
%     Rm = NaN;
% end
% Racc = nansum([Rs  Rm]);

% wholeInterval=dur/2;
% tau = abs(wholeInterval - length(r)/sr);
% tau = abs((duration / 2) - length(r) / sampleRate);%TO122305B

%TO122305B - The peak is extrapolated by finding t1 (1ms after the pulse) and t2 (50% of t1):
%            (t1V / t2V) = [Ae^(-t1 / tau) / Ae^(-t2/tau)]
%            (t1V / t2V) = e^[(-t1 + t2) / tau]
%            tau = (t2 - t1) / ln(t1V / t2V)
%
%            I_t1 - baselineAfterExp = Ae^(-t1 / tau)
%            A = (I_t1 - baselineAfterExp) * e^(t1 / tau)
t1 = ceil(0.25 * samples + sampleRate / 2000);%0.5ms after the pulse is delivered.
t1V = data(t1) - baselineAfterExp;%Value at time = t1.
t2V = 0.5 * t1V;%Value at time = t2.
searchStartIndex = t1;%It must come after this time point.
searchEndIndex = round(0.40 * samples);%Is this a good value? It should have decayed at least 50% by 40% of the total time interval of the pulse.
[t2Error t2] = min(abs(data(searchStartIndex : searchEndIndex) - baselineAfterExp - t2V));%Which point is closest to our optimal t2V?
t2 = t2 + searchStartIndex - 1;
t2V = data(t2) - baselineAfterExp;
t2 = (t2 - ceil(0.25 * samples)) / sampleRate;%Convert into time units and subtract the offset, so it's relative to time = 0.
t1 = (t1 - ceil(0.25 * samples)) / sampleRate;%Convert into time units and subtract the offset, so it's relative to time = 0.
%TO032206A
%TO032406G
if t2V ~= 0
    logRatio = log(t1V / t2V);
else
    logRatio = NaN;
end
if logRatio == 0
    tau = NaN;
else
    tau = (t2 - t1) / logRatio;%tau = (t2 - t1) / ln(baselineAfterExp)

end
peak = t1V * exp((t1-(1 / sampleRate)) / tau);%A = (I_t1 - baselineAfterExp) * e^(t1 / tau) computed at "sample 1".

%TOLP040706A
peak = peak - globalBaseline + baselineAfterExp;%Replace the offset.
% timeOffset = ceil(0.25 * samples) - 5;
% figure, plot(1 : length(timeOffset : round(0.745 * samples)), data(timeOffset : round(0.745 * samples)) - baselineAfterExp, 'o-', 6 + t1 * sampleRate, t1V, 'x', 6 + t2 * sampleRate, t2V, '^');
% fprintf(1, 'ephysAcc_calcCellParams:\n  baselineAfterExp = %3.3f\n  t1 = %3.3f\n  t1V = %3.3f\n  t2 = %3.3f\n  t2V = %3.3f\n  tau = %3.9f\n  (t1 / tau) = %3.3f\n  peak = %3.3f\n\n', baselineAfterExp, t1, t1V, t2, t2V, tau, t1 / tau, peak);
%TO032406G %TO033106A %TOLP040706A
if (peak - globalBaseline + baselineAfterExp) ~= 0
    Rs = 1000 * abs(amplitude / peak);
  %Rs = 1000 * abs(amplitude / (peak - globalBaseline + baselineAfterExp));
else
    Rs = NaN;
end
%TO032406G %TO033106A
if (globalBaseline - baselineAfterExp) ~= 0
    Rm = 1000 * abs(amplitude / (globalBaseline - baselineAfterExp)) - Rs;
    Racc = 1000 * abs(amplitude / (globalBaseline - baselineAfterExp));%TO021706B
else
    Rm = NaN;
    Racc = NaN;
end

%TO071105A: Watch out for divide by zero events.
numerator = 1000000 * (Rs + Rm) * tau;%TO121405D - Reduced by a factor of 1000. -- Tim O'Connor 12/14/05 %TO122005B - Added a factor of 10^6. -- Tim O'Connor 12/20/05
%TO032106B - Watch out for divide by zero. -- Tim O'Connor 3/21/06
denominator = (Rs * Rm);%TO121405D - This should be multiplcation, not addition. -- Tim O'Connor 12/14/05
if denominator ~= 0
    Cm = numerator / denominator;
else
    Cm = NaN;
end

% t(length(t) + 1) = toc; tic;
%TO070805B: Created setLocalBatch optimization. -- Tim O'Connor 7/8/06
setLocalBatch(progmanager, hObject, 'seriesResistance', roundTo(Rs, 1), 'membraneResistance', roundTo(Rm, 1), ...
    'membraneCapacitance', roundTo(Cm, 2), 'lastCalcCellParamsTime', lastCalcCellParamsTime, 'accessResistance', roundTo(Racc, 1));%TO121405D - Removed Racc. -- Tim O'Connor 12/14/05 %TO021706B - Replaced Racc. --Tim O'Connor 2/16/06

% setLocal(progmanager, hObject, 'seriesResistance', Rs);
% setLocal(progmanager, hObject, 'membraneResistance', Rm);
% setLocal(progmanager, hObject, 'membraneCapacitance', Cm);
% t(length(t) + 1) = toc; tic;
% toc
return;

%         if state.physiology.scope.amplitudeV < 0
%             r=find(scopeInput(round(.251*sr*dur):round(.745*sr*dur)) > pulse-((pulse-peak)/exp(1)));
%         else
%             r=find(scopeInput(round(.251*sr*dur):round(.745*sr*dur)) < pulse+((peak-pulse)/exp(1)));
%         end
%         wholeInterval=dur/2;
%         tau = abs(wholeInterval-length(r)/sr);
%         Cm=(Rs+Rm)*1000*tau/(Rs*Rm);
% 
% function calcCellParams
% global state gh scopeInput scopeWave avgWave
% %tries to do the series calculation for the cell...
% try
%     if state.physiology.scope.calcSeries 	%Series Calculate....
%         amp =state.physiology.scope.amplitudeV;	%voltage step applied
%         dur =2*state.physiology.scope.pulseWidth;	%pulse width
%         sr = .001*state.physiology.scope.inputRate; 	% in kHz
%         pulse = mean(scopeInput(round(.65*sr*dur):round(.745*sr*dur)));	% baseline after exponential....
%         base = mean(scopeInput(round(.02*sr*dur):round(.23*sr*dur)));	% baseline for whole trace...
%         if state.physiology.scope.amplitudeV < 0
%             if pulse < base
%                 peak = min(scopeInput(round(.24*sr*dur):round(.26*sr*dur))); %peak for Rs Calcualtion
%             else    %error
%                 state.physiology.scope.Rseries = NaN;
%                 updateGUIByGlobal('state.physiology.scope.Rseries');
%                 state.physiology.scope.Rinput = NaN;
%                 updateGUIByGlobal('state.physiology.scope.Rinput');
%                 state.physiology.scope.Cm = NaN;
%                 updateGUIByGlobal('state.physiology.scope.Cm');
%                 return
%             end
%         else
%             if pulse > base
%                 peak = max(scopeInput(round(.24*sr*dur):round(.26*sr*dur))); %peak for Rs Calcualtion
%             else    %error
%                 state.physiology.scope.Rseries = NaN;
%                 updateGUIByGlobal('state.physiology.scope.Rseries');
%                 state.physiology.scope.Rinput = NaN;
%                 updateGUIByGlobal('state.physiology.scope.Rinput');
%                 state.physiology.scope.Cm = NaN;
%                 updateGUIByGlobal('state.physiology.scope.Cm');
%                 return
%             end
%         end
%         
%         %Calculate Rs
%         Rs = abs(1000*amp/(base-peak));
%         state.physiology.scope.Rseries = (Rs);
%         updateGUIByGlobal('state.physiology.scope.Rseries');
%         
%         % Calculate Rm from Rs
%         Rm = abs(1000*amp/(base-pulse)) - Rs;
%         state.physiology.scope.Rinput = (Rm);
%         updateGUIByGlobal('state.physiology.scope.Rinput');
%         
%         % Look for where signal drops below 1/e of the initial...
%         if state.physiology.scope.amplitudeV < 0
%             r=find(scopeInput(round(.251*sr*dur):round(.745*sr*dur)) > pulse-((pulse-peak)/exp(1)));
%         else
%             r=find(scopeInput(round(.251*sr*dur):round(.745*sr*dur)) < pulse+((peak-pulse)/exp(1)));
%         end
%         wholeInterval=dur/2;
%         tau = abs(wholeInterval-length(r)/sr);
%         Cm=(Rs+Rm)*1000*tau/(Rs*Rm);
%         state.physiology.scope.Cm = Cm;
%         updateGUIByGlobal('state.physiology.scope.Cm');
%         
%         if state.physiology.scope.runningAvg	
%             pulse = mean(avgWave(round(.65*sr*dur):round(.745*sr*dur)));	% baseline after exponential....
%             base = mean(avgWave(round(.02*sr*dur):round(.23*sr*dur)));	% baseline for whole trace...
%             if state.physiology.scope.amplitudeV < 0
%                 if pulse < base
%                     peak = min(avgWave(round(.24*sr*dur):round(.26*sr*dur))); %peak for Rs Calcualtion
%                 else    %error
%                     state.physiology.scope.Rseries = NaN;
%                     updateGUIByGlobal('state.physiology.scope.Rseries');
%                     state.physiology.scope.Rinput = NaN;
%                     updateGUIByGlobal('state.physiology.scope.Rinput');
%                     state.physiology.scope.Cm = NaN;
%                     updateGUIByGlobal('state.physiology.scope.Cm');
%                     return
%                 end
%             else
%                 if pulse > base
%                     peak = max(avgWave(round(.24*sr*dur):round(.26*sr*dur))); %peak for Rs Calcualtion
%                 else    %error
%                     state.physiology.scope.Rseries = NaN;
%                     updateGUIByGlobal('state.physiology.scope.Rseries');
%                     state.physiology.scope.Rinput = NaN;
%                     updateGUIByGlobal('state.physiology.scope.Rinput');
%                     state.physiology.scope.Cm = NaN;
%                     updateGUIByGlobal('state.physiology.scope.Cm');
%                     return
%                 end
%             end
%         
%             %Calculate RsAvg
%             RsAvg = abs(1000*amp/(base-peak));
%             state.physiology.scope.RseriesAvg = RsAvg;
%             updateGUIByGlobal('state.physiology.scope.RseriesAvg');
%             
%             % Calculate RmAvg from RsAvg
%             RmAvg = abs(1000*amp/abs(base-pulse))- RsAvg;
%             state.physiology.scope.RinputAvg = RmAvg;
%             updateGUIByGlobal('state.physiology.scope.RinputAvg');
%             
%             % Look for where signal drops below 1/e of the initial...
%            % Look for where signal drops below 1/e of the initial...
%            if state.physiology.scope.amplitudeV < 0
%                r=find(avgWave(round(.251*sr*dur):round(.745*sr*dur)) > pulse-((pulse-peak)/exp(1)));
%            else
%                r=find(avgWave(round(.251*sr*dur):round(.745*sr*dur)) < pulse+((peak-pulse)/exp(1)));
%            end
%             wholeInterval=dur/2;
%             tau = abs(wholeInterval - length(r)/sr);
%             CmAvg=(RsAvg+RmAvg)*1000*tau/(RsAvg*RmAvg);
%             state.physiology.scope.CmAvg = CmAvg;
%             updateGUIByGlobal('state.physiology.scope.CmAvg');
%         end
%         
%     else	% calculate input resistance always if possible
%         if state.physiology.scope.currentClamp & state.physiology.scope.patch1   %Current Clamp
%             amp =state.physiology.scope.amplitudeA;
%             dur =2*state.physiology.scope.pulseWidthPA;
%         elseif state.physiology.scope.currentClamp2 & state.physiology.scope.patch2   %Current Clamp
%             amp =state.physiology.scope.amplitudeA;
%             dur =2*state.physiology.scope.pulseWidthPA;
%         else   %Voltage Clamp
%             amp =state.physiology.scope.amplitudeV;
%             dur =2*state.physiology.scope.pulseWidth;
%         end
%         sr = .001*state.physiology.scope.inputRate; 	% in kH
%         pulse = mean(scopeInput(round(.65*sr*dur):round(.745*sr*dur)));	% baseline
%         base = mean(scopeInput(round(.02*sr*dur):round(.23*sr*dur)));
%         
%         if state.physiology.scope.currentClamp & state.physiology.scope.patch1   %Current Clamp
%             Rm = abs(1000*abs(base-pulse)/amp);
%         elseif state.physiology.scope.currentClamp2 & state.physiology.scope.patch2   %Current Clamp
%             Rm = abs(1000*abs(base-pulse)/amp);
%         else   %Voltage Clamp
%         
%             Rm = abs(1000*amp/abs(base-pulse));
%         end
%         
%         state.physiology.scope.Rinput = Rm;
%         updateGUIByGlobal('state.physiology.scope.Rinput');
%         if state.physiology.scope.runningAvg	
%             pulse = mean(avgWave(round(.65*sr*dur):round(.745*sr*dur)));	% baseline
%             base = mean(avgWave(round(.02*sr*dur):round(.23*sr*dur)));
%             if state.physiology.scope.currentClamp & state.physiology.scope.patch1   %Current Clamp
%                 RmAvg = abs(1000*abs(base-pulse)/amp);
%             elseif state.physiology.scope.currentClamp2 & state.physiology.scope.patch2   %Current Clamp
%                 RmAvg = abs(1000*abs(base-pulse)/amp);
%             else   %Voltage Clamp
%                 RmAvg = abs(1000*amp/abs(base-pulse));
%             end
%             state.physiology.scope.RinputAvg = RmAvg;
%             updateGUIByGlobal('state.physiology.scope.RinputAvg');
%         end
% 	end
% end
% 
% return;