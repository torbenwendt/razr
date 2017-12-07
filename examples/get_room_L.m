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

% The sound absorption at the walls are specified in the field "materials".
% From room.materials, a new field "abscoeff" will be calculated internally,
% which is a matrix containing frequency dependent absorption coefficients for
% all room surfaces.
% room.materials can be specified in several ways. In short, they can be:
%   - key strings for wall materials, as done here in this file,
%   - or actual absorption coefficients, as done in GET_ROOM_A.
% If you would like to specify a desired reverberation time instead of absorbing
% material, you can do this too. See GET_ROOM_RT for details.
% 
% The order of walls (directions of outside-pointing normal vectors) is:
% {-z, -y, -x, +x, +y, +z}:
room.materials = {...
    'hall.carpet_on_conc'; 'hall.gypsum'; 'hall.plywood'; ...     % -z, -y, -x
    'hall.windowglass'; 'hall.plaster_sprayed'; 'hall.concrete'}; % +x, +y, +z

% Frequency base (in Hz) for absorption coefficients
% (must be octave band center frequencies between 250 Hz and 8 kHz):
room.freq = [250 500 1e3 2e3 4e3];

% Position [x, y, z] of sound source in meters:
room.srcpos = [1.40, 3.02, 1.36];

% Position [x, y, z] of receiver in meters:
room.recpos = [2.77, 1.30, 1.51];

% Orientation [azimuth, elevation] of receiver in degrees
% (angle convention: )
room.recdir	= [90, 0];
