function idx = wall2sub(walls)
% WALL2SUB - Transform wall IDs to subscriptable indices, i.e.:
% [-3, -2, -1, 1, 2, 3] --> [1, 2, 3, 4, 5, 6]
%
% Usage:
%   idx = WALL2SUB(walls)
%
% Example:
%   >> normdir = [-3, 1, 2];
%   >> idx = normdir2idx(normdir)
%   idx = 
%       1  4  5
%
% See also: SUB2WALL, WALL2FDN, FDN2WALL

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.93
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


if any(walls < -3) || any(walls > 3) || any(walls == 0)
    error('normdir must contain non-zero integer values between -3 and +3.')
end

idx_neg = walls < 0;
idx_pos = walls > 0;

idx = zeros(length(walls), 1);
idx(idx_neg) = walls(idx_neg) + 4;
idx(idx_pos) = walls(idx_pos) + 3;
