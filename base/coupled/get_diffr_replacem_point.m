function point = get_diffr_replacem_point(room, door_idx, inverse_pos)
% GET_DIFFR_REPLACEM_POINT - Calculate a position behind a selected door which can be used
% for calculation of the FDN diffraction filter.
%
% Usage:
%   point = get_diffr_replacem_point(room, door_idx, [inverse_pos])
%
% Input:
%   room        Romm structure
%   door_idx    Index of door to be used
%   inverse_pos If true, calc point in front of door instead of behind
%
% Output:
%   point       Point position [x y z]

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


% Torben Wendt
% 2016-02-02

if nargin < 3
    inverse_pos = false;
end

if inverse_pos
    sgn = -1;
else
    sgn = +1;
end

width = room.door(door_idx, 4);
height = room.door(door_idx, 5);

[pos, door_cntr] = doorpos(room);
point = door_cntr(door_idx, :);
point(abs(room.door(door_idx, 1))) = ...
    point(abs(room.door(door_idx, 1))) - sgn*sign(room.door(door_idx, 1))*sqrt(width*height);
