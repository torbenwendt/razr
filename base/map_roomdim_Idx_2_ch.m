function ch_idx = map_roomdim_Idx_2_ch(M)
% MAP_ROOMDIM_IDX_2_CH - Maps the indices [-3, -2, -1, +1, +2, +3] to FDN channel indices
%
% Usage:
%   idx_ch = MAP_ROOMDIM_IDX_2_CH(M)
%
% Input:
%   M       Total number of FDN channels
%
% Output:
%   idx_ch  FDN channel indices
%
% See also: CH2ROOMDIM, NORMDIR2IDX

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


switch M
    case 12
        ch_idx = repmat(1:6, 1, 2);
    case 24
        ch_idx = repmat(1:6, 1, 4);
    otherwise
        error('Not implemented.')
end

