function test(this, varargin)
global signalobjects;

signalobjects(this.ptr)
% signalobjects(this.ptr).options
% signalobjects(this.ptr).recursion
% signalobjects(this.ptr).analyticSpec
% signalobjects(this.ptr).numericSpecification

waveform = varargin{1};
amplitude = varargin{2};
offset = varargin{3};
frequency = varargin{4};
phi = varargin{5};
symmetry = varargin{6};
time = varargin{7};

set(this, 'waveform', waveform{1}, 'phi', phi(1), 'frequency', frequency(1), 'symmetry', symmetry(1), 'offset', offset(1)); 
legendString1 = sprintf('\\phi: %s [s]\nf: %s [Hz]\nsymmetry: %s\n', num2str(phi(1)), num2str(frequency(1)), num2str(symmetry(1)));
data1 = getdata(this, time);

set(this, 'waveform', waveform{2}, 'phi', phi(2), 'frequency', frequency(2), 'symmetry', symmetry(2), 'offset', offset(2));
legendString2 = sprintf('\\phi: %s [s]\nf: %s [Hz]\nsymmetry: %s\n', num2str(phi(2)), num2str(frequency(2)), num2str(symmetry(2)));
data2 = getdata(this, time);

set(this, 'waveform', waveform{3}, 'phi', phi(3), 'frequency', frequency(3), 'symmetry', symmetry(3), 'offset', offset(3)); 
legendString3 = sprintf('\\phi: %s [s]\nf: %s [Hz]\nsymmetry: %s\n', num2str(phi(3)), num2str(frequency(3)), num2str(symmetry(3)));
data3 = getdata(this, time);

f = figure;
domain = (1 : length(data1)) / signalobjects(this.ptr).sampleRate;
plot(domain, data1, ':o', domain, data2, ':s', domain, data3, ':x', 'MarkerSize', 5);

title('@signal/test');
ylabel('Amplitude [arbitrary units]');
xlabel('Time [s]');

legend(legendString1, legendString2, legendString3);

% f = figure;
% hold on;
% 
% signalobjects(this.ptr).debugMode = 1;
% signalobjects(this.ptr).plotAnalyticSignalGeneration = 1;
% 
% set(this, 'type', 'analytic', 'length', 500000, 'amplitude', 1, 'symmetry', 0);
% 
% domain = (0 : 1 / signalobjects(this.ptr).sampleRate : 1)';%/signalobjects(this.ptr).sampleRate;
% domain = domain(1 : end - 1);

% cspec = get(f, 'ColorMap');
% set(this, 'periodic', 0, 'distribution', 'gaussian', 'arg1', .5, 'arg2', .05);
% plot(domain, getdata(this, 1), 'Color', [0 0 1], 'MarkerEdgeColor', [0 0 1], 'MarkerFaceColor', [1 1 1], 'Marker', 's', 'MarkerSize', 3);
% 
% corder = get(get(f, 'Children'), 'ColorOrder');
% 
% set(this, 'periodic', 0, 'distribution', 'poisson', 'arg1', 1, 'arg2', 1);
% i = 2;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 's', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'binomial', 'arg1', 1, 'arg2', 1);
% i = 3;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 's', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'beta', 'arg1', 4, 'arg2', 4);
% i = 4;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 's', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'chi2', 'arg1', 1, 'arg2', 1);
% i = 5;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 's', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'ncchi2', 'arg1', 1, 'arg2', 1);
% i = 6;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 's', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'du', 'arg1', 1, 'arg2', 1);
% i = 7;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 's', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'exponential', 'arg1', 1, 'arg2', 1);
% i = 1;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 'o', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'f', 'arg1', 1, 'arg2', 1);
% i = 2;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 'o', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'ncf', 'arg1', 1, 'arg2', 1);
% i = 3;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 'o', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'gamma', 'arg1', 1, 'arg2', 1);
% i = 4;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 'o', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'geometric', 'arg1', 1, 'arg2', 1);
% i = 5;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 'o', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'lognormal', 'arg1', 1, 'arg2', 1);
% i = 6;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 'o', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'nbin', 'arg1', 1, 'arg2', 1);
% i = 7;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 'o', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'rayleigh', 'arg1', 1, 'arg2', 1);
% i = 1;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 'x', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 't', 'arg1', 1, 'arg2', 1);
% i = 2;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 'x', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'nct', 'arg1', 1, 'arg2', 1);
% i = 3;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 'x', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'weibull', 'arg1', 1, 'arg2', 1);
% i = 4;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 'x', 'MarkerSize', 3);
% 
% set(this, 'periodic', 0, 'distribution', 'hypergeometric', 'arg1', 1, 'arg2', 1);
% i = 5;
% plot(domain, getdata(this, 1), 'Color', corder(i, :), 'MarkerEdgeColor', corder(i, :), 'MarkerFaceColor', [1 1 1], 'Marker', 'x', 'MarkerSize', 3);
% 
% title('Aperiodic functions');
% legend('gaussian', 'poisson', 'binomial', 'beta', 'chi2', 'ncchi2', 'du', 'exponential', 'f', 'ncf', ...
%     'gamma', 'geometric', 'lognormal', 'nbin', 'rayleigh', 't', 'nct', 'weibull', 'hypergeometric');
% xlabel('Time [s]');
% ylabel('Amplitude [arbitrary units]');

return;