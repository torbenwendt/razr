function [idx_wall, idx_rest] = idx_door_wall(room)
% idx_door_wall - For a room with doors, indices of room directions [x, y, z] are obtained,
% depending on the walls at which the doors are placed.
%
% Usage:
%	[idx_wall, idx_rest] = idx_door_wall(room)
%
% Input:
%	room        Room structure
%
% Output:
%   idx_wall	Absolute values of direction indices of walls with door
%   idx_rest	All other direction indices (sorted in ascending order)
%
% Example:
% If a door is placed at the wall in -y direction (i.e. if the wall surface normal vector
% pointing outside the room points into -y direction), the door specification reads:
%   room.door = [-2, ...]
% For this case the following values are returned:
%   idx_wall = 2
%   idx_rest = [1 3]

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


% Torben Wendt
% last modified: 2015-02-09 (extension to a vector of doors)

numDoors = length(room.door);

idx_all = 1:3;
idx_wall = abs([room.door.wall]);

idx_rest = zeros(numDoors, 2);

for d = 1:numDoors
    idx_rest(d, :) = sort(idx_all(idx_all~=idx_wall(d)));
end
