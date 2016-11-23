function room = get_room_L
% GET_ROOM_L - Definintion of an example room: Laboratory.
%
% Usage:
%   room = GET_ROOM_L
%
% Output:
%   room    Room structure (see RAZR)
%
% See also: GET_ROOM_A, GET_ROOM_RT, SCENE


room.name = 'Laboratory';

% Room dimensions [x, y, z] in meters:
room.boxsize = [4.97, 4.12, 3];

% The sound absorption at the walls can be specified in three different ways:
% 1) Key strings for wall materials, as done below in this file.
% 2) Absorption coefficients. See GET_ROOM_A for details.
% 3) A desired reverberation time. See GET_ROOM_RT for details.
% For more details, see razr help.

% Wall materials. The order of walls (directions of outside-pointing normal vectors) is:
% {-z, -y, -x, +x, +y, +z}:
room.materials = {'carp_conc'; 'gypsum'; 'plywood'; 'windowglass'; 'plaster_sp'; 'concrete'};

% Frequency base (in Hz) for absorption frequencies
% (must be octave band center frequencies between 250 and 8k Hz):
room.freq = [250 500 1e3 2e3 4e3];

% Position [x, y, z] of sound source in meters:
room.srcpos = [1.40, 3.02, 1.36];

% Position [x, y, z] of receiver in meters:
room.recpos = [2.77, 1.30, 1.51];

% Orientation [azimuth, elevation] of receiver in degrees
% (angle convention: )
room.recdir	= [90, 0];
