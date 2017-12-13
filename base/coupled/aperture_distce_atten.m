% compress_hrtf_angles - To simulate the reverb of a neighbour room, this function transforms the
% HRTF angles (obtained, e.g., by get_hrtf_angles) to angles according to incidence directions only
% from the door surface.
%
% Usage:
%   shifted_angles = compress_hrtf_angles(relcoo, room, door_idx, [do_plot])
%
% Input:
%   relcoo              Positions of initial reverb sources, relative to receiver (cart. coo.)
%   room                Room structure of receiver room
%   door_idx            Index of door in receiver room to whose surface the sound incidence
%                       directions shall be mapped
%   do_plot             If true, illustrate the initial and changed sound incidence directions
%                       (optional, default: false)
%
% Output:
%   compressed_angles   The new angles of sound incidences
%   atten               Attenuation factor for each angle depending on its angular distance from
%                       aperture

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
