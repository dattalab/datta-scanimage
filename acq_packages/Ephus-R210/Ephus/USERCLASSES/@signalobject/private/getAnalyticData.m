% SIGNAL/private/getAnalyticData - Retrieve a raw numeric array of SIGNAL data.
%
% SYNTAX
%  data = getAnalyticData(SIGNAL, time) - Gets <time> seconds worth of datapoints at SIGNAL.sampleRate
%                                         of the analytically specified periodic SIGNAL.
%
% NOTES
%  The total number of data points is defined as ceil(time * get(SIGNAL, sampleRate)).
%
% Changed:
%  1/24/05 Tim O'Connor (TO012405b): Insert the signal's name into the figure's title, when plotting.
%  1/24/05 Tim O'Connor (TO012405c): Calls to createTimeVector for sin and cos waves should pass the signal's period, not 'time'.
%  2/3/05 Tim O'Connor (TO020305c): Added the warnAnalyticPadding variable.
%  2/3/05 Tim O'Connor (TO020305d): Added the noPadding variable.
%  TO053008D - Fixed to not bail out when working with equational signals. -- Tim O'Connor 5/30/08
%
% Created 8/19/04 - Tim O'Connor
% Copyright - Cold Spring Harbor Laboratories/Howard Hughes Medical Institute 2004
function data = getAnalyticData(this, time)
global signalobjects;

if time == 0
    warning('No data requested (0 time).');
end

pointer = indexOf(this);
data = [];

if signalobjects(pointer).sampleRate <= 0
    error('Data can not be generated for sample rates <= 0: %s', num2str(signalobjects(pointer).sampleRate));
end

%Make sure the specification is legal.
if (signalobjects(pointer).periodic && signalobjects(pointer).equational) ||  ...
        (signalobjects(pointer).periodic && signalobjects(pointer).distributional) || ...
        (signalobjects(pointer).distributional && signalobjects(pointer).equational)
    error('More than one type of analytical specification (periodic, equational, distributional) is not allowed for @signal object ''%s''.', ...
        signalobjects(pointer).name);
end

%Calculate total number of samples.
samples = ceil(time * signalobjects(pointer).sampleRate);

if signalobjects(pointer).frequency < 0
    error('Data can not be generated for negative frequencies: %s', num2str(signalobjects(pointer).sampleRate));
elseif (signalobjects(pointer).frequency == 0 || signalobjects(pointer).amplitude == 0) && ~signalobjects(pointer).equational
    %DC
    if signalobjects(pointer).repeatable || signalobjects(pointer).length < 0
        data = signalobjects(pointer).offset + zeros(samples, 1);
    else
        data = signalobjects(pointer).offset + zeros(ceil(signalobjects(pointer).length * signalobjects(pointer).sampleRate), 1);
    end
    return;
end

if signalobjects(pointer).sampleRate <= 2 * signalobjects(pointer).frequency && signalobjects(pointer).eagerWarningMode
    warning('The sampleRate (%s Hz) of a @signal object (%s) should be at least two times higher than the frequency (%s Hz) to maintain signal integrity.', ...
        num2str(signalobjects(pointer).sampleRate), signalobjects(pointer).name, num2str(signalobjects(pointer).frequency));
end

