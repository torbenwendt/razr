% EXAMPLE_MULTIPLE_SRC - Example script for RIR creation for multiple sound sources.
%
% See also: example_*, RAZR


%% Please see EXAMPLE_DEFAULT and EXAMPLE_OPTIONS first for a demonstration of the basic concepts
%% of RAZR.
%%

clear;

% Get a room:
room = get_room_L;

% Add new source positions:
room.srcpos = repmat(room.srcpos, 3, 1);
room.srcpos(:, 1) = room.srcpos(:, 1) + (0:2)';

% Note: The number of srcpos, recpos and recdir must either
% (1) match, or
% (2) only one of them must be larger than 1.

% Create a sketch of the room:
scene(room, 'materials', false);

% Create BRIRs:
ir = razr(room, 'verbosity', 1);

% Plot BRIRs:
plot_ir(ir);
