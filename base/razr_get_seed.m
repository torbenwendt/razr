function seed = razr_get_seed(seed, op)
% RAZR_GET_SEED - Get seed for init_rng, based on current RAZR options.
% If not pseudo-random numbers shall be used, a random seed based on CLOCK will
% be returned. Otherwise, the input seed, plus the seed_offset, specified in the
% options, will be returned.
%
% Usage:
%   RAZR_GET_SEED(seed, op)
%
% Input:
%   seed    Initial seed
%   op      Options structure (see RAZR)
%
% See also: INIT_RNG, GET_RNG_STATE

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.91
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
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


if op.pseudoRand
    seed = seed + op.seed_shift;
else
    seed = 100*sum(clock);
end
