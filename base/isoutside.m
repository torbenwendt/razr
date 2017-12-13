function [isout, isout_neg, isout_pos] = isoutside(room, pos)
% ISOUTSIDE - Check whether a point lies outside a room
%
% Usage:
%   [isout, isout_neg, isout_pos] = isoutside(room, pos)
%
% Input:
%   room            Room structure (see RAZR)
%   pos             Position vector [x, y, z] of point to check
%
% Output:
%   isout           True, if obj lies outside room
%   isout_neg,
%     isout_pos     True, if obj lies outside room in negative or positive direction
%                   in space, respectively

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


isout_pos = pos > room.boxsize;
isout_neg = pos < 0;
isout = any(isout_pos | isout_neg);