%Create the prototype of a periodic signal.
if signalobjects(pointer).periodic
    samplesPerPeriod = ceil(signalobjects(pointer).sampleRate / signalobjects(pointer).frequency);
    
    switch lower(signalobjects(pointer).waveform)
        %Periodic functions.
        case {'sin', 'sine', 'sinusoid', 'sinusoidal'}
            %Time vector.
            t = createTimeVector(this, 1 / signalobjects(pointer).frequency);%TO012405c - This should work on 1 period, not the whole signal duration.

            %Phase will get accounted for later.
            data = signalobjects(pointer).amplitude * sin(2 * pi * signalobjects(pointer).frequency * t) ...
                + signalobjects(pointer).offset;
            
        case {'cos', 'cosine', 'cosinusoid', 'cosinusoidal'}
            %Time vector.
            t = createTimeVector(this, 1 / signalobjects(pointer).frequency);%TO012405c - This should work on 1 period, not the whole signal duration.
            
            %Phase will get accounted for later.
            data = signalobjects(pointer).amplitude * cos(2 * pi * signalobjects(pointer).frequency * t) ...
                + signalobjects(pointer).offset;
            
        case {'tri', 'triangle', 'triangular'}
            %This computation forces the turning points to fall on actual samples, so that the amplitude
            %is garaunteed. This means that the symmetry may not be an exact match for what was specified,
            %to within a margin of error determined by the sample rate (it gets rounded off to the nearest sample).
            
            %The midpoint is defined by a fraction of the period, depending on the symmetry.
            midpoint = round((1 + signalobjects(pointer).symmetry) / 2 * samplesPerPeriod);

            if midpoint <= 1
                risingData = [];

                fallingSlope = -signalobjects(pointer).amplitude / max(1, samplesPerPeriod - 1);
                fallingData = fallingSlope * (1 : samplesPerPeriod) + 0.5 * signalobjects(pointer).amplitude - fallingSlope;
            elseif midpoint >= samplesPerPeriod
                fallingData = [];

                risingSlope = signalobjects(pointer).amplitude / midpoint;
                risingData = risingSlope * (1 : midpoint) - 0.5 * signalobjects(pointer).amplitude - risingSlope;
            elseif 1 < midpoint && midpoint < samplesPerPeriod
                risingSlope = signalobjects(pointer).amplitude / midpoint;
                risingData = risingSlope * (1 : midpoint) - 0.5 * signalobjects(pointer).amplitude - risingSlope;

                fallingSlope = -signalobjects(pointer).amplitude / (samplesPerPeriod - midpoint);
                fallingData = fallingSlope * (midpoint  + 1 : samplesPerPeriod) + 0.5 * signalobjects(pointer).amplitude - fallingSlope * midpoint;
            end

            %Combine and apply offset.
            data = cat(2, risingData, fallingData)' + signalobjects(pointer).offset;
        case {'sq', 'square'}
            data = signalobjects(pointer).offset + zeros(ceil(signalobjects(pointer).sampleRate / signalobjects(pointer).frequency), 1);
            midpoint = ceil((1 + signalobjects(pointer).symmetry) / 2 * length(data));

            if midpoint > 1
                %Low value.
                data(1 : midpoint) = signalobjects(pointer).offset - .5 * signalobjects(pointer).amplitude;
            end
            
            if midpoint < length(data) - 1
                %High value.
                if midpoint == 0
                    midpoint = 1;
                end
                data(midpoint + 1 : length(data)) = signalobjects(pointer).offset + .5 * signalobjects(pointer).amplitude;
            end
            
        otherwise
            error('The @signal object (%s) has an invalid waveform: %s', signalobjects(pointer).name, signalobjects(pointer).waveform);
    end
elseif signalobjects(pointer).equational
    %Time vector.
    t = createTimeVector(this, time);

    %signalobjects(pointer).equation is some calculation performed on `t`, and correctness of this statement is left up to the user.
    try
        eval(['data = ' signalobjects(pointer).equation ';']);
        if length(data) ~= length(t)
            error('Not enough data returned from calculation. Expected array of length %s, found array of length %s.', ...
                num2str(length(data)), num2str(length(t)));
        end
    catch
        error('Invalid equation ''f(t) = %s'' for @signal %s. Error: %s', signalobjects(pointer).equation, signalobjects(pointer).name, lasterr);
    end
