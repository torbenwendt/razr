function [ap, angles] = aperture_door(room, door_idx, point, do_plot)
% aperture2door - For a specified point in a room, the angular aperture to a specified door is
% returned.
%
% Usage:
%   [ap, angles] = aperture2door(room, door_idx, point, [do_plot])
%
% Input:
%   room        Room structure
%   door_idx    Index of door to be regarded
%   point       Position vector of point in room
%   do_plot     If true, make a test plot (optional, default: false)
%
% Output:
%   ap          Matrix containing angular apertures. Rows: doors, columns; azimuth and elevation
%   angles      Signed angles between point-door connections and door normal (projection x angles)

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
% modified last: 2015-07-31


if nargin < 4
    do_plot = false;
end

pr = [1, 2; 2, 3; 1, 3];    % projection dimensions

% the [wall idx]-th row of this matrix yields the projection indices (i.e. rows of pr):
wall_idx_2_pr = [1, 3; 1, 2; 2, 3];

dpos = doorpos(room);
dpos_cur = squeeze(dpos(door_idx, :, :));

rec_outside = any(room.recpos < 0) || any(room.recpos > room.boxsize);
effective_door_wall = room.door(door_idx).wall * sign(~rec_outside - 0.5);

% get current door normal:
door_normal = zeros(1, 3);
door_normal(abs(effective_door_wall)) = sign(effective_door_wall);

% grab rows of pr applicable for current door:
pr_rows = wall_idx_2_pr(abs(room.door(door_idx).wall), :);

% vectors from point to door vertices:
point = point(:);
vec_az = dpos_cur(pr(pr_rows(1), :), :) - repmat(point(pr(pr_rows(1), :)), 1, 2);
vec_el = dpos_cur(pr(pr_rows(2), :), :) - repmat(point(pr(pr_rows(2), :)), 1, 2);

angles = zeros(2, 2);

% azimuth (cross product is used to get signed angles):
for n = 1:2
    angles(1, n) = acosd(dot(vec_az(:, n), door_normal(pr(pr_rows(1), :)))/norm(vec_az(:, n))) * ...
        sign(sum(cross([door_normal(pr(pr_rows(1), :)), 0], [vec_az(:, n); 0])));
end

% elevation (here, z-component of vec is used for sign of angle):
for n = 1:2
    angles(2, n) = acosd(dot(vec_el(:, n), door_normal(pr(pr_rows(2), :)))/norm(vec_el(:, n))) * ...
        sign(vec_el(2, n));
end

ap = abs(angles(:, 2) - angles(:, 1))';


if do_plot
    scene(room);
    hold on;
    for k = 1:2
        plot3(...
            [point(1); squeeze(dpos_cur(1, k))], ...
            [point(2); squeeze(dpos_cur(2, k))], ...
            [point(3); squeeze(dpos_cur(3, k))], 'b');
    end
end
