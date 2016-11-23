function chmap = ch2roomdim(M)
% CH2ROOMDIM - Mapping of FDN channel numbers to room dimension
%
% Usage:
%   chmap = CH2ROOMDIM(M)
%
% Input:
%   M       Total number of FDN channels
%
% Output:
%   chmap   Vector of length M containing room dimension for FDN channels (= indices of chmap).
%           Room dimensions are represented by numbers as follows:
%           [-z, .y, -x, +x, +y, +z] <=> [-3, -2, -1, +1, +2, +3]

%------------------------------------------------------------------------------
% RAZR engine for Mathwork's MATLAB
%
% Version 0.90
%
% Author(s): Torben Wendt
%
% Copyright (c) 2014-2016, Torben Wendt, Steven van de Par, Stephan Ewert,
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


switch M
    case 12
        chmap = repmat([-3, -2, -1, 1, 2, 3], 1, 2);
    case 24
        chmap = repmat([-3, -2, -1, 1, 2, 3], 1, 4);
    otherwise
        error('Not implemented.')
end
