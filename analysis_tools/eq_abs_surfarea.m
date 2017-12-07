function [Aeq, S, room] = eq_abs_surfarea(room, door_idx)
% EQ_ABS_SURFAREA - Equivalent absorption surface area and wall surface area of a room.
%
% Usage:
%   [Aeq, S, room] = eq_abs_surfarea(room, [door_idx])
%
% Input:
%   room        Room strcuture (see RAZR)
%   door_idx    If one ore more doors exist, these are indices of those doors to be taken into
%               account for wall surface calculation (i.e. door surfaces will be subtracted).
%               Optional parameter; default: empty matrix
%
% Output:
%   Aeq         Equivalent absorption surface area (only if field 'room.materials' exists, otherwise
%               empty array)
%   S           Wall surface area
%   room        Room structure with field 'abscoeff' (if not existed before)

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


if nargin < 2
    door_idx = [];
end

if isfield(room, 'materials')
    room = add_abscoeff(room);
end

k = [1 2; 3 1; 2 3; 3 2; 1 3; 2 1];  % (materials specified as [-z -y -x x y z])
surfs = prod(room.boxsize(k), 2);

% subtract door surfaces from wall surfaces:
if isfield(room, 'door') && ~isempty(room.door) && ~isempty(door_idx)
    idx = normdir2idx(room.door(door_idx, 1));
    doorsurfs = prod(room.door(door_idx, [4, 5]), 2);
    surfs(idx) = surfs(idx) - doorsurfs;
end

S = sum(surfs);

if isfield(room, 'abscoeff')
    Aeq = surfs'*room.abscoeff;
else
    Aeq = [];
end
