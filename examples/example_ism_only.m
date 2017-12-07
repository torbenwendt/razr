% Example script for RIR creation demonstrating how to use only RAZR's image source model.
%
% See also: example_*, RAZR


%% Please see EXAMPLE_DEFAULT and EXAMPLE_OPTIONS first for a demonstration of the basic concepts
%% of RAZR.
%%

clear;

% Get a room:
room = get_room_L;

% ISM order for ISM-only mode. See also GET_DEFAULT_OPTIONS for details:
op.ism_only = 5;    

% We also might want to get the image sources as separate signals
% (mono, w/o spatialization):
op.return_ism_sigmat = true;

% To get some ISM metadata:
op.return_ism_data = true;

% Create BRIR:
[ir, ism_setup, fdn_setup, ism_data] = razr(room, op);

plot_ir(ir, 'r');

% Plot signals, separately for all image sources:
figure;
plot(timevec(ir), ir.early_refl_sigmat);
xlabel('Time (s)')
ylabel('Amplitude')
title('All image sources separately (not spatialized)')

%% ism_data can be passed to scene() in order to plot image source positions:
plot_ispos = 1;             % plot img src positions
plot_ispos_jit = 0;         % plot jittered img src positions
ism_order = 1:op.ism_only;  % plotted img src orders
discd_dir = [];        % discard img src in +/-z direction to plot only the 2D plane

scene(room, 'materials', 0, 'topview', 0, 'ism_data', ism_data, ...
    'plot_ispos', plot_ispos, 'plot_ispos_jit', plot_ispos_jit, ...
    'ism_order', ism_order, 'ism_discd_dir', discd_dir);
