function [nrows, ncols, sub] = get_panel_dims(num, ncols)
% GET_PANEL_DIMS - Get number of row and column subplot-panels for a required number of plots.
%
% Usage:
%   [nrows, ncols, sub] = GET_PANEL_DIMS(num, [ncols])
%
% Input:
%   num     Required number of plots.
%   ncols   Desired number of columns. Optional; default: ceil(sqrt(num))
%
% Output:
%   nrows   Number of subplot panels in y direction
%   ncols   Number of subplot panels in x direction
%   sub     Subscript indices (x,y) for linear indices 1:num
%
% Example:
%   A number of 5 plots will be arranged in 3x2 subplot panels. (Space for one panel at (3,2) will
%   remain.)

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


if nargin < 2
    ncols = floor(sqrt(num));
end

if ncols > num || ncols < 1
    error('ncols must be an integer between 1 and num.');
end

nrows = ceil(num./ncols);

[sub1, sub2] = ind2sub([nrows, ncols], 1:num);
sub = [sub1', sub2'];
