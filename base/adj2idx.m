function adj = adj2idx(roomIDs, adjacencies)
% ADJ2IDX - Transform "easy-to-read" adjacency specification to a more efficient idx-based
% specification.
%
% Usage:
%   adj = ADJ2IDX(roomIDs, adjacencies)
%
% Input:
%   roomIDs         Cell array containing room IDs in the form required by get_rooms(). Example:
%                   roomIDs = {'roomA', 'roomB', 'roomC'}
%   adjacencies     Cell array containing adjacency specifications of the rooms. Syntax example:
%                   adjacencies = {...
%                       'roomA', door_idx1_roomA, 'roomB', door_idx1_roomB, 1.0; ...
%                       'roomA', door_idx2_roomA, 'roomC', door_idx1_roomC, 0.5}
%                   The 1st row means that roomA and roomB are connected via the 1st specified
%                   door of roomA and the 1st specified door of roomB. This door is open ("1.0")
%                   The 2nd row means that roomA and roomC are connected via the 2nd specified
%                   door of roomA and the 1st specified door of roomC. The door is half open ("0.5")
%
% Output:
%   adj             Struct containing adjacency specifications of the rooms.
%                   The example input from above will be converted to:
%                   adj.rooms = [1, 2; 1, 2]
%                   adj.doors = [1, 1; 2, 1]

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.91
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
% Universitaet Oldenburg.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------


adjacencies = complement_door_states(adjacencies);
numAdj = size(adjacencies, 1);
adj.rooms = zeros(numAdj, 2);

for a = 1:numAdj
    adj.rooms(a, 1) = find(strcmp(roomIDs, adjacencies{a, 1}));     % from room
    adj.rooms(a, 2) = find(strcmp(roomIDs, adjacencies{a, 3}));     % to room
end

if numAdj > 0
    adj.doors = cell2mat(adjacencies(:, [2, 4]));
    adj.states = cell2mat(adjacencies(:, 5));
else
    adj.rooms = [];
    adj.doors = [];
    adj.states = [];
    return;
end

% check, if every room is really connected to any other one:
if ~all(ismember(1:length(roomIDs), unique(adj.rooms)))
    error('At least one room is not connected to another one.');
end

% check door states:
if any(adj.states < 0) || any(adj.states > 1)
    error('door states must be between 0 and 1.');
end
