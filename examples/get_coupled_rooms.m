function [rooms, adj] = get_coupled_rooms
% GET_COUPLED_ROOMS - Definintion of an example coupled-rooms setting.
%
% Usage:
%   [rooms, adj] = GET_COUPLED_ROOMS
%
% Output:
%   rooms   Vector of room structures (see RAZR)
%   adj     Adjacency specification
%
% See also: GET_ROOM_L, GET_ROOM_A, GET_ROOM_RT, SCENE


%% Please note: Syntax is preliminary and will be changed in a later version!
%%

rooms(1).boxsize = [2.6500 7.6000 2.4900];

% door specification:
%              [wall_ID, pos1,  pos2, width, height]
rooms(1).door = [2,       0.59,  0,    1.0,   2.4];
rooms(1).name = 'corridor';
rooms(1).TCelsius = 17;
rooms(1).recpos = [0.9000 1.4100 1.5100];
rooms(1).recdir = [90 0];
rooms(1).srcpos = [];
rooms(1).materials = [0.0872 0.0797 0.0880 0.0980 0.1057 0.1232];
rooms(1).freq = [250 500 1000 2000 4000 8000];

rooms(2).boxsize = [7.2400 3.5100 12.6000];
rooms(2).door = [-2 6.2400 0 1 2.4000];
rooms(2).name = 'staircase';
rooms(2).TCelsius = 17;
rooms(2).recpos = [];
rooms(2).recdir = [];
rooms(2).srcpos = [3.2900 1.3525 1.2900];
rooms(2).materials = [0.0312 0.0346 0.0387 0.0459 0.0630 0.0876];
rooms(2).freq = [250 500 1000 2000 4000 8000];

% adjacency specification:
% adj = {from_room,     door_idx, to_room,       door_idx, door_state}
adj   = {rooms(1).name, 1,        rooms(2).name, 1,        1};