elseif signalobjects(pointer).distributional
    %Time vector.
    t = createTimeVector(this, time);

    %Aperiodic functions.
    switch lower(signalobjects(pointer).distribution)
        case {'gauss', 'gaussian', 'normal'}
            %arg1 = mean, arg2 = variance
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * normpdf(t, signalobjects(pointer).arg1, signalobjects(pointer).arg2);
% plot((1:length(t)) / signalobjects(pointer).sampleRate, t, (1:length(t)) / signalobjects(pointer).sampleRate, data)
        case {'poiss', 'poisson'}
            %arg1 = lambda
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * poisspdf(t, signalobjects(pointer).arg1);
            
        case {'bin', 'bino', 'binomial'}
            %arg1 = N, arg2 = P
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * binopdf(t, signalobjects(pointer).arg1, signalobjects(pointer).arg2);
            
        case {'beta'}
            %arg1 = A, arg2 = B
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * betapdf(t, signalobjects(pointer).arg1, signalobjects(pointer).arg2);
            
        case {'chi', 'chi2', 'chi-squared', 'chi^2', 'chi-sq', 'chisquared', 'chisq'}
            %arg1 = V
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * chi2pdf(t, signalobjects(pointer).arg1);
            
        case {'ncchi2', 'nc-chi2', 'noncentral-chi2', 'non-central chi-squared', 'noncentral chi-squared'}
            %arg1 = V, arg2 = delta
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * ncx2pdf(t, signalobjects(pointer).arg1, signalobjects(pointer).arg2);
            
        case {'discrete-uniform', 'discreteuniform', 'du', 'discrete uniform'}
            %arg1 = N
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * unidpdf(t, signalobjects(pointer).arg1);
            
        case {'exp', 'exponential'}
            %arg1 = mean
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * exppdf(t, signalobjects(pointer).arg1);
            
        case {'f'}
            %arg1 = v1, arg2 = v2
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * fpdf(t, signalobjects(pointer).arg1, signalobjects(pointer).arg2);
            
        case {'ncf', 'nc-f', 'noncentral-f', 'noncentralf'}
            %arg1 = nu1, arg2 = nu2, arg3 = delta
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * ncfpdf(t, signalobjects(pointer).arg1, signalobjects(pointer).arg2, ...
                signalobjects(pointer).arg3);
            
        case {'gamma'}
            %arg1 = A, arg2 = B
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * gampdf(t, signalobjects(pointer).arg1, signalobjects(pointer).arg2);
            
        case {'geo', 'geometric'}
            %arg1 = P
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * geopdf(t, signalobjects(pointer).arg1);
            
        case {'logn', 'lognormal'}
            %arg1 = mean, arg2 = variance
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * lognpdf(t, signalobjects(pointer).arg1, signalobjects(pointer).arg2);
            
        case {'nbin', 'negative-binomial', 'negativebinomial', 'negative binomial'}
            %arg1 = R, arg2 = P
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * nbinpdf(t, signalobjects(pointer).arg1, signalobjects(pointer).arg2);
            
        case {'rayleigh', 'rayl'}
            %arg1 = B
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * raylpdf(t, signalobjects(pointer).arg1);
            
        case {'t'}
            %arg1 = V
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * tpdf(t, signalobjects(pointer).arg1);
            
        case {'nct', 'noncentral-t', 'noncentralt', 'non-central t', 'noncentral t'}
            %arg1 = V, arg2 = delta
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * nctpdf(t, signalobjects(pointer).arg1, signalobjects(pointer).arg2);
            
        case {'weibull', 'weib'}
            %arg1 = A, arg2 = B
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * weibpdf(t, signalobjects(pointer).arg1, signalobjects(pointer).arg2);
            
        case {'hyge', 'hyper-geometric', 'hypergeometric'}
            %arg1 = A, arg2 = B
            data = signalobjects(pointer).offset + signalobjects(pointer).amplitude * hygepdf(t, signalobjects(pointer).arg1, signalobjects(pointer).arg2, ...
                signalobjects(pointer).arg3);
            
        otherwise
            error('The @signal object (%s) has an invalid distribution: %s', signalobjects(pointer).name, signalobjects(pointer).distribution);
    end
else
    error('There is no form (equational, periodic, distributional) specified for this @signal object ''%s''.', signalobjects(pointer).name);
end

