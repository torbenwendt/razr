function init_rng(seed)
% INIT_RNG - Initialize random number generator independently from the current Matlab version.
%
% Usage:
%   INIT_RNG([seed])
%   INIT_RNG([state])
%
% Input:
%   seed        Seed for the random number generator (Mersenne Twister algorithm)
%               (Optional, default: 5489, equivalently to the Matlab default for any version)
%   state       Output of get_rng_state()
%
% For Matlab version 7.12 or higher, calling this function is equivalent to rng(seed),
% for older versions, it is equivalent to rand('twister', seed).
% The command init_rng(sum(100*clock)) can be used to get non-pseudo-random numbers.
%
% See also: GET_RNG_STATE

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


if nargin == 0
    seed = 5489;	% Matlab default
end

% seed random generator (both methods should produce the same random numbers):
if exist('rng', 'file') || exist('rng', 'builtin')
    rng('default');             % prevents error when old method has been used before
    rng(seed);
else
    if size(seed, 1) > 1        % i.e. input is probably state and no seed
        rand('state', seed);
    else
        rand('twister', seed);
    end
end
