function [plot_handles, absspec, irsig] = plotFrqRsp(b, a, fs, varargin)
% PLOTFRQRSP - Plot frequency response(s) of filter(s).
% Note: This function has been replaced by plot_freqrsp and will be removed in
% future versions.
%
% Usage:
%   [handle, absspek, irsig] = PLOTFRQRSP(b, a, fs, varargin)
%
% Input:
%   b, a            Filter coefficient vectors as rows of a matrix or cell array.
%                   If more than one filter is specified (i.e. size(b, 1) > 1), the
%                   frequency of all filters applied in series are plotted, too (gray line).
%   fs              Sampling rate
%   varargin        Parameters, which will be passed to the plotting function semilogx()
%                   Additionally, the following options are provided by this function:
%                   'mode'      If b, a contain coefficient vectors for more than one filter,
%                               it is specified, which freqency responce is plotted. Available opts:
%                               'sgl': Every single filter
%                               'casc': All filters in cascade
%                               'all': Both, single filters and cascade
%                               Default: 'all'
%                   'ax'        Axes, in which the frequency response shall be plotted, default:
%                               new axes
%                   'casc_opts' Cell array of varargin passed to call of cascaded-filters plot
%
% Output:
%   plot_handles    Plot handles
%   absspec         Frequency responses of filters in dB
%   irsig           Impulse responses of filters

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


%% parse varargin for custom options

options  = {'mode', 'ax', 'casc_opts'};
defaults = {'all',  [],   {'color', [1 1 1]*0.5, 'linewidth', 4}};

[opts, varargin] = extract_args(options, defaults, varargin);


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

numFilt     = size(b, 1);
maxCoeffLen = max(cellfun('length', [b; a]));

%% calc impulse responses and fft

ilen   = max(4410, 2*maxCoeffLen);                  % impulse signal length for ir calc
irsig  = [ones(1, numFilt); zeros(ilen - 1, numFilt)];
irsig1 = [1; zeros(ilen-1, 1)];

for k = 1:numFilt
    irsig(:, k) = filter(b{k}, a{k}, irsig(:, k));  % ir for each filter
    irsig1      = filter(b{k}, a{k}, irsig1);       % ir for all filters in series
end

absspec  = 20*log10(abs(fft(irsig)));
absspec1 = 20*log10(abs(fft(irsig1)));

%% plot

plot_handles = [];

if strcmp(opts.mode, 'all') || strcmp(opts.mode, 'sgl')
    plot_args = {linspace(1, fs, ilen), absspec, varargin{:}};
    if ~isempty(opts.ax)
        plot_args = [{opts.ax}, plot_args];
    end
    
    plot_handle = semilogx(plot_args{:});
    plot_handles = [plot_handles; plot_handle];
    hold on;
end

if strcmp(opts.mode, 'all') || strcmp(opts.mode, 'casc')
    plot_handle = semilogx(linspace(1, fs, ilen), absspec1, opts.casc_opts{:});
    plot_handles = [plot_handles; plot_handle];
end

xlabel('Frequency (Hz)')
ylabel('Gain (dB)')

xlim([25 fs/2])
xtick = octf(125/2, 16e3);
set(gca, 'xtick', xtick, 'xticklabel', freq2str(xtick))
grid on;
hold off;
