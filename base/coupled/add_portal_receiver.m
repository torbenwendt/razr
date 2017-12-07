function [room, op] = add_portal_receiver(room, door_idx, op)
% add_portal_receiver - For a room in which a portal acts as a receiver, this function translates
% it such that an RIR can be calculated as usual.
%
% Usage:
%   [room, op] = add_portal_receiver(room, door_idx, op)
%
% Input:
%   room            room structure
%   door_idx        Index of door (specified in room) at which portal receiver shall be located.
%   op              Options structure (see RAZR)
%
% Output:
%   room        Modified room structure
%   op          Modified op structure

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
% 2015-06-22


dpos_all = doorpos(room);

% add receiver at center position of door surface:
dpos_rec = squeeze(dpos_all(door_idx, :, :));
room.recpos = dpos_rec(:, 1)' + (dpos_rec(:, 2)' - dpos_rec(:, 1)')/2;
room.recdir = [0 0];

% direction of discarded image sources:
op.ism_discd_directions = room.door(door_idx, 1);
