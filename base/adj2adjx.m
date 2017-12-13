function adjx = adj2adjx(rooms, adj)
% ADJ2ADJX - Transform "easy-to-read" adjacency specification to a more efficient
% idx-based specification.
% This function is for internal call only.
%
% Usage:
%   adjx = ADJ2IDX(rooms, adj)
%
% Input:
%   rooms   Room vector
%   adj     Cell array containing adjacency specification for the rooms. Syntax:
%           adj = {...
%               'roomA', 'door_A1', 'roomB', 'door_B1'; ...
%               'roomA', 'door_A2', 'roomC', 'door_C1'}
%           representing a connection from room 'roomA' via door 'door_A1' to
%           room 'roomB' via door 'door_B1' and a connection from room 'roomA'
%           via door 'door_A2' to room 'roomC' via door 'door_C1'.
%
% Output:
%   adjx    Struct containing index-based adjacency specification. Contains
%           indices of rooms and doors.

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
    error('Not enough input arguments');
end

adj = complement_door_states(adj);
numAdj = size(adj, 1);
adjx.rooms = zeros(numAdj, 2);

if numAdj > 0
    for a = 1:numAdj
        [r, fr_room_idx] = get_by_name(rooms, adj{a, 1});
        [r, to_room_idx] = get_by_name(rooms, adj{a, 3});
        adjx.rooms(a, 1) = fr_room_idx;
        adjx.rooms(a, 2) = to_room_idx;
        
        fr_door_idx = find(strcmp({rooms(fr_room_idx).door.name}, adj{a, 2}));
        to_door_idx = find(strcmp({rooms(to_room_idx).door.name}, adj{a, 4}));
        
        if isempty(fr_door_idx)
            error('Room "%s" has no door named "%s". Check adjacency specification.', ...
                rooms(fr_room_idx).name, adj{a, 2});
        end
        if isempty(to_door_idx)
            error('Room "%s" has no door named "%s". Check adjacency specification.', ...
                rooms(to_room_idx).name, adj{a, 4});
        end
        
        adjx.doors(a, 1) = fr_door_idx;
        adjx.doors(a, 2) = to_door_idx;
    end
    
    adjx.states = cell2mat(adj(:, 5));    
else
    adjx.rooms = [];
    adjx.doors = [];
    adjx.states = [];
    return;
end

% check, if every room is really connected to any other one:
if ~all(ismember(1:length(rooms), unique(adjx.rooms)))
    error('At least one room is not connected to another one.');
end

% check door states:
if any(adjx.states < 0) || any(adjx.states > 1)
    error('door states must be between 0 and 1.');
end
