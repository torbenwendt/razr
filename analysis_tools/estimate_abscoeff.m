function absmean = estimate_abscoeff(room, Tr, estimator)
% ESTIMATE_ABSCOEFF - Average wall absorption coefficient from inverse form of Sabine's and Eyring's
% formulae.
%
% Usage:
%   absmean = ESTIMATE_ABSCOEFF(room, Tr, estimator)
%
% Input:
%   room        room structure (see RAZR)
%   Tr          Reverberation time in seconds
%   estimator   Underlying T60 estimator ('eyring' or 'sabine')
%
% Output:
%   absmean     Average wall absorption coefficient according to Tr values (row vector)

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.92
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2017, Torben Wendt, Steven van de Par, Stephan Ewert,
% University Oldenburg, Germany.
%
% This work is licensed under the
% Creative Commons Attribution-NonCommercial-NoDerivs 4.0 International
% License (CC BY-NC-ND 4.0).
% To view a copy of this license, visit
% http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California,
% 94041, USA.
%------------------------------------------------------------------------------


[Aeq, S] = eq_abs_surfarea(room);

const = 24*log(10)/speedOfSound(room);

switch estimator
    case 'sabine'
        absmean = const*prod(room.boxsize)./(S*Tr(:)');
    case 'eyring'
        absmean = 1 - exp(const*prod(room.boxsize)./(-S*Tr(:)'));
    otherwise
        error('Unknown estimator: %s', estimator);
end
