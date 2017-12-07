function origins = get_room_origins(rooms, adj)
% GET_ROOM_ORIGINS - For n rooms, get their origin in space such that they are concatenated with
% respect to their specified adjacency relations, i.e. such that the positions of their doors
% pairwisely match within the overall cartesian coordinate system. The origin of the first room is
% set to [0, 0, 0].
%
% Usage:
%   origins = GET_ROOM_ORIGINS(rooms, adj);
% 
% Input:
%   rooms               Vector of room structures
%   adj                 Adjacency specifications of the rooms; output of adj2idx()
%
% Output:
%   origins             Matrix containing origin vectors in the form
%                       [x_room1, y_room1, z_room1; x_room2, y_room2, z_room2; ...]

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


numRooms = length(rooms);

% remove those adjacencies, for which no room exists:
rows_keep = find(all(adj.rooms <= numRooms, 2));
adj.rooms = adj.rooms(rows_keep, :);
adj.doors = adj.doors(rows_keep, :);
adj.states = adj.states(rows_keep, :);

if isempty(adj) || any(structfun(@isempty, adj))
    if numRooms == 1
        origins = [0 0 0];
        return;
    else
        error('No adjacencies specified.');
    end
end

numAdj   = size(adj.rooms, 1);
displacm = zeros(numAdj, 3);

% First, get relative displacements of each room pair (i.e. for each row of adj).
% Here, the first room of each pair is assumed to be placed in [0, 0, 0]:
for a = 1:numAdj
    idx_r1 = adj.rooms(a, 1);       % room 1 of current connection
    idx_r2 = adj.rooms(a, 2);       % room 2 of current connection
    idx_d1 = adj.doors(a, 1);       % door-idx in room 1
    idx_d2 = adj.doors(a, 2);       % door-idx in room 2
    
    % Check if directions and sizes of connecting doors match:
    if rooms(idx_r1).door(idx_d1, 1) ~= -rooms(idx_r2).door(idx_d2, 1)
        error('Rooms %d and %d must be connected via doors with room(%d).door(1) == -room(%d).door(1).', ...
            idx_r1, idx_r2, idx_r1, idx_r2);
    end
    if any( rooms(idx_r1).door(idx_d1, [4, 5]) ~= rooms(idx_r2).door(idx_d2, [4, 5]) )
        error('Doors of rooms %d and %d must have same dimensions.', idx_r1, idx_r2);
    end
    
    [idx_wall, idx_rest] = idx_door_wall(rooms(idx_r2));
    
    if sign(rooms(idx_r1).door(idx_d1, 1)) > 0
        displacm(a, idx_wall) = rooms(idx_r1).boxsize(idx_wall);
    else
        displacm(a, idx_wall) = -rooms(idx_r2).boxsize(idx_wall);
    end
    
    displacm(a, idx_rest(idx_d2, :)) = -rooms(idx_r2).door(idx_d2, [2 3]) + rooms(idx_r1).door(idx_d1, [2 3]);
end
% Now, for each row of adj, a displacm vector exists.
% From them, absolute room positions are computed. Approach: Loop over room indexes and find their
% positions in adj.rooms.

% We start with the first room (positioned at [0 0 0]) and compute all rooms adjacent to room 1:
origins         = zeros(numRooms, 3);
origins_done    = false(numRooms, 1);
origins_done(1) = true;

while ~all(origins_done)
    % current "base room":
    for r = 1:numRooms
        if origins_done(r)
            [rows, cols] = find(adj.rooms == r);
            cols = abs(cols - 3);   % (1,2) --> (2,1), since we search the remaining room IDs
            
            % rooms connected to "base room":
            for r1 = 1:length(rows)
                cur_room_idx = adj.rooms(rows(r1), cols(r1));
                if ~origins_done(cur_room_idx)
                    if cols(r1) == 1
                        sgn = -1;
                    else
                        sgn = 1;
                    end
                    origins(cur_room_idx, :) = origins(r, :) + sgn*displacm(rows(r1), :);
                    origins_done(cur_room_idx) = true;
                end
            end
        end
        if all(origins_done)
            break;
        end
    end
end

% Check if there are contradicting relative positions
% (might be the case, if two doors exist at the same wall in one room):
% check, whether all connecting doors have the same corner positions in the overall coo system:
for a = 1:numAdj
    idx_r1 = adj.rooms(a, 1);       % room 1 of current connection
    idx_r2 = adj.rooms(a, 2);       % room 2 of current connection
    idx_d1 = adj.doors(a, 1);       % door-idx in room 1
    idx_d2 = adj.doors(a, 2);       % door-idx in room 2
    
    pos1 = doorpos(rooms(idx_r1));
    pos1 = squeeze(pos1(idx_d1, :, :)) + repmat(origins(idx_r1, :)', 1, 2);
    pos2 = doorpos(rooms(idx_r2));
    pos2 = squeeze(pos2(idx_d2, :, :)) + repmat(origins(idx_r2, :)', 1, 2);
    
    if ~all(all(round(pos1*1e4) == round(pos2*1e4)))    % round to ignore computational inaccuracy
        error('There are contradicting door positions connecting the rooms.');
    end
end
