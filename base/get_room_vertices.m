function vertices = get_room_vertices(b, wall_id)
% get_room_vertices - For each wall of a room, two opposing vertex points are returned.
%
% Usage:
%   [vertices, wall_idx] = get_room_vertices(b, wall_idx)
%
% Input:
%   b           Room dimensions [x, y, z] (Field "boxsize" of room structure)
%   wall_id     Wall IDs, for which vertices shall be returned. Conversion to walls:
%               [-z, -y, -x, +x, +y, +z] <-> [-3, -2, -1, +1, +2, +3]
%
% Output:
%   vertices    3-dim. matrix containing the vertex points.
%               1. dim: walls, 2. dim: vertices, 3. dimensions.

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
    wall_id = [-3, -2, -1, +1, +2, +3];
end

v = zeros(7, 2, 3);     % 6 walls + dummy, 2 vertices, 3 dimensions

v(1, :, :) = [0, 0, 0; b(1), b(2), 0];   % -z
v(2, :, :) = [0, 0, 0; b(1), 0, b(3)];   % -y
v(3, :, :) = [0, 0, 0; 0, b(2), b(3)];   % -x
v(5, :, :) = [b; b(1), 0, 0];            % +x
v(6, :, :) = [b; 0, b(2), 0];            % +y
v(7, :, :) = [b; 0, 0, b(3)];            % +z

vertices = v(wall_id + 4, :, :);
