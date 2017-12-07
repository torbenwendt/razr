function ch = wall2fdn(walls, numCh)
% WALL2FDN - Get FDN channel indices for given wall IDs.
% Note: This function assumes that there are the same number of FDN channels
% per wall.
%
% Usage:
%   ch = WALL2FDN(walls, numCh)
%
% Input:
%   walls   Vector of wall IDs, using the representation
%           [-z, .y, -x, +x, +y, +z] <=> [-3, -2, -1, +1, +2, +3]
%   numCh   Total number of FDN channels
%
% Output:
%   ch      Matrix containing FDN all channel indices per wall

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


walls_all = fdn2wall(numCh);

for n = length(walls):-1:1
    ch(n, :) = find(walls_all == walls(n));
end
