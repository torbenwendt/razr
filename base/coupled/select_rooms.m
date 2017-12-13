function [room_rec, room_ngb, adj, rec_src_same_room] = ...
    select_rooms(rooms, adj, op)
% SELECT_ROOMS - Extract those two rooms from a vector of rooms, that build a
% pair containing the source and receiver. If source and receiver are inside the
% same room, that adjacent room with highest T60 will be chosen as the second
% room.
%
% Usage:
%   [room_rec, room_ngb, adjacencies, rec_src_same_room] = SELECT_ROOMS(...
%       (rooms, adjacencies, op)
%
% Input:
%   rooms               Vector of room structures
%   adjacencies         Adjacency relations between the rooms (see CREATE_CRIR)
%   op                  Options structure (see RAZR)
%
% Output:
%   room_rec            Room that contains receiver
%   room_ngb            Chosen neighbor room (criterion: see above)
%   adjacencies         Remaining adjacency relation
%   rec_src_same_room   Boolean; true, if receiver and source are inside the
%                       same room
%
% See also: CREATE_CRIR

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


numRooms = length(rooms);
numAdj = size(adj, 1);
idx_rec = [];
idx_src = [];

for n = 1:numRooms
    if isfield(rooms(n), 'recpos') && ~isempty(rooms(n).recpos)
        idx_rec = [idx_rec, n];
    end
    if isfield(rooms(n), 'srcpos') && ~isempty(rooms(n).srcpos)
        idx_src = [idx_src, n];
    end
end

if length(idx_rec) ~= 1
    error('One receiver required.');
end

if length(idx_src) ~= 1
    error('One source required.');
end

room_rec = rooms(idx_rec);
rec_src_same_room = idx_rec == idx_src;

% if rec and src are within the same room, chose that adjacent room with highest T60:
if rec_src_same_room
    idx_adj_rooms = zeros(numAdj, 1);
    
    for n = 1:numAdj
        [ismem, col] = ismember({rooms(idx_rec).name}, adj(n, [1, 3]));
        if ismem
            switch col
                % cases 1 and 2 because it was searched in adjacencies(n, [1, 3]):
                case 1
                    idx_adj_room = 3;
                case 2
                    idx_adj_room = 1;
                otherwise
                    error('Room not found on expected position in adjacencies.');
            end
            % get idx of current adjacent room:
            [ans0, idx_adj_rooms(n)] = ismember(adj(n, idx_adj_room), {rooms.name});
        end
    end
    
    idx_adj_rooms(idx_adj_rooms == 0) = [];
    numAdjRooms = length(idx_adj_rooms);
    
    T60 = zeros(numAdjRooms, 1);
    for n = 1:numAdjRooms
        T60(n) = max(estimate_rt(rooms(idx_adj_rooms(n)), op.rt_estim));
    end
    [T60max, idx_maxT60] = max(T60);
    idx_ngb = idx_adj_rooms(idx_maxT60);
else
    idx_ngb = idx_src;
end

room_ngb = rooms(idx_ngb);

% --- keep only the relevant adjacency --- %
idx_keep = false(numAdj, 1);

for n = 1:numAdj
    idx_keep(n) = all(ismember({rooms([idx_rec, idx_ngb]).name}, adj(n, [1, 3])));
end

adj = adj(idx_keep, :);

if size(adj, 1) > 1
    error('Not yet implemented for the case of more than one connecting door.');
end

% keep only the door of current interest:
door_name_keep_rec = adj{find(strcmp(adj, room_rec.name)) + 1};
door_name_keep_ngb = adj{find(strcmp(adj, room_ngb.name)) + 1};
room_rec.door = get_by_name(room_rec.door, door_name_keep_rec);
room_ngb.door = get_by_name(room_ngb.door, door_name_keep_ngb);
