% EXAMPLE_COUPLED_ROOMS - Example script demonstrating how simulate BRIRs for
% two coupled rooms.
%
% See also: example_*, RAZR


%% Please note: Syntax is preliminary and will be changed in a later version!
%%

clear;

[rooms, adj] = get_coupled_rooms;

scene(rooms, adj, 'materials', 0, 'topview', 1);

op.return_rir_parts = 1;

% Synthesize BRIR. create_crir() is used instead of razr().
% However, razr() will be generalized in a later version to be used for coupled rooms
ir = create_crir(rooms, adj, op);

plot_ir(ir);

% auralize:
out = apply_rir(ir);

return

%% Listen to the auralization:
soundsc(out{1}, ir.fs);

%% Listen to the BRIR itself:
soundir(ir);
