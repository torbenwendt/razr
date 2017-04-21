function idx = normdir2idx(normdir)
% NORMDIR2IDX - Transform normal-vector directions to subscriptable indices, i.e.:
% [-3, -2, -1, 1, 2, 3] --> [1, 2, 3, 4, 5, 6]
%
% Usage:
%   idx = NORMDIR2IDX(normdir)
%
% Example:
%   >> normdir = [-3, 1, 2];
%   >> idx = normdir2idx(normdir)
%   idx = 
%       1  4  5
%
% See also: CH2ROOMDIM, MAP_ROOMDIM_IDX_2_CH

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


if any(normdir < -3) || any(normdir > 3)
    error('normdir must contain integer values between -3 and +3.')
end

idx_neg = normdir < 0;
idx_pos = normdir > 0;

idx = zeros(length(normdir), 1);
idx(idx_neg) = normdir(idx_neg) + 4;
idx(idx_pos) = normdir(idx_pos) + 3;
