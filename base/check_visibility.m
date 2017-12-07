% CHECK_VISIBILITY - Visibility check for image sources
% If both src and rec are in the same room and there are doors, check for which
% image source the sound ray intersects a door surface.
%
% Usage:
%   idx_visib = CHECK_VISIBILITY(isd, room, ism_setup)
%
% Input:
%   isd         Output of CREATE_IS_PATTERN
%   room        Room structure (see RAZR)
%   ism_setup   Output of GET_ISM_SETUP
%
% Output:
%   idx_visib   Logical indices, indicating whether image sources are visible

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
