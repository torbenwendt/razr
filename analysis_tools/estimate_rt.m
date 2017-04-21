function [rt, surfarea] = estimate_rt(room, measure)
% ESTIMATE_RT - Reverberation time estimation after Eyring or Sabine.
%
% Usage:
%   [rt, surfarea] = ESTIMATE_RT(room, [measure])
%
% Input:
%   room        room strcuture (see RAZR)
%   measure     'eyring'/'e' or 'sabine'/'s' for specifying the estimation measure
%               (optional, default: 'eyring')
%
% Output:
%   rt          Reverberation time in seconds for those frequency bands for which room.abscoeff is
%               specified
%   surfarea    Total wall surface area

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


if nargin < 2
    measure = 'eyring';
end

[Aeq, surfarea, room] = eq_abs_surfarea(room);

const = 24*log(10)/speedOfSound(room);

switch measure
    case {'e', 'eyring'}
        rt = const*prod(room.boxsize)./(-surfarea.*log(1 - mean(room.abscoeff, 1)));
    case {'s', 'sabine'}
        rt = const*prod(room.boxsize)./Aeq;
end
