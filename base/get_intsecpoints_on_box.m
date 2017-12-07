function [intsecpoints, wall_idx] = get_intsecpoints_on_box(boxsize, srcpos, recpos)
% get_intsecpoints_on_box - Calculate intersection points of the connections between some sources
% and one receiver on the surface of a cuboid, where the receiver is placed inside the cuboid.
%
% Usage:
%   [intsecpoints, wall_idx] = get_intsecpoints_on_box(boxsize, srcpos, recpos)
%
% Input:
%   boxsize         Dimensions [x, y, z] of the cuboid
%   srcpos          Matrix containing source positions [x, y, z] (one row per source)
%   recpos          Receiver position [x, y, z]
%
% Output:
%   intsecpoints    Intersection points. If the receiver is not placed inside the cuboid, this
%                   function at least accounts for the case that the connection line does not
%                   intersect any surface of the cuboid at all. Theses respective rows of the
%                   intsecpoints matrix is then set to -1.
%   wall_idx        Direction of wall normal vector of that wall being intersected:
%                   [-3, -2, -1, 1, 2, 3] <=> [-z, -y, -x, x, y, z].
%                   If no instersection found, a wall_idx of 0 is returned.

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


numSrc = size(srcpos, 1);

src_outside_pos = srcpos > repmat(boxsize, numSrc, 1);
src_outside_neg = srcpos < 0;
src_outside = [fliplr(src_outside_neg), src_outside_pos];

vertices = get_room_vertices(boxsize);
numWalls = size(vertices, 1);

% ---- using cell: -------
%intsecpoints = cell(numSrc, 1);
% ---- using matrix: -----
% (matrix solution is much faster. And it is sufficient since only one intsecpoint per src exists,
% because rec is assumed to be inside the box)
intsecpoints = zeros(numSrc, 3);
% ------------------------

for n = 1:numWalls
    % find all sources with rec-connections intersecting the current wall:
    idx_src = src_outside(:, n);
    
    % calc intersection points:
    [points_tmp, isonwallsurf] = get_intsecpoints(...
        squeeze(vertices(n, :, :)), srcpos(idx_src, :), recpos);
    
    % keep points with intersection point on wall surface:
    % ---- using cells: -------
    %points_tmp = num2cell(points_tmp, 2);
    %points_tmp(~isonwallsurf) = {[]};
    % ---- using matrices: ----
    points_tmp(~isonwallsurf, :) = 0;
    % -------------------------
    
    % add these points to collection of intsecpoints:
    % ---- using cell: ------
    %intsecpoints(idx_src) = cellfun(...
    %    @vertcat, intsecpoints(idx_src), points_tmp, 'UniformOutput', false);
    % ---- using matrix: ----
    % assumption to allow addition: only one intsectpoint per source:
    intsecpoints(idx_src, :) = intsecpoints(idx_src, :) + points_tmp;
    % -----------------------
end

% Ok, here we can at least account for the case, that both src and rec are outside and the
% connecting line doesn't hit the box at all. It that case, intsecpoints are all zero. (For the
% other case - the connection line intersects tow or more box surfaces - this function still returns
% only one of them):
idx_no_intsec = all(~intsecpoints, 2);
intsecpoints(idx_no_intsec, :) = -1;

wall_idx = zeros(1, numSrc);
[r, c] = find(round(intsecpoints*1e3) == 0);    % round((.)*1e3) accounts for comp. inaccuracies
wall_idx(r) = -c;
[r, c] = find(round(intsecpoints*1e3) == repmat(round(boxsize*1e3), numSrc, 1));
wall_idx(r) = c;

% ---- using cell: ----
%intsecpoints = cell2mat(intsecpoints);
