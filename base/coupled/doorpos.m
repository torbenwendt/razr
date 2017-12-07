function [pos, cntr] = doorpos(room)
% DOORPOS - Transforms the room.door vector into a matrix containing the positions of all
% door vertices
%
% Usage:
%   pos = doorpos(room)
%
% Input:
%   room    room structure
%
% Output:
%	pos     Matrix containing door vertex positions. For each door (indexed by first index of pos)
%           the format is: [x1, x2; y1, y2; z1, z2]
%           (at the same time, both columns represent the positions of two opposing door vertices)
%   cntr    Center points of doors

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
% modified: 2016-04-26


[idx_wall, idx_rest] = idx_door_wall(room);

numDoors = size(room.door, 1);

pos = zeros(numDoors, 3, 2);

for d = 1:numDoors
    if sign(room.door(d, 1)) == 1
        pos(d, idx_wall(d), :) = [1, 1]*room.boxsize(idx_wall(d));
    end
    
    pos(d, idx_rest(d, :), :) = ...
        [room.door(d, [2, 3])', (room.door(d, [2, 3]) + room.door(d, [4, 5]))'];
end

cntr = mean(pos, 3);
