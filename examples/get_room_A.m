function room = get_room_A
% GET_ROOM_A - Definintion of an example room: Aula.
% The design is inspired by a measured BRIR of the Aula Carolina, Aachen, available in the AIR
% database [1].
%
% Usage:
%   room = GET_ROOM_A
%
% Output:
%   room    Room structure (see RAZR)
%
% Reference:
% [1] Jeub, M., Sch�er, M., Vary, P. (2009): "A Binaural Room Impulse Response Database for the
%     Evaluation of Dereverberation Algorithms", Technical report.
%
% See also: GET_ROOM_L, GET_ROOM_RT, SCENE


% For details on the fields see GET_ROOM_L or razr help.
room.name = 'Aula';
room.boxsize   = [12, 30, 10];

% Absorption coefficients for the walls [-z, -y, -x, +x, +y, +z] (direction of outside-pointing
% normal vectors), same for all frequencies. For more possibilities to specify absorption
% coefficients, see razr help.
room.materials = [0.05, 0.1, 0.13, 0.16, 0.22];

room.freq = [250, 500, 1e3, 2e3, 4e3];

room.srcpos = [6.3, 28, 1.2];
room.recpos = [6.7, 25.3, 1.2];
room.recdir	= [95, 0];
