% Example script for RIR creation
% Writes wav files into ./examples
% Needs no HRTF configuration

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.90
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2016, Torben Wendt, Steven van de Par, Stephan Ewert,
% Universitaet Oldenburg.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------



disp('Starting RAZR demo ...')

room = get_room_L;
scene(room, 'title', 'Sketch of the room');

disp('Synthesize RIR ...')
ir = razr(room, 'spat_mode', 'shm');
disp('Done.')

%%
disp('Analyze RIR ...')

% plot time signal:
plot_ir(ir);
title('RIR time signal');

% calc T30 from RIR and plot EDC:
[T30, freq] = schroeder_rt(ir, 'freq', room.freq, 'plot', true);
title('Energy decay curve, calculated from Schroeder integral');

% compare Eyring estimation with T30 calculated from synth. RIR:
TrEyr = estimate_rt(room, 'eyring');
figure;
synth = semilogx(freq, T30, 'o-', 'markerfacecolor', 'w', 'linewidth', 1.3);
hold on;
sabine = semilogx(room.freq, TrEyr, 'rs-', 'markerfacecolor', 'w', 'linewidth', 1.3);
xlabel('Frequency (Hz)');
ylabel('Reverberation time (s)');
title('Reverberation time T30');
legend([synth, sabine], {'Synthesized', 'Eyring estimation from room'});
set(gca, 'xtick', freq, 'xticklabel', freq2str(freq));
grid on;
ylim([floor(min([TrEyr(:); T30(:)])), ceil(max([TrEyr(:); T30(:)]))]);

disp('Done.')

%%
disp('Create test signal ...')
[out, in] = apply_rir(ir, 'src', 'olsa1', 'eq', 'none');

fname = 'demo.wav';
ffname = fullfile(get_razr_path, fname);

if exist('audiowrite', 'file') || exist('audiowrite', 'builtin')
    audiowrite(ffname, out{1}, ir.fs);
else
    wavwrite(out{1}, ir.fs, ffname);
end

fprintf('Done.\n\n');
fprintf('A sound example has been created: %s\n', fname);
fprintf('To play the sound example, type "play_demo"\n');
