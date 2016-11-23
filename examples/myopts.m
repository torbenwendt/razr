function op = myopts
% MYOPTS - Example for defining a set of options in a function.
% Functions like this allow the convenient syntax "ir = razr(room, myopts)".
%
% Usage:
%   op = MYOPTS


op.ism_order = 2;           % maximum image source order (default: 3)
op.pseudoRand = false;      % use non-pseudo-random numbers for simulation
op.return_rir_parts = true; % return direct sound, early and late BRIR parts as fields of ir
op.verbosity = 1;           % display calculation duration in command window
op.return_op = 1;           % Return applied options structure as additional field of ir
