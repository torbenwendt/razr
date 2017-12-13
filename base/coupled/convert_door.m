function [rooms, adj] = convert_door(rooms, adj)
% CONVERT_DOOR - Convert doors and adjacencies to new format

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

% set all door names for all rooms:
for n = 1:numRooms
    for d = 1:size(rooms(n).door, 1)
        rooms(n).doornames{d} = sprintf('%s_door_%d', rooms(n).name, d);
    end
end

for n = 1:numRooms
    d_orig = rooms(n).door;
    
    for d = size(d_orig, 1):-1:1
        door(d).wall = d_orig(d, 1);
        door(d).pos  = d_orig(d, 2:3);
        door(d).size = d_orig(d, 4:5);
        door(d).name = rooms(n).doornames{d};
    end
    
    rooms(n).door = door;
    clear door;
end

for n = 1:size(adj, 1)
    idx_door_from = adj{n, 2};
    rname_from    = adj{n, 1};
    room_from     = get_by_name(rooms, rname_from);
    dname_from    = room_from.door(idx_door_from).name;
    adj{n, 2}     = dname_from;
    
    idx_door_to = adj{n, 4};
    rname_to    = adj{n, 3};
    room_to     = get_by_name(rooms, rname_to);
    dname_to    = room_to.door(idx_door_to).name;
    adj{n, 4}   = dname_to;
end

rooms = rmfield(rooms, 'doornames');
