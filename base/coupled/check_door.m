function check_door(room)
% check_door - Checks for a room whether a door - if exists - lies not outside the room.
% If this is not the case, an error message is created.
% 
% Usage:
%   out = check_door(room)
% 
% Input:
%   room        room structure

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


if isfield(room, 'door')
	[idx_door, idx_rest] = idx_door_wall(room);
	
    vertices = [...
        room.door.pos(1) + room.door.size(1), ...
        room.door.pos(2) + room.door.size(2)];
    
	if any(vertices > room.boxsize(idx_rest)) || any(room.door.pos < 0)
		error('Door is not or not completely within the room');
	end
	
end
