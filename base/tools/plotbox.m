function handle = plotbox(ax, b, pos, varargin)
% PLOTBOX - Sketch a cuboid box
%
% Usage:
%   handle = PLOTBOX(ax, b, pos, varargin)
%
% Input:
%   ax      Axes handle
%   b       Box size [x y z]
%   pos     Box position [x y z]
%
% Output:
%   handle  Plot handle

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


posr = repmat(pos, 5, 1);

vertices_front = posr + [...
    0       0       0       ;...
    b(1)    0       0       ;...
    b(1)    0       b(3)    ;...
    0       0       b(3)    ;...
    0       0       0       ];

vertices_back = vertices_front + repmat([0, b(2), 0], 5, 1);

vertices_left = posr + [...
    0       0       0       ;...
    0       b(2)    0       ;...
    0       b(2)    b(3)    ;...
    0       0       b(3)    ;...
    0       0       0       ];

vertices_right = vertices_left + repmat([b(1), 0, 0], 5, 1);

handle(1) = plot3(ax, vertices_front(:, 1), vertices_front(:, 2), vertices_front(:, 3), ...
    'color', 'k', varargin{:});
hold on;
handle(2) = plot3(ax, vertices_back(:, 1),  vertices_back(:, 2),  vertices_back(:, 3), ...
    'color', 'k', varargin{:});
handle(3) = plot3(ax, vertices_left(:, 1),  vertices_left(:, 2),  vertices_left(:, 3), ...
    'color', 'k', varargin{:});
handle(4) = plot3(ax, vertices_right(:, 1), vertices_right(:, 2), vertices_right(:, 3), ...
    'color', 'k', varargin{:});