if signalobjects(pointer).debugMode & signalobjects(pointer).plotAnalyticSignalGeneration
    f = figure;
    set(f, 'Name', signalobjects(pointer).name);%TO012405b - Insert the signal's name into the figure's title.
    h1 = axes('Position', [0 0 1 1], 'Visible', 'Off');
    h2 = axes('Position', [.1 .20 .85 .4]);
    axes('Position', [.1 .75 .85 .2]);
    plot((1:length(data)) / signalobjects(pointer).sampleRate, data, '-o', 'MarkerSize', 5);
    if signalobjects(pointer).periodic
        title(sprintf('@signal: Periodic - ''%s'' One Period At Zero Phase', signalobjects(pointer).waveform));
    else
        title(sprintf('@signal: Aperiodic - ''%s'' One Period At Zero Phase', signalobjects(pointer).distribution));
    end
    xlabel('Time [s]');

    set(f, 'CurrentAxes', h1);
    if signalobjects(pointer).periodic
        detailsText = sprintf('\nFrequency: %s [Hz]\nAmplitude: %s\n\\Phi: %s [s]', ...
            num2str(signalobjects(pointer).frequency), num2str(signalobjects(pointer).amplitude), num2str(signalobjects(pointer).phi));
        text(.1, .1, detailsText, 'FontSize', 10);
        detailsText = sprintf('\nSampleRate: %s [Hz]\nOffset: %s\nSymmetry: %s', ...
            num2str(signalobjects(pointer).sampleRate), num2str(signalobjects(pointer).offset), num2str(signalobjects(pointer).symmetry));
        text(.7, .1, detailsText, 'FontSize', 10);
    else
        detailsText = sprintf('\nArg1: %s \nArg2: %s\nArg3: %s', ...
            num2str(signalobjects(pointer).arg1), num2str(signalobjects(pointer).arg2), num2str(signalobjects(pointer).arg3));
        text(.1, .1, detailsText, 'FontSize', 10);
    end
end

%Make it a column vector (by default), to be easily compatible with the daq toolbox.
if size(data, 2) > size(data, 1)
    data = data';
end

%Replicate out the periodic signal.
%This must also extend it out enough to account for the discrete phase shift operation.
if time > (1 / signalobjects(pointer).frequency)
    if signalobjects(pointer).repeatable
        repetitions = ceil((time + abs(signalobjects(pointer).phi)) * signalobjects(pointer).sampleRate / length(data));
        %Watch out for repetition on the first and last sample points.
        %Do this in two stages, because the second stage will be assured to have enough datapoints for the subsindex.
        if length(data) > 1
            data = cat(1, data(1), repmat(data(2 : end), repetitions, 1));
            data = cat(1, data, data(2 : repetitions));
        else
            data = data * ones(repetitions, 1);
        end
    else
        data = cat(1, data, data(end) * ones(samples - length(data), 1));
    end
end

%Apply any needed phase shifts.
phase = ceil(signalobjects(pointer).phi * signalobjects(pointer).sampleRate);
%Negative phase shifts right, positive shifts left (following trigonometric convention).
if phase < 0
    buffer = data(end - abs(phase) : end);
    data = data(1 : end - abs(phase) - 1);
    data = cat(1, buffer, data);
elseif phase > 0
    buffer = data(1 : phase);
    data = data(phase + 1 : end);
    data = cat(1, data, buffer);
end

%Trim excess from replication.
maxAllowed = ceil(signalobjects(pointer).length * signalobjects(pointer).sampleRate);
%TO020305d - Only pad if padding is allowed, new field: noPadding.
if maxAllowed < ceil(time * signalobjects(pointer).sampleRate) && maxAllowed > 0 ...
    && ~signalobjects(pointer).repeatable && ~signalobjects(pointer).noPadding

    data(ceil(signalobjects(pointer).length / signalobjects(pointer).sampleRate) : end) = ...
        data(ceil(signalobjects(pointer).length / signalobjects(pointer).sampleRate));
    %TO020305c - Only print a warning if both eagerWarningMode and warnAnalyticPadding are enabled.
    if signalobjects(pointer).warnAnalyticPadding && signalobjects(pointer).eagerWarningMode
        warning('More data was requested than this @signal object (%s) can generate (%s seconds). The last datapoint in the signal will be repeated, to fill out the array.', ...
            signalobjects(pointer).name, signalobjects(pointer).length);
    end
elseif length(data) > (time * signalobjects(pointer).sampleRate)
    data = data(1 : ceil(time * signalobjects(pointer).sampleRate));
end

if signalobjects(pointer).debugMode && signalobjects(pointer).plotAnalyticSignalGeneration
    set(f, 'CurrentAxes', h2);
    plot((1:length(data)) / signalobjects(pointer).sampleRate, data, ':o');
    title(sprintf('@signal: %s Seconds Of Signal', num2str(time)));
    xlabel('Time [s]');
    ylabel('Amplitude [arbitrary units]');
end

return;