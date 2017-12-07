function [B, A, arr, diffpoints] = get_diffr_filtcoeff(...
    room, door_idx, srcpos, recpos, fs, do_distce_atten, methd, do_plot)
% GET_DIFFR_FILTCOEFF - Get filter coefficients for diffraction filtering in the ISM.
%
% Usage:
%   [B, A, arr] = get_diffr_filtcoeff(...
%       room, door_idx, srcpos, recpos, fs, do_distce_atten, methd, do_plot)
%
% Input:
%   room        Room structure
%   door_idx    Index of door to be used for diffraction
%   srcpos      Positions of source(s) (rows = sources, columns = dimensions)
%   recpos      Positions of receiver(s).
%               The number of srcpos and recpos (i.e. their number of rows) must match or equal to 1
%   do_distce_atten  If true, apply distance attenuation
%   methd       Key string for filter creation method. Available are:
%               'comsh': Comb and lowpass shelving filter (see GET_DIFFR_FILTCOEFF_COMBSHELVING)
%               'grimm': Simple lowpass after Grimm and Luberadzka (see GET_DIFFR_FILTCOEFF_GRIMM)
%   do_plot     If true, plot SCENE, image sources and diffraction points (optional, default: false)
%
% Output:
%   B, A        Filter coefficients for all filter components
%   arr         Angles and distances of source(s) and receiver(s) relative to diffraction point and
%               normal vector on door
%   diffpoints  Diffraction points

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


% Torben Wendt
% Date: 2016-02-15

if nargin < 8
    do_plot = 0;
end

[diffpoints, arr] = get_diffraction_points(room, door_idx, srcpos, recpos, do_plot);

switch methd
    case 'comsh'
        [B, A] = get_diffr_filtcoeff_combshelving(...
            room.door(door_idx, 4), room.door(door_idx, 5), ...
            arr, fs, speedOfSound(room), do_distce_atten);
    case 'grimm'
        [B, A] = get_diffr_filtcoeff_grimm(...
            room.door(door_idx, 4), room.door(door_idx, 5), ...
            arr, fs, speedOfSound(room), do_distce_atten);
    otherwise
        error('Diffraction filter creation method not available: %s', methd);
end
