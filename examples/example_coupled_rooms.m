% EXAMPLE_COUPLED_ROOMS - Example script demonstrating how simulate BRIRs for
% two coupled rooms.
%
% See also: example_*, RAZR


clear;

% Get a vector of rooms and an adjacency specification. See the comments in
% get_coupled_rooms for details:
[rooms, adj] = get_coupled_rooms;

% Plot a sketch of the rooms:
scene(rooms, adj, 'materials', 0, 'topview', 0);

% Synthesize BRIR. See razr help for syntax variants:
ir = razr(rooms, adj);

plot_ir(ir);

% auralize:
out = apply_rir(ir);

return

%% Listen to the auralization:
soundsc(out{1}, ir.fs);

%% Listen to the BRIR itself:
soundir(ir);
