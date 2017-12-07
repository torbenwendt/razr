% Example script for RIR creation demonstrating how to use custom options
% and to do some useful room manipulations.
%
% See also: example_*, RAZR, GET_DEFAULT_OPTIONS, MYOPTS


%% Please see EXAMPLE_DEFAULT first for a demonstration of the basic concepts of RAZR.
%%

clear;

% First, we need a room:
room = get_room_L;

% Here we change the receiver orientation such that it focusses the sound source (see function
% help entry for details; could also be done within get_room_L):
room.recdir = transform_orientation(room, [0 0], 'all');

% The manipulation above can be checked by sketching the room
% (see help scene for more plotting options):
scene(room, 'topview', true, 'materials', false);

% Now we come to the options: All default options are stored in GET_DEFAULT_OPTIONS. There are
% two ways to run razr using custom options, that overload the defaults:

%% 1) Pass options structure to razr:
% We can create a structure of allowed options and pass it to razr. The structure might look like
% this:
op.ism_order = 2;              % maximum image source order (default: 3)
op.pseudoRand = false;         % use non-pseudo-random numbers for simulation
op.return_rir_parts = true;    % return direct sound, early and late BRIR parts as fields of ir
op.verbosity = 1;              % display calculation duration in command window
op.rirname = room.name;        % give a name created BRIR

% Now we can call razr using op:
ir = razr(room, op);

return

%%
% Note: In some cases it might be convenient to define a set of custom options in a separate
% function, e.g. myopts and pass it to razr (see also MYOPTS):
ir = razr(room, myopts);

%% 2) Pass options directly to razr:
% The second way is to directly pass certain options to razr as Name-Value-pair arguments, which
% might look like this:
ir = razr(room, 'ism_order', 2, 'rirname', room.name);

%% Note:
% razr also allows a syntax like
ir = razr(room, op, 'ism_order', 2, 'rirname', room.name)

% In this case, the Name-Value-argument options overload those specified in op.
