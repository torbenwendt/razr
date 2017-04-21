function h = plot_ispos(room, ism_data, varargin)
% PLOT_ISPOS - Plot image source positions
%
% Usage:
%   h = PLOT_ISPOS(room, ism_data, Name, Value)
%
% Input:
%   room            Room structure (see RAZR)
%   ism_data        ISM metadata (output of RAZR or IMAGE_SOURCE_MODEL)
%
% Optional Name-Value-pair arguments (defaults in parentheses):
%   scene_opts      ({}) Cell array which can contain any Name-Value-Args that
%                   can be passed to SCENE
%   order           ([]) ISM orders to be plotted. Set empty for all available orders
%
% Output:
%   h               Struct containing plot handles
%
% See also: PLOT_DIFFR_FILTERS

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
    error('Not enough input parameters.');
end

p = inputParser;
addparam = get_addparam_func;
addparam(p, 'scene_opts', {});
addparam(p, 'order', []);
parse(p, varargin{:});

if isempty(p.Results.order)
    order = unique(ism_data.order);
else
    order = p.Results.order;
end

idx_o = ismember(ism_data.order, order);


h = scene(room, p.Results.scene_opts{:});
hold(h.ax, 'on');

h.plot.img_src = plot3(h.ax, ...
    ism_data.positions(ism_data.idx_auralize & idx_o, 1), ...
    ism_data.positions(ism_data.idx_auralize & idx_o, 2), ...
    ism_data.positions(ism_data.idx_auralize & idx_o, 3), ...
    'x', 'color', [0 1 1]*0.8, 'linewidth', 2);

h.plot.img_src_invalid = plot3(h.ax, ...
    ism_data.positions(~ism_data.idx_auralize & idx_o, 1), ...
    ism_data.positions(~ism_data.idx_auralize & idx_o, 2), ...
    ism_data.positions(~ism_data.idx_auralize & idx_o, 3), ...
    'x', 'color', [1 1 1]*0.8, 'linewidth', 2);

axis('auto');

if nargout == 0
    clear h;
end
