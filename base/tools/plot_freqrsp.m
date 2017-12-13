function [h, absspec, irsig] = plot_freqrsp(b, a, varargin)
% PLOT_FREQRSP - Plot frequency response(s) of filter(s).
% Multiple single filters and/or all filters cascaded.
%
% Usage:
%   [h, absspec, irsig] = PLOT_FREQRSP(b, a, Name, Value)
%
% Required input:
%   b, a            Filter coefficient vectors as rows of a matrix or cell array.
%
% Optional Name-Value-pair arguments (defaults in parentheses):
%   fs              (44100) Sampling rate in Hz
%   disp_mode       ('sgl')
%                   'sgl': multiple filters are plotted
%                   'csc': cascade of multiple filters are plotted
%                   'all': both, 'sgl' and 'csc'
%   casc_mode       ('filt')
%                   'filt': Filters are cascaded applying filter() on impulse response
%                   'conv': Filter coefficients are convolved (might lead to instabilities)
%   irlen           (4410) Length of dirac impulse to be filtered (in samples)
%   plot_opts_sgl   ({}) Cell array of Name-Value arguments to be passed to the plot function
%                   plotting the single filters (e.g. color, linewidth)
%   plot_opts_csc   ({'color', 'k', 'linewidth', 1.5}) Same as plot_opts_sgl, but for cascade
%   ax              ([]) Handle of axes to plot curves into. If empty, new axes will be created.
%
% Output:
%   h               Structure containing handles for figure, axes, plot
%   absspec         Structure containing frequency responses of filters in dB
%   irsig           Structure containing impulse responses of filters

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.93
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


%% imput parameters

p = inputParser;
addparam = get_addparam_func;
addparam(p, 'fs', 44100);
addparam(p, 'disp_mode', 'sgl');   % 'sgl', 'csc', 'all'
addparam(p, 'casc_mode', 'filt');  % 'filt', 'conv'
addparam(p, 'irlen', 4410);
addparam(p, 'plot_opts_sgl', {});
addparam(p, 'plot_opts_csc', {'color', 'k', 'linewidth', 1.5});
addparam(p, 'ax', []);

%addparam(p, 'calc_mode', 'ir');   % 'ir', 'freqz'
%addparam(p, 'n', 512);

parse(p, varargin{:});

do_sgl = any(strcmp(p.Results.disp_mode, {'sgl', 'all'}));
do_csc = any(strcmp(p.Results.disp_mode, {'csc', 'all'}));

%% convert input to cell array

if ~iscell(b)
    b = mat2cell(b, ones(1, size(b, 1)), size(b, 2));
else
    b = b(:);
end
if ~iscell(a)
    a = mat2cell(a, ones(1, size(a, 1)), size(a, 2));
else
    a = a(:);
end

if size(b, 1) ~= size(a, 1)
    error('Number of nominator and denominator coefficients must match.');
end

numFilt     = size(b, 1);
maxCoeffLen = max(cellfun('length', [b; a]));

%% calc impulse responses and fft

ilen = max(p.Results.irlen, 2*maxCoeffLen);

if do_sgl
    irsig.sgl = zeros(ilen, numFilt);
    irsig.sgl(1, :) = 1;
    
    for k = 1:numFilt
        irsig.sgl(:, k) = filter(b{k}, a{k}, irsig.sgl(:, k));
    end
    
    absspec.sgl = 20*log10(abs(fft(irsig.sgl)));
end

if do_csc
    irsig.csc = zeros(ilen, 1);
    irsig.csc(1) = 1; 
    
    switch p.Results.casc_mode
        case 'filt'
            for k = 1:numFilt
                irsig.csc = filter(b{k}, a{k}, irsig.csc);
            end
            
        case 'conv'
            bb = b{1};
            aa = a{1};
            for k = 2:numFilt
                bb = conv(bb, b{k});
                aa = conv(aa, a{k});
            end
            
            irsig.csc = filter(bb, aa, irsig.csc);
    end
    
    absspec.csc = 20*log10(abs(fft(irsig.csc)));
end


%% plot

if isempty(p.Results.ax)
    h.fig = figure;
    h.ax = gca;
else
    h.ax = p.Results.ax;
end

h.plot = [];

freq = linspace(1, p.Results.fs, ilen);

if do_sgl
    plot_opts_sgl = p.Results.plot_opts_sgl;
    plot_handle = semilogx(h.ax, freq, absspec.sgl, plot_opts_sgl{:});
    h.plot = [h.plot; plot_handle];
    hold(h.ax, 'on');
end

if do_csc
    plot_opts_csc = p.Results.plot_opts_csc;
    plot_handle = semilogx(h.ax, freq, absspec.csc, plot_opts_csc{:});
    h.plot = [h.plot; plot_handle];
end

xlabel(h.ax, 'Frequency (Hz)')
ylabel(h.ax, 'Gain (dB)')

xlim(h.ax, [25 p.Results.fs/2])
xtick = octf(125/2, 16e3);
grid(h.ax, 'on');
set(h.ax, 'xtick', xtick, 'xminortick', 'off', 'xminorgrid', 'off', ...
    'xticklabel', freq2str(xtick));
hold(h.ax, 'off');

if nargout == 0
    clear h;
end
