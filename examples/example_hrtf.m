% Example script for RIR creation demonstrating how to use HRTFs.
%
% See also: example_*, RAZR

%% Please see EXAMPLE_DEFAULT and EXAMPLE_OPTIONS first for a demonstration of the basic concepts
%% of RAZR.
%%

% Note: This script can only run, if a HRTF database is linked to RAZR.
% See the section "Using HRTFs" in README.txt for details.

clear;

% Get a room:
room = get_room_L;

% Specify, that we want to use HRTFs for spatialization:
op.spat_mode = 'hrtf';

% In case we have linked the cipic database, we would write:
op.hrtf_database = 'cipic';

% BRIR synthesis:
ir = razr(room, op);

% Convolve BRIR with a test signal:
[out, in] = apply_rir(ir, 'src', 'olsa2');

return

%% You can listen to the result by the following command:
soundsc(out{1}, ir.fs);
