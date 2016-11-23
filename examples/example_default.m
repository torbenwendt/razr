% EXAMPLE_DEFAULT - Example script for RIR creation using all default options.
% For all functions called in this script the simplest usages are demonstrated. Most of them accept
% multiple optional parameters. More advanced usages of them are explained in the respective help
% entries and they are demonstrated in EXAMPLE_ANALYSIS.
% Before you run this script, make sure that all subfolders of RAZR are added to your Matlab search
% path. You can do this, e.g., by calling "razr addpath" from RAZR's root directory.
%
% See also: example_*, RAZR

clear;

% In RAZR, rooms are defined as structures. They can be defined in functions like GET_ROOM_L or in
% any other way, e.g. in a .mat file. See also the section "Data structures" in README.txt. For
% required fields, see razr help.
room = get_room_L;

% RIR synthesis using the RAZR toplevel function. Here, no options are passed to razr. To see how
% options are used, see razr help or the script example_options.m.
ir = razr(room);

% The first output parameter of razr is the room impulse response (ir), stored as a structure. See
% also the section "Data structures" in README.txt. For details on returned fields, see razr help.

% The first way to analyze "ir" is to plot the time signal:
plot_ir(ir);

% More ir analysis functions can be found in the folder ANALYSIS_TOOLS. Some of them are
% demonstrated in the script example_analysis.m.

% Last but not least, we would like to auralize the room, i.e. convolve the ir with an
% unreverberated test signal. Here, a default test signal is used by APPLY_RIR. It is also returned
% as the second output parameter. Custom test signals can be specified in different ways. For
% details, see the help entry of APPLY_RIR or EXAMPLE_ANALYSIS.
[out, in] = apply_rir(ir);

return

%% You can listen to the result by the following command:
soundsc(out{1}, ir.fs);
