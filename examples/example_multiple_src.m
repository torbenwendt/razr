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
room.srcpos = [...
    1.40, 3.02, 1.36; ...
    2.40, 3.02, 1.36; ...
    3.40, 3.02, 1.36];

% Create a sketch of the room:
scene(room, 'materials', false);

% Create BRIRs:
ir = razr(room, 'verbosity', 1);

% Plot BRIRs:
plot_ir(ir);
