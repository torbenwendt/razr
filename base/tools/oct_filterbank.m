function [b, a] = oct_filterbank(f0, fs, includeEdges, do_plot)
% OCT_FILTERBANK - Get filter coefficients for octave filterbank.
%
% Usage:
%   [b, a] = OCT_FILTERBANK(f0, fs, [includeEdges], [do_plot])
%
% Input:
%   f0              Vector containing octave band center frequencies
%   fs              Sampling rate in Hz
%   includeEdges    Get also filters for the outer spectral regions? (optional, default: false)
%   do_plot         Create a test plot of frequency responses? (optional, default: false)
%
% Output:
%   b, a            Matrices containing the filter coefficient vectors in its rows

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.92
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
% University Oldenburg, Germany.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------


%% test call

if nargin == 0
    fs = 44100;
    f0 = [250 500 1e3 2e3 4e3 8e3];
    %f0 = [250 500 1e3];
    includeEdges = 1;
    do_plot = true;
    
    [b, a] = oct_filterbank(f0, fs, includeEdges, do_plot);
    
    return;
end


%% input

if nargin < 4
    do_plot = false;
    if nargin < 3
        includeEdges = 0;
    end
end

includeEdges = sign(double(includeEdges));  % includeEdges also needed as number of value 0 or 1

%%

num_f0 = length(f0);    % number of center freqs
nButter = 4;            % order of each filter
fb = f0;                % bandwidths

% calc [centerfreq, bandwidth] -> [cutofffreq]:
f1 = sqrt(f0.^2 + fb.^2/4) - fb/2;
f2 = sqrt(f0.^2 + fb.^2/4) + fb/2;

% normalize:
f1 = f1/fs*2;
f2 = f2/fs*2;

b = zeros(num_f0 + 2*includeEdges, 2*nButter + 1);
a = b;

% bandpass filters:
for n = 1:num_f0
    [b_tmp, a_tmp] = butter(nButter, [f1(n), f2(n)]);
    b(n+includeEdges, :) = b_tmp;
    a(n+includeEdges, :) = a_tmp;
end

% edges:
if includeEdges
    fcut1 = min(f0)*(sqrt(5) + 1)/4;  % yields from f2/2 for fb = f0
    fcut2 = max(f0)*(sqrt(5) - 1);    % yields from f1*2 for fb = f0
    
    [b_tmp, a_tmp] = butter(nButter, fcut1/fs*2, 'low');
    b(1, :) = [b_tmp, zeros(1, nButter)];
    a(1, :) = [a_tmp, zeros(1, nButter)];
    
    [b_tmp, a_tmp] = butter(nButter, fcut2/fs*2, 'high');
    b(end, :) = [b_tmp, zeros(1, nButter)];
    a(end, :) = [a_tmp, zeros(1, nButter)];
end


%% plot

if do_plot
    ilen = fs/10;
    
    [h, absspec, irsig] = plot_freqrsp(b, a, 'fs', fs, 'disp_mode', 'sgl', 'irlen', ilen);
    hold on;
    sumspec = 20*log10(abs(fft(sum(irsig.sgl, 2))));
    semilogx(h.ax, linspace(1, fs, ilen), sumspec, '-.', 'color', 'k', 'linewidth', 2);
    
    ylim([-100, 10])
    xlim2 = get(gca, 'xlim');
    xlim([100, xlim2(2)])
end
