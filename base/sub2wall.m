function walls = sub2wall(idx)
% SUB2WALL - Get wall IDs for given subscript indices.
%
% Usage:
%   walls = SUB2WALL(idx)
%
% Input:
%   idx     Subscript indices used for walls
%
% Output:
%   walls   Matrix of wall IDs, using the representation
%           [-z, .y, -x, +x, +y, +z] <=> [-3, -2, -1, +1, +2, +3]
%
% See also: WALL2SUB, FDN2WALL, WALL2FDN

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


walls_all = [-3, -2, -1, 1, 2, 3];
idx_all = wall2sub(walls_all);

for n = length(idx):-1:1
    walls(n, 1) = walls_all(idx_all == idx(n));
end
