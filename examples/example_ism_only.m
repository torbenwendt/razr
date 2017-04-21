% Example script for RIR creation demonstrating how to use only RAZR's image source model.
%
% See also: example_*, RAZR

%% Please see EXAMPLE_DEFAULT and EXAMPLE_OPTIONS first for a demonstration of the basic concepts
%% of RAZR.
%%

clear;

% Get a room:
room = get_room_L;

% ISM order for ISM-only mode. See also GET_DEFAULT_OPTIONS for details.
% (See also option tlen_max there):
op.ism_only = 5;    

% Limit length of RIR (in sec.):
op.tlen = 0.3;

% We also might want to get the image sources as separate signals
% (mono, w/o spatialization):
op.return_ism_sigmat = true;

% Create BRIR:
ir = razr(room, op);

% Plot BRIR:
plot_ir(ir, 'r');

% Plot signals, separately for all image sources:
figure;
plot(timevec(ir), ir.early_refl_sigmat);
xlabel('Time (s)')
ylabel('Amplitude')
