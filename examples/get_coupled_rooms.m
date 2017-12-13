function [rooms, adj] = get_coupled_rooms
% GET_COUPLED_ROOMS - Definintion of an example coupled-rooms setting.
%
% Usage:
%   [rooms, adj] = GET_COUPLED_ROOMS
%
% Output:
%   rooms   Vector of room structures (see RAZR)
%   adj     Adjacency specification (see RAZR)
%
% See also: SCENE, GET_ROOM_L, GET_ROOM_A, GET_ROOM_RT


% ---------- Room 1 ---------- %
rooms(1).name = 'corridor';
rooms(1).boxsize = [2.65, 7.6, 2.49];

% door specification:
rooms(1).door.name = 'corr_d1';
rooms(1).door.wall = 2;             % i.e., at wall +y
rooms(1).door.pos  = [0.59, 0];     % [x, z] position of lower vertex
rooms(1).door.size = [1.0, 2.4];    % [width, height]

rooms(1).TCelsius   = 17;
rooms(1).recpos    = [0.9, 3.0, 1.51];
rooms(1).recdir    = [90 0];
rooms(1).srcpos    = [];
rooms(1).materials = [0.0872 0.0797 0.0880 0.0980 0.1057 0.1232];
rooms(1).freq      = [250 500 1e3 2e3 4e3 8e3];

% ---------- Room 2 ---------- %
rooms(2).name = 'staircase';
rooms(2).boxsize = [7.24, 3.51, 12.6];

rooms(2).door.name = 'stai_d1';
rooms(2).door.wall = -rooms(1).door.wall;  % Must be -rooms(1).door.wall for coupling
rooms(2).door.pos  = [6.24, 0];
rooms(2).door.size = [1, 2.4];  % Must equal rooms(1).door.size

rooms(2).TCelsius  = 17;
rooms(2).recpos    = [];
rooms(2).recdir    = [];
rooms(2).srcpos    = [3.29, 1.353, 1.29];
rooms(2).materials = [0.0312 0.0346 0.0387 0.0459 0.0630 0.0876];
rooms(2).freq      = [250 500 1e3 2e3 4e3 8e3];

% adjacency specification:
adj = {...
    rooms(1).name, rooms(1).door(1).name, ...  % {from_room, via_door, ...
    rooms(2).name, rooms(2).door(1).name};     % ... to_room, via_door}
