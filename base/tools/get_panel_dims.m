function [nrows, ncols, sub] = get_panel_dims(num)
% GET_PANEL_DIMS - Get number of row and column subplot-panels for a required number of plots.
%
% Usage:
%   [nrows, ncols, sub] = GET_PANEL_DIMS(num)
%
% Input:
%   num     Required number of plots.
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
% Version 0.90
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2016, Torben Wendt, Steven van de Par, Stephan Ewert,
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


nrows = ceil(sqrt(num));
ncols = ceil(num./nrows);

[sub1, sub2] = ind2sub([nrows, ncols], 1:num);
sub = [sub1', sub2'];
