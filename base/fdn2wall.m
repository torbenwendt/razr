function walls = fdn2wall(numCh)
% FDN2WALL - For a given number of FDN channels, return a vector containing
% wall-IDs for each channel.
%
% Usage:
%   chmap = FDN2WALL(numCh)
%
% Input:
%   numCh   Number of FDN channels
%
% Output:
%   walls   Wall IDs for FDN channels.
%           Room dimensions are represented by numbers as follows:
%           [-z, .y, -x, +x, +y, +z] <=> [-3, -2, -1, +1, +2, +3]
%
% See also: WALL2FDN, WALL2SUB, SUB2WALL

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


switch numCh
    case 12
        walls = repmat([-3; -2; -1; 1; 2; 3], 2, 1);
    case 24
        walls = repmat([-3; -2; -1; 1; 2; 3], 4, 1);
    otherwise
        error('Not implemented.')
end
