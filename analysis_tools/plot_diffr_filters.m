function h = plot_diffr_filters(ism_data, fs)
% PLOT_DIFFR_FILTERS - Plot diffraction filters
%
% Usage:
%   h = PLOT_DIFFR_FILTERS(ism_data, [fs])
%
% Input:
%   ism_data        ISM metadata (output of RAZR or IMAGE_SOURCE_MODEL)
%   fs              Sampling rate in Hz (default: 44100)
%
% Output:
%   h               Struct containing plot handles
%
% See also: PLOT_ISPOS

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.91
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
% Universitaet Oldenburg.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------


if nargin < 2
    fs = 44100;
end

if ~isfield(ism_data, 'b_diffr') || isempty(ism_data.b_diffr)
    disp('No diffraction filters existing.')
    if nargout > 0
        h = [];
    end
    return;
end


ords = unique(ism_data.order);
numOrd = length(ords);
colors = lines(numOrd);
lw = 1;

h.fig = figure;

for n = numOrd:-1:1
    ord = ords(n);
    idx_o = find(ism_data.order == ord);
    for k = 1:length(idx_o)
        h.freqrsp{n}{k} = plot_freqrsp(...
            ism_data.b_diffr{idx_o(k)}, ism_data.a_diffr{idx_o(k)}, ...
            'ax', gca, 'fs', fs, 'disp_mode', 'csc', ...
            'plot_opts_csc', {'color', colors(n, :), 'linewidth', lw + 2*(ord == 0)});
        hold on;
    end
    h_plot_leg(n) = h.freqrsp{n}{1}.plot;
end

hold off;

title('Diffraction filters');
leg_str = strsplit(sprintf('ISM order = %d#', ords), '#');

legend(h_plot_leg, leg_str(1:end-1), 'location', 'southwest');

if nargout == 0
    clear h;
end
