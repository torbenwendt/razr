function [intsecpoints, isonrectsurf] = get_intsecpoints(rect_vertices, srcpos, recpos)
% get_intsecpoints - Calculates the intersection points of the connection lines between some source
% points and one receiver point with the surface of a rectangle. The surface must be orientated in
% such a way that its normal is parallel to one base vector of the standard Euklidean coordinate
% system.
%
% Usage:
%   [intsecpoints, isonrectsurf] = get_penpoints(rect_vertices, srcpos, recpos)
%
% Input:
%   rect_vertices   Matrix containing two opposite vertices of recangular surface (rows: vertices,
%                   columns: dimensions). Due to the claimed orientation of the surface, two
%                   opposite vertices are unique to describe the rectangle. 
%   srcpos          Positions of sources (rows = sources, columns = dimensions).
%   recpos          Position of receiver point(s). May be one or the same number as sources.
%
% Output:
%   intsecpoints    Intersection points. If the connection line between a source and receiver is
%                   parallel to the rectanle surface, vector components are returned as Inf or NaN
%                   and a warning is thrown.
%   isonrectsurf    Boolesh; true, if intersection point lies on the rectangle surface

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


% Calculation:
% An intersection point is defined by the following linear equation system (leq):
% a + lambda*u = b + mu*v + rho*w,
% where
% a:        position vector of source
% u:        direction vector source->receiver
% b:        position vector of vertex point of door
% v,w:      direction vectors defining door plane
% lambda,
% mu, rho:  paramters to be calculated
%
% If e.g. room.door.wall == -2, the leq writes:
% a1 + lambda*u1 = b1 + mu
% a2 + lambda*u2 = b2
% a3 + lambda*u3 = b3 + rho
%

numSrc = size(srcpos, 1);

if size(recpos, 1) == 1
    recpos = repmat(recpos, numSrc, 1);
elseif size(recpos, 1) ~= numSrc
    error('Number of receiver points must be 1 or match the number of sources.')
end

rect_normal_dim = find(rect_vertices(1, :) == rect_vertices(2, :));

if length(rect_normal_dim) > 1
    error('Rectangle must be parallel to two of the standard Euklidean axes.');
end

idx_all = 1:3;
idx_rest = idx_all(idx_all ~= rect_normal_dim);

% direction vectors: sources -> receiver:
u = recpos - srcpos;

% result from leq (2nd equation):
b_i = repmat(rect_vertices(1, rect_normal_dim), numSrc, 1);
lambda = (b_i - srcpos(:, rect_normal_dim)) ./ u(:, rect_normal_dim);

%if any(isinf(lambda))
%    warning('Some connection lines between source and receiver are parallel to rectangle surface');
%end

% plugging in the result into the parameter representation
% of the straight line from src to rec:
intsecpoints = srcpos + repmat(lambda, 1, 3).*u;

isonrectsurf = ...
    intsecpoints(:, idx_rest(1)) >= min(rect_vertices(:, idx_rest(1))) & ...
    intsecpoints(:, idx_rest(1)) <= max(rect_vertices(:, idx_rest(1))) & ...
    intsecpoints(:, idx_rest(2)) >= min(rect_vertices(:, idx_rest(2))) & ...
    intsecpoints(:, idx_rest(2)) <= max(rect_vertices(:, idx_rest(2)));

isonrectsurf = isonrectsurf & lambda <= 1 & lambda >= 0;
