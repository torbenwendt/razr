% CHECK_VALIDITY - Validity check for image sources
%
% Usage:
%   [idx_valid, ISpos_vis_check, recpos_vis_check] = CHECK_VALIDITY(...
%       isd, room, op, ism_setup)
%
% Input:
%   isd         Output of CREATE_IS_PATTERN
%   room        Room structure (see RAZR)
%   op          Options structure (see RAZR)
%   ism_setup   Output of GET_ISM_SETUP
%
% Output:
%   idx_auralize    Logical indices, indicating whether image sources are to be
%                   auralized

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
